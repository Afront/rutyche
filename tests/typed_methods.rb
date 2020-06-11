module TypedMethods
  module_function

  def self.bye
    'Bye!'
  end

  def self.wow(a, b)
    [a, b]
  end

  def self.add_integers(a, b)
    a + b
  end

  def self.add_two_integers(a:, b:)
    a + b
  end

  def self.concatenate_all_strings(string, *args)
    string + args.join
  end

  def self.puts(string, *args)
    Kernel.puts string, *args
  end
end

class SomeClass
  def initialize
  end

  def foo
    puts 'foo'
  end

  def bar(foo, baz)
    foo + baz
  end

  def get_block
    yield if block.given?
    
  end

end

class Stack
  def initialize
    @array = []
  end

  def push(*args)
    @array.push args
  end

  def pop
    @array.pop
  end

  # def each
  #   each_index do |i|
  #     yield get_value i
  #   end
  # end

  # def each_index
  #     i = 0
  #     while i < @array.length
  #       yield i
  #       i += 1
  #     end
  # end

  # def get_value idx
  #   if idx.is_a? Integer
  #     i = 0
  #     p i.class
  #     p "oww"
  #   else
  #     p "ahh"
  #     raise if idx.length != 1
  #     i = idx.flatten.first
  #     p "#{i.class} #{i}"
  #   end 

  #   @array[i]  
  # end
end

