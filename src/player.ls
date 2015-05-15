
require! {
  './bet': Bet
}

/*return*
 * A blackjack player has a cash balance and a strategy.  The game interacts
 * with the player, which causes the game to progress.
 */
class Player

  balance: 0
  name: 'Player'

  (@strategy) ->

  choose-bet: (game) ->
    amount = strategy.chooseBet(this, game)
    bet = new Bet(amount)
    @change-balance(amount * -1);
    bet

  choosePlay: (hand, dealerCard, validPlays, game) ->
    strategy.choosePlay(hand, dealerCard, validPlays, this, game)

  collect-winnings: (bet) ->
    @changeBalance(bet.getWinnings())

  change-balance: (amount) ->
    @balance += amount

  get-balance: -> @balance

  set-name: (value) ->
    @name = String value

  get-name: -> name

module.exports = Player;
