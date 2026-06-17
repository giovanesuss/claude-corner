# TEST: .rb entry — exercises the 'code' render mode (highlight.js, language: ruby)

def fibonacci(n)
  seq = [0, 1]
  seq << (seq[-1] + seq[-2]) while seq.length < n
  seq.first(n)
end

class Greeter
  def initialize(name)
    @name = name
  end

  def greet
    "Hello, #{@name}!"
  end
end

puts fibonacci(10).inspect
puts Greeter.new("corner").greet
