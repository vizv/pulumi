package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"

	pbempty "github.com/golang/protobuf/ptypes/empty"
	"github.com/pkg/errors"
	"github.com/pulumi/pulumi/sdk/v3/go/common/resource/plugin"
	"github.com/pulumi/pulumi/sdk/v3/go/common/util/cmdutil"
	"github.com/pulumi/pulumi/sdk/v3/go/common/util/contract"
	"github.com/pulumi/pulumi/sdk/v3/go/common/util/logging"
	"github.com/pulumi/pulumi/sdk/v3/go/common/util/rpcutil"
	"github.com/pulumi/pulumi/sdk/v3/go/common/version"
	pulumirpc "github.com/pulumi/pulumi/sdk/v3/proto/go"
	"github.com/pulumi/pulumi/sdk/v3/ruby/ruby"
	"google.golang.org/grpc"
)

const (
	// By convention, the executor is the name of the current program (pulumi-language-ruby) plus this suffix.
	rubyDefaultExec = "pulumi-language-ruby-exec" // the exec shim for Pulumi to run Ruby programs.

	// The runtime expects the config object to be saved to this environment variable.
	pulumiConfigVar = "PULUMI_CONFIG"

	// The runtime expects the array of secret config keys to be saved to this environment variable.
	//nolint: gosec
	pulumiConfigSecretKeysVar = "PULUMI_CONFIG_SECRET_KEYS"
)

// Launches the language host RPC endpoint, which in turn fires up an RPC server implementing the
// LanguageRuntimeServer RPC endpoint.
func main() {
	var tracing string
	var root string
	flag.StringVar(&tracing, "tracing", "", "Emit tracing to a Zipkin-compatible tracing endpoint")
	flag.StringVar(&root, "root", "", "Project root path to use")

	cwd, err := os.Getwd()
	if err != nil {
		cmdutil.Exit(errors.Wrapf(err, "getting the working directory"))
	}

	// You can use the below flag to request that the language host load a specific executor instead of probing the
	// PATH.  This can be used during testing to override the default location.
	var givenExecutor string
	flag.StringVar(&givenExecutor, "use-executor", "",
		"Use the given program as the executor instead of looking for one on PATH")

	flag.Parse()
	args := flag.Args()
	logging.InitLogging(false, 0, false)
	cmdutil.InitTracing("pulumi-language-ruby", "pulumi-language-ruby", tracing)

	var rubyExec string
	if givenExecutor == "" {
		// By default, the -exec script is installed next to the language host.
		thisPath, err := os.Executable()
		if err != nil {
			err = errors.Wrap(err, "could not determine current executable")
			cmdutil.Exit(err)
		}

		pathExec := filepath.Join(filepath.Dir(thisPath), rubyDefaultExec)
		if _, err = os.Stat(pathExec); os.IsNotExist(err) {
			err = errors.Errorf("missing executor %s", pathExec)
			cmdutil.Exit(err)
		}

		logging.V(3).Infof("language host identified executor from path: `%s`", pathExec)
		rubyExec = pathExec
	} else {
		logging.V(3).Infof("language host asked to use specific executor: `%s`", givenExecutor)
		rubyExec = givenExecutor
	}

	// Optionally pluck out the engine so we can do logging, etc.
	var engineAddress string
	if len(args) > 0 {
		engineAddress = args[0]
	}

	// Fire up a gRPC server, letting the kernel choose a free port.
	port, done, err := rpcutil.Serve(0, nil, []func(*grpc.Server) error{
		func(srv *grpc.Server) error {
			host := newLanguageHost(rubyExec, engineAddress, tracing, cwd)
			pulumirpc.RegisterLanguageRuntimeServer(srv, host)
			return nil
		},
	}, nil)
	if err != nil {
		cmdutil.Exit(errors.Wrapf(err, "could not start language host RPC server"))
	}

	// Otherwise, print out the port so that the spawner knows how to reach us.
	fmt.Printf("%d\n", port)

	// And finally wait for the server to stop serving.
	if err := <-done; err != nil {
		cmdutil.Exit(errors.Wrapf(err, "language host RPC stopped serving"))
	}
}

