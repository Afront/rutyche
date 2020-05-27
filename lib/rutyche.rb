require "rutyche/version"

module Rutyche
  class Error < StandardError; end
  # Your code goes here...
end

# module TypeChecker
#   @@tp_hash = {}

#   def self.add_type_checking(collection, function, parameter_types = {}, return_type = :untyped)
#     singleton_class = collection.singleton_class
#     if  @@tp_hash[singleton_class].nil?
#       @@tp_hash[singleton_class] = Hash.new { 
#         |klass, function| klass[function] = {
#           parameter_types: Hash.new { |types, parameter| types[parameter] =  :untyped},
#           return_type: :untyped
#         }
#       }
#     end

#     @@tp_hash[singleton_class][function] = {
#         parameter_types: parameter_types,
#         return_type: return_type        
#     }
#   end

#   TracePoint.trace(:call, :return) do |tp|
#     # TODO: Check tp.method_id vs tp.callee_id
#     collection_name = tp.defined_class
#     method_name = tp.method_id
#     next if method_name == :add_type_checking  || !@@tp_hash.has_key?(collection_name)


#     collection_hash = @@tp_hash[collection_name]
#     type_error = nil

#     next if collection_hash[method_name][:parameter_types].empty?

#     case tp.event
#     when :call
#       tp.parameters.each_with_index do |parameter, i|
#         parameter_types = collection_hash[method_name][:parameter_types]
#         expected_parameter_type = parameter_types[parameter_types.class == Hash ? parameter[1] : i]
#         next if expected_parameter_type == :untyped
#         argument = tp.binding.local_variable_get(parameter[1].to_s)
#         type_error = TypeError.new "Argument `#{argument}' is not of class #{expected_parameter_type}" if !argument.is_a? expected_parameter_type
#       end
#     when :return
#       return_value = tp.return_value
#       expected_return_type = collection_hash[method_name][:return_type]
#       next if collection_hash[method_name][:return_type] == :untyped

#       if !return_value.is_a? collection_hash[method_name][:return_type]
#         type_error = TypeError.new "Return value (#{return_value}) is not of class #{collection_hash[method_name][:return_type]}" unless type_error
#       end
#     end

#     raise type_error unless type_error.nil?
#   end
# end
