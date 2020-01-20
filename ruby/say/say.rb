class Say
  attr_reader :number

  def initialize(number)
    @number = number
  end 

  def in_english 
    raise ArgumentError if number < 0 || number >= 1_000_000_000_000
    return 'zero' if number.zero? 
    recursive_numeral(number).strip 
  end

  private

  def recursive_numeral(num)
    remainder = bignum_factory(num).remainder
    next_num = if remainder >= 100
                 recursive_numeral(remainder)
               else
                 smallnum_factory(remainder).in_english 
               end
    [bignum_factory(num).in_english, next_num].compact.join(' ')
  end

  def smallnum_factory(num)
    SmallNumberFactory.new(remainder)
  end

  def bignum_factory(num)
    [Hundred, Thousand, Million, Billion][Math.log(num, 1000).to_i].new(num)
  end

  class Hundred
    attr_reader :number

    def initialize(number)
      @number = number
    end

    def in_english
      return nil if first_digits.zero?
      "#{beginning} #{name}"
    end

    def remainder
      return 0 if (number % denominator).zero?
      number % denominator
    end

    private

    def denominator
      100
    end

    def name
      class.name.to_s.downcase
    end

    def beginning
      return two_digit_beginning if first_digits < 100
      "#{Hundred.new(first_digits).in_english} #{factory.new(first_digits % 100).in_english}"
    end

    def two_digit_beginning
      factory.new(first_digits).in_english
    end

    def first_digits
      number / denominator
    end

    def factory
      SmallNumberFactory
    end
  end
  class Thousand < Hundred 
    def denominator
      1000
    end
  end

  class Million < Hundred
    def denominator
      1_000_000
    end
  end

  class Billion < Hundred
    def denominator
      1_000_000_000
    end
  end

  class SmallNumber
    attr_reader :number
    ONES_MAPPING = %w[zero one two three four five six seven eight nine ten]
    TENS_MAPPING = %w[_ _ twenty thirty forty fifty sixty seventy eighty ninety]
    def initialize(number, format=nil)
      @number = number
    end
    def in_english
      ONES_MAPPING[number] 
    end
  end 

  class TeenNumber < SmallNumber
    def in_english
      "%steen" % ONES_MAPPING[number % 10]
    end
  end

  class SimpleTensNumber < SmallNumber
    def in_english
      TENS_MAPPING[number / 10]
    end
  end

  class ComplexTensNumber < SmallNumber
    def in_english
      "%s-%s" % [TENS_MAPPING[number.floor(-1) / 10], ONES_MAPPING[number % 10]] 
    end
  end 

  class NilNumber
    def in_english
      nil
    end
  end

  class SmallNumberFactory
    attr_reader :number

    def initialize(number)
      @number = number
    end

    def in_english
      factoried.in_english
    end

    def factoried
      return NilNumber.new if number.zero? || number.nil?
      return SmallNumber.new(number) if number < 10
      return TeenNumber.new(number) if number < 20
      return ComplexTensNumber.new(number) if (number % 10) > 0
      SimpleTensNumber.new(number)
    end 
  end
end