// rubyLanguageHost implements the LanguageRuntimeServer interface
// for use as an API endpoint.
type rubyLanguageHost struct {
	exec          string
	engineAddress string
	tracing       string

	// current working directory
	cwd string
}

func newLanguageHost(exec, engineAddress, tracing, cwd string) pulumirpc.LanguageRuntimeServer {
	return &rubyLanguageHost{
		cwd:           cwd,
		exec:          exec,
		engineAddress: engineAddress,
		tracing:       tracing,
	}
}

// GetRequiredPlugins computes the complete set of anticipated plugins required by a program.
func (host *rubyLanguageHost) GetRequiredPlugins(ctx context.Context,
	req *pulumirpc.GetRequiredPluginsRequest) (*pulumirpc.GetRequiredPluginsResponse, error) {

	// Now, determine which Pulumi packages are installed.
	pulumiPackages, err := determinePulumiPackages(host.cwd)
	if err != nil {
		return nil, err
	}

	plugins := []*pulumirpc.PluginDependency{}
	for _, pkg := range pulumiPackages {

		plugin, err := determinePluginDependency(host.cwd, pkg.Name, pkg.Version)
		if err != nil {
			return nil, err
		}

		if plugin != nil {
			plugins = append(plugins, plugin)
		}
	}

	return &pulumirpc.GetRequiredPluginsResponse{Plugins: plugins}, nil
}

// These packages are known not to have any plugins.
// TODO[pulumi/pulumi#5863]: Remove this once the `pulumi-policy` package includes a `pulumiplugin.json`
// file that indicates the package does not have an associated plugin, and enough time has passed.
var packagesWithoutPlugins = map[string]struct{}{
	"pulumi-policy": {},
}

type rubyPackage struct {
	Name    string `json:"name"`
	Version string `json:"version"`
}

func determinePulumiPackages(cwd string) ([]rubyPackage, error) {
	logging.V(5).Infof("GetRequiredPlugins: Determining pulumi packages")

	// Run the bundler in-line script.
	args := []string{"-e", "require 'bundler'; require 'json'; puts Bundler.load.specs.each_with_object({}) { |s, h| h[s.name] = { name: s.name, version: s.version.to_s + s.git_version.to_s } }.sort.map(&:last).to_json"}
	output, err := runRubyCommand(cwd, args...)
	if err != nil {
		return nil, err
	}

	// Parse the JSON output.
	var packages []rubyPackage
	if err := json.Unmarshal(output, &packages); err != nil {
		return nil, errors.Wrapf(err, "parsing `ruby %s` output", strings.Join(args, " "))
	}

	// Only return Pulumi packages.
	var pulumiPackages []rubyPackage
	for _, pkg := range packages {
		// We're only interested in packages that start with "pulumi-".
		if !strings.HasPrefix(pkg.Name, "pulumi-") {
			continue
		}

		// Skip packages that are known not have an associated plugin.
		if _, ok := packagesWithoutPlugins[pkg.Name]; ok {
			continue
		}

		pulumiPackages = append(pulumiPackages, pkg)
	}

	logging.V(5).Infof("GetRequiredPlugins: Pulumi packages: %#v", pulumiPackages)

	return pulumiPackages, nil
}

