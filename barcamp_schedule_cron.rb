require 'rubygems'
require 'barcamp_data'
require 'haml'
require 'facets/file/write'

class BarCampContext
  def wiki_link(key,text='notes')
    key.downcase!
    @wiki_index ||= File.read('public/notes/data/index/page.idx').split("\n")
    "<a href='/notes/#{key}' class='notes#{@wiki_index.include?(key) ? ' exists' : ''}'>#{text}</a>"
  end
end

data = BarCampData.new
data.add_missing_keys

grid_engine = Haml::Engine.new(File.read('views/schedule_grid.haml'))
list_engine = Haml::Engine.new(File.read('views/session_list.haml'))
chat_engine = Haml::Engine.new(File.read('views/chat.haml'))

File.write('public/index.html',grid_engine.render(BarCampContext.new,{:days => data.days}))
File.write('public/sessions/index.html',list_engine.render(BarCampContext.new,{:days => data.days}))
File.write('public/chat/index.html',chat_engine.render(Object.new,{:days => data.days}))