class MessagesController < ApplicationController
    before_action :authorize_request

            
            def create
                mesg = Message.new({user_id: @current_user.id, receiver_id: params[:receiver_id], content: params[:content], request_id: params[:request_id]})
                if mesg.save
                    render json: {
                        status: 'success',
                        message: 'Your message was sent',
                        data: mesg,
                    },
                    status: :created
                else
                    render json: {
                        status: 'error',
                        message: 'Message not sent',
                        data: mesg.errors
                    },
                    status: :unprocessable_entity
                end
            end

            
            def my_messages
                my_mesgs = Message.includes(:user).where(receiver_id: @current_user.id).order(created_at: :desc)
                if my_mesgs.any?
                    render json: my_mesgs, :include => {
                        :user => {
                            :only => [:id, :firstname, :lastname]
                        }
                    },
                    status: :ok
                else
                    render json: {
                        status: 'no-content',
                        message: 'You don\'t have any message yet',
                        data: []
                    },
                    status: :no_content
                end
            end

            
            
            def update_read_status
                
                the_mesg = Message.find_by(receiver_id: @current_user.id, user_id: params[:user_id], request_id: params[:request_id], read_status: 0)
                if the_mesg
                    the_mesg.read_status = 1
                    if the_mesg.save
                        render json: {
                            status: 'success',
                            message: 'Read status updated',
                            data: the_mesg
                        }    
                    else
                        render json: {
                            status: 'error',
                            message: 'Unable to update read receipts'
                        },
                        status: :unprocessable_entity
                    end
                end
            end

            
            def get_chat_messages
        
                chats = Message.includes(:user).where(receiver_id: @current_user.id, user_id: params[:user_id], request_id: params[:request_id]).or(Message.includes(:user).where(user_id: @current_user.id, receiver_id: params[:user_id], request_id: params[:request_id])).order(created_at: :asc)
                if chats.any?
                    render json: chats, :include => {
                        :user => {
                            :only => [:id, :firstname, :lastname]
                        },
                    },
                    status: :ok
                else
                    render json: {
                        status: 'no-content',
                        message: 'No chat on this request yet'
                    },
                    status: :no_content
                end
            end


            
            def message_notifications
                notifications = Message.where(receiver_id: @current_user.id, read_status: 0)
               if notifications
                    render json: {
                        status: 'success',
                        message: 'Your notifications',
                        data: notifications.length()
                    },
                    status: :ok
                end
            end
    
end
