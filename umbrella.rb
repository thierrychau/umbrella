require "http"
require "json"
require "pry-byebug"

gmaps_key = ENV.fetch("GMAPS_KEY")
pirate_weather_key = ENV.fetch("PIRATE_WEATHER_KEY")

puts "Will you need an umbrella today?"

#Ask the user for their location. (Recall gets.)
location_result = []
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

      pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_key}/#{user_lat},#{user_lng}"
      raw_pirate_weather_response = HTTP.get(pirate_weather_url)
      parsed_pirate_weather_response = JSON.parse(raw_pirate_weather_response)
      user_temp_F = parsed_pirate_weather_response.fetch("currently").fetch("temperature")
      user_temp_C = (user_temp_F - 32) * 5/9
      puts "It is currently #{user_temp_F.round(0)}°F (#{user_temp_C.round(0)}°C)"
      user_rain = parsed_pirate_weather_response.fetch("hourly").fetch("data")[n].fetch()
      puts "Next hour: Possible light rain starting in #{} min."
    end
  end
end

#Get the weather at the user’s coordinates from the Pirate Weather API.

#Display the current temperature and summary of the weather for the next hour.
#If you get that far, then stretch further:

#For each of the next twelve hours, check if the precipitation probability is greater than 10%.
#If so, print a message saying how many hours from now and what the precipitation probability is.
#If any of the next twelve hours has a precipitation probability greater than 10%, print “You might want to carry an umbrella!”

#If not, print “You probably won’t need an umbrella today.”
