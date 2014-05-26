require 'Tailor/Tileset'
require 'singleton'

module Tailor
  class Library
    include Singleton
    
    attr_accessor :tilesets

    def initialize
      self.tilesets = []
    end

    def tileset_names
      x = []
      idx = 0
      self.tilesets.each do |tileset|
        x << [idx, tileset.tileset_name]
        idx += 1
      end
    end

    def unload_tileset(tileset)
      self.tilesets.delete(tileset)
    end

    def add_tileset(path)
      ts = Tailor::Tileset.new
      ts.from_json(JSON.parse(File.read(path)))
      self.tilesets << ts
    end

  end
end
