require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  def setup
    @player = Player.new(name: 'David', alias: 'Muffin')
    @league1 = leagues(:league1)
    @league2 = leagues(:league2)
    @player1 = players(:player1)
    @player2 = players(:player2)
    @player3 = players(:player3)
    @player4 = players(:player4)
    @player5 = players(:player5)
    @player6 = players(:player6)
    @match1 = matches(:match1)
    @match3 = matches(:match3)
  end

  test 'should be valid' do
    assert @player.valid?
  end

  test 'name should be present' do
    @player.name = '     '
    assert_not @player.valid?
  end

  test 'player alias should be unique' do
    duplicate_player = @player.dup
    duplicate_player.alias = @player.alias.upcase
    @player.save
    assert_not duplicate_player.valid?
  end

  test 'score & position methods' do
    # league1
    assert_equal(-21.7, @player1.score(@league1))
    assert_equal 4, @player1.position(@league1)
    assert_equal 5.5, @player2.score(@league1)
    assert_equal 3, @player2.position(@league1)
    assert_equal 21.7, @player3.score(@league1)
    assert_equal 1, @player3.position(@league1)
    assert_equal 21.7, @player4.score(@league1)
    assert_equal '1 =', @player4.position(@league1, true)
    assert_equal(-27.2, @player5.score(@league1))
    assert_equal 5, @player5.position(@league1)
    # league2
    assert_equal 13, @player1.score(@league2)
    assert_equal 1, @player1.position(@league2)
    assert_equal(-10, @player3.score(@league2))
    assert_equal 4, @player3.position(@league2)
    assert_equal 3, @player4.score(@league2)
    assert_equal 3, @player4.position(@league2)
    assert_equal(-13, @player5.score(@league2))
    assert_equal 5, @player5.position(@league2)
    assert_equal 7, @player6.score(@league2)
    assert_equal 2, @player6.position(@league2)
  end

  test 'leagues method' do
    assert_equal 2, @player1.leagues.count
    assert_equal 1, @player2.leagues.count
    assert_equal 2, @player3.leagues.count
    assert_equal 1, @player6.leagues.count
  end

  test 'league_matches method' do
    assert_equal 2, @player1.league_matches(@league1).count
    assert_equal 2, @player1.league_matches(@league2).count
    assert_equal 1, @player2.league_matches(@league1).count
    assert_equal 0, @player2.league_matches(@league2).count
  end

  test 'match_score' do
    assert_equal 27.2, @player4.match_score(@match1)
    assert_equal 10, @player6.match_score(@match3)
  end

  test 'partner' do
    assert_equal 'kdskds', @player4.partner(@match1)
    assert_equal 'thecactus', @player6.partner(@match3)
  end

  test 'opponents' do
    assert_equal ['Andy','Martin'], @player4.opponents(@match1)
  end

  test 'seat' do
    assert_equal 'W', @player4.seat(@match1)
  end
end
