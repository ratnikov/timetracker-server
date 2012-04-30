class EventUploadsController < ApplicationController
  def create
    upload = EventUpload.new params[:upload]

    if upload.save
      render :json => upload.to_json
    else
      render :json => upload.to_json, :status => 400
    end
  end
end
