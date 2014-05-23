require 'tailor'
require 'Tailor/GUI/TilesetProperties'
require 'Tailor/GUI/TilesetDisplay'
require 'Tailor/GUI/GridDisplay'

module Tailor
  module GUI
    class TilesetEditor < Wx::Frame
      def initialize(*args)
        super(*args)
        @tilesetFilename = ""
        @tilesetImage = nil
        
        @panel = Wx::Panel.new(self)
        @sizer = Wx::BoxSizer.new(Wx::VERTICAL)

        rowsizer = Wx::BoxSizer.new(Wx::HORIZONTAL)

        tmpversizer = Wx::BoxSizer.new(Wx::VERTICAL)
        @tilesetProperties = Tailor::GUI::TilesetProperties.new(@panel, Wx::ID_ANY)
        evt_tileprops_changed(@tilesetProperties) { |event| on_tilepropsChanged(event) }
        tmpversizer.add(@tilesetProperties, 0, flag = Wx::EXPAND|Wx::ALL)
        @cancelBtn = Wx::Button.new(@panel, Wx::ID_ANY, "Cancel")
        evt_button(@cancelBtn.get_id()) { |event| on_CancelClicked(event) }
        @importBtn = Wx::Button.new(@panel, Wx::ID_ANY, "Import")
        evt_button(@importBtn.get_id()) { |event| on_ImportClicked(event) }

        @exportBtn = Wx::Button.new(@panel, Wx::ID_ANY, "Export")
        evt_button(@exportBtn.get_id()) { |event| on_ExportClicked(event) }

        @saveBtn = Wx::Button.new(@panel, Wx::ID_ANY, "Save")
        evt_button(@saveBtn.get_id()) { |event| on_SaveClicked(event) }

        tmpversizer.add_spacer(20)
        tmpversizer.add(@importBtn, 0, flag=Wx::EXPAND)
        tmpversizer.add_spacer(20)
        tmpversizer.add(@exportBtn, 0, flag=Wx::EXPAND)
        tmpversizer.add_spacer(20)
        tmpversizer.add(@saveBtn, 0, flag=Wx::EXPAND)
        tmpversizer.add_spacer(20)
        tmpversizer.add(@cancelBtn, 0, flag=Wx::EXPAND)
        rowsizer.add(tmpversizer, 0, flag = Wx::EXPAND|Wx::ALL)

        @tilesetSlicer = Tailor::GUI::GridDisplay.new(@panel, Wx::ID_ANY)
        @tilesetSlicer.set_min_size(Wx::Size.new(320, 240))
        rowsizer.add(@tilesetSlicer, 1, flag = Wx::EXPAND|Wx::ALL)

        tmpversizer = Wx::BoxSizer.new(Wx::VERTICAL)
        @tilesetNameCtrl = Wx::TextCtrl.new(@panel,
                                            Wx::ID_ANY,
                                            "Tileset Name")
        tmpversizer.add(@tilesetNameCtrl, 0, flag = Wx::EXPAND|Wx::ALIGN_TOP)
        @tileNameCtrl = Wx::TextCtrl.new(@panel,
                                            Wx::ID_ANY,
                                            "Tile Name")
        tmpversizer.add(@tileNameCtrl, 0, flag = Wx::EXPAND|Wx::ALIGN_TOP)
        @tilesetNotesCtrl = Wx::TextCtrl.new(@panel,
                                             Wx::ID_ANY,
                                             "Notes about this tileset",
                                             Wx::DEFAULT_POSITION,
                                             Wx::DEFAULT_SIZE,
                                             Wx::TE_MULTILINE|Wx::TE_WORDWRAP)
        @tilesetNotesCtrl.set_min_size(Wx::Size.new(200,120))
        tmpversizer.add(@tilesetNotesCtrl, 1, flag = Wx::EXPAND|Wx::ALL)
        @tilesetLicenseCtrl = Wx::TextCtrl.new(@panel,
                                               Wx::ID_ANY,
                                               "Legal License of this tileset",
                                               Wx::DEFAULT_POSITION,
                                               Wx::DEFAULT_SIZE,
                                               Wx::TE_MULTILINE|Wx::TE_WORDWRAP)
        @tilesetLicenseCtrl.set_min_size(Wx::Size.new(200,120))
        tmpversizer.add(@tilesetLicenseCtrl, 1, flag = Wx::EXPAND|Wx::ALL)

        rowsizer.add(tmpversizer, 0, flag=Wx::EXPAND)

        @sizer.add(rowsizer, 1, flag = Wx::EXPAND|Wx::ALL)

        @panel.set_sizer(@sizer)
        @sizer.set_size_hints(self)
        show()
      end

      def on_CancelClicked(event)
        close
      end

      def on_ImportClicked(event)
        wildcards = "*.png;*.bmp;*.tiff;*.gif"
        fd = Wx::FileDialog.new(self, "Select tileset to import",
                                :wildcard => wildcards,
                                :style => Wx::FD_FILE_MUST_EXIST | Wx::FD_PREVIEW )
        if fd.show_modal == Wx::ID_OK
          @tilesetFilename = fd.get_path
          refresh_image
        end
      end

      def on_ExportClicked(event)
      end

      def on_SaveClicked(event)
      end

      def on_tilepropsChanged(event)
        puts "Tileset properties changed : #{event.inspect} #{event.client_data}"
        @tilesetSlicer.set_grid(event.client_data['padX'],
                                event.client_data['padY'],
                                event.client_data['pitchX'],
                                event.client_data['pitchY'],
                                event.client_data['gridX'],
                                event.client_data['gridY']
                                )
      end

      def refresh_image
        begin
          @tilesetImage = Wx::Bitmap.new(@tilesetFilename)
          if @tilesetImage.is_ok
            @tilesetSlicer.set_image @tilesetImage
            # The + 20 here is a hack to make scroll bars go away where we don't want them
            x = ( @tilesetImage.get_width > 600 ? 600 : @tilesetImage.get_width + 20)
            y = ( @tilesetImage.get_height > 400 ? 400 : @tilesetImage.get_height + 20)
            @tilesetSlicer.set_min_size(Wx::Size.new(x, y))
            @sizer.set_size_hints(self)
          end
        rescue Exception => e
          puts e
        end
      end

    end
  end
end
