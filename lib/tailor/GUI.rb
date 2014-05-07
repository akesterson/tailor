require 'wx'
require 'tailor/GUI/MainWindow'

module Tailor
  module GUI
    class Application < Wx::App
      def on_init
        Tailor::GUI::MainWindow.new
      end
    end
  end
end
