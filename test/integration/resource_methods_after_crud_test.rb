require 'test_helper'

class ResourceMethodsAfterCrudTest < ActionDispatch::IntegrationTest
  setup do
    @player1 = players(:player1)
    @player2 = players(:player2)
    @player3 = players(:player3)
    @player4 = players(:player4)
    @player5 = players(:player5)
    @player6 = players(:player6)
    @league1 = leagues(:league1)
    @league2 = leagues(:league2)
    # NOTE: SQL results are explicitly unordered unless ORDER BY is present
    # Player.first orders by primary key whereas Player.all is unordered so
    # Player.first should not be expected to be equal to Player.all[0]
    # therefore use Model.order(:attribute).first when order matters
    # players are added in the form for a new match, but are used in the RelPlayerMatch model not the Match model
    @match_new1 = { match: { date: '2021-04-10', score: 1, league_id: @league2.id, north: players(:player1).id,
                             south: players(:player2).id, east: players(:player3).id, west: players(:player4).id } }
    @match_new2 = { match: { date: '2021-04-17', score: -2, league_id: @league2.id, north: players(:player2).id,
                             south: players(:player3).id, east: players(:player4).id, west: players(:player5).id } }
    @match2_score_change = { match: { score: 100 } }
    # originally in match 1 south is p5 & east is p3
    @match1_player_switch = { match: { south: players(:player3).id, east: players(:player2).id } }
  end

  test 'player scores & positions after create matches' do
    post matches_path, params: @match_new1
    post matches_path, params: @match_new2
    # league1 (no change)
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
    assert_equal 14, @player1.score(@league2)
    assert_equal 1, @player1.position(@league2)
    assert_equal(-1, @player2.score(@league2))
    assert_equal 4, @player2.position(@league2)
    assert_equal(-13, @player3.score(@league2))
    assert_equal 6, @player3.position(@league2)
    assert_equal 4, @player4.score(@league2)
    assert_equal 3, @player4.position(@league2)
    assert_equal(-11, @player5.score(@league2))
    assert_equal 5, @player5.position(@league2)
    assert_equal 7, @player6.score(@league2)
    assert_equal 2, @player6.position(@league2)
  end

  test 'player scores & positions after update match score' do
    sign_in users(:dan)
    patch match_url(Match.order(:date).limit(2).last), params: @match2_score_change
    # league1
    assert_equal 72.8, @player1.score(@league1)
    assert_equal 2, @player1.position(@league1)
    assert_equal 100, @player2.score(@league1)
    assert_equal 1, @player2.position(@league1)
    assert_equal(-72.8, @player3.score(@league1))
    assert_equal 4, @player3.position(@league1)
    assert_equal(-72.8, @player4.score(@league1))
    assert_equal '4 =', @player4.position(@league1, true)
    assert_equal(-27.2, @player5.score(@league1))
    assert_equal 3, @player5.position(@league1)
    # league2 (unchanged)
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

  test 'player scores & positions after update match seating' do
    sign_in users(:dan)
    patch match_url(Match.order(:date).limit(2).first), params: @match1_player_switch
    # league1
    assert_equal(-21.7, @player1.score(@league1))
    assert_equal 3, @player1.position(@league1)
    assert_equal 32.7, @player2.score(@league1)
    assert_equal 1, @player2.position(@league1)
    assert_equal(-32.7, @player3.score(@league1))
    assert_equal 4, @player3.position(@league1)
    assert_equal 21.7, @player4.score(@league1)
    assert_equal 2, @player4.position(@league1)
    # player 5 no longer participated in league1 after update
    assert_equal 0, @player5.league_matches(@league1).count
    # league2 (unchanged)
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

  test "player's seat method after player deletion" do
    sign_in users(:dan)
    delete player_url(@player4)
    assert_equal '----', Match.order(:date).last.player('east')
    assert_equal players(:player1).name, Match.order(:date).last.player('west')
  end

  test "other players' positions after player deletion" do
    sign_in users(:dan)
    delete player_url(@player1)
    # league1
    assert_equal 5.5, @player2.score(@league1)
    assert_equal 3, @player2.position(@league1)
    assert_equal 21.7, @player3.score(@league1)
    assert_equal 1, @player3.position(@league1)
    assert_equal 21.7, @player4.score(@league1)
    assert_equal '1 =', @player4.position(@league1, true)
    assert_equal(-27.2, @player5.score(@league1))
    assert_equal 4, @player5.position(@league1)
    # league2
    assert_equal(-10, @player3.score(@league2))
    assert_equal 3, @player3.position(@league2)
    assert_equal 3, @player4.score(@league2)
    assert_equal 2, @player4.position(@league2)
    assert_equal(-13, @player5.score(@league2))
    assert_equal 4, @player5.position(@league2)
    assert_equal 7, @player6.score(@league2)
    assert_equal 1, @player6.position(@league2)
  end

  test "players' positions after match deletion" do
    sign_in users(:dan)
    delete match_url(matches(:match3))
    # league1 (unchanged)
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
    assert_equal 3, @player1.score(@league2)
    assert_equal 1, @player1.position(@league2)
    assert_equal 3, @player4.score(@league2)
    assert_equal 1, @player4.position(@league2)
    assert_equal(-3, @player5.score(@league2))
    assert_equal 3, @player5.position(@league2)
    assert_equal(-3, @player6.score(@league2))
    assert_equal 3, @player6.position(@league2)
    # the only match of p2 and p3 now deleted
    assert_equal 0, @player2.league_matches(@league2).count
    assert_equal 0, @player3.league_matches(@league2).count
  end
end
