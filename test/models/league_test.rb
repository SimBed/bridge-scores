require 'test_helper'

class LeagueTest < ActiveSupport::TestCase
  def setup
    @league = League.new(name: 'ace of spades')
    @league1 = leagues(:league1)
    @league2 = leagues(:league2)
  end

  test 'should be valid' do
    assert @league.valid?
  end

  test 'name should not be more than max length' do
    @league.name = 'p' * 21
    assert_not @league.valid?
  end

  test 'names should be unique' do
    @league2 = @league.dup
    @league2.name = @league.name.upcase
    @league2.save
    assert_not @league.valid?
  end

  test 'players method' do
    assert_equal 5, @league1.players.count
    assert_equal 5, @league2.players.count
  end

  test 'scores method' do
    assert_equal [21.7, 21.7, 5.5, -21.7, -27.2], @league1.scores
    assert_equal [13, 7, 3, -10, -13], @league2.scores
  end
end
