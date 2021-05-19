require 'test_helper'

class LeaguesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @league = leagues(:league1)
  end

  # index
  test 'should get index' do
    get leagues_url
    assert_response :success
  end

  # new
  test 'should redirect new league when not logged in' do
    get new_league_url
    assert_redirected_to root_url
  end

  test 'should get new league when logged in' do
    sign_in users(:dan)
    get new_league_url
    assert_response :success
  end

  # create
  test 'should redirect create league when not logged in' do
    assert_no_difference('League.count') do
      post leagues_url, params: { league: { name: @league.name } }
    end
    assert_redirected_to root_url
  end

  test 'should create league when logged in' do
    new_name = "#{@league.name}2"
    sign_in users(:dan)
    assert_difference('League.count') do
      post leagues_url, params: { league: { name: new_name } }
    end
    assert_redirected_to league_url(League.last)
  end

  # show
  test 'should show league' do
    get league_url(@league)
    assert_response :success
  end

  # edit
  test 'should redirect edit league when not logged in' do
    get edit_league_url(@league)
    assert_redirected_to root_url
  end

  test 'should get edit league when logged in' do
    sign_in users(:dan)
    get edit_league_url(@league)
    assert_response :success
  end

  # update
  test 'should redirect update league when not logged in' do
    name = @league.name
    new_name = "#{name}new"
    patch league_url(@league), params: { league: { name: new_name } }
    assert_redirected_to root_url
    @league.reload
    assert_equal name, @league.name
  end

  test 'should update league when logged in' do
    name = @league.name
    new_name = "#{name}new"
    sign_in users(:dan)
    patch league_url(@league), params: { league: { name: new_name } }
    assert_redirected_to league_url(@league)
    @league.reload
    assert_equal new_name, @league.name
  end

  # destroy
  test 'should redirect destroy league when not logged in' do
    assert_no_difference('League.count') do
      delete league_url(@league)
    end
    assert_redirected_to root_url
  end

  test 'should destroy league when logged in' do
    sign_in users(:dan)
    assert_difference('League.count', -1) do
      delete league_url(@league)
    end
    assert_redirected_to leagues_url
  end

  test 'associated matches should be destroyed when league destroyed' do
    sign_in users(:dan)
    assert_difference('Match.count', -2) do
      delete league_url(@league)
    end
    assert_redirected_to leagues_url
  end
end
