require 'pp'

# module TypedMethods
#   def self.extended(base)
#     def self.bye
#       p "Bye!"
#     end

#     def self.wow(a, b)
#       p a,b
#     end

#     def self.add_integers(a, b)
#       p a+b
#     end
#   end
# end

module TypedMethods
  extend self

  def self.bye
    p "Bye!"
  end

  def self.wow(a, b)
    p a,b
  end

  def self.add_integers(a, b)
    puts "Hi #{a+b}"
    a+b
  end

  def self.add_two_integers(a:, b:)
    p a+b
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
    # TODO: Checl tp.method_id vs tp.callee_id
    next if tp.method_id == :add_type_checking || @@tp_hash[tp.method_id].nil? || @@tp_hash[tp.method_id].empty?

    case tp.event
    when :call
      tp.parameters.each_with_index do |parameter, i|
        parameter_types = @@tp_hash[tp.method_id][:parameter_types]
        expected_parameter_type = parameter_types[parameter_types.class == Hash ? parameter[1] : i] 
        next (p "hi #{parameter[1]} #{parameter_types} #{@@tp_hash[tp.method_id]}") if expected_parameter_type == :untyped
        raise TypeError.new( "Value (#{parameter[1].to_s}) is not of class #{expected_parameter_type.to_s}") if expected_parameter_type != tp.binding.local_variable_get(parameter[1].to_s).class
      end
    when :return
      puts tp.return_value
      next if @@tp_hash[tp.method_id][:return_type] == :untyped
      raise TypeError.new("Value (#{tp.return_value}) is not of class #{@@tp_hash[tp.method_id][:return_type]}") if tp.return_value.class != @@tp_hash[tp.method_id][:return_type]
    end
  end
end

module SelfMethods
  # extend TypedMethods

  TypeChecker.add_type_checking(:bye)
  TypeChecker.add_type_checking(:add_integers, {:a => Integer, :b => Integer}, Integer)
  TypeChecker.add_type_checking(:add_two_integers, [Integer, Integer], Integer)
  TypeChecker.add_type_checking(:concatenate_all_strings, [String, Array], String)

  # puts "hi"
  TypedMethods.bye
  TypedMethods.wow(5,3)
  TypedMethods.add_integers(2, 5)
  p TypedMethods.add_two_integers(a: 2, b: 5)
  TypedMethods.concatenate_all_strings("1", "2", "3")


 # TypedMethods.add_integers("2", "5")
end