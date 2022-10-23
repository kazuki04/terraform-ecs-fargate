module API
    module V1
        class Api::V1::AlbController < ApplicationController
            def healthcheck
                render :json => {:data => "healthy", :status => 200}
            end
        end
    end
end
