# frozen_string_literal: true

require 'pp'

module TypedMethods
  module_function

  def self.bye
    p 'Bye!'
  end

  def self.wow(a, b)
    p a, b
  end

  def self.add_integers(a, b)
    p a + b
  end

  def self.add_two_integers(a:, b:)
    p a + b
  end

  def self.concatenate_all_strings(string, *args)
    p string + args.join
  end
end

module TypeChecker
  @@tp_hash = {}

  def self.add_type_checking(function, parameter_types = {}, return_type = :untyped)
    @@tp_hash[function] = {
      parameter_types: parameter_types,
      return_type: return_type
    }

    @@tp_hash[function].default = {}

    @@tp_hash[function][parameter_types].default = :untyped
  end

  TracePoint.trace(:call, :return) do |tp|
    # TODO: Use tp.defined_class to add support for multiple classes
    # TODO: Check tp.method_id vs tp.callee_id
    method_name = tp.method_id
    type_error = nil
    next if method_name == :add_type_checking || @@tp_hash[method_name].nil? || @@tp_hash[method_name].empty?

    case tp.event
    when :call
      tp.parameters.each_with_index do |parameter, i|
        parameter_types = @@tp_hash[method_name][:parameter_types]
        expected_parameter_type = parameter_types[parameter_types.class == Hash ? parameter[1] : i]
        next if expected_parameter_type == :untyped
        argument = tp.binding.local_variable_get(parameter[1].to_s)
        type_error = TypeError.new "Argument `#{argument}' is not of class #{expected_parameter_type}" if !argument.is_a? expected_parameter_type
      end
    when :return
      return_value = tp.return_value
      expected_return_type = @@tp_hash[method_name][:return_type]
      puts return_value, "hi"
      next if @@tp_hash[tp.method_id][:return_type] == :untyped

      if !return_value.is_a? @@tp_hash[tp.method_id][:return_type]
        type_error = TypeError.new "Return value (#{return_value}) is not of class #{@@tp_hash[tp.method_id][:return_type]}" unless type_error
      end
    end

    raise type_error unless type_error.nil?
  end
end

module SelfMethods
  # extend TypedMethods
  def self.assert result
    raise unless result
  end

  def self.assert_error(container, method, *args)
    begin
     container.send(method, *args)
    rescue TypeError
    else
     raise "Test failed!"
    end
  end

  TypeChecker.add_type_checking(:bye)
  TypeChecker.add_type_checking(:wow, { a: Integer, b: Symbol }, Array)
  TypeChecker.add_type_checking(:add_integers, { a: Integer, b: Integer }, Integer)
  TypeChecker.add_type_checking(:add_two_integers, [Integer, Integer], Integer)
  TypeChecker.add_type_checking(:concatenate_all_strings, [String, Array], String)

  # puts "hi"
  assert TypedMethods.bye
  assert TypedMethods.wow(5, :a)
  assert TypedMethods.add_integers(2, 5)
  assert p TypedMethods.add_two_integers(a: 2, b: 5)
  assert TypedMethods.concatenate_all_strings('1', '2', '3')

  assert_error(TypedMethods, :add_integers, "2", "5")
  assert_error(TypedMethods, :add_integers, "2", 5)
  assert_error(TypedMethods, :add_integers, 2.3, 5.1)
  assert_error(TypedMethods, :add_integers, 2.3, 5)
end
