require 'wx'
require 'tailor'
require 'Tailor/GUI/TilesetProperties'
require 'Tailor/GUI/TilesetDisplay'
require 'Tailor/GUI/GridDisplay'
require 'Tailor/Tileset'
module Tailor
  module GUI
    class TilesetEditor < Wx::Frame

      attr_accessor :has_saved
      attr_accessor :has_loaded

      def initialize(*args)
        super(*args)
        self.has_saved = false
        self.has_loaded = false
        @tilesetFilename = ""
        @tilesetImage = nil
        @tilesetNames = []
        @tileset = nil

        @panel = Wx::Panel.new(self)
        @sizer = Wx::BoxSizer.new(Wx::VERTICAL)

        rowsizer = Wx::BoxSizer.new(Wx::HORIZONTAL)

        tmpversizer = Wx::BoxSizer.new(Wx::VERTICAL)
        @tilesetProperties = Tailor::GUI::TilesetProperties.new(@panel, Wx::ID_ANY)
        evt_tileprops_changed(@tilesetProperties) { |event| on_tilepropsChanged(event) }
        tmpversizer.add(@tilesetProperties, 0, flag = Wx::EXPAND|Wx::ALL)
        @cancelBtn = Wx::Button.new(@panel, Wx::ID_ANY, "Close")
        evt_button(@cancelBtn.get_id()) { |event| on_CancelClicked(event) }
        @importBtn = Wx::Button.new(@panel, Wx::ID_ANY, "Import Image")
        evt_button(@importBtn.get_id()) { |event| on_ImportClicked(event) }

        @exportBtn = Wx::Button.new(@panel, Wx::ID_ANY, "Export Images")
        evt_button(@exportBtn.get_id()) { |event| on_ExportClicked(event) }

        @loadBtn = Wx::Button.new(@panel, Wx::ID_ANY, "Load JSON")
        evt_button(@loadBtn.get_id()) { |event| on_LoadClicked(event) }

        @saveBtn = Wx::Button.new(@panel, Wx::ID_ANY, "Save JSON")
        evt_button(@saveBtn.get_id()) { |event| on_SaveClicked(event) }

        tmpversizer.add_spacer(20)
        tmpversizer.add(@importBtn, 0, flag=Wx::EXPAND)
        tmpversizer.add_spacer(20)
        tmpversizer.add(@exportBtn, 0, flag=Wx::EXPAND)
        tmpversizer.add_spacer(20)
        tmpversizer.add(@loadBtn, 0, flag=Wx::EXPAND)
        tmpversizer.add_spacer(20)
        tmpversizer.add(@saveBtn, 0, flag=Wx::EXPAND)
        tmpversizer.add_spacer(20)
        tmpversizer.add(@cancelBtn, 0, flag=Wx::EXPAND)
        rowsizer.add(tmpversizer, 0, flag = Wx::EXPAND|Wx::ALL)

        @tilesetSlicer = Tailor::GUI::GridDisplay.new(@panel, 
                                                      Wx::ID_ANY,
                                                      Wx::DEFAULT_POSITION,
                                                      Wx::DEFAULT_SIZE,
                                                      Wx::VSCROLL | Wx::HSCROLL | Wx::ALWAYS_SHOW_SB)
        @tilesetSlicer.set_min_size(Wx::Size.new(320, 240))
        rowsizer.add(@tilesetSlicer, 1, flag = Wx::EXPAND|Wx::ALL)
        evt_griddisplay_selected(@tilesetSlicer) { |event| on_gridSelected(event) }

        tmpversizer = Wx::BoxSizer.new(Wx::VERTICAL)
        @tilesetNameCtrl = Wx::TextCtrl.new(@panel,
                                            Wx::ID_ANY,
                                            "Tileset Name")
        tmpversizer.add(@tilesetNameCtrl, 0, flag = Wx::EXPAND|Wx::ALIGN_TOP)
        evt_text(@tilesetNameCtrl) { |event| on_tilesetNameChanged(event) }

        @tileNameCtrl = Wx::TextCtrl.new(@panel,
                                            Wx::ID_ANY,
                                            "Tile Name")
        tmpversizer.add(@tileNameCtrl, 0, flag = Wx::EXPAND|Wx::ALIGN_TOP)
        evt_text(@tileNameCtrl) { |event| on_tileNameChanged(event) }

        @tilesetNotesCtrl = Wx::TextCtrl.new(@panel,
                                             Wx::ID_ANY,
                                             "Notes about this tileset",
                                             Wx::DEFAULT_POSITION,
                                             Wx::DEFAULT_SIZE,
                                             Wx::TE_MULTILINE|Wx::TE_WORDWRAP)
        evt_text(@tilesetNotesCtrl) { |event| on_tilesetNotesChanged(event) }
        @tilesetNotesCtrl.set_min_size(Wx::Size.new(200,120))
        tmpversizer.add(@tilesetNotesCtrl, 1, flag = Wx::EXPAND|Wx::ALL)
        @tilesetLicenseCtrl = Wx::TextCtrl.new(@panel,
                                               Wx::ID_ANY,
                                               "Legal License of this tileset",
                                               Wx::DEFAULT_POSITION,
                                               Wx::DEFAULT_SIZE,
                                               Wx::TE_MULTILINE|Wx::TE_WORDWRAP)
        evt_text(@tilesetLicenseCtrl) { |event| on_tilesetLicenseChanged(event) }
        @tilesetLicenseCtrl.set_min_size(Wx::Size.new(200,120))
        tmpversizer.add(@tilesetLicenseCtrl, 1, flag = Wx::EXPAND|Wx::ALL)

        rowsizer.add(tmpversizer, 0, flag=Wx::EXPAND)

        @sizer.add(rowsizer, 1, flag = Wx::EXPAND|Wx::ALL)

        @panel.set_sizer(@sizer)
        @sizer.set_size_hints(self)
      end

      def disable_load
        @loadBtn.disable
      end

      def disable_import
        @importBtn.disable
      end

      def on_CancelClicked(event)
        close
      end

      def on_ImportClicked(event)
        @tileset = Tailor::Tileset.new
        @tilesetSlicer.tileset = @tileset
        @tilesetProperties.set_tileset(@tileset)
        wildcards = "*.png;*.bmp;*.tiff;*.gif"
        fd = Wx::FileDialog.new(self, "Select tileset to import",
                                :wildcard => wildcards,
                                :style => Wx::FD_FILE_MUST_EXIST | Wx::FD_PREVIEW )
        if fd.show_modal == Wx::ID_OK
          @tilesetNames = []
          @tilesetImage = Wx::Image.new(fd.get_path)
          refresh_image
          (0..(@tilesetSlicer.get_size)).each do |i|
            @tilesetNames << "Tile #{i}"
          end
          @tileNameCtrl.disable
          self.has_saved = false
          self.has_loaded = true
        end
      end

      def on_gridSelected(event)
        @tileNameCtrl.enable
        @tileNameCtrl.set_value(@tilesetNames[event.client_data['index']])
      end

      def on_ExportClicked(event)
        dirfinder = Wx::DirDialog.new(self, message = "Choose an export folder")
        if dirfinder.show_modal == Wx::ID_OK
          progdialog = Wx::ProgressDialog.new("Exporting...", 
                                              "Exporting...",
                                              @tilesetSlicer.get_size - 1,
                                              self,
                                              style = Wx::PD_CAN_ABORT | Wx::PD_SMOOTH | Wx::PD_AUTO_HIDE)
          dirname = dirfinder.get_path
          tiles = @tilesetSlicer.get_tile_bitmaps
          (0..(tiles.size-1)).each do |i|
            tile = tiles[i]
            tileName = @tilesetNames[i]
            filename = File.join(dirname, tileName) + ".png"
            check = progdialog.update_and_check(i, "Exporting #{tileName} ... ")
 
            if not check[0]
              next
            elsif check[1]
              Wx::MessageDialog.new(self, 
                                    "Export operation aborted by user!", 
                                    style = Wx::ICON_EXCLAMATION).show_modal
              return
            end
            Wx::Image.from_bitmap(tile).save_file(filename)
          end
        end
                                      
      end

      def set_tileset(tileset)
        @tileset = tileset
        tileset_changed
        self.has_loaded = false
        self.has_saved = false
      end

      def tileset_changed
        # FIXME : This is redundant.
        @tileset.tiles.each do |tile|
          @tilesetNames << tile['name']
        end
        @tilesetImage = @tileset.image
        @tilesetNameCtrl.set_value(@tileset.tileset_name)
        @tilesetNotesCtrl.set_value(@tileset.notes)
        @tilesetLicenseCtrl.set_value(@tileset.license)
        @tileNameCtrl.disable
        @tilesetSlicer.tileset = @tileset
        @tilesetProperties.set_tileset(@tileset)
        refresh_image
        set_label("Tailor :: Tileset :: #{@tileset.tileset_name}")
      end
      
      def on_LoadClicked(event)
        @tileset = Tailor::Tileset.new
        wildcards = "*.json"
        fd = Wx::FileDialog.new(self, "Select tileset to load",
                                :wildcard => wildcards,
                                :style => Wx::FD_FILE_MUST_EXIST)
        if fd.show_modal == Wx::ID_OK
          @tileset.from_file(fd.get_path)
          tileset_changed
        end
        self.has_saved = false
        self.has_loaded = true
      end

      def on_SaveClicked(event)        
        wildcards = "*.json"
        fd = Wx::FileDialog.new(self, "Select tileset to import",
                                :wildcard => wildcards)
        if fd.show_modal == Wx::ID_OK
          filename = fd.get_path

          progdialog = Wx::ProgressDialog.new("Saving...", 
                                              "Saving...",
                                              @tilesetSlicer.get_size - 1,
                                              self,
                                              style = Wx::PD_SMOOTH | Wx::PD_AUTO_HIDE)
          tiles = @tilesetSlicer.get_tile_bitmaps
          (0..(tiles.size-1)).each do |i|
            @tileset.add_tile(@tilesetNames[i], tiles[i])
          end

          callback = Proc.new do |msg, tile, tileName, tileIndex|
            progdialog.update(tileIndex)
          end

          File.open(filename, "w") do |file|
            @tileset.write(file, callback)
          end
          self.has_saved = true
        end
      end

      def on_tilepropsChanged(event)
        return if @tilesetSlicer.get_size < 1
        self.has_saved = false
        ret = Wx::MessageDialog.new(self,
                                    "Changing tile properties will reset all tile names. Continue?",
                                    "WARNING").show_modal
        return if [Wx::ID_CANCEL, Wx::ID_NO].include?(ret)

        if @tileNameCtrl.is_enabled
          @tileNameCtrl.disable 
          @tileNameCtrl.set_value("")
        end

        @tilesetSlicer.refresh_grid
      end
      
      def on_tilesetNameChanged(event)
        @tileset.tileset_name = @tilesetNameCtrl.get_value
        self.has_saved = false
      end

      def on_tilesetLicenseChanged(event)
        @tileset.license = @tilesetLicenseCtrl.get_value
        self.has_saved = false
      end

      def on_tilesetNotesChanged(event)
        @tileset.notes = @tilesetNotesCtrl.get_value
        self.has_saved = false
      end

      def on_tileNameChanged(event)
        @tilesetNames[@tilesetSlicer.get_selected_index] = @tileNameCtrl.get_value
        self.has_saved = false
      end

      def refresh_image
        begin
          if @tilesetImage.is_ok
            @tilesetSlicer.set_image @tilesetImage
            @sizer.set_size_hints(self)
          end
        rescue Exception => e
          puts e
        end
      end

    end
  end
end
