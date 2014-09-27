require "gosu"

class GameWindow < Gosu::Window

  def initialize width, height, fullscreen
    super(width, height, fullscreen)
    self.caption = "Snake"
    @snake = Snake.new(self)
    @food  = Food.new(self)
    @score = 0
    @text_object = Gosu::Font.new(self, "Ubuntu Sans", 30)
  end

  def update
    if button_down? Gosu::KbLeft and @snake.direction != "right"
      @snake.direction = "left"
    end
    if button_down? Gosu::KbRight and @snake.direction != "left"
      @snake.direction = "right"
    end
    if button_down? Gosu::KbUp and @snake.direction != "down"
      @snake.direction = "up"
    end
    if button_down? Gosu::KbDown and @snake.direction != "up"
      @snake.direction = "down"
    end
    if button_down? Gosu::KbEscape
      self.close
    end

    if @snake.ate_food?(@food)
      @food = Food.new(self)
      @score += 10
      @snake.length += 10
      @snake.ticker += 11
      if @score % 100 == 0
        @snake.velocity += 0.5
      end
    end

    if @snake.hit_self?
      @new_game = Gosu::Font.new(self, 'Ubuntu Sans', 30)
    end

    if @snake.hit_wall?
      @new_game = Gosu::Font.new(self, 'Ubuntu Sans', 30)
    end

    if @new_game and button_down? Gosu::KbReturn
      @new_game = nil
      @score = 0
      @snake = Snake.new(self)
      @food  = Food.new(self)
    end

    @snake.ticker -= 1 if @snake.ticker > 0
  end

  def draw
    if @new_game
      @new_game.draw("Final Score: #{@score}", 5, 200, 100)
      @new_game.draw("Press Return to Try Again", 5, 250, 100)
      @new_game.draw("Or Esc to Close the game", 5, 300, 100)
    else
      @snake.update_position
      @snake.draw
      @food.draw
      @text_object.draw("Score: #{@score}", 5, 5, 0)
    end
  end
end


class Snake
  attr_accessor :direction, :xpos, :ypos, :velocity, :length, :segments, :ticker

  def initialize(window)
    @window = window
    @xpos = 200
    @ypos = 200
    @segments = []
    @direction = "right"
    @head_segment = Segment.new(self, @window, [@xpos, @ypos])
    @segments.push(@head_segment)
    @velocity = 2
    @length = 1
    @ticker = 0
  end

  def draw
    @segments.each do |s|
      s.draw
    end
  end

  def add_segment
    if @direction == "left"
      xpos = @head_segment.xpos - @velocity
      ypos = @head_segment.ypos
      new_segment = Segment.new(self, @window, [xpos, ypos])
    elsif @direction == "right"
      xpos = @head_segment.xpos + @velocity
      ypos = @head_segment.ypos
      new_segment = Segment.new(self, @window, [xpos, ypos])
    elsif @direction == "up"
      xpos = @head_segment.xpos
      ypos = @head_segment.ypos - @velocity
      new_segment = Segment.new(self, @window, [xpos, ypos])
    elsif @direction == "down"
      xpos = @head_segment.xpos
      ypos = @head_segment.ypos + @velocity
      new_segment = Segment.new(self, @window, [xpos, ypos])
    end

    @head_segment = new_segment
    @segments.push(@head_segment)
  end

  def update_position
    add_segment
    @segments.shift(1) unless @ticker > 0
  end

  def ate_food?(food)
    if Gosu::distance(@head_segment.xpos, @head_segment.ypos, food.xpos, food.ypos) < 10
      return true
    end
  end

  def hit_self?
    segments = Array.new(@segments)
    if segments.length > 21
      segments.pop(10 * @speed)
      segments.each do |s|
        if Gosu::distance(@head_segment.xpos, @head_segment.ypos, s.xpos, s.ypos) < 11
          puts "true, head: #{@head_segment.xpos}, #{@head_segment.ypos}; seg: #{s.xpos}, #{s.ypos}"
          return true
        else
          next
        end
      end
      return false
    end
  end

  def hit_wall?
    if @head_segment.xpos < 0 or @head_segment.xpos > 800
      return true
    elsif @head_segment.ypos < 0 or @head_segment.ypos > 600
      return true
    else
      return false
    end
  end
end

class Segment
  attr_accessor :xpos, :ypos
  def initialize(snake, window, position)
    @window = window
    @xpos = position[0]
    @ypos = position[1]
  end

  def draw
    @window.draw_quad(@xpos, @ypos, Gosu::Color::GRAY, @xpos + 10, @ypos, Gosu::Color::GRAY, @xpos, @ypos + 10, Gosu::Color::GRAY, @xpos + 10, @ypos + 10, Gosu::Color::GRAY)
  end
end

class Food
  attr_reader :xpos, :ypos

  def initialize(window)
    @window = window
    @xpos = rand(10..800)
    @ypos = rand(50..600)
  end

  def draw
    @window.draw_quad(@xpos, @ypos, Gosu::Color::YELLOW, @xpos + 10 , @ypos, Gosu::Color::YELLOW, @xpos, @ypos + 10, Gosu::Color::YELLOW, @xpos + 10, @ypos + 10, Gosu::Color::YELLOW)
  end
end

window = GameWindow.new(800, 600, false)
window.show
