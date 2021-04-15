class VolunteersController < ApplicationController
    before_action :authorize_request

    def index
        volunteers = Volunteer.all
        render json: volunteers
    end

    def my_volunteerings
        volunteering = Volunteer.where(user_id: @current_user.id)
        if volunteering
            render json: volunteering, :include => {
                :request => {
                    :only => [:id, :title, :need, :description, :lat, :lng, :address, :status],
                    :include => {
                        :user => {
                            :only => [:id, :firstname, :lastname]
                        }
                    }
                }
            },
            status: :ok
        else
            render json: {
                status: 'no content',
                message: 'No volunteering found'
            },
            status: :no_content
        end
    end

    def create
        total_volunteers = Volunteer.where(request_id: params[:request_id])
    
        if total_volunteers.length() == 4
            
            the_request = Request.find_by_id(params[:request_id])
            the_request.status = 1
            if the_request.save

                volunteer = Volunteer.new({request_id: params[:request_id], requester_id: params[:requester_id], user_id: @current_user.id})
                if volunteer.save
                    render json: {
                        status: 'success',
                        message:  'Your volunteering was successful',
                        data: volunteer,
                    },
                    status: :created
                else
                    render json: {
                        status: 'error',
                        message: 'Volunteering not saved',
                        data: volunteer.errors
                    },
                    status: :unprocessable_entity
                end
            else
                render json: {
                    status: 'error',
                    message: 'Volunteering not saved',
                    data: volunteer.errors
                },
                status: :unprocessable_entity
            end

        else
            volunteer = Volunteer.new({request_id: params[:request_id], requester_id: params[:requester_id], user_id: @current_user.id})
            if volunteer.save
                render json: {
                    status: 'success',
                    message:  'Your volunteering was successful',
                    data: volunteer,
                },
                status: :created
            else
                render json: {
                    status: 'error',
                    message: 'Volunteering not saved',
                    data: volunteer.errors
                },
                status: :unprocessable_entity
            end
        end
    end
end
