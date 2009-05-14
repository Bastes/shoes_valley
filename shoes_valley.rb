$LOAD_PATH << './lib'

require 'board'

module BoardView
  attr_accessor :board
  attr_reader :width, :height

  def width= value
    if @width.nil? or @height.nil? or value < [@width, @height].sort.first
      clear_sizes!
    end
    @width = value
  end

  def height= value
    if @width.nil? or @height.nil? or value < [@width, @height].sort.first
      clear_sizes!
    end
    @height = value
  end

  def redraw all = false
    if all or @pieces.nil?
      self.clear do
        self.image "./board.png", :top => 0, :left => 0,
                   :width => board_size, :height => board_size

        fill rgb(0, 0, 0, 0)
        15.times do |y|
          15.times do |x|
            if @board.cell? x, y
              zone = rect((cell_gap * x).to_i, (cell_gap * y).to_i,
                          cell_size, cell_size)
              zone.click do
                self.clicked x, y
              end
            end
          end
        end
      end

      @pieces = []
    else
      @pieces.each { |piece| piece.remove }
      @pieces.empty
    end

    @board.each do |piece|
      @pieces << piece_image(piece) unless piece.dead?
    end
  end

  def clicked x, y
    if @selection.nil?
      find_piece_image(@board[x, y]).displace(0, -cell_size / 4)
      @selection = {:x => x, :y => y}
    else
      piece = @board[@selection[:x], @selection[:y]]
      @selection = nil
      this_piece_image = find_piece_image(piece)
      this_piece_image.displace(0, 0)
      piece.move(x, y)
      this_piece_image.move((cell_gap * x).to_i, (cell_gap * y).to_i)
    end
  end

  private
  
  def piece_image piece
    image "./#{piece.type}.png",
          :top => (piece.y * cell_gap).to_i,
          :left => (piece.x * cell_gap).to_i,
          :width => cell_size, :height => cell_size
  end

  def find_piece_image piece
    x = (cell_gap * piece.x).to_i
    y = (cell_gap * piece.y).to_i
    @pieces.detect do |piece_image|
      piece_image.left == x and piece_image.top == y 
    end
  end

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
