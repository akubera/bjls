

/**
 * Logic and rules for a single hand of blackjack.  Should be able to handle
 * either a dealer hand or a player hand.  All it really does is keep track of
 * hard and soft hands.
 */
class Hand
  cards: []
  value: 0
  aces: 0  # Number of aces.
  hardenedAces: 0  # Number of aces considered hard.
  _isSoft: false

  # Add one card to the hand.
  deal-card: (card) ->
    @cards.push card
    @value += card.getValue()

    # Handle Aces
    if card.getRank() == "A"
      @aces += 1
      @_isSoft = true

    if @value > 21 && @hardenedAces < @aces
      @value -= 10
      @hardenedAces += 1
      if @hardenedAces == @aces
        @_isSoft = false

  # Get the blackjack value of this hand.
  get-value: -> @value

   # Return whether or not any aces are considered soft.
  is-soft = -> @_isSoft

  is-black-jack: -> @cards.length == 2 && @value == 21

   # Returns a copy of the cards.
  get-cards: -> @cards.slice()

  get-card-at: (i) -> @cards[i]

  to-string: ->
    result = @cards.reduce (a, b) -> "#{a} and #{b}"
    soft_str = if @_isSoft then "soft" else "hard"
    "#{result} (#{soft_str} #{@value})"

module.exports = Hand
