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

require 'piece'

module Game
  module Thud
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
  end
end
