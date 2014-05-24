require 'wx'
require 'Tailor/version'
require 'Tailor/GUI/TilesetProperties'
require 'tailor/GUI/TilesetEditor'

module Tailor
  module GUI
    class MainWindow < Wx::Frame
      def initialize()
        super(nil, -1, 'Tailor')
        init_menubar()        
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
        menuEdit = Wx::Menu.new
        menuEditTileset = menuEdit.append(Wx::ID_ANY, "&Tileset\tAlt-T", "Edit Tileset")
        @menuBar.append(menuEdit, "&Edit")
        menuHelp = Wx::Menu.new
        menuHelpAbout = menuHelp.append(Wx::ID_ABOUT, "&About...\tF1", "About Tailor")
        @menuBar.append(menuHelp, "&Help")
        self.menu_bar = @menuBar

        evt_menu(menuFileNew, :on_file_new)
        evt_menu(menuEditTileset, :on_edit_tileset)
        evt_menu(menuFileOpen, :on_file_open)
        evt_menu(menuFileSave, :on_file_save)
        evt_menu(menuFileExport, :on_file_export)
        evt_menu(menuFileClose, :on_file_close)
        evt_menu(Wx::ID_EXIT, :on_file_exit)
        evt_menu(Wx::ID_ABOUT, :on_help_about)
      end

      def on_file_new
        @mainPanel = Wx::Panel.new(self)
        @mainPanelSizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
        @mainPanel.set_sizer(@mainPanelSizer)
        @tilesetProperties = Tailor::GUI::TilesetProperties.new(@mainPanel, Wx::ID_ANY)
        @mainPanelSizer.add(@tilesetProperties)
        button = Wx::Button.new(@mainPanel, Wx::ID_ANY, "Open Tileset Editor")
        evt_button(button.get_id()) { |event| on_clickme(event) }
        @mainPanelSizer.add(button, 0, Wx::EXPAND|Wx::ALL, 2)
        @mainPanelSizer.set_size_hints(@mainPanel)
        @mainPanelSizer.set_size_hints(self)
      end

      def on_clickme(event)
        puts "I don't do anything"
      end

      def on_edit_tileset
        Tailor::GUI::TilesetEditor.new(self, Wx::ID_ANY, 'Tailor')
      end

      def on_file_open
      end

      def on_file_save
      end

      def on_file_export
      end

      def on_file_close
        @mainPanel.destroy
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
