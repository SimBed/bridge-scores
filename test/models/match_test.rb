require 'test_helper'

class MatchTest < ActiveSupport::TestCase
  def setup
    @match = Match.new(date: "2021-03-10", score: -27.2)
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

  test "match count" do
     assert_equal 2, Match.count
   end

end
