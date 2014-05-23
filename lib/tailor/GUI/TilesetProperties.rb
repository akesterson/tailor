require 'wx'

module Tailor
  module GUI
 
    class TilesetPropertiesChangedEvent < Wx::CommandEvent
      EVT_TILEPROPS_CHANGED = Wx::EvtHandler.register_class(self,
                                                            nil,
                                                            "evt_tileprops_changed", 
                                                            1)
      def initialize(source, grid)
        super(EVT_TILEPROPS_CHANGED)
        self.id = source.get_id
        self.client_data = grid
      end

    end

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
                                      value.to_s,
                                      :style => Wx::TE_PROCESS_ENTER)
          evt_text_enter(elemCtrl) { |event| on_textChanged(event) }
          tmpsizer.add(elemCtrl, flag = Wx::EXPAND|Wx::ALIGN_RIGHT)

          rubyname = elem.gsub(/ /, '')
          create_method( "@#{rubyname}=".to_sym ) { |val| 
            elemCtrl.set_value(val)
          }
          create_method( "#{rubyname}".to_sym ) { 
            elemCtrl.get_value.to_i
          }
          @sizer.add(tmpsizer)
        end
        @sizer.set_size_hints(self)
      end

      def on_textChanged(event)
        grid = { 'gridX' => self.TileX,
          'gridY' => self.TileY,
          'pitchX' => self.SpaceX,
          'pitchY' => self.SpaceY,
          'padX' => self.PadX,
          'padY' => self.PadY }
        evt = TilesetPropertiesChangedEvent.new(self, grid)
        event_handler.process_event(evt)
      end
    end

  end
end
