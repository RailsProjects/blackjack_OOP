# Blackjack in OOP-Style Ruby Code
# by Laurence Kauffman
# July 1, 2013

# Methodology:
# Objects first - take apart classes, focus on how each of these objects behave,
# and the state of each object w/o deeply thinking about the game play (with the
# exception of the card class).  We then extracted behaviors common to Dealer
# and Player into module Hand.  This is called The data-oriented approach to
# OOP, which is also how Rails is built.  It is also known as the classic-style
# of OOP.

# We tested along the way with some methods e.g. Create a deck, player & dealer,
# assign some cards, calculate total, show cards:

# deck = Deck.new

# player = Player.new('Larry'); player.add_card(deck.deal_a_card);
#     player.add_card(deck.deal_a_card); player.show_hand

# dealer = Dealer.new; dealer.add_card(deck.deal_a_card);
#     dealer.add_card(deck.deal_a_card); dealer.show_hand

# Then (after general class behavior is fairly complete) in order to use this
# type of OOP we need an engine/controller to orchestrate how these objects
# interact with each other.  We will call this engine the Blackjack class.


require 'rubygems'
require 'pry'

class Card
	attr_accessor :suit, :face_value

	def initialize(s, fv)
		@suit = s
		@face_value = fv
	end

  def pretty_output
   "The #{face_value} of #{find_suit}"
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

module Hand # Keeps track of behaviors common to Dealer and Player
  def show_hand
    puts "==== #{name}'s Hand ====" #name is getter of instance var
    cards.each do|card|  #itereate through each of the cards
    puts "=> #{card}"  # calls card.to_s, which is pretty_output
                    # if I preface with a "puts" it displays object info, unless I remove puts from pretty_output
                    # which I did to fix dealer.dealer_flop because it had a puts
    end
    puts "=> Total: #{total}"
  end

  def total
    face_value = cards.map{|card| card.face_value } #face_values grabs each card's face value using the getter of each card
                                      # create new array using map method on array of just the face values e.g. 3. 4. J. Q
    total = 0
    face_value.each do |value|
      if value == "A"
        total += 11
      else
        total += (value.to_i == 0 ? 10 : value.to_i) #If to_i = 0 then j, K, Q so add 10, else add face value
      end
    end

    face_value.select{|value| value == "A"}.count.times do        # Correct for any Aces
      break if total <= 21
      total -= 10
    end

    total
  end

  def add_card(new_card)
    cards << new_card # in the module once these instance methods have been added to the class it is
                      # just as if this method was in the class itself, so it has access to the getter: cards.
                      # Once I mixin this module it's as if these methods are in the class and can access instance variables.
                      # There is a coupling in involved-Assumption of cards in class that uses this module.
                      # Once this module is included in the class the class needs an array of cards.
                      # Module is a great way to extract behavior, but there is still a coupling/assumptions there.
  end

  def is_busted? # returns T if busted, F if not.  Put here so because it's common to both Player and Dealer
    total > 21
  end
end

class Player
  include Hand

  attr_accessor :name, :cards

  def initialize(n)
    @name = n # w/o @ it is a local var
    @cards = [] # allows us to add card to player e.g. bob.cards << deck.deal_a_card
  end

  def show_flop
    show_hand
  end
end

class Dealer
  include Hand

  attr_accessor :name, :cards

  def initialize
    @name = "Dealer"  #nothing passed in
    @cards = []
  end

  def show_flop
    puts "==== Dealer's Hand ====" # This is within the dealer class so don't worry about #{name}
    puts "=> First card is hidden"
    puts "=> Second card is #{cards[1]}" # access cards array in Dealer object
  end
end

# Game engine
class Blackjack
  attr_accessor :deck, :player, :dealer  # make getters and setters for instance vars

  def initialize
    #           # start with just the instance vars, then worry about what to initialize them to
    # @deck =
    # @player =
    # @dealer =

    @deck = Deck.new
    @player = Player.new("Player 1") #init takes a param
    @dealer = Dealer.new
  end

  def start
      # Do this part after finishing the design portion of the game above/outside of the game engine.
      # Here is an example of building a game by starting with sequence of events to execute game.
      # ****Use this as a guide to build these methods:

      # set_player_name
      # deal_cards
      # show_hands
      # player_turn
      # dealer_turn
      # who_won?(player, dealer) # use if both players stay

      # Play game
      set_player_name
      deal_cards
      show_flop
      player_turn
      # dealer_turn
      # who_won?(player, dealer)
  end

  def set_player_name
    print "Please type your name: "
    player.name = gets.chomp  # player uses setter method created by attr_accessor to set instance var
  end

  def deal_cards
    player.add_card(deck.deal_a_card)
    dealer.add_card(deck.deal_a_card)
    player.add_card(deck.deal_a_card)
    dealer.add_card(deck.deal_a_card)
  end

  def show_flop # just call methods from respective classes.  Flop is the cards when they first come out.
    player.show_flop
    dealer.show_flop
  end

  def blackjack_or_bust?(player_or_dealer) # player or dealer responds to the same method calls
    if player_or_dealer.total == 21 # duck typing...as long as it can respond to .total, that's all the matters
      if player_or_dealer.is_a?(Dealer)  # If it's a dealer, put this message:
        puts "Sorry, dealer hit blackjack.  #{player.name} loses."
      # you still have access to the name getter as long as you are in the game engine,
      # and the game engine is the Blackjack class
      else
        puts "Congratulations, you hit blackjack!  #{player.name} wins!"
      end
      exit # exit program
    elsif player_or_dealer.is_busted?
      if player_or_dealer.is_a?(Dealer)
        puts "Congratulations, dealer busted.  #{player.name} wins!"
      else
        puts "Sorry, #{player.name} busted.  #{player.name} loses."
      end
      exit
    end
  end

  def player_turn
    puts "its #{player.name}'s turn."

    blackjack_or_bust?(player) # Did they hit blackjack?  This is a subset of blackjack_or_bust, so just call that
    while !player.is_busted?
      puts "What would your like to do?  1) hit 2) stay"
      response = gets.chomp # response is local to while loop

      if !['1', '2'].include?(response)
        puts "Error: you must enter 1 or 2"
        next # go to next iteration of while loop
      end

      if response == '2'
        puts "#{player.name} chose to stay."
        break
      end

      # player asks for a hit
      new_card = deck.deal_a_card
      puts "Dealing card to #{player.name}: #{new_card}"
      player.add_card(new_card)
      puts "#{player.name}'s total is now: #{player.total}"

      blackjack_or_bust?(player)
    end
      puts "#{player.name} stays"
  end

  def dealer_turn

  end

  def who_won?(player, dealer)

  end
end # end of class Blackjack

game = Blackjack.new
game.start


