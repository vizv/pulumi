# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: provider.proto

require 'google/protobuf'

require 'plugin_pb'
require 'google/protobuf/empty_pb'
require 'google/protobuf/struct_pb'
Google::Protobuf::DescriptorPool.generated_pool.build do
  add_file("provider.proto", :syntax => :proto3) do
    add_message "pulumirpc.GetSchemaRequest" do
      optional :version, :int32, 1
    end
    add_message "pulumirpc.GetSchemaResponse" do
      optional :schema, :string, 1
    end
    add_message "pulumirpc.ConfigureRequest" do
      map :variables, :string, :string, 1
      optional :args, :message, 2, "google.protobuf.Struct"
      optional :acceptSecrets, :bool, 3
      optional :acceptResources, :bool, 4
    end
    add_message "pulumirpc.ConfigureResponse" do
      optional :acceptSecrets, :bool, 1
      optional :supportsPreview, :bool, 2
      optional :acceptResources, :bool, 3
    end
    add_message "pulumirpc.ConfigureErrorMissingKeys" do
      repeated :missingKeys, :message, 1, "pulumirpc.ConfigureErrorMissingKeys.MissingKey"
    end
    add_message "pulumirpc.ConfigureErrorMissingKeys.MissingKey" do
      optional :name, :string, 1
      optional :description, :string, 2
    end
    add_message "pulumirpc.InvokeRequest" do
      optional :tok, :string, 1
      optional :args, :message, 2, "google.protobuf.Struct"
      optional :provider, :string, 3
      optional :version, :string, 4
      optional :acceptResources, :bool, 5
    end
    add_message "pulumirpc.InvokeResponse" do
      optional :return, :message, 1, "google.protobuf.Struct"
      repeated :failures, :message, 2, "pulumirpc.CheckFailure"
    end
    add_message "pulumirpc.CallRequest" do
      optional :tok, :string, 1
      optional :args, :message, 2, "google.protobuf.Struct"
      map :argDependencies, :string, :message, 3, "pulumirpc.CallRequest.ArgumentDependencies"
      optional :provider, :string, 4
      optional :version, :string, 5
      optional :project, :string, 6
      optional :stack, :string, 7
      map :config, :string, :string, 8
      repeated :configSecretKeys, :string, 9
      optional :dryRun, :bool, 10
      optional :parallel, :int32, 11
      optional :monitorEndpoint, :string, 12
    end
    add_message "pulumirpc.CallRequest.ArgumentDependencies" do
      repeated :urns, :string, 1
    end
    add_message "pulumirpc.CallResponse" do
      optional :return, :message, 1, "google.protobuf.Struct"
      map :returnDependencies, :string, :message, 2, "pulumirpc.CallResponse.ReturnDependencies"
      repeated :failures, :message, 3, "pulumirpc.CheckFailure"
    end
    add_message "pulumirpc.CallResponse.ReturnDependencies" do
      repeated :urns, :string, 1
    end
    add_message "pulumirpc.CheckRequest" do
      optional :urn, :string, 1
      optional :olds, :message, 2, "google.protobuf.Struct"
      optional :news, :message, 3, "google.protobuf.Struct"
    end
    add_message "pulumirpc.CheckResponse" do
      optional :inputs, :message, 1, "google.protobuf.Struct"
      repeated :failures, :message, 2, "pulumirpc.CheckFailure"
    end
    add_message "pulumirpc.CheckFailure" do
      optional :property, :string, 1
      optional :reason, :string, 2
    end
    add_message "pulumirpc.DiffRequest" do
      optional :id, :string, 1
      optional :urn, :string, 2
      optional :olds, :message, 3, "google.protobuf.Struct"
      optional :news, :message, 4, "google.protobuf.Struct"
      repeated :ignoreChanges, :string, 5
    end
    add_message "pulumirpc.PropertyDiff" do
      optional :kind, :enum, 1, "pulumirpc.PropertyDiff.Kind"
      optional :inputDiff, :bool, 2
    end
    add_enum "pulumirpc.PropertyDiff.Kind" do
      value :ADD, 0
      value :ADD_REPLACE, 1
      value :DELETE, 2
      value :DELETE_REPLACE, 3
      value :UPDATE, 4
      value :UPDATE_REPLACE, 5
    end
    add_message "pulumirpc.DiffResponse" do
      repeated :replaces, :string, 1
      repeated :stables, :string, 2
      optional :deleteBeforeReplace, :bool, 3
      optional :changes, :enum, 4, "pulumirpc.DiffResponse.DiffChanges"
      repeated :diffs, :string, 5
      map :detailedDiff, :string, :message, 6, "pulumirpc.PropertyDiff"
      optional :hasDetailedDiff, :bool, 7
    end
    add_enum "pulumirpc.DiffResponse.DiffChanges" do
      value :DIFF_UNKNOWN, 0
      value :DIFF_NONE, 1
      value :DIFF_SOME, 2
    end
    add_message "pulumirpc.CreateRequest" do
      optional :urn, :string, 1
      optional :properties, :message, 2, "google.protobuf.Struct"
      optional :timeout, :double, 3
      optional :preview, :bool, 4
    end
    add_message "pulumirpc.CreateResponse" do
      optional :id, :string, 1
      optional :properties, :message, 2, "google.protobuf.Struct"
    end
    add_message "pulumirpc.ReadRequest" do
      optional :id, :string, 1
      optional :urn, :string, 2
      optional :properties, :message, 3, "google.protobuf.Struct"
      optional :inputs, :message, 4, "google.protobuf.Struct"
    end
    add_message "pulumirpc.ReadResponse" do
      optional :id, :string, 1
      optional :properties, :message, 2, "google.protobuf.Struct"
      optional :inputs, :message, 3, "google.protobuf.Struct"
    end
    add_message "pulumirpc.UpdateRequest" do
      optional :id, :string, 1
      optional :urn, :string, 2
      optional :olds, :message, 3, "google.protobuf.Struct"
      optional :news, :message, 4, "google.protobuf.Struct"
      optional :timeout, :double, 5
      repeated :ignoreChanges, :string, 6
      optional :preview, :bool, 7
    end
    add_message "pulumirpc.UpdateResponse" do
      optional :properties, :message, 1, "google.protobuf.Struct"
    end
    add_message "pulumirpc.DeleteRequest" do
      optional :id, :string, 1
      optional :urn, :string, 2
      optional :properties, :message, 3, "google.protobuf.Struct"
      optional :timeout, :double, 4
    end
    add_message "pulumirpc.ConstructRequest" do
      optional :project, :string, 1
      optional :stack, :string, 2
      map :config, :string, :string, 3
      optional :dryRun, :bool, 4
      optional :parallel, :int32, 5
      optional :monitorEndpoint, :string, 6
      optional :type, :string, 7
      optional :name, :string, 8
      optional :parent, :string, 9
      optional :inputs, :message, 10, "google.protobuf.Struct"
      map :inputDependencies, :string, :message, 11, "pulumirpc.ConstructRequest.PropertyDependencies"
      optional :protect, :bool, 12
      map :providers, :string, :string, 13
      repeated :aliases, :string, 14
      repeated :dependencies, :string, 15
      repeated :configSecretKeys, :string, 16
    end
    add_message "pulumirpc.ConstructRequest.PropertyDependencies" do
      repeated :urns, :string, 1
    end
    add_message "pulumirpc.ConstructResponse" do
      optional :urn, :string, 1
      optional :state, :message, 2, "google.protobuf.Struct"
      map :stateDependencies, :string, :message, 3, "pulumirpc.ConstructResponse.PropertyDependencies"
    end
    add_message "pulumirpc.ConstructResponse.PropertyDependencies" do
      repeated :urns, :string, 1
    end
    add_message "pulumirpc.ErrorResourceInitFailed" do
      optional :id, :string, 1
      optional :properties, :message, 2, "google.protobuf.Struct"
      repeated :reasons, :string, 3
      optional :inputs, :message, 4, "google.protobuf.Struct"
    end
  end
