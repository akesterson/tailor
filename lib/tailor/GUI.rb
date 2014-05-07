require 'wx'
require 'tailor/GUI/MainWindow'
require 'tailor/GUI/TilesetEditor'

module Tailor
  module GUI
    class Application < Wx::App
      def on_init
        #Tailor::GUI::MainWindow.new
        Tailor::GUI::TilesetEditor.new(nil, -1, 'Tailor')
      end
    end
  end
end
