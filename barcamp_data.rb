require 'google_spreadsheet'
require 'facets/enumerable/mash'
require 'facets/to_hash'
require 'facets/kernel/ergo'
require 'facets/dictionary'

class BarCampData
  
  GOOGLE_LOGIN = 'barcamp@reidbeels.com'
  GOOGLE_PASSWORD = 'nomnomnom'
  SPREADSHEET_KEY = 'rm-yYix4xAxq7hQbOd-R-Rg'

  ID_REGEX = /\[id:([^\]]{3})\]/
  ID_CHARACTERS = [('a'..'z'),('0'..'9')].map{|i| i.to_a}.flatten
  
  attr_reader :days
  
  def initialize
    @gs = GoogleSpreadsheet.login(GOOGLE_LOGIN, GOOGLE_PASSWORD).spreadsheet_by_key(SPREADSHEET_KEY)
    
    @days = Dictionary[
      *@gs.worksheets.map { |sheet| 
        [ sheet.title, 
          Dictionary[
            *sheet.rows[1..-1].map { |time| 
              [ time[0],
                Dictionary[
                  *(sheet.rows[0][1..-1].zip(time[1..-1].map{ |session| 
                    { 
                      :description => session.gsub(ID_REGEX,'').strip, 
                      :key => session[ID_REGEX, 1]
                    }
                  }).flatten)
                ]
            ]}.flatten
          ] ]
      }.flatten
    ]
  end
  
  def add_missing_keys
    session_keys = @days.values.map{|times| times.values.map{|rooms| rooms.values.map{|session| session[:key]}}}.flatten.compact

    @days.each do |day,times|
      worksheet = @gs.worksheets.select{|w| w.title == day}.first
      data_changed = false
      times.each do |time,rooms|
        rooms.each do |room,session|
          if !session[:description].empty? && session[:key].nil?
            data_changed = true
            time_row = times.keys.index(time)+2
            room_column = rooms.keys.index(room)+2
            key = false

            until key && !session_keys.include?(key)
              key = (1..3).map{ ID_CHARACTERS[rand(ID_CHARACTERS.length)]  }.to_s
            end

            session_keys << session[:key] = key

            if worksheet && time_row && room_column && key
              worksheet[time_row,room_column] = "#{session[:description]} [id:#{key}]"
            end
          end
        end
      end
      worksheet.save if data_changed
    end
  end
  
end
