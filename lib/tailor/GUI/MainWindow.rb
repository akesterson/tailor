require 'wx'
require 'Tailor/version'
require 'Tailor/Collection'
require 'Tailor/GUI/TilesetProperties'
require 'tailor/GUI/TilesetEditor'
require 'tailor/GUI/LibraryManager'

module Tailor
  module GUI
    class MainWindow < Wx::Frame
      def initialize()
        super(nil, -1, 'Tailor')
        @collection = Tailor::Collection.instance
        @mainPanel = nil
        init_menubar()        
        show()
      end

      def init_menubar
        @menuBar = Wx::MenuBar.new
        @menuFile = Wx::Menu.new
        menuFileNew = @menuFile.append(Wx::ID_ANY, "&New\tAlt-N", "New Compilation")
        menuFileOpen = @menuFile.append(Wx::ID_ANY, "&Open\tAlt-O", "Open Compilation")
        @menuFileSave = @menuFile.append(Wx::ID_ANY, "&Save\tAlt-S", "Save Compilation")
        @menuFileSaveAs = @menuFile.append(Wx::ID_ANY, "Save As", "Save Compilation As...")
        @menuFileExport = @menuFile.append(Wx::ID_ANY, "&Export\tAlt-E", "Export Compilation")
        @menuFile.append_separator
        @menuFileClose = @menuFile.append(Wx::ID_ANY, "&Close\tAlt-W", "Close Compilation")
        @menuFile.append_separator
        menuFileExit = @menuFile.append(Wx::ID_EXIT, "E&xit\tAlt-X", "Exit Tailor")
        @menuBar.append(@menuFile, "&File")
        @menuLibrary = Wx::Menu.new
        @menuLibraryManager = @menuLibrary.append(Wx::ID_ANY, "&Manage\tAlt-M", "Library Manager")
        menuLibraryTileset = @menuLibrary.append(Wx::ID_ANY, "&Tileset Editor\tAlt-T", "Tileset Editor")
        @menuBar.append(@menuLibrary, "&Library")
        menuHelp = Wx::Menu.new
        menuHelpAbout = menuHelp.append(Wx::ID_ABOUT, "&About...\tF1", "About Tailor")
        @menuBar.append(menuHelp, "&Help")
        self.menu_bar = @menuBar

        evt_menu(menuFileNew, :on_file_new)
        evt_menu(menuLibraryTileset, :on_library_tileset)
        evt_menu(@menuLibraryManager, :on_library_manager)
        evt_menu(menuFileOpen, :on_file_open)
        evt_menu(@menuFileSave, :on_file_save)
        evt_menu(@menuFileSaveAs, :on_file_saveas)
        evt_menu(@menuFileExport, :on_file_export)
        evt_menu(@menuFileClose, :on_file_close)
        evt_menu(Wx::ID_EXIT, :on_file_exit)
        evt_menu(Wx::ID_ABOUT, :on_help_about)

        @menuFile.enable(@menuFileSave.get_id, false)
        @menuFile.enable(@menuFileSaveAs.get_id, false)
        @menuFile.enable(@menuFileExport.get_id, false)
        @menuFile.enable(@menuFileClose.get_id, false)
        @menuLibrary.enable(@menuLibraryManager.get_id, false)
      end

      def refresh_project
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

        @menuFile.enable(@menuFileSave.get_id, true)
        @menuFile.enable(@menuFileSaveAs.get_id, true)
        @menuFile.enable(@menuFileExport.get_id, true)
        @menuFile.enable(@menuFileClose.get_id, true)
        @menuLibrary.enable(@menuLibraryManager.get_id, true)
      end


      def on_file_new
        wildcards = "*.json"
        fd = Wx::FileDialog.new(self, "Select location for new collection",
                                :wildcard => wildcards,
                                :style => Wx::FD_OVERWRITE_PROMPT | Wx::FD_SAVE)
        if fd.show_modal == Wx::ID_OK
          @filename = fd.get_path
          on_file_close
          @collection.clear
          refresh_project
        end
      end

      def on_clickme(event)
        puts "I don't do anything"
      end

      def on_library_tileset
        Tailor::GUI::TilesetEditor.new(self, Wx::ID_ANY, 'Tailor :: Tileset').show
      end

      def on_library_manager
        Tailor::GUI::LibraryManager.new(self,
                                        Wx::ID_ANY, 
                                        'Tailor :: Library :: Manager').show
      end

      def on_file_open
        wildcards = "*.json"
        fd = Wx::FileDialog.new(self, "Select collection to load",
                                :wildcard => wildcards,
                                :style => Wx::FD_FILE_MUST_EXIST | Wx::FD_OPEN)
        if fd.show_modal == Wx::ID_OK
          on_file_close
          @filename = fd.get_path
          @collection.load_json(@filename)
          refresh_project
        end
      end

      def on_file_saveas
        wildcards = "*.json"
        fd = Wx::FileDialog.new(self, "Select save location",
                                :wildcard => wildcards)
        if fd.show_modal == Wx::ID_OK
          @filename = fd.get_path
          on_file_save
        end
      end

      def on_file_save
        @collection.save_json(@filename)
        @has_saved = true
      end

      def on_file_export
      end

      def on_file_close
        @collection.clear
        @menuFile.enable(@menuFileSave.get_id, false)
        @menuFile.enable(@menuFileSaveAs.get_id, false)
        @menuFile.enable(@menuFileExport.get_id, false)
        @menuFile.enable(@menuFileClose.get_id, false)
        @menuLibrary.enable(@menuLibraryManager.get_id, false)
        if not @mainPanel.nil?
          @mainPanel.destroy
          @mainPanel = nil
        end
      end

      def on_help_about
        Wx::about_box( :name        => self.title,
                       :version     => Tailor::VERSION,
                       :description => (
                                        "Tailor : A program for stitching tilesets\n" + 
                                        "(C) 2014 Andrew Kesterson <andrew@aklabs.net>\n" +
                                        "" + 
                                        "Released under the MIT License\n" +
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
