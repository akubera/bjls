/**
 * A jackjack shoe,  a 1-8 deck stack of cards.
 */

require! {
  './card': Card
}

class Shoe
  cursor: 0
  stack: []

  (size) ->
    for (i = 0; i < size; i++)
      Card.suits.forEach (suit) ->
        Card.ranks.forEach (rank) ->
          card = new Card(rank, suit)
          position = Math.floor((stack.length + 1) * Math.random())
          @stack.splice(position, 0, card)

  # Get the next card from the shoe.
  draw: ->
    if @cursor >= stack.length
      throw 'The deck has been exhausted'
    stack[@cursor++]

  cards-left: -> stack.length - @cursor

  # Shuffles the deck.  All cards are assumed to be gathered back.
  shuffle: ->
    @cursor = 0
    newstack = []
    @stack.forEach (card) ->
      position = Math.floor((stack.length + 1) * Math.random())
      newstack.splice(position, 0, card)
    @stack = newstack

  # Return a copy of the remaining stack
  get-remaining-cards: ->
    stack.slice(cursor, stack.length)

module.exports = Shoe;
