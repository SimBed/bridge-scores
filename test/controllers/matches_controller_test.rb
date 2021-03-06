require 'test_helper'
class MatchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @match = matches(:match1)
    # note SQL results are explicitly unordered unless ORDER BY is present
    # Player.first orders by primary key whereas Player.all is unordered so
    # Player.first should not be expected to be equal to Player.all[0]
    # therefore use Model.order(:attribute).first when order matters
    @match_new1 = { match: { date: "2021-03-05", score: 10, north: players(:player1).id, south: players(:player2).id, east: players(:player3).id, west: players(:player4).id } }
    @match_new2 = { match: { date: "2021-03-12", score: -100, north: players(:player2).id, south: players(:player3).id, east: players(:player5).id, west: players(:player1).id } }
    @match2_score_change = { match: { date: "2021-03-12", score: 100, north: players(:player2).id, south: players(:player3).id, east: players(:player5).id, west: players(:player1).id } }
    @match1_player_switch = { match: { date: "2021-03-05", score: 10, north: players(:player1).id, south: players(:player3).id, east: players(:player2).id, west: players(:player4).id } }
  end

  test "should get index" do
    get matches_url
    assert_response :success
  end

  test "should get new" do
    get new_match_url
    assert_response :success
  end

  test "should create match" do
    assert_difference('Match.count') do
      post matches_url, params: { match: { date: @match.date, score: @match.score } }
    end
    assert_redirected_to matches_url
  end

  test "should show match" do
    get match_url(@match)
    assert_response :success
  end

  test "should get edit" do
    get edit_match_url(@match)
    assert_response :success
  end

  test "should update match" do
    patch match_url(@match), params: { match: { date: @match.date, score: @match.score } }
    assert_redirected_to matches_url
  end

  test "should destroy match" do
    assert_difference('Match.count', -1) do
      delete match_url(@match)
    end
    assert_redirected_to matches_url
  end

  test "associated matches and relationships should be destroyed" do
    assert_difference 'Match.count', 1 do
      assert_difference 'RelPlayerMatch.count', 4 do
        post matches_path, params: @match_new1
      end
    end
    assert_difference 'Match.count', -1 do
      assert_difference 'RelPlayerMatch.count', -4 do
        matches(:match1).destroy
      end
    end
  end

  test "scores & positions update correctly after 1 match" do
    post matches_path, params: @match_new1
    assert_equal -11.7, players(:player1).score
    assert_equal 4, players(:player1).position
    assert_equal 15.5, players(:player2).score
    assert_equal 1, players(:player2).position
    assert_equal 11.7, players(:player3).score
    assert_equal 2, players(:player3).position
    assert_equal 11.7, players(:player4).score
    assert_equal 2, players(:player4).position
    assert_equal -27.2, players(:player5).score
    assert_equal 5, players(:player5).position
  end

  test "scores & positions update correctly after 2 matches" do
    post matches_path, params: @match_new1
    post matches_path, params: @match_new2
    assert_equal 88.3, players(:player1).score
    assert_equal 1, players(:player1).position
    assert_equal -84.5, players(:player2).score
    assert_equal 4, players(:player2).position
    assert_equal -88.3, players(:player3).score
    assert_equal 5, players(:player3).position
    assert_equal 11.7, players(:player4).score
    assert_equal 3, players(:player4).position
    assert_equal 72.8, players(:player5).score
    assert_equal 2, players(:player5).position
  end

  test "scores & positions update correctly after edit score" do
    post matches_path, params: @match_new1
    post matches_path, params: @match_new2
    patch match_url(Match.order(:created_at).last), params: @match2_score_change
    assert_equal -111.7, players(:player1).score
    assert_equal 4, players(:player1).position
    assert_equal 115.5, players(:player2).score
    assert_equal 1, players(:player2).position
    assert_equal 111.7, players(:player3).score
    assert_equal 2, players(:player3).position
    assert_equal 11.7, players(:player4).score
    assert_equal 3, players(:player4).position
    assert_equal -127.2, players(:player5).score
    assert_equal 5, players(:player5).position
  end

  test "scores & positions update correctly after edit partnership" do
    post matches_path, params: @match_new1
    post matches_path, params: @match_new2
    patch match_url(Match.order(:created_at)[2]), params: @match1_player_switch
    assert_equal 88.3, players(:player1).score
    assert_equal 1, players(:player1).position
    assert_equal -104.5, players(:player2).score
    assert_equal 5, players(:player2).position
    assert_equal -68.3, players(:player3).score
    assert_equal 4, players(:player3).position
    assert_equal 11.7, players(:player4).score
    assert_equal 3, players(:player4).position
    assert_equal 72.8, players(:player5).score
    assert_equal 2, players(:player5).position
  end

end
