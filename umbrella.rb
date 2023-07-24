require "http"
require "json"
require "pry-byebug"
require "ascii_charts"

gmaps_key = ENV.fetch("GMAPS_KEY")
pirate_weather_key = ENV.fetch("PIRATE_WEATHER_KEY")

puts "Will you need an umbrella today?"

location_result = []

#Ask the user for their location. (Recall gets.)
while location_result == []
  puts "Enter your location:"

  #Get and store the user’s location.
  location = gets.chomp

  if location == "exit"
    break
  else
    puts "Checking the weather at #{location}..."

    #Get the user’s latitude and longitude from the Google Maps API.
    maps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{location.gsub(" ", "%20")}&key=#{gmaps_key}"

    raw_maps_response = HTTP.get(maps_url)

    parsed_maps_response = JSON.parse(raw_maps_response)

    if parsed_maps_response.fetch("results") == []
      puts "Location not found"
    else
      location_result = parsed_maps_response.fetch("results")

      user_lat = location_result[0].fetch("geometry").fetch("location").fetch("lat")

      user_lng = location_result[0].fetch("geometry").fetch("location").fetch("lng")

      pp "Your coordinates are #{user_lat}, #{user_lng}."

      #Get the weather at the user’s coordinates from the Pirate Weather API.
      pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_key}/#{user_lat},#{user_lng}"

      raw_pirate_weather_response = HTTP.get(pirate_weather_url)

      parsed_pirate_weather_response = JSON.parse(raw_pirate_weather_response)

      currently_hash = parsed_pirate_weather_response.fetch("currently")

      currently_temp_F = currently_hash.fetch("temperature")

      currently_temp_C = (currently_temp_F - 32) * 5/9

      hourly_hash = parsed_pirate_weather_response.fetch("hourly")

      hourly_summary = hourly_hash.fetch("summary")

      #Display the current temperature and summary of the weather for the next hour.
      puts "It is currently #{currently_temp_F.round(0)}°F (#{currently_temp_C.round(0)}°C)"

      puts "#{hourly_summary} for the next hour."

      #If you get that far, then stretch further:
      #For each of the next twelve hours, check if the precipitation probability is greater than 10%.
      #If so, print a message saying how many hours from now and what the precipitation probability is.
      #If any of the next twelve hours has a precipitation probability greater than 10%, print “You might want to carry an umbrella!”
      #If not, print “You probably won’t need an umbrella today.”

      precip_threshold = 0.10

      any_precipitation = false

      next_twelve_hours = hourly_hash.fetch("data")[1..12]

      next_twelve_hours_precip_probability_array = []

      hour = 1

      next_twelve_hours.each do |next_twelve_hours_hash|

        hour_precip_probability = next_twelve_hours_hash.fetch("precipProbability")

        next_twelve_hours_precip_probability_array.push([hour, (hour_precip_probability*100).round.to_i])

        if hour_precip_probability >= precip_threshold
          any_precipitation = true

          # seconds_from_now = precip_time - Time.now
          
          # hours_from_now = seconds_from_now / 60 / 60
        end
        hour += 1
      end

      puts "Hours from now vs Precipitation probability"
      
      puts AsciiCharts::Cartesian.new(next_twelve_hours_precip_probability_array, :bar => true, :hide_zero => true).draw

      if any_precipitation
        puts "You might want to take an umbrella!"
      else
        puts "You probably won’t need an umbrella today."
      end
    end
  end
end
