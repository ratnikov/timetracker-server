require 'accessible_accessor'

class EventUpload
  extend ActiveModel::Callbacks

  define_model_callbacks :save

  before_save :parse_events, :validate_events

  def initialize(json)
    @json = json
  end

  def save
    run_callbacks(:save) { valid? && persist_events }
  end

  def to_json
    if valid?
      { uploaded: @events.count { |event| event.persisted? } }.to_json
    else
      errors.to_json
    end
  end

  def errors
    @errors ||= []
  end

  private

  def parse_events
    parsed = JSON.parse(@json.to_s)

    # Support the case of a single event
    parsed = [ parsed ] if parsed.respond_to?(:to_hash)

    @events = parsed.map { |hash| build_event hash }

    true
  rescue JSON::ParserError => parser_error
    errors << "Bad JSON: #{parser_error.message}"

    false
  end

  def validate_events
    @events.each do |event|
      unless event.valid?
        event.errors.full_messages.each { |error| errors << error }
      end
    end

    valid?
  end

  def persist_events
    @events.each &:save!

    true
  rescue ActiveRecord::RecordInvalid => invalid_record_error
    # An unexpected event saving error occured. Raising an ActiveRecord::RecordInvalid instead,
    # since we don't really know if any other events could have been saved, so providing
    # a single error message would be confusing
    raise ActiveRecord::RecordInvalid.new(self)
  end 

  def valid?
    errors.none?
  end
  
  def build_event(hash)
    Event.new(hash.select { |key, _| Event.accessible_attribute? key })
  end
end
