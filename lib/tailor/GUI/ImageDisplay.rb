require 'wx'

module Tailor
  module GUI

    # Ganked from http://rubyforscientificresearch.blogspot.com/2009/05/displaying-images-in-wxruby.html

    class ImageDisplay < Wx::ScrolledWindow
     def initialize(*args)
       super(*args)
       @image = nil
     end

     def set_image image
       @image = image
       set_scrollbars(1, 1, @image.width, @image.height)
       refresh
     end

     def on_draw dc
       dc.set_background Wx::WHITE_BRUSH
       dc.clear
       return if @image == nil
       dc.draw_bitmap(@image, 0, 0, true)
     end
    end
  end
end
