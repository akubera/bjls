/**
 * A jackjack shoe,  a 1-8 deck stack of cards.
 */

require! {
  './card': Card
}

function random_position (max)
  Math.floor (max + 1) * Math.random!

class Shoe
  cursor: 0
  stack: []

  (size) ->
    for i from 0 to size
      for suit in Card.suits
        for rank in Card.rank
          card = new Card(rank, suit)
          position = random_position @stack.length
          @stack.splice(position, 0, card)

  # Get the next card from the shoe.
  draw: ->
    if @cursor >= @stack.length
      throw 'The deck has been exhausted'
    @stack[@cursor++]

  cards-left: -> @stack.length - @cursor

  # Shuffles the deck.  All cards are assumed to be gathered back.
  shuffle: ->
    @cursor = 0
    newstack = []
    @stack.forEach (card) ->
      position = random_position @stack.length
      newstack.splice(position, 0, card)
    @stack = newstack

  # Return a copy of the remaining stack
  get-remaining-cards: -> @stack[@cursor til @stack.length]

module.exports = Shoe;
