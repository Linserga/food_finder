require 'restaurant'

class Guide
	class Config
		@@actions = ['list', 'find', 'add', 'quit']

		def self.actions; @@actions; end
	end
	def initialize(path = nil)
		# locate the restaurant text file at path
		Restaurant.filepath = path
		if Restaurant.file_usable?
			puts "Found restaurant file"
		# or create a new file
		elsif Restaurant.create_file
			puts "Created restaurant file"
		# exit if create fails
		else
			puts "Exiting.\n\n"
			exit!
		end		
	end

	def launch!
		introduction
		# action loop
		result = nil
		until result == :quit
			action, args = get_action
			result = do_action(action, args)
		end
		conclusion
	end

	def get_action
		action = nil
		# Keep asking for user input until we get a valid action
		until Guide::Config.actions.include?(action)
			puts "Actions: " + Guide::Config.actions.join(', ') if action
			print "> "
			user_response = gets.chomp
			args = user_response.downcase.strip.split(' ')
			action = args.shift
		end
		return [action, args]
	end

	def do_action(action, args=[])
		case action
			when 'list' then list(args)
			when 'find' then 
				keyword = args.shift
				find(keyword)
			when 'add'  then add
			when 'quit' then return :quit
		else puts "\n I don't understand that command.\n"
		end
	end

	def add
		
		puts "\nAdd a restaurant\n\n".upcase
		
		
		restaurant = Restaurant.build_using_questions

		if restaurant.save
			puts "\nRestaurant added"
		else
			puts "\nSave Error: Restaurant not added"
		end
	end

	def list(args=[])
		puts "\nListing restaurants\n\n".upcase
		sort_order = args.shift
		sort_order = args.shift if sort_order == 'by'
		sort_order = 'name' unless ['name', 'cuisine', 'price'].include?(sort_order)


		restaurants = Restaurant.saved_restaurants
		restaurants.sort! do |r1, r2|
			case sort_order
			when 'name'    then r1.name.downcase <=> r2.name.downcase
			when 'cuisine' then r1.cuisine.downcase <=> r2.cuisine.downcase
			when 'price'   then r1.price.to_i <=> r2.price.to_i
			end
		end

		restaurants.each do |restaurant|
			puts restaurant.name + " | " + restaurant.cuisine + " | " + restaurant.price 
		end
		puts "Sort using: 'list cuisine' or 'list by cuisine"
	end

	def find(keyword = "")
		puts "\nFinding a restaurant\n\n".upcase
		if keyword
			# search
			restaurants = Restaurant.saved_restaurants
			found = restaurants.select do |r|
				r.name.downcase.include?(keyword.downcase) ||
				r.cuisine.downcase.include?(keyword.downcase) ||
				r.price.to_i <= keyword.to_i
			end

			found.each do |f|
				puts f.name + " | " + f.cuisine + " | " + f.price 
			end
		else
			puts "Error"
		end
	end

	def introduction
		puts "\n\n<<< Welcome to the Food Finder >>>\n\n"
		puts "This is an interactive guide to help you find the food you love.\n\n"
	end

	def conclusion
		puts "\n<<< Goodbye and Bon Appetite>>>\n\n\n"
	end

end