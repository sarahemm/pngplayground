def check(actual, expected, desc)
  if(actual == Array.class) then
    actual.each_idx do |idx|
      check(actual[idx], expected[idx], desc)
    end
  end

  if(actual != expected) then
    puts "#{desc} invalid, expected #{expected} but got #{actual}"
    return 1
  end

  return 0
end

class String
  def is_upper?
    self == self.upcase
  end

  def is_lower?
    self == self.downcase
  end
end
