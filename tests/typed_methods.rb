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

end