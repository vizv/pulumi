# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: language.proto for package 'pulumirpc'
# Original file comments:
# Copyright 2016-2018, Pulumi Corporation.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'grpc'
require 'language_pb'

module Pulumirpc
  module LanguageRuntime
    # LanguageRuntime is the interface that the planning monitor uses to drive execution of an interpreter responsible
    # for confguring and creating resource objects.
    class Service

      include ::GRPC::GenericService

      self.marshal_class_method = :encode
      self.unmarshal_class_method = :decode
      self.service_name = 'pulumirpc.LanguageRuntime'

      # GetRequiredPlugins computes the complete set of anticipated plugins required by a program.
      rpc :GetRequiredPlugins, ::Pulumirpc::GetRequiredPluginsRequest, ::Pulumirpc::GetRequiredPluginsResponse
      # Run executes a program and returns its result.
      rpc :Run, ::Pulumirpc::RunRequest, ::Pulumirpc::RunResponse
      # GetPluginInfo returns generic information about this plugin, like its version.
      rpc :GetPluginInfo, ::Google::Protobuf::Empty, ::Pulumirpc::PluginInfo
    end

    Stub = Service.rpc_stub_class
  end
end
