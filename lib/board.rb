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

require 'dwarf'
require 'troll'
require 'stone'

module Game
  module Thud
    class Board
      attr_accessor :turn

      # See default setup on general class comments.
      def initialize
        @callbacks = []
        @pieces = []
        @turn = :dwarf

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
      # "nil" on an occupied cell takes the occupant out.
      # Anything on an occupied cell results in an ArgumentError.
      # A Piece class (or matching symbol) on an empty cell makes a new instance
      # and put it on the cell.
      # Existing instance of a Piece class belonging to this board on an empty
      # cell moves this piece on this cell.
      # Anything else results in an ArgumentError.
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

      # Add a board event callback.
      # callback:: board event callback to add
      def listen &callback
        @callbacks << callback
      end

      # Triggered by pieces when they move.
      #
      # piece:: an event is happening to a piece
      # x, y:: former position of the piece
      def piece_event piece, fromx = nil, fromy = nil
        @callbacks.each do |callback|
          callback.call piece, fromx, fromy
        end
      end
    end
  end
end
