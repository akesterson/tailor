require 'wx'
require 'Tailor/GUI/ImageDisplay'

module Tailor
  module GUI
    class GridDisplay < Tailor::GUI::ImageDisplay

      def initialize(*args)
        super(*args)
        @padX = 0
        @padY = 0
        @pitchX = 0
        @pitchY = 0
        @gridX = 0
        @gridY = 0
      end

      def set_grid(padX, padY, pitchX, pitchY, gridX, gridY)
        @padX = padX
        @padY = padY
        @pitchX = pitchX
        @pitchY = pitchY
        @gridX = gridX
        @gridY = gridY
      end

      def on_draw(dc)
        super.on_draw(dc)
        dc.set_pen(Wx::BLACK_DASHED_PEN)
        rows = ( (@image.height - @padY) / (@gridY + @pitchY) )
        columns = ( (@image.width - @padX) / (@gridX + @pitchX) )
        points = []
        curX = @padX
        curY = @padY
        for row in 0..rows
          for column in 0..columns
            dc.draw_rectangle(curX, curY, @gridX, @gridY)
            curX += (@gridX + @pitchX)
          end
          curX = @padX
          curY += (@gridY + @pitchY)
        end
      end
    end
  end
end
