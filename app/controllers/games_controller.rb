require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = []
    10.times do
      @letters << [*'A'..'Z'].sample
    end
    @start_time = Time.now
  end

  def score
    @end_time = Time.now.to_i
    @attempt = params[:word]
    @grid = params[:token].chars
    @start_time = Time.parse(params[:start_time]).to_i

    @results = run_game(@attempt, @grid, @start_time, @end_time)
    # The word can’t be built out of the original grid
    # The word is valid according to the grid, but is not a valid English word
    # The word is valid according to the grid and is an English word
  end

  private

  def word_uses_grid(attempt, grid)
    # verify 1)using the letters from the grid 2) used not too many times the character
    attempt = attempt.upcase.chars
    attempt.all? do |char|
      attempt.count(char) <= grid.count(char)
    end
  end

  def check_word_exists(attempt)
    # verify word is an actual word
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    api_return = URI.open(url).read
    check_word = JSON.parse(api_return)
    check_word["found"]
  end

  def calculation(attempt, start_time, end_time)
    ttanswer = (end_time - start_time) / 60
    attempt.length * 10 / ttanswer
  end

  def result(attempt, grid, start_time, end_time)
    if check_word_exists(attempt) && word_uses_grid(attempt, grid)
      score = calculation(attempt, start_time, end_time)
      [score, "Congratulations! #{attempt} is a valid English word"]
    elsif check_word_exists(attempt) == false
      [0, "Sorry but #{attempt} does not seem to be a valid English word..."]
    elsif word_uses_grid(attempt, grid) == false
      [0, "Sorry but #{attempt} can't be built out of #{grid.join(",")}"]
    end
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
    # verify 1)using the letters from the grid 2) used not too many times the character
    score = result(attempt, grid, start_time, end_time)[0]
    message = result(attempt, grid, start_time, end_time)[1]
    return { score: score, message: message, time: end_time - start_time }
  end
end
