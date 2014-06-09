module Tailor
  module GUI
    class ImageDisplay < Wx::Panel
      def initialize(*args)
        super(*args)
        @bitmap = nil
      end

      def set_image image
        @bitmap = image.to_bitmap
        refresh
      end
      
      def on_draw dc
        dc.set_background Wx::WHITE_BRUSH
        dc.clear
        return if @bitmap == nil
        dc.draw_bitmap(@bitmap, 0, 0, true)
      end
    end
  end
end
