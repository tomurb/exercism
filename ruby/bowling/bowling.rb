require 'forwardable'

class Game
  class BowlingError < StandardError; end
  extend Forwardable
  def initialize
    @score = 0
    @frames = Frames.new
    @roll_factor = 1
    @next_roll_factor = 1
  end

  def roll(pins)
    raise BowlingError if completed? || pins < 0
    @score += evaluate_score(pins)
    @frames << pins
    bonuses
  end
  
  def score
    raise BowlingError unless completed? && started?
    @score
  end

  private

  def_delegators :@frames, :started?, :completed?, :roll_bonus?, :next_roll_bonus?

  def bonuses
    @roll_factor, @next_roll_factor = @next_roll_factor, 1
    @roll_factor += 1 if roll_bonus?
    @next_roll_factor += 1 if next_roll_bonus?
  end

  def evaluate_score(pins)
    result = pins * @roll_factor
    result
  end

  class Frames
    include Enumerable
    extend Forwardable
    NORMAL_FRAMES = 9

    def initialize
      @index = 0
      @started = false
    end

    def current
      @current = @current.nil? || @current.end? ? pop : @current
    end

    def pop
      @index += 1
      return nil if @index > 10
      @index <= NORMAL_FRAMES ? Frame.new : LastFrame.new
    end

    def next_roll_bonus?
      @current&.next_roll_bonus?
    end

    def roll_bonus?
      @current&.roll_bonus?
    end

    def <<(pins)
      current << pins  unless current.nil?
    end

    def completed?
      return true if current.nil?
      @index == 10 && current.end?  
    end

    def started?
      @index > 0
    end
  end
  class Frame
    def initialize
      @rolls = []
      @spare = false
      @strike = false
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

    def roll_bonus?
      (spare? || strike?) && !last?
    end

    def next_roll_bonus?
      strike? && !last?
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
      spare_bonus! if spare?
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