// determinePluginDependency attempts to determine a plugin associated with a package. It checks to see if the package
// contains a pulumiplugin.json file and uses the information in that file to determine the plugin. If `resource` in
// pulumiplugin.json is set to false, nil is returned. If the name or version aren't specified in the file, these values
// are derived from the package name and version. If the plugin version cannot be determined from the package version,
// nil is returned.
func determinePluginDependency(cwd, packageName, packageVersion string) (*pulumirpc.PluginDependency, error) {

	logging.V(5).Infof("GetRequiredPlugins: Determining plugin dependency: %v, %v", packageName, packageVersion)

	// Determine the location of the installed package.
	packageLocation, err := determinePackageLocation(cwd, packageName)
	if err != nil {
		return nil, err
	}

	// The name of the module inside the package can be different from the package name.
	// However, our convention is to always use the same name, e.g. a package name of
	// "pulumi-aws" will have a module named "pulumi_aws", so we can determine the module
	// by replacing hyphens with underscores.
	packageModuleName := strings.ReplaceAll(packageName, "-", "_")

	pulumiPluginFilePath := filepath.Join(packageLocation, packageModuleName, "pulumiplugin.json")
	logging.V(5).Infof("GetRequiredPlugins: pulumiplugin.json file path: %s", pulumiPluginFilePath)

	var name, version, server string
	plugin, err := plugin.LoadPulumiPluginJSON(pulumiPluginFilePath)
	if err == nil {
		// If `resource` is set to false, the Pulumi package has indicated that there is no associated plugin.
		// Ignore it.
		if !plugin.Resource {
			logging.V(5).Infof("GetRequiredPlugins: Ignoring package %s with resource set to false", packageName)
			return nil, nil
		}

		name, version, server = plugin.Name, plugin.Version, plugin.Server
	} else if !os.IsNotExist(err) {
		// If the file doesn't exist, the name and version of the plugin will attempt to be determined from the
		// packageName and packageVersion. If it's some other error, report it.
		logging.V(5).Infof("GetRequiredPlugins: err: %v", err)
		return nil, err
	}

	if name == "" {
		name = strings.TrimPrefix(packageName, "pulumi-")
	}

	if version == "" {
		version = packageVersion
	}
	if !strings.HasPrefix(version, "v") {
		// Add "v" prefix if not already present.
		version = fmt.Sprintf("v%s", version)
	}

	result := pulumirpc.PluginDependency{
		Name:    name,
		Version: version,
		Kind:    "resource",
		Server:  server,
	}

	logging.V(5).Infof("GetRequiredPlugins: Determining plugin dependency: %#v", result)
	return &result, nil
}

// determinePackageLocation determines the location on disk of the package by running `python -m pip show <package>`
// and parsing the output.
func determinePackageLocation(cwd, packageName string) (string, error) {
	b, err := runRubyCommand(cwd, "-e", "require 'bundler'; puts Bundler.load.specs[ARGV.first].first&.full_gem_path", packageName)
	if err != nil {
		return "", err
	}
	return string(b), nil
}

func runRubyCommand(cwd string, arg ...string) ([]byte, error) {
	var err error
	var cmd *exec.Cmd

	cmd, err = ruby.Command(arg...)
	if err != nil {
		return nil, err
	}

	if logging.V(5) {
		commandStr := strings.Join(arg, " ")
		logging.V(5).Infof("Language host launching process: %s %s", cmd.Path, commandStr)
	}

	cmd.Dir = cwd
	output, err := cmd.Output()
	if err != nil {
		return nil, err
	}

	if logging.V(9) {
		logging.V(9).Infof("Process output: %s", string(output))
	}

	return output, err
}

