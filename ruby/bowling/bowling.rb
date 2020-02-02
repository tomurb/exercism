class Game
  class BowlingError < StandardError; end
  def initialize
    @score = 0
    @started = false
    @frames = [LastFrame.new] + Array.new(8) { Frame.new }
    @frame = Frame.new
    @roll_factor = 1
    @next_roll_factor = 1
  end

  def roll(pins)
    raise BowlingError if completed? || pins < 0
    @started = true
    @frame = @frames.pop if @frame.end?
    @score += evaluate_score(pins)
    @frame << pins unless @frame.nil?
    @roll_factor += 1 if (@frame.spare? || @frame.strike?) && !@frame.last?
    @next_roll_factor += 1 if @frame.strike? && !@frame.last?
    @frame.spare_bonus! if @frame.spare?
  end
  
  def score
    raise BowlingError unless completed? && started?
    @score
  end

  private

  def started?
    @started
  end

  def completed?
    @frames.size == 0 && @frame.end?
  end

  def evaluate_score(pins)
    result = pins * @roll_factor
    @roll_factor = @next_roll_factor
    @next_roll_factor = 1
    result
  end

  class Frame
    def initialize
      @rolls = []
      @spare = false
      @factor = 1
      @strike = false
      @strike_bonus = false
    end

    def end?
      return true if @strike
      @rolls.size >= 2
    end

    def <<(roll)
      @rolls << roll
      @strike = true if roll == 10
      @spare = true if @rolls.sum == 10 && !strike?
      raise BowlingError if @rolls.sum > 10
    end

    def spare?
      @spare
    end

    def strike?
      @strike
    end

    def last?
      false
    end

    def spare_bonus!; end
  end

  class LastFrame < Frame
    def initialize
      @bonus_rolls = 0
      @strikes = 0
      super
    end

    def <<(roll)
      raise BowlingError if roll == 10 && strike? && @rolls.size == 2 && @rolls.sum != 20
      @strike = true if @rolls.size.zero? && roll == 10
      @spare = true if @rolls.sum == 10 && !strike?
      @rolls << roll
      @strikes += 1 if roll == 10
      raise BowlingError if roll > 10
      raise BowlingError if @rolls.sum > 20 && @strikes < 2
      @spare = true if @rolls.sum == 10
    end

    def end?
      @rolls.size >= 2 + @bonus_rolls
    end 

    def spare_bonus!
      @bonus_rolls = 1
    end

    def strike_bonus!
      @bonus_rolls = 1
    end

    def last?
      true
    end
  end
end
