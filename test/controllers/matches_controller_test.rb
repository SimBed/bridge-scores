require 'test_helper'
class MatchesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @match = matches(:match1)
    @league1 = leagues(:league1)
    # NOTE: SQL results are explicitly unordered unless ORDER BY is present
    # Player.first orders by primary key whereas Player.all is unordered so
    # Player.first should not be expected to be equal to Player.all[0]
    # therefore use Model.order(:attribute).first when order matters
    # players are added in the form for a new match, but are used in the RelPlayerMatch model not the Match model
    @match_new1 = { match: { date: '2021-04-10', score: 15, league_id: @league1.id, north: players(:player1).id,
                             south: players(:player2).id, east: players(:player3).id, west: players(:player4).id } }
    @match_new2 = { match: { date: '2021-04-17', score: -40, league_id: @league1.id, north: players(:player2).id,
                             south: players(:player3).id, east: players(:player5).id, west: players(:player1).id } }
    @match2_score_change = { match: { date: '2021-03-12', score: 100, north: players(:player2).id,
                                      south: players(:player3).id, east: players(:player5).id,
                                      west: players(:player1).id } }
    @match1_player_switch = { match: { date: '2021-03-05', score: 10, north: players(:player1).id,
                                       south: players(:player3).id, east: players(:player2).id,
                                       west: players(:player4).id } }
  end

  test 'should get index' do
    get matches_url
    assert_response :success
  end

  test 'should get new match' do
    get new_match_url
    assert_response :success
  end

  test 'should create match and relationships' do
    assert_difference 'Match.count', 1 do
      assert_difference 'RelPlayerMatch.count', 4 do
        post matches_path, params: @match_new1
      end
    end
    assert_redirected_to matches_url
  end

  test 'should show match' do
    get match_url(@match)
    assert_response :success
  end

  test 'should redirect edit match when not logged in' do
    get edit_match_url(@match)
    assert_redirected_to root_url
  end

  test 'should edit match when logged in' do
    sign_in users(:dan)
    get edit_match_url(@match)
    assert_response :success
  end

  test 'should redirect update match when not logged in' do
    score = @match.score
    new_score = score * 2
    patch match_url(@match), params: { match: { score: new_score } }
    assert_redirected_to root_url
    @match.reload
    assert_equal score, @match.score
  end

  test 'should update match when logged in' do
    score = @match.score
    new_score = score * 2
    sign_in users(:dan)
    patch match_url(@match), params: { match: { score: new_score } }
    assert_redirected_to matches_url
    @match.reload
    assert_equal new_score, @match.score
  end

  test 'should redirect destroy match when not logged in' do
    assert_no_difference('Match.count') do
      delete match_url(@match)
    end
    assert_redirected_to root_url
  end

  test 'should destroy match when logged in' do
    sign_in users(:dan)
    assert_difference('Match.count', -1) do
      delete match_url(@match)
    end
    assert_redirected_to matches_url
  end

  test 'associated matches and relationships should be destroyed' do
    assert_difference 'Match.count', -1 do
      assert_difference 'RelPlayerMatch.count', -4 do
        matches(:match1).destroy
      end
    end
  end
end
