class UsersController < ApplicationController
    before_action :authorize_request, except: [:create, :login, :index]

    
    def index
        user = User.order('id DESC')
        render json: {
            status: 'success',
            message: 'Users counter result',
            data: user.length()
        },
        status: :ok
    end

    
    def create
        if User.exists?(email: params[:email])
            render json: {
                status: 'warning',
                message: 'User already exists',
            },
            status: :unprocessable_entity
        else
            # upload user image to cloudinary
            value = Cloudinary::Uploader.upload(params[:image], :folder => 'HelpingHands')
            # create a new user object and save it to the database
            user = User.new({firstname: params[:firstname], lastname: params[:lastname], email: params[:email], password: params[:password], image: value['secure_url']})
            if user.save
                # generate token for the user
                token = encode_token({user_id: user.id, firstname: user.firstname, lastname: user.lastname, email: user.email})
                render json: {
                    status: 'success',
                    message: 'User created',
                    data: user,
                    token: token,
                },
                status: :created
            else 
                render json: {
                    status: 'error',
                    message: 'User not created',
                    data: user.errors,
                },
                status: :unprocessable_entity
            end
        end
    end

    
    def login
        user = User.find_by_email(params[:email])
        if user&.authenticate(params[:password])
            # generate user token
            token = encode_token({user_id: user.id, firstname: user.firstname, lastname: user.lastname, email: user.email})
            render json: {
                status: 'success',
                message: 'Login successful',
                token: token,
            },
            status: :ok
        else
            render json: {
                status: 'error',
                message: 'Incorrect email or password',
            },
            status: :unprocessable_entity
        end 
    end
    
    private
    def user_params
        params.permit(:firstname, :lastname, :email, :password, :image)
    end
    
    SECRET_KEY = Rails.application.secrets.secret_key_base. to_s
    
    def encode_token(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY) 
    end
end
