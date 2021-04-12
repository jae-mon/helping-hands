class RequestsController < ApplicationController
    before_action :authorize_request, except: [:request_counter]


    def index
        requests = Request.where(status: 0)
        if requests
            render json: requests, :include => {
                :user => {
                    :only => [:id, :firstname, :lastname]
                }
            },
            status: :ok
        else
            render status: :unprocessable_entity
        end
    end
 
    
    def create
        request = Request.new({title: params[:title], need: params[:need], description: params[:description],
            lat: params[:lat], lng: params[:lng], address: params[:address], status: params[:status], user_id: @current_user.id})
        if request.save
            render json: {
                status: 'success',
                message: 'Request added successfully',
                data: request
            },
            status: :created
        else 
            render json: {
                status: 'error',
                message: 'Request not saved',
                data: request.errors
            },
            status: :unprocessable_entity
        end
    end

    def show
        request = Request.includes(:user).find_by_id(params[:id])
        if request
            render json: request, :include => {
                :user => {
                    :only => [:id, :firstname, :lastname, :email]
                },
                :volunteers => {
                    :only => [:id, :user_id, :created_at],
                    :include => {
                        :user => {
                            :only => [:id, :firstname, :lastname, :email]
                        }
                    }
                }
            },
            status: :ok
        else 
            render json: {
                status: 'error',
                message: 'Request not found',
            },
            status: :unprocessable_entity
        end
    end


    def my_request
        request = Request.where(user_id: @current_user.id)
        if request
            render json: {
                status: 'success',
                message: 'Requests found',
                data: request,
            },
            status: :ok
        else 
            render json: {
                status: 'no-content',
                message: 'Requests not found',
            },
            status: :no_content
        end
    end


    def update
        request = Request.find_by_id(params[:id])
        if request
            request.status = 1
            if request.save
                render json: {
                    status: 'success',
                    message: 'Request marked as fulfilled',
                },
                status: :ok
            else
                render json: {
                    status: 'error',
                    message: 'Request failed',
                    data: request.errors,
                },
                status: :unprocessable_entity
            end
        else
            render status: :unauthorized
        end
    end

    
    def destroy
        request = Request.find_by_id(params[:id])
        if request
            
            request.destroy
            render json: {
                status: 'success',
                message: 'Request deleted',
            },
            status: :ok
        else
            render status: :unauthorized
        end
    end
    
    
    
    def republish
        request = Request.find_by_id(params[:request_id])
        if request
            request.republish_status = !request.republish_status
            if request.save
                volunteers = Volunteer.where(request_id: params[:request_id])
                if volunteers
                    
                    volunteers.destroy_all
                    render json: {
                        status: 'success',
                        message: 'Request republished',
                        data: request,
                    },
                    status: :ok
                else
                    render json: {
                        status: 'error',
                        message: 'Unable to republish this request'
                    },
                    status: :unprocessable_entity
                end
            end
        else
            render status: :unauthorized
        end
    end

    
    def request_counter
        unfulfilled = Request.where(status: 0)
        fulfilled = Request.where(status: 1)
        if unfulfilled && fulfilled
            render json: {
                status: 'success',
                message: 'Your requests counter result',
                data: {
                    unfulfilled: unfulfilled.length(),
                    fulfilled: fulfilled.length()
                }
            },
            status: :ok
        else
            render status: :unprocessable_entity
        end
    end

    private
    def request_params
        params.permit(:title, :need, :description, :lat, :lng, :address, :status)
    end

end

