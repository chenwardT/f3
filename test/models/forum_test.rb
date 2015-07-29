require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  test 'forum hierarchy' do
    assert_equal forums(:cars).forums, [forums(:na), forums(:hybrids), forums(:electric)]
    assert_includes forums(:hybrids).forums, forums(:prius)
    assert_includes forums(:electric).forums, forums(:model_s)
    assert_equal forums(:model_s).forums, [forums(:model_s_2014), forums(:model_s_2015)]
  end

  test 'to_s returns title' do
    assert_equal forums(:cars).to_s, forums(:cars).title
  end

  test 'topic_count returns count of nested topics' do
    assert_equal forums(:cars).topic_count, forums(:cars).topics.count
  end
end
