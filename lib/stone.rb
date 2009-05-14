=begin
=The thud Stone (S)

Does not do much in this version of the game, just stays around in the middle
of the board.
=end

require 'piece'

module Game
  module Thud
    class Stone
      include Piece

      def self.type # :nodoc:
        :stone
      end

      def type # :nodoc:
        self.class.type
      end
    end
  end
end
