require 'wx'
require 'Tailor/GUI/ImageDisplay'

module Tailor
  module GUI
    class GridDisplay < Tailor::GUI::ImageDisplay

      def initialize(*args)
        super(*args)
        @imageGrid = nil
        @padX = 0
        @padY = 0
        @pitchX = 0
        @pitchY = 0
        @gridX = 32
        @gridY = 32
      end

      def set_image(image)
        _super.set_image(image)
        @imageGrid = Wx::Bitmap.new(@image.get_width(),
                                    @image.get_height(),
                                    32
                                    )
        set_grid(@padX, @padY, @pitchX, @pitchY, @gridX, @gridY)
      end

      def set_grid(padX, padY, pitchX, pitchY, gridX, gridY)
        @padX = padX
        @padY = padY
        @pitchX = pitchX
        @pitchY = pitchY
        @gridX = gridX
        @gridY = gridY

        @imageGrid.draw() { |dc|
          dc.draw_bitmap(@image, 0, 0, true)
          stepx = @gridX + @pitchX
          stepx = 1 unless stepx != 0
          stepy = @gridY + @pitchY
          stepy = 1 unless stepy != 0
          rows = ( (@image.height - @padY) / stepy )
          columns = ( (@image.width - @padX) / stepx )
          points = []
          curX = @padX
          curY = @padY

          dc.set_brush(Wx::TRANSPARENT_BRUSH)
          dc.set_pen(Wx::RED_PEN)

          for row in 0..rows
            for column in 0..columns
              dc.draw_rectangle(curX, curY, @gridX, @gridY)
              curX += stepx
            end
            curX = @padX
            curY += stepy
          end
        }
      end

      def on_draw(dc)
        _super.on_draw(dc)
        tmp=@image
        @image=@imageGrid
        _super.on_draw(dc)
        @image=tmp
      end

    end
  end
end
