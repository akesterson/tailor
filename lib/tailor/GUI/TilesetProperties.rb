require 'wx'

module Tailor
  module GUI
    class TilesetProperties < Wx::Panel
      def create_method( name, &block )
        self.class.send( :define_method, name, &block )
      end

      def initialize(*args)
        super(*args)
        values = {
          "Tile X"  => 32,
          "Tile Y"  => 32,
          "Pad X"   => 0,
          "Pad Y"   => 0,
          "Space X" => 0,
          "Space Y" => 0
        }
        @sizer = Wx::BoxSizer.new(Wx::VERTICAL)
        self.set_sizer(@sizer)
        values.each_pair do |elem, value|
          tmpsizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
          tmpsizer.add(Wx::StaticText.new(self, 
                                          Wx::ID_ANY, 
                                          elem),
                       flag = Wx::EXPAND|Wx::ALIGN_LEFT)
          elemCtrl = Wx::TextCtrl.new(self, 
                                      Wx::ID_ANY, 
                                      value.to_s)
          tmpsizer.add(elemCtrl, flag = Wx::EXPAND|Wx::ALIGN_RIGHT)

          rubyname = elem.gsub(/ /, '')
          create_method( "@#{rubyname}=".to_sym ) { |val| 
            elemCtrl.set_value(val)
          }
          create_method( "#{rubyname}".to_sym ) { 
            elemCtrl.get_value
          }
          @sizer.add(tmpsizer)
        end
        @sizer.set_size_hints(self)
      end
    end
  end
end
