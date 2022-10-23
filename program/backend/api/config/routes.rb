Rails.application.routes.draw do
    namespace :api, format: 'json' do
            namespace :v1 do
            get '/healthcheck' =>'alb#healthcheck'
        end
    end
end
