require 'wx'

module Tailor
  module GUI
 
    class TilesetPropertiesChangedEvent < Wx::CommandEvent
      attr_accessor :padX
      attr_accessor :padY
      attr_accessor :pitchX
      attr_accessor :pitchY
      attr_accessor :gridX
      attr_accessor :gridY

      def initialize(*args)
        super(*args)
        @padX = args[2]['padX']
        @padY = args[2]['padY']
        @pitchX = args[2]['pitchX']
        @pitchY = args[2]['pitchY']
        @gridX = args[2]['gridX']
        @gridY = args[2]['gridY']
      end

      def clone
        TilesetPropertiesChangedEvent.new(self.id,
                                          self.eventType,
                                          { 'padX' => @padX,
                                            'padY' => @padY,
                                            'pitchX' => @pitchX,
                                            'pitchY' => @pitchY,
                                            'gridX' => @gridX,
                                            'gridY' => @gridY }
                                          )
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
                                      value.to_s)
          evt_text(elemCtrl) { |event| on_textChanged(event) }
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

      def on_textChanged(event)
        add_pending_event(TilesetPropertiesChangedEvent.new(Wx::ID_ANY,
                                                            EVT_TILEPROPS_CHANGED,
                                                            { 'PadX' => @TileX,
                                                              'PadY' => @TileY,
                                                              'PitchX' => @SpaceX,
                                                              'PitchY' => @SpaceY,
                                                              'GridX' => @TileX,
                                                              'GridY' => @TileY }
                                                            )
                          )
      end
    end

    EVT_TILEPROPS_CHANGED = Wx::Event.new_event_type
    Wx::EvtHandler.register_class(TilesetPropertiesChangedEvent,
                                  EVT_TILEPROPS_CHANGED,
                                  "evt_tileprops_changed", 
                                  1)
  end
end
