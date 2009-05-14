=begin
Gives "boardable" pieces the basics for being placed and moving.
=end

module Game
  module Thud
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
  end
end
