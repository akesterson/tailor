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

    def initialize
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
      @tiles = []
    end

    def add_tile(name, image)
      if image.instance_of?(Wx::Bitmap)
        image = Wx::Image.from_bitmap(image)
      elsif not image.instance_of?(Wx::Image)
        throw TypeError("Tailor::Tileset::add_tile only accepts Wx::Image or Wx::Bitmap")
        return
      end
      @tiles << {"name" => name, "image" => image}
    end

    def get_tile(elem)
      if elem.instance_of?(String)
        @tiles.each do
          if tile['name'] == elem
            return tile['image']
          end
        end
      elsif elem.instance_of?(Integer)
        return @tiles[elem]['image']
      end
    end

    def write(io_obj, callback = nil)
      obj = self.to_json(callback)
      if not callback.nil?
        callback.call("Saving JSON...", nil, '', 0)
      end
      io_obj.write(JSON.pretty_generate(obj))
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
      @tiles.each do |tile|
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
