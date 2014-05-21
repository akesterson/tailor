require "tailor/version"
require "tailor/GUI"

class SuperProxy
  def initialize(obj)
    @obj = obj
  end

  def method_missing(meth, *args, &blk)
    @obj.class.superclass.instance_method(meth).bind(@obj).call(*args, &blk)
  end
end

class Object
  private
  def _super
    SuperProxy.new(self)
  end
end

module Tailor
  # Your code goes here...
end
