require 'chingu'


class SpaceInvaders < Chingu::Window
	def setup
		super
		@background = Background.create
		@difficulty = Difficulty.new
		self.input = {esc: :exit}
		@ship = SpaceShip.create
		Mine.create
		@score = Score.create
	end

	def update
		super
		self.caption = "Health: #{@ship.health}      Score: #{@score.score}      FPS: #{self.fps}"
		@ship.each_collision(Mine) do |ship, mine|
			mine.destroy
			ship.health_down
		end
	end
end 

class Score < Chingu::GameObject

	has_traits :timer
	attr_reader :score

	def setup
		@score = 0

		file = File.open("difficulty.txt", "r")
			file.each do |value|
				@difficulty = value.to_i
			end
		file.close

		puts @difficulty
		every(100) {@score += 1*@difficulty}
	end

end

class SpaceShip < Chingu::GameObject

	has_traits :bounding_circle, :timer
	traits :collision_detection
	attr_reader :speed, :health, :score
	def setup
		@image = Gosu::Image["./lib/first_ship.png"]

		@x = $window.width/2
		@y = $window.height - 50

		@speed = 5
		@health = 3
		@score = 0

		self.input = {
			holding_up: :up,
			holding_down: :down,
			holding_left: :left,
			holding_right: :right
			}

	end

	def up
		unless @y == 15
			@y -= @speed
		end
	end

	def down
		unless @y == $window.height - 15
			@y += @speed
		end
	end

	def right
		@x += @speed
	end

	def left
		@x -= @speed
	end

	def health_down
		@health -= 1
		check_health
	end

	def check_health
		if @health == 0
			abort
		end
	end

	def update
		super
		every(1000) {@score += 1}
		@x %= $window.width
	end
end

class Mine < Chingu::GameObject

	has_traits :velocity, :bounding_circle, :timer

	def setup
		@x = rand($window.width)
		@y = -20
		@angle = 180
		@image = Gosu::Image["./lib/mine.png"]

		file = File.open("difficulty.txt", "r")
			file.each do |value|
				@difficulty = value.to_i
			end
		file.close

		self.velocity_y = Gosu::offset_y(@angle, 1.5)
		after(100/@difficulty) {Mine.create}
	end

	def update
		super
		if @y == $window.height + 20
			self.destroy
		end
	end
end

class Background < Chingu::GameObject

	def setup
		@image = Gosu::Image["menu_background.png"]
		@x = $window.width/2
		@y = $window.height/2
		@zorder = -1
	end
end


class Difficulty
	def initialize
		puts "1-3"
		@difficulty = gets.chomp
		
		if @difficulty == "easy"
			@difficulty = 1
		elsif @difficulty == "medium"
			@difficulty = 2
		elsif @difficulty == "hard"
			@difficulty = 3
		end
			
			
		p @difficulty
		set_difficulty
	end

	def set_difficulty
		if @difficulty != "\n"
			puts "start writing"
			file = File.new("difficulty.txt","w")
			file.write @difficulty.to_i
			file.close

		end
	end
end



SpaceInvaders.new.show