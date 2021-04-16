require 'test_helper'

class LeagueTest < ActiveSupport::TestCase
  def setup
    @league = League.new(name: "premier")
  end

  test "should be valid" do
    assert @league.valid?
  end

  test "name should not be more than max length" do
    @league.name = 'p'*21
    assert_not @league.valid?
  end

  test "names should be unique" do
    @league2 = @league.dup
    @league2.name = @league.name.upcase
    @league2.save
    assert_not @league.valid?
  end
end
