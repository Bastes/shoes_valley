module Piece
  attr_reader :x, :y, :board

  def initialize board, x = nil, y = nil
    @board = board
    self.put x, y
  end

  def put x, y
    unless @board.free? x, y
      raise ArgumentError.new("Cell #{x}, #{y} occupied.")
    end
    @x, @y = [x, y]
    self
  end

  def kill
    @x = @y = nil
    self
  end

  def dead?
    @x.nil?
  end

  def to_s
    "\#<#{self.class}:#{__id__} @board: #{@board}, @x: #{x}, @y: #{y}>"
  end
end

class Dwarf
  include Piece

  def move x, y
    raise ArgumentError.new "Already on #{x}, #{y}." if [@x, @y] == [x, y]
    unless @x = 0 or @y = 0 or [-1, 1].include? (@x - x) / (@y - y)
      raise ArgumentError.new "Only move on rows, columns or diagonals."
    end
    # FIXME
  end

  def == other
    if other == self.class
      return true
    elsif other.to_sym == :dwarf
      return true
    end
  end
end

class Troll
  include Piece

  def move x, y
    # FIXME
  end
end

class Stone
  include Piece
end

class Board
  def initialize
    @pieces =  []
    15.times do |x|
      15.times do |y|
        xr = [x, 14 - x].sort.first
        yr = [y, 14 - y].sort.first
        if piece = (xr == 7 and yr == 7) ? Stone :
                   (xr > 5 and yr > 5) ? Troll :
                   (xr + yr == 5 or [xr, yr].sort == [0, 6]) ? Dwarf: nil
          @pieces << piece.new(self, x, y) 
        end
      end
    end
  end

  def [] x, y
    raise ArgumentError.new("Bad coordinates #{x}, #{y}.") unless cell? x, y
    @pieces.detect { |piece| not piece.dead? and [piece.x, piece.y] == [x, y] }
  end

  def []= x, y, something
    if something.nil?
      if piece = self[x, y]
        piece.kill
      end
    else
      if [Dwarf, Troll, Stone].include? something
        return @pieces << something.new(self, x, y)
      elsif pclass = {:dwarf => Dwarf, :troll => Troll, :stone => Stone}[something]
        return @pieces << pclass.new(self, x, y)
      elsif [Dwarf, Troll, Stone].include? something.class
        unless something.board == self
          raise ArgumentError.new("This #{something} belongs to another board")
        end
        @pieces << something unless @pieces.include? something
        return something.put x, y
      else
        raise ArgumentError.new("This #{something} can't be put on the board.")
      end
    end
  end

  def each &block
    @cells.each block
  end

  def free? x, y
    self[x, y].nil?
  end

  def cell? x, y
    xr = [x, 14 - x].sort.first
    yr = [y, 14 - y].sort.first
    (0..7).include? xr and (0..7).include? yr and xr + yr > 4
  end
end

=begin
Shoes.app do
  # FIXME
end
=end
