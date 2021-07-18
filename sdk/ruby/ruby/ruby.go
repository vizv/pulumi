package ruby

import (
	"os"
	"os/exec"

	"github.com/pkg/errors"
)

// Command returns an *exec.Cmd for running `ruby`. If the `PULUMI_RUBY_CMD` variable is set
// it will be looked for on `PATH`, otherwise, `ruby` will be looked for.
func Command(arg ...string) (*exec.Cmd, error) {
	var err error
	var rubyCmd, rubyPath string

	if rubyCmdFromEnv := os.Getenv("PULUMI_RUBY_CMD"); rubyCmdFromEnv != "" {
		rubyCmd = rubyCmdFromEnv
	} else {
		rubyCmd = "ruby"
	}

	rubyPath, err = exec.LookPath(rubyCmd)
	if err != nil {
		return nil, errors.Errorf(
			"Failed to locate any of %q on your PATH.  Have you installed Python 3.6 or greater?",
			rubyCmd)
	}

	return exec.Command(rubyPath, arg...), nil
}
