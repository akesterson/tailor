[![Stories in Ready](https://badge.waffle.io/akesterson/tailor.png?label=ready&title=Ready)](https://waffle.io/akesterson/tailor)
tailor
==========

tailor is a tool for stitching small individual images (or regions thereof) together into tilemaps

Status
======

Tailor is currently in pre-alpha. It currently performs some of its functions (tileset import, slicing, image exporting, library and project management) but the actual combining of individual tiles into new tilesets does not yet work.

I expect to release 1.0 in a few weeks.

Installing & Running
====================

This depends on [rvpacker](https://github.com/akesterson/rvpacker) and [wxruby](http://wxruby.rubyforge.org/wiki/wiki.pl), and is built with rake/bundler.

    cd tailor
    bundle install
    rake build
    gem install ./pkg/tailor*gem
    tailor
