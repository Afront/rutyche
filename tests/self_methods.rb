module SelfMethods
  @@tp_hash = {}

  # The user writes:
  def foo(x, y)
    (x + y).to_s
  end

  # The runtime checker generates:
  def foo_with_type_checking(x, y)
    raise unless x.is_a?(Integer)
    raise unless y.is_a?(Float)
    
    ret = foo_original(x, y)
    
    raise unless ret.is_a?(String)
    
    ret  
  end

  def self.add_type_checking(function, parameter_types = {}, return_type = :untyped)
    method(function)

    @@tp_hash[function] = {
      parameter_types: parameter_types,
      return_type: return_type
    }

    @@tp_hash[function].default = :untyped
  end

  def self.bye
    p "Bye!"
  end

  def self.wow(a, b)
    p a,b
  end

  TracePoint.trace(:call, :return) do |tp|
    next if tp.method_id == :add_type_checking || @@tp_hash[tp.method_id].nil? || @@tp_hash[tp.method_id].empty?

    case tp.event
    when :call
      params = tp.parameters.map { |arg| eval(arg[1].to_s, tp.binding) }
      puts "Method #{tp.method_id}(#{params.join(', ')}) called"
      puts tp.method_id
      p @@tp_hash
    when :return
      puts "return value #{tp.return_value}"
    end
  end


  add_type_checking(:bye)

  puts "hi"
  bye
  wow(5,3)
end