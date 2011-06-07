
start_time = Time.now
i_count = 100
i_count.times do |i|
  `convert test.jpg -resize '1024x768>' test-resized.jpg`
  puts i
end
end_time = Time.now
puts
puts "Time in agent_create with #{i_count} photos: #{end_time - start_time}"
