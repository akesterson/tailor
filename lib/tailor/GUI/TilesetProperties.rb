require 'wx'

module Tailor
  module GUI
    class TilesetProperties < Wx::Panel
      def initialize(parent = nil, 
                     id = Wx::ID_ANY, 
                     pos = Wx::DEFAULT_POSITION, 
                     size = Wx::DEFAULT_SIZE, 
                     style = Wx::TAB_TRAVERSAL, 
                     name = "TilesetProperties")
        super(parent, id, pos, size, style, name)
        values = {
          "Tile X"  => 32,
          "Tile Y"  => 32,
          "Pad X"   => 0,
          "Pad Y"   => 0,
          "Space X" => 0,
          "Space Y" => 0
        }
        @sizer = Wx::BoxSizer.new(Wx::VERTICAL)
        values.each_pair do |elem, value|
          tmpsizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
          Wx::StaticText.new(tmpsizer, Wx::ID_ANY, elem)
          self.send(elem.gsub(/ /, ''), Wx::TextCtrl.new(tmpsizer, Wx::ID_ANY, value.to_s))
          @sizer.add(tmpsizer)
        end
      end
    end
  end
end
