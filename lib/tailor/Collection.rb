require 'singleton'

module Tailor
  module Collection
    include Singleton

    attr_accessor :library

    def initialize
      @metadata = {
        "author": "",
        "name": "",
        "license": ""
        }
      self.library = Tailor::Library.new
      @pages = {}
    end

    def to_json
      js = { 
        "metadata" => metadata,
        "library" => {},
        "pages" => {}
      }

      @library.each do |tileset|
        js['library'][tileset['name']] = tileset.get_filename
      end
      @pages.each do |page|
        js['pages'][page.page_name] = page.to_json
      end
    end
    
    def save_json(filename)
      dname = File.dirname(filename)
      Dir.mkdir(dname) unless Dir.exist?(dname)

      File.open(filename, "w") do |file|
        file.write(JSON.pretty_generate(to_json))
      end
    end

    def from_json(js)
      js['library'].each_pair do |name, filename|
        @library.load_tileset(filename)
      end
      js['pages'].each_pair do |name, data|
        @pages[name] = Tailor::Page.new
        @pages[name].from_json(data)
      end
    end

    def load_json(filename)
      dname = File.dirname(filename)
      Dir.mkdir(dname) unless Dir.exist?(dname)
      File.open(filename, "r") do |file|
        js = JSON.parse(file.read)
      end
      from_json(js)
    end

  end
end
