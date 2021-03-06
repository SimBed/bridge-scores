require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  def setup
    @player = Player.new(name: "David", alias: "Muffin")
  end

  test "should be valid" do
    assert @player.valid?
  end

  test "name should be present" do
    @player.name = "     "
    assert_not @player.valid?
  end

  test "player alias should be unique" do
    duplicate_player = @player.dup
    duplicate_player.alias = @player.alias.upcase
    @player.save
    assert_not duplicate_player.valid?
  end

  test "player count" do
     assert_equal 5, Player.count
   end

  test "player scores" do
    assert_equal -21.7, players(:player1).score
    assert_equal 4, players(:player1).position
    assert_equal 5.5, players(:player2).score
    assert_equal 3, players(:player2).position
    assert_equal 21.7, players(:player3).score
    assert_equal 1, players(:player3).position
    assert_equal 21.7, players(:player4).score
    assert_equal 1, players(:player4).position
    assert_equal -27.2, players(:player5).score
    assert_equal 5, players(:player5).position
  end
end
