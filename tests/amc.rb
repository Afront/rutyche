# frozen_string_literal: true
require 'rbs'
require_relative 'typed_methods'

class Module
  # Directly copied from Rails' own alias_method_chain
  def alias_method_chain(target, feature)
    # Strip out punctuation on predicates, bang or writer methods since
    # e.g. target?_without_feature is not a valid method name.
    aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1
    yield(aliased_target, punctuation) if block_given?

    with_method = "#{aliased_target}_with_#{feature}#{punctuation}"
    without_method = "#{aliased_target}_without_#{feature}#{punctuation}"

    alias_method without_method, target
    alias_method target, with_method

    case
    when public_method_defined?(without_method)
      public target
    when protected_method_defined?(without_method)
      protected target
    when private_method_defined?(without_method)
      private target
    end
  end
end



class TypeChecker
  attr_reader :calls

  @@untyped_types = Set[:untyped, :void] # insert other types
  ArgumentReturn = Struct.new(:arguments, :return_value, :exception, keyword_init: true)
  CallTrace = Struct.new(:method_name, :method_call, :block_calls , :block_given, keyword_init: true)

  def initialize env
    @env = env
    @calls = []
  end

  def type_check_arguments(expected_parameter_types, args)
    return if expected_parameter_types.delete_if { |param_type| @@untyped_types.include? param_type}.empty?
    
    # Does not support :untyped yet
    # args.each_with_index do |arg|
    # end


    args.map { |arg| arg.class} == expected_parameter_types
  end

  def type_check_return_type(value, expected_return_type)
    return if @@untyped_types.include? expected_return_type
#    raise TypeError unless value.is_a? expected_return_type
  end

  def type_check_method_body(actual_method, expected_parameter_types = [], expected_return_type = :untyped)
    this = self

    lambda { |*args|
      this.type_check_arguments(expected_parameter_types, args)
      value = send(actual_method, *args)
      this.type_check_return_type(value, expected_return_type)

      this.calls << ArgumentReturn.new(arguments: args, return_value: value, exception: nil)


      value
    }
  end

  def add_type_checking_to_instance_method(class_name, method_symbol, expected_parameter_types = [], expected_return_type = :untyped)
    method_name = method_symbol.to_s
    
    type_checked_method = method_name + '_with_type_check'
    original_method = method_name + '_without_type_check'
    
    typed_proc = type_check_method_body(original_method, expected_parameter_types, expected_return_type)
    class_name.instance_eval do
      define_method(type_checked_method, typed_proc)

      alias_method_chain method_symbol, :type_check
    end
  end

end

module SelfMethods
  def self.assert result  
    raise unless result
  end

  def self.assert_error(collection, method, *args)
    begin
     collection.send(method, *args)
    rescue TypeError
    else
     raise 'Test failed!'
    end
  end


  env = RBS::Environment.new()
  checker = TypeChecker.new(env)
  checker.add_type_checking_to_instance_method(SomeClass, :foo)
  checker.add_type_checking_to_instance_method(SomeClass, :bar, [Integer, Integer], Integer)


  some_object = SomeClass.new

  some_object.foo
  some_object.bar(1,2)

  begin
    some_object.bar(1,2.1)  
  rescue Exception => e
    
  end
  pp checker.calls

  # assert TypedMethods.bye
  # assert TypedMethods.wow(5, :a)
  # assert TypedMethods.add_integers(2, 5)
  # assert TypedMethods.add_two_integers(a: 2, b: 5)
  # assert TypedMethods.concatenate_all_strings('1', '2', '3')

  # TypeChecker.add_type_checking(TypedMethods, :bye)
  # TypeChecker.add_type_checking(TypedMethods, :wow, { a: Integer, b: Symbol }, Array)
  # TypeChecker.add_type_checking(TypedMethods, :add_integers, { a: Integer, b: Integer }, Integer)
  # TypeChecker.add_type_checking(TypedMethods, :add_two_integers, [Integer, Integer], Integer)
  # TypeChecker.add_type_checking(TypedMethods, :concatenate_all_strings, [String, Array], String)

  # assert TypedMethods.bye
  # assert TypedMethods.wow(5, :a)
  # assert TypedMethods.add_integers(2, 5)
  # assert TypedMethods.add_two_integers(a: 2, b: 5)
  # assert TypedMethods.concatenate_all_strings('1', '2', '3')

  # assert_error(TypedMethods, :add_integers, '2', '5')
  # assert_error(TypedMethods, :add_integers, '2', 5)
  # assert_error(TypedMethods, :add_integers, 2.3, 5.1)
  # assert_error(TypedMethods, :add_integers, 2.3, 5)

  # assert TypedMethods.puts('Hi', 'how', 'are', 'you?').nil?
end
