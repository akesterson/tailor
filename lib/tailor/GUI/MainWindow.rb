require 'wx'
require 'Tailor/version'
require 'Tailor/GUI/TilesetProperties'

module Tailor
  module GUI
    class MainWindow < Wx::Frame
      def initialize()
        super(nil, -1, 'Tailor')
        init_menubar()        
        init_mainpanel()
        show()
      end

      def init_menubar
        @menuBar = Wx::MenuBar.new
        menuFile = Wx::Menu.new
        menuFileNew = menuFile.append(Wx::ID_ANY, "&New\tAlt-N", "New Compilation")
        menuFileOpen = menuFile.append(Wx::ID_ANY, "&Open\tAlt-O", "Open Compilation")
        menuFileSave = menuFile.append(Wx::ID_ANY, "&Save\tAlt-S", "Save Compilation")
        menuFileExport = menuFile.append(Wx::ID_ANY, "&Export\tAlt-E", "Export Compilation")
        menuFile.append_separator
        menuFileClose = menuFile.append(Wx::ID_ANY, "&Close\tAlt-W", "Close Compilation")
        menuFile.append_separator
        menuFileExit = menuFile.append(Wx::ID_EXIT, "E&xit\tAlt-X", "Exit Tailor")
        @menuBar.append(menuFile, "&File")
        menuHelp = Wx::Menu.new
        menuHelpAbout = menuHelp.append(Wx::ID_ABOUT, "&About...\tF1", "About Tailor")
        @menuBar.append(menuHelp, "&Help")
        self.menu_bar = @menuBar

        evt_menu(menuFileNew, :on_file_new)
        evt_menu(menuFileOpen, :on_file_open)
        evt_menu(menuFileSave, :on_file_save)
        evt_menu(menuFileExport, :on_file_export)
        evt_menu(menuFileClose, :on_file_close)
        evt_menu(Wx::ID_EXIT, :on_file_exit)
        evt_menu(Wx::ID_ABOUT, :on_help_about)
      end

      def init_mainpanel
        @mainPanel = Wx::Panel.new(self)
        @mainPanelSizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
      end

      def on_file_new
        @tilesetProperties = Tailor::GUI::TilesetProperties.new(@mainPanelSizer, Wx::ID_ANY)
      end

      def on_file_open
      end

      def on_file_save
      end

      def on_file_export
      end

      def on_file_close
      end

      def on_help_about
        Wx::about_box( :name        => self.title,
                       :version     => Tailor::VERSION,
                       :description => (
                                        "Tailor : A program for stitching tilesets\n" + 
                                        "Please file bugs at https://github.com/akesterson/tailor"
                                        )
                       )
      end

      def on_file_exit
        close
      end

    end
  end
end
