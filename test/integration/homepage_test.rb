require 'test_helper'

class HomepageTest < ActionDispatch::IntegrationTest
  test 'welcoming the user' do
    visit '/'

    assert_match /welcome/i, page.body
  end
end
