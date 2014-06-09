require 'Tailor/Tileset'

module Tailor
  class Library
    
    def initialize
      @tilesets = []
    end

    def tileset_names
      x = []
      idx = 0
      @tilesets.each do |tileset|
        x << tileset.tileset_name
        idx += 1
      end
      x
    end

    def each
      @tilesets.each do |tileset|
        yield tileset
      end
    end

    def count
      @tilesets.size
    end

    def tile_count
      count = 0
      @tilesets.each do |ts|
        count += ts.count
      end
      count
    end

    def delete(tileset)
      if tileset.instance_of?(String)
        @tilesets.delete(by_name(tileset))
      end
      @tilesets.delete(tileset)
    end

    def add_tileset(tileset)
      @tilesets << tileset if tileset.instance_of?(Tailor::Tileset)
    end

    def load_tileset(path)
      ts = Tailor::Tileset.new
      ts.from_file(path)
      @tilesets << ts
      return ts
    end

    def by_name(name)
      @tilesets.each do |ts|
        return ts if ts.tileset_name == name
      end
    end

    def by_index(idx)
      return @tilesets[idx]
    end

  end
end
