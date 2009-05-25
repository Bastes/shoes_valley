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

require 'piece'

module Game
  module Thud
    class Dwarf
      include Piece

      # If the move is not legit, an exception is raised.
      def move x, y
        super
=begin
    raise ArgumentError.new "Already on #{x}, #{y}." if [@x, @y] == [x, y]
    unless @x = 0 or @y = 0 or [-1, 1].include? (@x - x) / (@y - y)
      raise ArgumentError.new "Only move on rows, columns or diagonals."
    end
=end
        @board.turn = :troll
        put x, y # FIXME
      end

      def self.type # :nodoc:
        :dwarf
      end

      def type # :nodoc:
        self.class.type
      end
    end
  end
end
