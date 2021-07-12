// Copyright 2016-2021, Pulumi Corporation

using System;
using System.Threading.Tasks;
using Google.Protobuf.WellKnownTypes;
using Pulumi.Serialization;
using Pulumirpc;

namespace Pulumi
{
    public sealed partial class Deployment
    {
        public void Call(string token, CallArgs args, CallOptions? options)
            => Call<object>(token, args, options, convertResult: false);

        public Output<T> Call<T>(string token, CallArgs args, CallOptions? options)
            => Call<T>(token, args, options, convertResult: true);

        private Output<T> Call<T>(string token, CallArgs args, CallOptions? options, bool convertResult)
        {
            // var result = await InvokeRawAsync(token, args, options);

            // if (!convertResult)
            // {
            //     return default!;
            // }

            // var data = Converter.ConvertValue<T>($"{token} result", new Value { StructValue = result });
            // return data.Value;
            throw new NotImplementedException("TODO");
        }

        private async Task<Struct> InvokeRawAsync(string token, InvokeArgs args, InvokeOptions? options)
        {
            var label = $"Invoking function: token={token} asynchronously";
            Log.Debug(label);

            // Be resilient to misbehaving callers.
            // ReSharper disable once ConstantNullCoalescingCondition
            args ??= InvokeArgs.Empty;

            // Wait for all values to be available, and then perform the RPC.
            var argsDict = await args.ToDictionaryAsync().ConfigureAwait(false);
            var serialized = await SerializeAllPropertiesAsync(
    				$"invoke:{token}",
    				argsDict, await this.MonitorSupportsResourceReferences().ConfigureAwait(false)).ConfigureAwait(false);
            Log.Debug($"Invoke RPC prepared: token={token}" +
                (_excessiveDebugOutput ? $", obj={serialized}" : ""));

            var provider = await ProviderResource.RegisterAsync(GetProvider(token, options)).ConfigureAwait(false);

            var result = await this.Monitor.InvokeAsync(new InvokeRequest
            {
                Tok = token,
                Provider = provider ?? "",
                Version = options?.Version ?? "",
                Args = serialized,
                AcceptResources = !_disableResourceReferences,
            });

            if (result.Failures.Count > 0)
            {
                var reasons = "";
                foreach (var reason in result.Failures)
                {
                    if (reasons != "")
                    {
                        reasons += "; ";
                    }

                    reasons += $"{reason.Reason} ({reason.Property})";
                }

                throw new InvokeException($"Invoke of '{token}' failed: {reasons}");
            }

            return result.Return;
        }

        private static ProviderResource? GetProvider(string token, InvokeOptions? options)
                => options?.Provider ?? options?.Parent?.GetProvider(token);

        private class InvokeException : Exception
        {
            public InvokeException(string error)
                : base(error)
            {
            }
        }
    }
}