end

module Pulumirpc
  GetSchemaRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.GetSchemaRequest").msgclass
  GetSchemaResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.GetSchemaResponse").msgclass
  ConfigureRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.ConfigureRequest").msgclass
  ConfigureResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.ConfigureResponse").msgclass
  ConfigureErrorMissingKeys = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.ConfigureErrorMissingKeys").msgclass
  ConfigureErrorMissingKeys::MissingKey = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.ConfigureErrorMissingKeys.MissingKey").msgclass
  InvokeRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.InvokeRequest").msgclass
  InvokeResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.InvokeResponse").msgclass
  CallRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.CallRequest").msgclass
  CallRequest::ArgumentDependencies = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.CallRequest.ArgumentDependencies").msgclass
  CallResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.CallResponse").msgclass
  CallResponse::ReturnDependencies = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.CallResponse.ReturnDependencies").msgclass
  CheckRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.CheckRequest").msgclass
  CheckResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.CheckResponse").msgclass
  CheckFailure = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.CheckFailure").msgclass
  DiffRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.DiffRequest").msgclass
  PropertyDiff = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.PropertyDiff").msgclass
  PropertyDiff::Kind = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.PropertyDiff.Kind").enummodule
  DiffResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.DiffResponse").msgclass
  DiffResponse::DiffChanges = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.DiffResponse.DiffChanges").enummodule
  CreateRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.CreateRequest").msgclass
  CreateResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.CreateResponse").msgclass
  ReadRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.ReadRequest").msgclass
  ReadResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.ReadResponse").msgclass
  UpdateRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.UpdateRequest").msgclass
  UpdateResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.UpdateResponse").msgclass
  DeleteRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.DeleteRequest").msgclass
  ConstructRequest = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.ConstructRequest").msgclass
  ConstructRequest::PropertyDependencies = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.ConstructRequest.PropertyDependencies").msgclass
  ConstructResponse = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.ConstructResponse").msgclass
  ConstructResponse::PropertyDependencies = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.ConstructResponse.PropertyDependencies").msgclass
  ErrorResourceInitFailed = ::Google::Protobuf::DescriptorPool.generated_pool.lookup("pulumirpc.ErrorResourceInitFailed").msgclass
end
