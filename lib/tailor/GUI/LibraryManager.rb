require 'wx'
require 'Tailor/Library'

module Tailor
  module GUI
    class LibraryManager
      def initialize(*args)
        super(*args)
        @library = Tailor::Library.instance
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
        horizSizer.add(vertSizer, 0, flags = Wx::EXPAND|Wx::ALL)
        @sizer.add(horizSizer, 1, flag=Wx::EXPAND|Wx::ALL)
        @panel.set_sizer(@sizer)
        @sizer.set_size_hints(self)
        show()
      end
    end
  end
end
