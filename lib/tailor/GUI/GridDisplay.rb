require 'wx'
require 'Tailor/GUI/BitmapDisplay'

module Tailor
  module GUI
    class GridDisplaySelectedEvent < Wx::CommandEvent
      EVT_GRIDDISPLAY_SELECTED = Wx::EvtHandler.register_class(self,
                                                               nil,
                                                               "evt_griddisplay_selected", 
                                                               1)
      def initialize(source)
        super(EVT_GRIDDISPLAY_SELECTED)
        self.id = source.get_id
        self.client_data = { 
          'size' => source.get_size,
          'index' => source.get_selected_index,
          'tile' => source.get_selected_tile }
      end

    end

    class GridDisplay < Wx::ScrolledWindow

      attr_accessor :tileset

      def initialize(*args)
        super(*args)
        self.tileset = nil
        @bitmapGrid = nil
        @darkenCell = nil
        @darken_x = 0
        @darken_y = 0
        @rectlist = []
        @selected = nil

        evt_left_up() { |event| on_gridClicked(event) }
      end

      def set_tileset(tileset)
        self.tileset = tileset
        @bitmap = tileset.image.convert_to_bitmap
        refresh_grid
      end

      def set_image(image)
        self.tileset.image = image
        @bitmap = image.convert_to_bitmap
        set_scrollbars(1, 1, @bitmap.width, @bitmap.height)
        refresh_grid
      end

      def refresh_grid
        @rectlist = []
        @selected = nil

        @bitmapGrid = Wx::Bitmap.new(@bitmap.get_width(),
                                    @bitmap.get_height(),
                                    @bitmap.get_depth()
                                    )
        tmpImage = Wx::Image.new(self.tileset.tile_x, self.tileset.tile_y)
        tmpImage.init_alpha
        (0..self.tileset.tile_x).each do |x|
          (0..self.tileset.tile_y).each do |y|
            tmpImage.set_rgb(x, y, 0, 0, 0)
            tmpImage.set_alpha(x, y, 150)
          end
        end
        @darkenCell = tmpImage.to_bitmap
        @darken_x = -(self.tileset.tile_x)
        @darken_y = -(self.tileset.tile_y)

        stepx = self.tileset.tile_x + self.tileset.space_x
        stepx = 1 unless stepx != 0
        stepy = self.tileset.tile_y + self.tileset.space_y
        stepy = 1 unless stepy != 0
        rows = ( (@bitmap.height - self.tileset.pad_y) / stepy )
        columns = ( (@bitmap.width - self.tileset.pad_x) / stepx )
        curX = self.tileset.pad_x
        curY = self.tileset.pad_y
        
        @bitmapGrid.draw() { |dc|
          dc.clear
          dc.draw_bitmap(@bitmap, 0, 0, true)

          dc.set_brush(Wx::TRANSPARENT_BRUSH)
          dc.set_pen(Wx::RED_PEN)

          for row in 0..rows
            for column in 0..columns
              next if ((curX + stepx + self.tileset.pad_x) > @bitmapGrid.get_width)
              next if ((curY + stepy + self.tileset.pad_y) > @bitmapGrid.get_height)
              dc.draw_rectangle(curX, curY, self.tileset.tile_x, self.tileset.tile_y)
              @rectlist << Wx::Rect.new(curX, curY, self.tileset.tile_x, self.tileset.tile_y)
              curX += stepx
            end
            curX = self.tileset.pad_x
            curY += stepy
          end
        }
        refresh
      end

      def on_draw(dc)
        dc.set_background Wx::WHITE_BRUSH
        dc.clear
        return if @bitmapGrid == nil
        dc.draw_bitmap(@bitmapGrid, 0, 0, true)
        return if @darkenCell == nil
        dc.draw_bitmap(@darkenCell, @darken_x, @darken_y, true)
      end

      def on_gridClicked(event)
        @rectlist.each do |rect|
          next unless rect.contains(event.get_x, event.get_y)
          @darken_x = rect.get_x
          @darken_y = rect.get_y
          @selected = rect
          evt = GridDisplaySelectedEvent.new(self)
          event_handler.process_event(evt)
        end
        refresh
      end

      def get_size
        @rectlist.length
      end

      def get_bitmap
        @bitmap
      end

      def get_tile_bitmaps
        ret = []
        @rectlist.each do |rect|
          img = @bitmap.sub_bitmap(rect)
          ret << img
        end
        ret
      end

      def get_selected_tile
        @bitmap.get_sub_bitmap(@selected)
      end

      def get_selected_index
        @rectlist.index(@selected)
      end

    end
  end
end
