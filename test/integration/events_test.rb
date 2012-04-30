require 'test_helper'

class EventsTest < RackTest
  setup do
    @youtube = { started_at: 5.minutes.ago, ended_at: 3.minutes.ago, name: 'Watch Youtube' }
    @nokogiri = { started_at: 1.hour.ago, ended_at: 35.minutes.ago, name: 'Trying to fix nokogiri' }
  end

  test 'uploading a set of events' do
    post '/upload.json', { :upload => [ @youtube, @nokogiri ].to_json }

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

  test 'retrieving uploaded events' do
    [ @youtube, @nokogiri ].each { |hash| Event.create! hash }

    get '/events.json'

    assert_equal 200, last_response.status

    returned_json = JSON.parse(last_response.body)

    [ Event.find_by_name('Watch Youtube'), Event.find_by_name('Trying to fix nokogiri') ].zip(returned_json).each do |event, returned|
      assert_equal event.name, returned['name']
      assert_delta event.started_at, 1.second, Time.parse(returned['started_at'])
      assert_delta event.ended_at, 1.second, Time.parse(returned['ended_at'])
    end
  end

  private

  def assert_delta(expected, delta, actual)
    # *sigh* Stupid timestamp comparison. :(
    assert ((expected - delta).to_i .. (expected + delta).to_i).include?(actual.to_i), "Expected #{actual} to be within #{delta} of #{expected}"
  end
end
