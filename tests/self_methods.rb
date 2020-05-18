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
    p a+b
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

    @@tp_hash[function].default = :untyped
  end

  TracePoint.trace(:call, :return) do |tp|
    # tp.defined_class
    # tp.method_id vs tp.callee_id
    next if tp.method_id == :add_type_checking || @@tp_hash[tp.method_id].nil? || @@tp_hash[tp.method_id].empty?

    case tp.event
    when :call
      p tp.parameters
      params = tp.parameters.map { |arg| tp.binding.local_variable_get(arg[1].to_s) }
      puts "Method #{tp.method_id}(#{params.join(', ')}) called"
      puts tp.method_id
      puts tp.callee_id
      p params
      p params.class

#      p @@tp_hash
    when :return
      next if @@tp_hash[tp.method_id][:return_type] == :untyped
      raise if tp.return_value.class != @@tp_hash[tp.method_id][:return_type]
    end
  end
end

module SelfMethods
  # extend TypedMethods

  TypeChecker.add_type_checking(:bye)
  TypeChecker.add_type_checking(:add_integers, {0 => Integer, 1 => Integer, 2 => Integer}, Integer)
  TypeChecker.add_type_checking(:add_two_integers, {0 => Integer, 1 => Integer, 2 => Integer}, Integer)
  TypeChecker.add_type_checking(:concatenate_all_strings, {0 => Integer, 1 => Integer, 2 => Integer}, String)

  puts "hi"
  TypedMethods.bye
  TypedMethods.wow(5,3)
  TypedMethods.add_integers(2, 5)
  TypedMethods.add_two_integers(a: 2, b: 5)
  TypedMethods.concatenate_all_strings("1", "2", "3")


#  TypedMethods.add_integers("2", "5")
end