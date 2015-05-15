#
#
#

require! {
  './shoe': Shoe
  './hand': Hand
  './player': Player
  './strategy/DealerStrategy'
}

/**
 * The game itself.  Handles house rules, deciding results, dealing, etc.  You
 * could almost think of this as a Dealer object.  (The actual dealer is a
 * seperate object that runs the game, and makes no deciions about the actual
 * game progression, mirroring real life.)
 */
class BlackJackGame

  maxPlayers: 0
  players: []
  shoe: null

  (houseRules) ->

    if not houseRules.decks
      houseRules.decks = 2

    maxPlayers = houseRules.decks * 5  # Most games shouldn't get near this.
    @shoe = new Shoe houseRules.decks

    # We model the dealer after a player, which may buy us some code reuse.
    dealer = new Player(new DealerStrategy())
    dealer.setName \Dealer

  /**
   * A a player to the game.  If position (given as a player to sit before)
   * isn't given, player is added to last seat at the table.  (Rules about
   * table size are outside of this object, but we set a ceiling based on the
   * max number of cards possibly needed to deal to all these people )
   */
  add-player: (player, position) ->
    if players.length >= maxPlayers
      throw "Too many players."
    # TODO: Position
    players.push player

  get-players: -> players.slice()

  do-one-round: ->
    playersInThisRound = []
    playerHands = []

    @emit \story "Starting Round"

    # Shuffle, if we need to. (TODO: How best to model the timing of a shuffle?)
    # Let's say we want 5 cards available per hand being dealt. If we can't
    # have that, we shuffle.
    desired-shoe-size = (players.length + 1) * 5

    if shoe.cardsLeft() < desiredShoeSize
      @emit \story "Shuffling deck."
      shoe.shuffle()

    # Gather bets
    players.forEach (player) ->
      bet = player.chooseBet()
      if bet.get-amount! > 0
        @emit \story "#{player.getName()} bets #{bet.getAmount()}"
        playersInThisRound.push player

        # Alright, so I want to associate players and their hands in the
        # context of this current round.  I could make hands aware of players
        # or vis-versa, but those types don't really need to know about
        # eachother.  I could just set hand.player, which is almost certainly
        # an anti-pattern, though I can't really say why.  I think making a
        # playerhand object sounds like a pretty good way of doing things.
        # I'll just make that up here for now.. maybe I'll formalize it later.
        playerHands.push do
          hand: new Hand()
          player: player
          bet: bet
      else
        @emit \story "#{player.getName()} sits out."

    # If nobody is going to play, then that's that.
    if playersInThisRound.length == 0
      return

    # Deal first card
    playerHands.forEach (playerHand) ->
      playerHand.hand.dealCard shoe.draw()

    # Deal second card. Also check for Yeah yeah, it doesn't matter, I know.
    playerHands.forEach (playerHand) ->
      playerHand.hand.dealCard(shoe.draw());
      @emit \story "#{playerHand.player.getName()} draws a #{playerHand.hand.toString()}."

    # Deal dealer
    dealerHand = new Hand()
    dealerHand.dealCard shoe.draw()
    dealerHand.dealCard shoe.draw()

    # If dealer first card is an ace, call for insurance
    showingCard = dealerHand.getCardAt(0)
    @emit \story "Dealer shows " + showingCard.toString()
    if showingCard.getRank() == "A"
      # Offer insurance. XXX: Everyone knows you don't take insurance.
      @emit \story "Insurance? No takers."
      # Check for dealer blackjack
      if dealerHand.getValue() == 21
        showing_card_str = showingCard.toString()
        dealer_card = dealerHand.getCardAt(1).toString()
        @emit \story "Dealer blackjack with #{showing_card_str} and #{dealer_card}"
        # In the event of a dealer blackjack, we just resolve winnings without
        # letting players play.  A player blackjack will result in a push.
        @resolveWinnings(playerHands, dealerHand)
        return;

    # Go around the table so players can play
    for (i = 0; i < playerHands.length; i++)
      splitHands = @playHand(playerHands[i], showingCard)
      # If the hands split, make sure they're accounted for and played.
      if splitHands
        @playHand(splitHands[0], showingCard, true);
        @playHand(splitHands[1], showingCard, true);
        # The splice will increase the length by 1.  We i++ to make sure the
        # next iteration is the hand after these splits.
        playerHands.splice(i,1,splitHands[0],splitHands[1]);
        i++;

    # If all players have busted, the dealer need not play.
    everyoneLost = playerHands.every (playerHand) ->
      return playerHand.hand.getValue! > 21 || playerHand.bet.isSurrendered!

    if (everyoneLost)
      @emit \story "Everyone has busted or surrendered."
      @resolveWinnings playerHands, dealerHand
      return

    @emit \story "#{dealer.getName()} has a #{dealerHand.toString()}."
    @playHand do
      hand: dealerHand
      player: dealer

    @resolveWinnings(playerHands, dealerHand)

  playHand: (playerHand, dealerCard, isSplit) ->
    player = playerHand.player
    hand = playerHand.hand

    function playerDoes (what)
      @emit \story "#{player.getName()} #{what}"

    playerDone = false
    if hand.getValue() == 21
      playerDoes "has blackjack!"
      playerDone = true

    while not playerDone
      # TODO var validPlays = this.getValidPlaysFor(hand);
      validPlays = ["hit", "stay"]
      play = player.choosePlay hand, dealerCard, validPlays, this

      switch play
      case \stay
        playerDoes 'stays'
        playerDone = true
      case \hit
        playerDoes 'hits'
        card = shoe.draw()
        hand.dealCard card
        handtype = if hand.isSoft() then 'soft' else 'hard'
        playerDoes "draws a #{card.toString()}. (#{handtype} #{hand.getValue()})"

      case \split
        playerDoes 'splits'
        originalBet = hand.getBet()
        split1 = new Hand(originalBet)
        split1.dealCard(hand.getCardAt(0))
        split1.dealCard(shoe.draw())

        newBet = new Bet originalBet.getAmount()
        player.changeBalance newBet.getAmount()
        split2 = new Hand(newBet)
        split2.dealCard hand.getCardAt(1)
        split2.dealCard shoe.draw()

        # Break out with the two new hands.  The caller must account for
        # them and ensure they get played out.
        return [split1, split2];
      case \double
        playerDoes 'doubles down'
        hand.getBet().double()
        card = shoe.draw()
        hand.dealCard(card)
        handtype = if hand.isSoft() then 'soft' else 'hard'
        playerDoes "draws a #{card.toString()}. (#{handtype} #{hand.getValue()})"
        playerDone = true

      case \surrender
        playerDoes 'surrenders'
        hand.getBet().surrender()
        playerDone = true;


      if hand.getValue() == 21
        playerDoes "stops with 21"
        playerDone = true
      else if hand.getValue() > 21
        playerDoes "busts"
        playerDone = true

  # I forget how to do emit right now.
  emit: (topic, message) ->
    console.log message

  resolveWinnings: (playerHands, dealerHand) ->
    dealerHandValue = dealerHand.getValue()
    playerHands.forEach (playerHand) ->
      playerHandValue = playerHand.hand.getValue()
      bet = playerHand.bet;
      player = playerHand.player;

      winRatio = 2; # That is, 1 + 1 = 2;

      # If a player has blackjack, they're eligible to win more.
      if playerHand.hand.isBlackJack()
        winRatio = 3; # That is, 1 + 2 = 3.

      # If the player has busted or surrendered, all is lost.
      if playerHandValue > 21 || bet.isSurrendered()
        @emit \story "#{player.get-name()} loses."

      # If Dealer busted, all unbusted hands win
      else if dealerHandValue > 21 && playerHandValue <= 21
        @emit \story "#{player.getName()} wins."
        bet.setWinnings(bet.getAmount() * winRatio);

      # If dealer didn't bust, player must beat dealer score.
      else if playerHandValue > dealerHandValue
        @emit \story "#{player.getName()} wins."
        bet.setWinnings(bet.getAmount() * winRatio);

      else if playerHandValue == dealerHandValue
        @emit \story "#{player.getName()} pushes."
        bet.setWinnings(bet.getAmount())

      else
        @emit \story "#{player.getName()} loses."

      playerHand.player.collectWinnings(bet)

module.exports = BlackJackGame;
