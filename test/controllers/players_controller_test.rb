require 'test_helper'

class PlayersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @player = players(:player1)
  end

  test "should get index" do
    get players_url
    assert_response :success
  end

  test "should redirect new player when not logged in" do
    get new_player_url
    assert_redirected_to root_url
  end

  test "should get new player when logged in" do
    sign_in users(:dan)
    get new_player_url
    assert_response :success
  end

  test "should redirect create player when not logged in" do
    assert_no_difference('Player.count') do
      post players_url, params: { player: { alias: "Muffin", name: "David" } }
    end
    assert_redirected_to root_url
  end

  test "should create player when logged in" do
    sign_in users(:dan)
    assert_difference('Player.count') do
      post players_url, params: { player: { alias: "Muffin", name: "David" } }
    end
    assert_redirected_to players_url
  end

  test "should show player" do
    get player_url(@player)
    assert_response :success
  end

  test "should redirect edit player when not logged in" do
    get edit_player_url(@player)
    assert_redirected_to root_url
  end

  test "should edit player when logged in" do
    sign_in users(:dan)
    get edit_player_url(@player)
    assert_response :success
  end

  test "should redirect update player when not logged in" do
    name = @player.name
    new_name = name + "new"
    patch player_url(@player), params: { player: { alias: @player.alias, name: new_name } }
    assert_redirected_to root_url
    @player.reload
    assert_equal name, @player.name
  end

  test "should update player when logged in" do
    name = @player.name
    new_name = name + "new"
    sign_in users(:dan)
    patch player_url(@player), params: { player: { alias: @player.alias, name: new_name } }
    assert_redirected_to players_url
    @player.reload
    assert_equal new_name, @player.name
  end

  test "should redirect destroy player when not logged in" do
    assert_no_difference('Player.count') do
      delete player_url(@player)
    end
    assert_redirected_to root_url
  end

  test "should destroy player when logged in" do
    sign_in users(:dan)
    assert_difference('Player.count', -1) do
      delete player_url(@player)
    end
    assert_redirected_to players_url
  end
end
