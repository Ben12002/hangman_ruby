require 'yaml'

class Game


  def initialize(word = "", lives = 5, curr_guess = "", curr_state = [], wrong_chars = [])
    @word = word
    @lives = lives
    @curr_guess = curr_guess # e.g "a"
    @curr_state = curr_state # e.g "__a__e__"
    @wrong_chars = wrong_chars
  end

  

  def to_yaml
    str = YAML.dump ({
      :word => @word,
      :lives => @lives,
      :curr_guess => @curr_guess,
      :curr_state => @curr_state,
      :wrong_chars => @wrong_chars
    })
    file = File.open("test.yaml", "w")
    file.write(str)
    file.close
  end

  def self.from_yaml(fname)
    contents = File.open(fname, "r") {|file| file.read}
    data = YAML.load contents
    self.new(data[:word],data[:lives],data[:curr_guess],data[:curr_state], data[:wrong_chars])
  end



  def play
    if @word == ""
      generate_word
    end

    puts @word
    while !game_over?
      display_game
      if save?
        to_yaml
      end

      display_game
      make_guess
      update_game

      if (@curr_state.join("") == @word)
        puts "Congratulations!"
        break
      elsif @lives == 0
        puts "You Lost! The word was: #{@word}"
        break
      end
    end
  end

  def save?
    valid = false
    while !valid
      print "save game? (y/n):  "
      answer = gets.chomp.downcase
      valid = (answer == "y") || (answer == "n")
    end
    answer == "y" ? true : false
  end

  def generate_word
    dict = File.open("google-10000-english-no-swears.txt", "r").
    readlines().
    filter{|word| word.length.between?(5,12)}

    @word = dict.shuffle[0].chomp
    @curr_state = Array.new(@word.length, "_")
  end

  def game_over?
    @lives == 0
  end

  def make_guess
    valid = false
    while !valid
      print "Your guess?: "
      answer = gets.chomp.downcase
      valid = valid_guess?(answer)
    end
    @curr_guess = answer
  end

  def valid_guess?(guess)
    guess.match?(/[a-zA-Z]/) && (guess.length == 1) && !((@curr_state + @wrong_chars).include?(guess))
  end

  def update_game
    if @word.include?(@curr_guess)
      @word.split("").each_with_index do |char,i|
        if char == @curr_guess
          @curr_state[i] = @curr_guess
        end
      end
    else
      @wrong_chars.push(@curr_guess)
      @lives -= 1
    end
  end

  def display_game
    puts "=============================================================="
    puts @curr_state.join(" ")
    puts "Wrong: #{@wrong_chars}"
    puts "Lives: #{@lives}"
    puts "=============================================================="
  end
end





def load?
  valid = false
  while !valid
    print "Load previously saved game? (y/n):  "
    answer = gets.chomp.downcase
    valid = (answer == "y") || (answer == "n")
  end
  answer == "y" ? true : false
end

def play_game
  if load?
    game = Game.from_yaml("test.yaml")
  else
    game = Game.new
  end

  game.play
  play_again

end

def play_again
  # After game ends, give option to play again or end program
  answer = ""
  while answer != "y" && answer != "n"
    puts "would you like to play again? (y/n)"
    answer = gets.chomp

    if answer == "n"
      puts "Shutting down......."
    elsif answer != "y"
      puts "invalid answer"
    else
      puts "Another game!"
      play_game
    end
  end
end

    
play_game