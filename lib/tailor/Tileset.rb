require 'wx'
require 'json'
require 'base64'
require 'stringio'

module Tailor
  class Tileset
    attr_accessor :image
    attr_accessor :license
    attr_accessor :notes
    attr_accessor :tileset_name
    attr_accessor :tile_x
    attr_accessor :tile_y
    attr_accessor :space_x
    attr_accessor :space_y
    attr_accessor :pad_x
    attr_accessor :pad_y
    attr_accessor :tiles

    def initialize
      @filename = ''
      self.image = nil
      self.license = ''
      self.notes = ''
      self.tileset_name = ''
      self.tile_x = 32
      self.tile_y = 32
      self.space_x = 0
      self.space_y = 0
      self.pad_x = 0
      self.pad_y = 0
      self.tiles = []
    end
    
    def add_tile(name, image)
      if image.instance_of?(Wx::Bitmap)
        image = Wx::Image.from_bitmap(image)
      elsif not image.instance_of?(Wx::Image)
        throw TypeError("Tailor::Tileset::add_tile only accepts Wx::Image or Wx::Bitmap")
        return
      end
      self.tiles << {"name" => name, "image" => image}
    end
    
    def get_tile(elem)
      if elem.instance_of?(String)
        self.tiles.each do
          if tile['name'] == elem
            return tile['image']
          end
        end
      elsif elem.instance_of?(Integer)
        if elem <= self.tiles.size
          return self.tiles[elem]['image']
        end
      end
    end

    def get_filename
      puts @filename
      return @filename
    end

    def write(io_obj, callback = nil)
      obj = self.to_json(callback)
      if not callback.nil?
        callback.call("Saving JSON...", nil, '', 0)
      end
      io_obj.write(JSON.pretty_generate(obj))
    end

    def to_file(filename)
      @filename = filename
      File.open(filename, "w") do |file|
        write(file)
      end
    end

    def from_file(filename)
      @filename = filename
      File.open(filename, "r") do |file|
        from_json(JSON.parse(file.read))
      end
    end

    def from_json(js)
      self.tileset_name = js['name']
      self.license = js['license']
      self.notes = js['notes']
      self.tile_x = js['dimensions']['tile_x']
      self.tile_y = js['dimensions']['tile_y']
      self.space_x = js['dimensions']['space_x']
      self.space_y = js['dimensions']['space_y']
      self.pad_x = js['dimensions']['pad_x']
      self.pad_y = js['dimensions']['pad_y']
      StringIO.open do |iostream|
        iostream.write(Base64.decode64(js['image']))
        iostream.rewind
        self.image = Wx::Image.read(iostream, Wx::BITMAP_TYPE_PNG)
      end
      self.tiles = []
      js['tiles'].each do |tile|
        StringIO.open do |iostream|
          iostream.write(Base64.decode64(tile['image']))
          iostream.rewind
          self.tiles << {
            'name' => tile['name'], 
            'image' => Wx::Image.read(iostream, Wx::BITMAP_TYPE_PNG)
          }
        end
      end
    end
    
    def to_json(callback = nil)
      obj = {
        "name" => self.tileset_name,
        "license" => self.license,
        "notes" => self.notes,
        "dimensions" => {
          "tile_x" => self.tile_x,
          "tile_y" => self.tile_y,
          "space_x" => self.space_x,
          "space_y" => self.space_y,
          "pad_x" => self.pad_x,
          "pad_y" => self.pad_y
        },
        "image" => "",
        "tiles" => []
      }
      
      StringIO.open do |iostream|
        if self.image.nil?
          obj['image']=nil
        else
          self.image.write(iostream, Wx::BITMAP_TYPE_PNG)
          iostream.rewind
          obj['image'] = Base64.encode64(iostream.read)
        end
      end

      idx = 0
      self.tiles.each do |tile|
        StringIO.open do |iostream|
          if not callback.nil?
            callback.call("Converting to base64", tile['image'], tile['name'], idx)
          end
          tile['image'].write(iostream, Wx::BITMAP_TYPE_PNG)
          iostream.rewind
          data = {
            "name" => tile['name'],
            "image" => Base64.encode64(iostream.read)
          }
          obj['tiles'] << data
        end
        idx += 1
      end
      
      obj
    end
    
  end
end