// RPC endpoint for LanguageRuntimeServer::Run
func (host *rubyLanguageHost) Run(ctx context.Context, req *pulumirpc.RunRequest) (*pulumirpc.RunResponse, error) {
	args := []string{host.exec}
	args = append(args, host.constructArguments(req)...)

	config, err := host.constructConfig(req)
	if err != nil {
		err = errors.Wrap(err, "failed to serialize configuration")
		return nil, err
	}
	configSecretKeys, err := host.constructConfigSecretKeys(req)
	if err != nil {
		err = errors.Wrap(err, "failed to serialize configuration secret keys")
		return nil, err
	}

	if logging.V(5) {
		commandStr := strings.Join(args, " ")
		logging.V(5).Infoln("Language host launching process: ", host.exec, commandStr)
	}

	// Now simply spawn a process to execute the requested program, wiring up stdout/stderr directly.
	var errResult string
	var cmd *exec.Cmd
	cmd, err = ruby.Command(args...)
	if err != nil {
		return nil, err
	}

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if config != "" || configSecretKeys != "" {
		env := os.Environ()
		if config != "" {
			env = append(env, pulumiConfigVar+"="+config)
		}
		if configSecretKeys != "" {
			env = append(env, pulumiConfigSecretKeysVar+"="+configSecretKeys)
		}
		cmd.Env = env
	}
	if err := cmd.Run(); err != nil {
		// Python does not explicitly flush standard out or standard error when exiting abnormally. For this reason, we
		// need to explicitly flush our output streams so that, when we exit, the engine picks up the child Python
		// process's stdout and stderr writes.
		//
		// This is especially crucial for Python because it is possible for the child Python process to crash very fast
		// if Pulumi is misconfigured, so we must be sure to present a high-quality error message to the user.
		contract.IgnoreError(os.Stdout.Sync())
		contract.IgnoreError(os.Stderr.Sync())
		if exiterr, ok := err.(*exec.ExitError); ok {
			// If the program ran, but exited with a non-zero error code.  This will happen often, since user
			// errors will trigger this.  So, the error message should look as nice as possible.
			if status, stok := exiterr.Sys().(syscall.WaitStatus); stok {
				err = errors.Errorf("Program exited with non-zero exit code: %d", status.ExitStatus())
			} else {
				err = errors.Wrapf(exiterr, "Program exited unexpectedly")
			}
		} else {
			// Otherwise, we didn't even get to run the program.  This ought to never happen unless there's
			// a bug or system condition that prevented us from running the language exec.  Issue a scarier error.
			err = errors.Wrapf(err, "Problem executing program (could not run language executor)")
		}

		errResult = err.Error()
	}

	return &pulumirpc.RunResponse{Error: errResult}, nil
}

// constructArguments constructs a command-line for `pulumi-language-python`
// by enumerating all of the optional and non-optional arguments present
// in a RunRequest.
func (host *rubyLanguageHost) constructArguments(req *pulumirpc.RunRequest) []string {
	var args []string
	maybeAppendArg := func(k, v string) {
		if v != "" {
			args = append(args, "--"+k, v)
		}
	}

	maybeAppendArg("monitor", req.GetMonitorAddress())
	maybeAppendArg("engine", host.engineAddress)
	maybeAppendArg("project", req.GetProject())
	maybeAppendArg("stack", req.GetStack())
	maybeAppendArg("pwd", req.GetPwd())
	maybeAppendArg("dry_run", fmt.Sprintf("%v", req.GetDryRun()))
	maybeAppendArg("parallel", fmt.Sprint(req.GetParallel()))
	maybeAppendArg("tracing", host.tracing)

	// If no program is specified, just default to the current directory (which will invoke "__main__.py").
	if req.GetProgram() == "" {
		args = append(args, ".")
	} else {
		args = append(args, req.GetProgram())
	}

	args = append(args, req.GetArgs()...)
	return args
}

// constructConfig json-serializes the configuration data given as part of a RunRequest.
func (host *rubyLanguageHost) constructConfig(req *pulumirpc.RunRequest) (string, error) {
	configMap := req.GetConfig()
	if configMap == nil {
		return "", nil
	}

	configJSON, err := json.Marshal(configMap)
	if err != nil {
		return "", err
	}

	return string(configJSON), nil
}

// constructConfigSecretKeys JSON-serializes the list of keys that contain secret values given as part of
// a RunRequest.
func (host *rubyLanguageHost) constructConfigSecretKeys(req *pulumirpc.RunRequest) (string, error) {
	configSecretKeys := req.GetConfigSecretKeys()
	if configSecretKeys == nil {
		return "[]", nil
	}

	configSecretKeysJSON, err := json.Marshal(configSecretKeys)
	if err != nil {
		return "", err
	}

	return string(configSecretKeysJSON), nil
}

func (host *rubyLanguageHost) GetPluginInfo(ctx context.Context, req *pbempty.Empty) (*pulumirpc.PluginInfo, error) {
	return &pulumirpc.PluginInfo{
		Version: version.Version,
	}, nil
}
