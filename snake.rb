require "gosu"

class GameWindow < Gosu::Window

  def initialize width, height, fullscreen
    super(width, height, fullscreen)
    self.caption = "Snake"
    @snake = Snake.new(self)
    @food  = Food.new(self)
    @score = 0
    @text_object = Gosu::Font.new(self, "Ubuntu Sans", 32)
  end

  def update
    if button_down? Gosu::KbLeft && @snake.direction != "right"
      @snake.direction = "left"
    end
    if button_down? Gosu::KbRight && @snake.direction != "left"
      @snake.direction = "right"
    end
    if button_down? Gosu::KbUp && @snake.direction != "down"
      @snake.direction = "up"
    end
    if button_down? Gosu::KbDown && @snake.direction != "up"
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
      @new_game = Gosu::Font.new(self, 'Ubuntu Sans', 32)
    end

    if @snake.hit_wall?
      @new_game = Gosu::Font.new(self, 'Ubuntu Sans', 32)
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
      @new_game.draw("Press Return to Try Again", 5, 200, 100)
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
  attr_accessor :direction, :x, :y, :velocity, :length, :segments, :ticker

  def initialize(window)
    @window = window
    @x = 200
    @y = 200
    @segments = []
    @direction = "right"
    @head_segment = Segment.new(self, @window, [@x, @y])
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
      xpos = @head_segment.xpos - @speed
      ypos = @head_segment.ypos
      new_segment = Segment.new(self, @window, [xpos, ypos])
    elsif @direction == "right"
      xpos = @head_segment.xpos + @speed
      ypos = @head_segment.ypos
      new_segment = Segment.new(self, @window, [xpos, ypos])
    elsif @direction == "up"
      xpos = @head_segment.xpos
      ypos = @head_segment.ypos - @speed
      new_segment = Segment.new(self, @window, [xpos, ypos])
    elsif @direction == "down"
      xpos = @head_segment.xpos
      ypos = @head_segment.ypos + @speed
      new_segment = Segment.new(self, @window, [xpos, ypos])
    end

    @head_segment = new_segment
    @segments.push(@head_segment)
  end

  def update_position
    add_segment
    @segments.shift(1) unless @ticker > 0
  end

  def ate_food?
    if Gosu::distance(@head_segment.x, @head_segment.y, food.x, food.y) < 10
      return true
    end
  end

  def hit_self?
    segments = Array.new(@segments)
    if segments.length > 21
      segments.pop(10 * @speed)
      segments.each do |s|
        if Gosu::distance(@head_segment.x, @head_segment.y, s.x, s.y) < 11
          puts "true, head: #{@head_segment.x}, #{@head_segment.y}; seg: #{s.x}, #{s.y}"
          return true
        else
          next
        end
      end
    end
  end

  def hit_wall?
    if @head_segment.x < 0 or @head_segment.x > 800
      return true
    elsif @head_segment.y < 0 or @head_segmenty > 600
      return true
    else
      return false
    end
  end
end

class Segment
  attr_accessor :x, :y
  def initialize(snake, window, position)
    @window = window
    @x = position[0]
    @y = position[1]
  end

  def draw
    @window.draw_quad(@x, @y, Gosu::Color::GREY, @x + 10, @y, Gosu::Color::GREY, @x, @y + 10, Gosu::Color::GREY, @x + 10, @y + 10, Gosu::Color::GREY)
  end
end

class Food
  attr_reader :x, :y

  def initialize(window)
    @window = window
    @x = rand(10..800)
    @y = rand(50..600)
  end

  def draw
    @window.draw_quad(@x, @y, Gosu::Color::YELLOW, @x, @y + 10, Gosu::Color::YELOW, @x + 10, @y, Gosu::Color::YELLOW, @x + 10, @y + 10, Gosu::Color::YELLOW)
  end
end

window = GameWindow.new
window.show
