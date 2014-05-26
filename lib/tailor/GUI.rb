require 'wx'
require 'tailor/GUI/MainWindow'
require 'tailor/Library'

module Tailor
  module GUI
    class Application < Wx::App
      def on_init
        Tailor::GUI::MainWindow.new
      end
    end
  end
end
