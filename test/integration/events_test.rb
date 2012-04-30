require 'test_helper'

class EventsTest < RackTest
  setup do
    @youtube = { started_at: 5.minutes.ago, ended_at: 3.minutes.ago, name: 'Watch Youtube' }
  end

  test 'uploading a set of events' do
    events = [
      @youtube,
      { started_at: 1.hour.ago, ended_at: 35.minutes.ago, name: 'Trying to fix nokogiri' }
    ]

    post '/upload.json', { :upload => events.to_json }

    assert_equal({ 'uploaded' => 2 }, JSON.parse(last_response.body), "Should port how many events were uploaded")

    events.each { |event| assert Event.exists?(:name => event[:name]), "Should have created event #{event[:name]}" }
  end

  test 'uploading invalid event' do
    bad_event = { started_at: 1.hour.ago, ended_at: 35.minutes.ago, wrong_name: 'bad name' }

    assert_no_difference -> { Event.count } do
      post '/upload.json', { :upload => [ @youtube, bad_event ].to_json }
    end

    assert_equal 400, last_response.status
    assert_equal [ "Name can't be blank" ], JSON.parse(last_response.body)
  end

  test 'uploading invalid json' do
    post '/upload.json', { :upload => 'hello world' }

    assert_equal 400, last_response.status, "Should state that page was not processable"
    assert_match /Bad JSON:/, JSON.parse(last_response.body).first, "Should yell about bad json"
  end
end
