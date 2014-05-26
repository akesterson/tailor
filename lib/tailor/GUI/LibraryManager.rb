require 'wx'
require 'Tailor/Collection'

module Tailor
  module GUI
    class LibraryManager < Wx::Frame
      def initialize(*args)
        super(*args)
        @library = Tailor::Collection.instance.library
        @tileset = nil
        @panel = Wx::Panel.new(self)
        @sizer = Wx::BoxSizer.new(Wx::VERTICAL)
        
        horizSizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
        vertSizer = Wx::BoxSizer.new(Wx::VERTICAL)
        @tilesetList = Wx::ListBox.new(@panel,
                                       Wx::ID_ANY,
                                       Wx::DEFAULT_POSITION,
                                       Wx::DEFAULT_SIZE,
                                       @library.tileset_names,
                                       Wx::LB_SORT | Wx::LB_SINGLE)
        vertSizer.add(@tilesetList, 0, flags = Wx::EXPAND|Wx::ALL)
        @addBtn = Wx::Button.new(@panel, Wx::ID_ANY, "Add Tileset")
        evt_button(@addBtn.get_id()) { |event| on_AddClicked(event) }        
        @removeBtn = Wx::Button.new(@panel, Wx::ID_ANY, "Remove Tileset")
        evt_button(@removeBtn.get_id()) { |event| on_RemoveClicked(event) }
        vertSizer.add(@addBtn, 1, flags = Wx::GROW)
        vertSizer.add(@removeBtn, 1, flags = Wx::GROW)
        horizSizer.add(vertSizer, 0, flags = Wx::EXPAND|Wx::ALL)
        @previewPane = Tailor::GUI::GridDisplay.new(@panel, 
                                                    Wx::ID_ANY,
                                                    Wx::DEFAULT_POSITION,
                                                    Wx::DEFAULT_SIZE,
                                                    Wx::VSCROLL | Wx::HSCROLL | Wx::ALWAYS_SHOW_SB)
        @previewPane.set_min_size(Wx::Size.new(320, 240))
        horizSizer.add(@previewPane, 1, flags=Wx::EXPAND|Wx::ALL)
        @sizer.add(horizSizer, 1, flag=Wx::EXPAND|Wx::ALL)
        @panel.set_sizer(@sizer)
        @sizer.set_size_hints(self)

        evt_listbox(@tilesetList) { |event| on_ListClicked(event) }
        evt_listbox_dclick(@tilesetList) { |event| on_ListDoubleClicked(event) }
        if @tilesetList.get_count > 0
          @tilesetList.set_selection(0)
          on_ListClicked(nil)
        end
        show()
      end

      def on_AddClicked(event)
        wildcards = "*.json"
        fd = Wx::FileDialog.new(self, "Select tileset to load",
                                :wildcard => wildcards,
                                :style => Wx::FD_FILE_MUST_EXIST)
        if fd.show_modal == Wx::ID_OK
          @tileset = @library.load_tileset(fd.get_path)
          idx = @tilesetList.append(@tileset.tileset_name)
          @tilesetList.set_selection(idx)
          refresh_image
        end
        refresh
      end

      def on_RemoveClicked(event)
        idx = @tilesetList.get_selection
        name = @tilesetList.get_string_selection
        @library.delete(name)
        @tilesetList.deselect(idx)
        @tilesetList.delete(idx)
        if @tilesetList.get_count > 0 
          @tilesetList.set_selection(0)
          on_ListClicked(nil)
        else
          @previewPane.hide
        end
      end

      def on_ListDoubleClicked(event)
        @tileset = @library.by_name(@tilesetList.get_string_selection)
        editor = Tailor::GUI::TilesetEditor.new(self, Wx::ID_ANY)
        editor.set_tileset(@tileset)
        editor.disable_load
        editor.disable_import
        editor.show
        if (editor.has_saved and (not editor.has_loaded))
          on_RemoveClicked
          idx = @tilesetList.append(@tileset.tileset_name)
          @tilesetList.set_selection(idx)
          on_ListClicked
        end
      end

      def on_ListClicked(event)
        @tileset = @library.by_name(@tilesetList.get_string_selection)
        refresh_image
      end

      def refresh_image
        @previewPane.set_tileset(@tileset)
        @previewPane.show
      end

    end
  end
end
