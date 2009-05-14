$LOAD_PATH << './lib'

require 'board'

module BoardView
  attr_accessor :board
  attr_reader :width, :height

  def width= value
    clear_sizes! if @width.nil? or @height.nil? or value < [@width, @height].sort.first
    @width = value
  end

  def height= value
    clear_sizes! if @width.nil? or @height.nil? or value < [@width, @height].sort.first
    @height = value
  end

  def redraw
    self.image "./board.png", :top => 0, :left => 0, :width => board_size, :height => board_size

    fill rgb(0, 0, 0, 0)
    15.times do |y|
      15.times do |x|
        if @board.cell? x, y
          zone = rect((cell_gap * x).to_i, (cell_gap * y).to_i, cell_size, cell_size)
          # FIXME
        end
      end
    end
  end

  private

  def board_size
    @board_size ||= [@width, @height].sort.first
  end

  def cell_gap
    @cell_gap ||= board_size.to_f / 15
  end

  def cell_size
    @cell_size ||= cell_gap.to_i
  end

  def clear_sizes!
    @board_size = nil
    @cell_gap = nil
    @cell_size = nil
  end

end

Shoes.app :width => 600, :height => 600 do
  @my_stack = stack(:width => 600)
  @my_stack.extend BoardView
  @my_stack.board = Game::Thud::Board.new
  @my_stack.width = width
  @my_stack.height = height
  @my_stack.redraw
end

=begin
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
    @board_size = [width, height].sort.first
    @cell_gap = @board_size.to_f / 15
    @cell_size = @cell_gap.to_i

    board_image = image "./board.png", :top => 0, :left => 0,
                        :width => @board_size, :height => @board_size

    # clickable cells (to drop pieces)
    fill rgb(0, 0, 0, 0)
    15.times do |y|
      15.times do |x|
        if @board.cell? x, y
          zone = rect((@cell_gap * x).to_i, (@cell_gap * y).to_i,
               @cell_size, @cell_size)
          zone.click do
            debug "clickedi at #{x}, #{y}"
            unless @selected.nil?
              begin
                @selected_piece.move x, y
                @selected.move((@cell_gap * x).to_i, (@cell_gap * y).to_i)
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
                            :top => (piece.y * @cell_gap).to_i,
                            :left => (piece.x * @cell_gap).to_i,
                            :width => @cell_size, :height => @cell_size

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
                :width => @cell_size, :height => @cell_size
        end
      end
    end
  end
end
=end
