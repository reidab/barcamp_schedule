require 'rubygems'
require 'barcamp_data'
require 'haml'
require 'facets/file/write'

data = BarCampData.new
data.add_missing_keys

grid_engine = Haml::Engine.new(File.read('views/schedule_grid.haml'))
list_engine = Haml::Engine.new(File.read('views/session_list.haml'))

File.write('public/index.html',grid_engine.render(Object.new,{:days => data.days}))
File.write('public/sessions/index.html',list_engine.render(Object.new,{:days => data.days}))