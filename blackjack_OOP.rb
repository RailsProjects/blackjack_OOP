# Blackjack in OOP-Style Ruby Code
# by Laurence Kauffman
# July 1, 2013
require 'rubygems'
require 'pry'

class Card
	attr_accessor :suit, :face_value

	def initialize(s, fv)
		@suit = s
		@face_value = fv
	end

  def pretty_output
    puts "The #{face_value} of #{find_suit}"
  end

  def to_s
    pretty_output
  end

  def find_suit
    # ret_val = // optional.  implicit return of suit works w/o this
    case suit
                when 'H' then 'Hearts' #implicit return on each case
                when 'D' then 'Diamonds'
                when 'S' then 'Spades'
                when 'C' then 'Clubs'
              end
    # ret_val  // part of optional above


  end
  #value of card depends on context of game,
  #esp. Aces so don't calculate card value here

end

class Deck # behavior of a deck
  attr_accessor :cards

  def initialize
    @cards = [] # Deck is an array of card objects.  Pop 52 cards w/ 2 loops:
    ['H', 'D', 'S', 'C'].each do |suit| # pass suit in as var here, then fv below
      ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'].each do |face_value|
        @cards << Card.new(suit, face_value) # pop card array with objects
      end
    end
    shuffle!
  end

  def shuffle!
    cards.shuffle!  # shuffle is a method on the array class
  end

  def deal_a_card
    cards.pop #pop method from array (don't access instance var directly)
  end

  def size
    cards.size  # call this vs. just using deck.card.size in pry to decouple dependencies; allows another
                # layer to do some processing e.g. process out certain values e.g. don't include jokers
                # allows another layer to add or interject or filter based on your class's application logic w/o
                # depending on the size  implementation of array
  end

end

module Hand #keep track of behaviors common to Dealer and Player
  def show_hand
    puts "==== #{name}'s Hand ====" #name is getter of instance var
    cards.each do|card|  #itereate through each of the cards
      puts "=> #{card}"  # calls card.to_s, which is pretty_output
    end
    puts "=> Total: #{total}"
  end

  def total
    puts "a total"
  end

  def add_card(new_card)
    cards << new_card  # in the module once these instance methods have been added to the class it is
                      # just as if this method was in the class itself, so it has access to the getter: cards.
                      # Once I mixin this module it's as if these methods are in the class and can access instance variables.
                      # There is a coupling in involved-Assumption of cards in class that uses this module.
                      # Once this module is included in the class the class needs an array of cards.
                      # Module is a great way to extract behavior, but there is still a coupling/assumptions there.
      end
end

class Player
  include Hand

  attr_accessor :name

  def initialize(n)
    @name = n
    @cards = [] # allows us to add card to player e.g. bob.cards << deck.deal_a_card
  end
end

class Dealer
  include Hand

  attr_accessor :name, :cards

  def initialize
    @name = "Dealer"  /#nothing passed in
    @cards = []
  end
end


deck = Deck.new # create 52-card deck


player = Player.new('Larry')
player.add_card(deck.deal_a_card)
player.add_card(deck.deal_a_card)
player.show_hand

dealer = Dealer.new
dealer.add_card(deck.deal_a_card)
dealer.add_card(deck.deal_a_card)
dealer.show_hand
dealer.total



#puts deck.cards
#binding.pry
# in pry try:  deck, deck.cards, deck.cards.first (or last or size),
# deck.cards.each{|card| card.to_s}, deck.deal_a_card -THEN- deck.size

#puts deck.cards # calls to_s, which we have overwritten in deck
#puts deck.cards.size
#deck.deal_one # return card object
