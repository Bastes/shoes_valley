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

  def == other
    if other == self.class || other.to_sym == :dwarf
      return true
    end
		false
  end
end

class Dwarf
  include Piece

  def move x, y
=begin
    raise ArgumentError.new "Already on #{x}, #{y}." if [@x, @y] == [x, y]
    unless @x = 0 or @y = 0 or [-1, 1].include? (@x - x) / (@y - y)
      raise ArgumentError.new "Only move on rows, columns or diagonals."
    end
=end
    put x, y # FIXME
  end

	def type
		:dwarf
	end
end

class Troll
  include Piece

  def move x, y
    put x, y # FIXME
  end

	def type
		:troll
	end
end

class Stone
  include Piece

	def type
		:stone
	end
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
    @pieces.each &block
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

Shoes.app :width => 800, :height => 600, :resizable => false do
	@board = Board.new

	@selected = nil # no selected piece at first
	@selected_piece = nil
	animate(24) do |i| # animates selected piece
		unless @selected.nil?
			@selected.displace(0, (Math.sin(i) * 3).to_i - 3)
		end
	end

	stack :width => 600 do # here goes the board
		@boardsize = [width, height].sort.first
		@cellgap = @boardsize.to_f / 15
		@cellsize = @cellgap.to_i

		board_image = image "./board.png", :top => 0, :left => 0,
					              :width => @boardsize, :height => @boardsize

		# clickable cells (to drop pieces)
		fill rgb(0, 0, 0, 0)
		15.times do |y|
			15.times do |x|
				if @board.cell? x, y
					zone = rect((@cellgap * x).to_i, (@cellgap * y).to_i,
						   @cellsize, @cellsize)
					zone.click do
						debug "clickedi at #{x}, #{y}"
						unless @selected.nil?
							begin
								@selected_piece.move x, y
								@selected.move((@cellgap * x).to_i, (@cellgap * y).to_i)
								@selected.displace 0, 0
								@selected = @selected_piece = nil
							rescue
								warn "move incomplete"
							end
						end
					end
				end
			end
		end

		@board.each do |piece|
			unless piece.dead?
				piece_image = image "./#{piece.type}.png",
							              :top => (piece.y * @cellgap).to_i,
														:left => (piece.x * @cellgap).to_i,
														:width => @cellsize, :height => @cellsize

				piece_image.click do # selection of a piece
				  debug "clicked the #{piece.type} at #{piece.x}, #{piece.y}"
					if @selected.equal? piece_image
						@selected = nil
						@selected_piece = nil
					  piece_image.displace(0, 0)
					else
					  @selected.displace(0, 0) unless @selected.nil?
						@selected = piece_image
						@selected_piece = piece
					end
				end
			end
		end
	end

	stack :width => -600 do
		flow do # there goes outer controls
			button("Pass")
		end
		flow do # a place for the dead
			@board.each do |piece|
				if piece.dead?
					image "./#{piece.type}.png",
								:width => @cellsize, :height => @cellsize
				end
			end
		end
	end
end
