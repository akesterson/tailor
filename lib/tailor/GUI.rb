require 'wx'

module Tailor
  module GUI
    class Application < Wx::App
      def on_init
        MainWindow.new
      end
    end

    class MainWindow < Wx::Frame
      def initialize()
        super(nil, -1, 'Tailor')
        @mainpanel = Wx::Panel.new(self)
        @close_button = Wx::Button.new(@mainpanel, -1, 'Quit')
        evt_button(@close_button.get_id()) { |event| close_button_clicked(event) }
        @mainpanel_sizer = Wx::BoxSizer.new(Wx::VERTICAL)
        @mainpanel.set_sizer(@mainpanel_sizer)
        @mainpanel_sizer.add(@close_button, 0, Wx::GROW|Wx::ALL, 2)
        @button1 = Wx::Button.new(@mainpanel, -1, 'Button 1')
        @button2 = Wx::Button.new(@mainpanel, -1, 'Button 2')
        @button3 = Wx::Button.new(@mainpanel, -1, 'Button 3')
        @mainpanel_sizer.add(@Button1, -1, Wx::GROW|Wx::ALL, 2)
        @mainpanel_sizer.add(@Button2, -1, Wx::GROW|Wx::ALL, 2)
        @mainpanel_sizer.add(@Button3, -1, Wx::GROW|Wx::ALL, 2)
        
        show()
      end

      def close_button_clicked(event)
        puts "I don't do anything, but good on you for using a mouse"
      end

    end
  end
end
