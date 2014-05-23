require 'wx'
require 'Tailor/GUI/ImageDisplay'

module Tailor
  module GUI
    class GridDisplay < Tailor::GUI::ImageDisplay

      def initialize(*args)
        super(*args)
        @imageGrid = nil
        @darkenCell = nil
        @pristineImage = nil
        @darken_x = 0
        @darken_y = 0
        @rectlist = []
      end

      def set_image(image)
        @pristineImage = image
        set_grid(0, 0, 0, 0, 32, 32)
      end

      def set_grid(padX, padY, pitchX, pitchY, gridX, gridY)
        @imageGrid = Wx::Bitmap.new(@pristineImage.get_width(),
                                    @pristineImage.get_height(),
                                    @pristineImage.get_depth()
                                    )
        tmpImage = Wx::Image.new(gridX, gridY)
        tmpImage.init_alpha
        (0..gridX).each do |x|
          (0..gridY).each do |y|
            tmpImage.set_rgb(x, y, 0, 0, 0)
            tmpImage.set_alpha(x, y, 150)
          end
        end
        @darkenCell = tmpImage.to_bitmap

        evt_left_up() { |event| on_gridClicked(event) }
        @imageGrid.draw() { |dc|
          dc.clear
          dc.draw_bitmap(@pristineImage, 0, 0, true)
          stepx = gridX + pitchX
          stepx = 1 unless stepx != 0
          stepy = gridY + pitchY
          stepy = 1 unless stepy != 0
          rows = ( (@pristineImage.height - padY) / stepy )
          columns = ( (@pristineImage.width - padX) / stepx )
          curX = padX
          curY = padY

          dc.set_brush(Wx::TRANSPARENT_BRUSH)
          dc.set_pen(Wx::RED_PEN)

          for row in 0..rows
            for column in 0..columns
              next if ((curX + stepx + padX) > @imageGrid.get_width)
              next if ((curY + stepy + padY) > @imageGrid.get_height)
              dc.draw_rectangle(curX, curY, gridX, gridY)
              @rectlist << Wx::Rect.new(curX, curY, gridX, gridY)
              curX += stepx
            end
            curX = padX
            curY += stepy
          end
        }
        _super.set_image(@imageGrid)
      end

      def on_draw(dc)
        dc.set_background Wx::WHITE_BRUSH
        dc.clear
        return if @imageGrid == nil
        dc.draw_bitmap(@imageGrid, 0, 0, true)
        return if @darkenCell == nil
        dc.draw_bitmap(@darkenCell, @darken_x, @darken_y, true)
      end

      def on_gridClicked(event)
        @rectlist.each do |rect|
          next unless rect.contains(event.get_x, event.get_y)
          @darken_x = rect.get_x
          @darken_y = rect.get_y
        end
        refresh
      end

    end
  end
end
