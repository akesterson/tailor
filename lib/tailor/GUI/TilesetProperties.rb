require 'wx'

module Tailor
  module GUI
 
    class TilesetPropertiesChangedEvent < Wx::CommandEvent
      EVT_TILEPROPS_CHANGED = Wx::EvtHandler.register_class(self,
                                                            nil,
                                                            "evt_tileprops_changed", 
                                                            1)
      def initialize(source)
        super(EVT_TILEPROPS_CHANGED)
        self.id = source.get_id
      end

    end

    class TilesetProperties < Wx::Panel
      def create_method( name, &block )
        self.class.send( :define_method, name, &block )
      end

      def set_tileset(tileset)
        @tileset = tileset
        self.tile_x = @tileset.tile_x
        self.tile_y = @tileset.tile_y
        self.pad_x = @tileset.pad_x
        self.pad_y = @tileset.pad_y
        self.space_x = @tileset.space_x
        self.space_y = @tileset.space_y
        refresh
      end

      def initialize(*args)
        super(*args)
        @tileset = nil
        values = {
          "Tile X"  => 0,
          "Tile Y"  => 0,
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
                                      value.to_s,
                                      :style => Wx::TE_PROCESS_ENTER)
          evt_text_enter(elemCtrl) { |event| on_textChanged(event) }
          tmpsizer.add(elemCtrl, flag = Wx::EXPAND|Wx::ALIGN_RIGHT)

          rubyname = elem.gsub(/ /, '_').downcase
          create_method( "#{rubyname}=".to_sym ) { |val| 
            if val.instance_of?(Integer) or val.instance_of?(Fixnum)
              elemCtrl.set_value(val.to_s)
            else
              elemCtrl.set_value(val)
            end
          }
          create_method( "#{rubyname}".to_sym ) { 
            elemCtrl.get_value.to_i
          }
          @sizer.add(tmpsizer)
        end
        @sizer.set_size_hints(self)
      end

      def on_textChanged(event)
        return if @tileset.nil?
        @tileset.tile_x = self.tile_x
        @tileset.tile_y = self.tile_y
        @tileset.space_x = self.space_x
        @tileset.space_y = self.space_y
        @tileset.pad_x = self.pad_x
        @tileset.pad_y = self.pad_y

        evt = TilesetPropertiesChangedEvent.new(self)
        event_handler.process_event(evt)
      end
    end

  end
end
