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
        fromx, fromy = [@x, @y]
        @x, @y = [x, y]
        @board.piece_event self, fromx, fromy
        self
      end

      # moves the piece according to the rules
      # to be implemented by the implementing classes
      # x, y:: new position
      def move x, y
        raise "It's not #{self.type}'s turn to play !" unless self.type == @board.turn
      end

      # takes the piece out of the board as a prisonner
      def kill
        fromx, fromy = [@x, @y]
        @x = @y = nil
        @board.piece_event self, fromx, fromy
        self
      end

      # is the piece out of the board ?
      def dead?
        @x.nil?
      end
    end
  end
end
