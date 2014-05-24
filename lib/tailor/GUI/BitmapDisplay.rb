require 'wx'

module Tailor
  module GUI

    # Ganked from http://rubyforscientificresearch.blogspot.com/2009/05/displaying-images-in-wxruby.html

    class BitmapDisplay < Wx::ScrolledWindow
     def initialize(*args)
       super(*args)
       @bitmap = nil
     end

     def set_bitmap bmp
       puts "Setting bitmap to #{bmp}"
       @bitmap = bmp
       set_scrollbars(1, 1, @bitmap.width, @bitmap.height)
       refresh
     end

     def on_draw dc
       puts "Drawing #{@bitmap}"
       dc.set_background Wx::WHITE_BRUSH
       dc.clear
       return if @bitmap == nil
       dc.draw_bitmap(@bitmap, 0, 0, true)
     end
    end
  end
end
