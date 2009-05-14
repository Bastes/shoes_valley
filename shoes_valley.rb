$LOAD_PATH << './lib'

require 'board'

Shoes.app :width => 800, :height => 600 do
  @board = Game::Thud::Board.new

  @selected = nil # no selected piece at first
  @selected_piece = nil
  animate(10) do |i| # animates selected piece
    unless @selected.nil?
      @selected.displace(0, 1 - (Math.sin(i) * 3).to_i.abs)
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
