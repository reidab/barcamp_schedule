root=Dir.pwd + '/public'
puts ">>> Serving: #{root}"
run Rack::Static.new("#{root}")