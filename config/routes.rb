Timetracker::Application.routes.draw do
  resources :events, only: :index
  resource :event_upload, only: :create, path: '/upload'
end
