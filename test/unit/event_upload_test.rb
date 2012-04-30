require 'test_helper'

class EventUploadTest < ActiveSupport::TestCase
  def test_weird_initialization_json
    [ nil, [ { '' => 'no name' } ].to_json, { 'hello' => 'world' }.to_json ].each do |input|
      assert_equal false, EventUpload.new(input).save, "Should handle #{input.inspect} input"
    end
  end
end
