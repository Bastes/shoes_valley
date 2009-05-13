module Game
  module Thud
=begin
Gives "boardable" pieces the basics for being placed and moving.
=end
    module Piece
      attr_reader :x, :y, :board # has a board and coordinates

      # board:: Board instance, required
      # x, y::  coordinates, only if the piece is not out
      def initialize board, x = nil, y = nil
        @board = board
        self.put x, y
      end

      # put the piece from wherever to a free position on the board
      # x, y:: new position
      def put x, y
        unless @board.free? x, y
          raise ArgumentError.new("Cell #{x}, #{y} occupied.")
        end
        @x, @y = [x, y]
        self
      end

      # takes the piece out of the board as a prisonner
      def kill
        @x = @y = nil
        self
      end

      # is the piece out of the board ?
      def dead?
        @x.nil?
      end

      # can be compared to any of its own class, its own class or its symbol
      def == other
        if other == self.class || other.to_sym == :dwarf
          return true
        end
        false
      end
    end

=begin
=The Dwarf piece (D)

Moves in any straight row, column or diagonal line on free cells to any
free cell
\  |  /
 \ | /
  \|/
---D---
  /|\
 / | \
/  |  \

Can be hurled to land on and capture a troll as long as it's got as many
supporting dwarves behind as cells between it and the troll.
The cells between him and the troll should be free, in a straight row,
column or diagonal line, and the support dwarves must be on the same line
just behind it.
DDD   T
DD.-->D

The board starts with dwarves all around the outmost cells of the board,
except for the middle cells of each side.

A captured dwarf awards 1 point to the Troll player.
=end
    class Dwarf
      include Piece

      # If the move is not legit, an exception is raised.
      def move x, y
=begin
    raise ArgumentError.new "Already on #{x}, #{y}." if [@x, @y] == [x, y]
    unless @x = 0 or @y = 0 or [-1, 1].include? (@x - x) / (@y - y)
      raise ArgumentError.new "Only move on rows, columns or diagonals."
    end
=end
        put x, y # FIXME
      end

      def self.type # :nodoc:
        :dwarf
      end

      def type # :nodoc:
        self.class.type
      end
    end

=begin
=The Troll piece (T)

The troll piece move to any free adjacent cell.
\|/
-T-
/|\

A troll can be shoved to any free cell adjacent to at least one dwarf, with
as much supporting trolls as cells between it and its destination cell. The
cells crossed must be free, in any straight row, column or diagonal ligne,
and the supporting trolls must be behind the moving troll. The player may
capture any dwarf adjacent to the landing cell and must capture at least one.
     DDD
TTT    D
     DDD
     xxx
TT.-->Tx
     xxx

The board starts with 8 trolls adjacent to the central cell.

A captured troll awards 4 points to the Dwarf player.
=end
    class Troll
      include Piece

      # If the move is not legit, an exception is raised.
      def move x, y
        put x, y # FIXME
      end

      def self.type # :nodoc:
        :troll
      end

      def type # :nodoc:
        self.class.type
      end
    end

=begin
=The thud Stone (S)

Does not do much in this version of the game, just stays around in the middle
of the board.
=end
    class Stone
      include Piece

      def self.type # :nodoc:
        :stone
      end

      def type # :nodoc:
        self.class.type
      end
    end

=begin
=The thud board.

Where the action takes place. It holds the pieces on the board or captured.
The basic setup is :
#################
######DD DD######
#####D     D#####
####D       D####
###D         D###
##D           D##
#D             D#
#D     TTT     D#
#      TST      #
#D     TTT     D#
#D             D#
##D           D##
###D         D###
####D       D####
#####D     D#####
######DD DD######
#################

The dwarves (D) surround the board and the trolls (T) surround the central
stone (S).

The pieces can be accessed 2D array style :
board[1, 5]
board[11, 7] = :troll

To execute legit moves, use the piece's move method, putting on the board is
not the way to do it.
=end
    class Board
      # See default setup on general class comments.
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

      # Access to a cell's content.
      # Returns nil when the cell is empty, raise an ArgumentError when there's
      # no such cell.
      # x, y:: coordinates of the cell
      def [] x, y
        raise ArgumentError.new("Bad coordinates #{x}, #{y}.") unless cell? x, y
        @pieces.detect { |piece| not piece.dead? and [piece.x, piece.y] == [x, y] }
      end

      # Putting something on the board.
      # Putting "nil" on an occupied cell takes the occupant out.
      # Putting anything on an occupied cell results in an ArgumentError.
      # Putting a Piece class (or matching symbol) on an empty cell makes a new
      # instance and put it on the cell.
      # Putting an existing instance of a Piece class belonging to this board on
      # an empty cell moves this piece on this cell.
      # Putting anything else results in an ArgumentError.
      # x, y:: coordinates of the cell
      # something:: what is put
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

      # Iterates through the piece's list.
      def each &block
        @pieces.each &block
      end

      # Check wether the cell is free.
      # x, y:: coordinates of the cell to check
      def free? x, y
        self[x, y].nil?
      end

      # Check wether a position exists as a cell.
      # x, y:: coordinates of the position to check
      def cell? x, y
        xr = [x, 14 - x].sort.first
        yr = [y, 14 - y].sort.first
        (0..7).include? xr and (0..7).include? yr and xr + yr > 4
      end
    end
  end
end

Shoes.app :width => 800, :height => 600, :resizable => false do
  @board = Game::Thud::Board.new

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
