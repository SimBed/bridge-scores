require 'test_helper'

class MatchTest < ActiveSupport::TestCase
  def setup
    @league1 = leagues(:league1)
    @match = @league1.matches.build(date: "2021-03-10", score: -27.2)
    @match3 = matches(:match3)
  end

  test "should be valid" do
    assert @match.valid?
  end

  test "date should be present" do
    @match.date = "     "
    assert_not @match.valid?
  end

  test "score should be present" do
    @match.score = "     "
    assert_not @match.valid?
  end

  test "score should be a number" do
    @match.score = "a"
    assert_not @match.valid?
  end

  test "league should be present" do
    @match.league_id = nil
    assert_not @match.valid?
  end

  test "player method" do
    assert_equal "Jo", @match3.player("north")
    assert_equal "Andy", @match3.player("south")
    assert_equal "Kevin", @match3.player("east")
    assert_equal "Martin", @match3.player("west")
  end

end
