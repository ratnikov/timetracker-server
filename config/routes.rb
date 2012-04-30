Timetracker::Application.routes.draw do
  resource :event_upload, only: :create, path: '/upload'
end
