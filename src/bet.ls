#
# Logic and rules for a single bet in BlackJack.
#

class Bet

  winnings = 0
  doubled = false
  surrendered = false

  (@amount) ->


  # Double down
  double: ->
    @amount = @amount * 2
    @doubled = true

  # Get half your money back.
  surrender: ->
    surrendered = true

  #
  is-surrendered: ->
    surrendered

  #
  set-winnings: (how-much) ->
    if (surrendered)
      # Fail silently?
      return
    winnings = how-much

  #
  get-winnings: ->
    result = winnings
    if (surrendered)
      result = @amount / 2
    return result

  get-amount: ->
    @amount

module.exports = Bet;
