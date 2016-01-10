require 'yaml'

class Settings
  def self.open(filename)
    file = YAML.load_file(filename)
    file.each do |key, value|
      define_singleton_method key do
        value
      end
    end
  end
end

module Card
  def value; raise NotImplementedError; end

  def self.included(base)
    base.class_eval do
      def self.+(card0, card1)
        if card0.value.class == Array and card1.value.class == Array
          [card0.value[0]+card1.value[0], card0.value[1]+card1.value[1]]
        elsif card0.value.class == Array
          [card0.value[0]+card1.value, card.value[1]+card1.value]
        elsif value.class == Array
          [card0.value+card1.value[0], card0.value+card1.value[1]]
        else
          card0.value + card1.value
        end
      end

      def +(card)
        self.+(card, self)
      end
    end
  end
end

class Ace
  include Card

  def value; [1, 11]; end
  def to_s; "A"; end
end

module Face
  include Card

  def value; 10; end
end

class King
  include Face

  def to_s; "K"; end
end

class Queen
  include Face

  def to_s; "Q"; end
end

class Jack
  include Face

  def to_s; "J"; end
end

module NumberCard
  include Card

  CARDS_IN_LETTERS = {
    two: 2,
    three: 3,
    four: 4,
    five: 5,
    six: 6,
    seven: 7,
    eight: 8,
    nine: 9,
    ten: 10
  }

  def self.included(base)
    define_method :value do
      CARDS_IN_LETTERS[self.class.to_s.downcase.to_sym]
    end

    define_method :to_s do
      value.to_s
    end
  end
end

NumberCard::CARDS_IN_LETTERS.each do |cardname, cardvalue|
  new_class = Class.new(Object) do
    include NumberCard
  end

  Object.const_set(cardname.to_s.capitalize, new_class)
end

module SingleDeck
  def self.deck
    %i{two three four five six seven eight nine ten jack queen king ace} * 4
  end
end

class Deck
  def initialize
    @deck = []
  end
end

Settings.open("settings.yaml")
puts Settings.number_of_decks

puts Jack.new.value
puts Ten.new.value
puts Nine.new.value

a, b, c = Ten.new, Nine.new, Two.new
puts a, b, c
