/**
 * A card, valued for blackjack
 */

class Card

  # I don't want to use unicode suits.
  @suits = <[hearts spades clubs diamonds]>
  @ranks = <[A 2 3 4 5 6 7 8 9 10 J Q K]>

  (@rank, @suit) ->
    @value = switch rank
    case \A then 11
    case \2 then 2
    case \3 then 3
    case \4 then 4
    case \5 then 5
    case \6 then 6
    case \7 then 7
    case \8 then 8
    case \9 then 9
    case \10, \J, \Q, \K then 10
    default
      throw "#{rank} is not a real card rand."

  get-rank: -> @rank

  get-suit: -> @suit

  get-value: -> @value

  to-string: -> "#{@rank} of #{@suit}"

module.exports = Card
