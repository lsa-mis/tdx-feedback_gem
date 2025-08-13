# frozen_string_literal: true

module TdxFeedbackGem
  class FeedbacksController < ActionController::Base
    protect_from_forgery with: :exception, unless: -> { request.format.json? }
    skip_forgery_protection only: [:new]
    skip_forgery_protection only: [:create], if: -> { Rails.env.test? }

    before_action :ensure_authenticated

    def new
      @feedback = Feedback.new
      render :new
    end

    def create
      feedback = Feedback.new(feedback_params)
      if feedback.save
        ticket_id = nil
        if TdxFeedbackGem.config.enable_ticket_creation
          email = if respond_to?(:current_user, true) && current_user && current_user.respond_to?(:email)
                    current_user.email
                  end
          result = TicketCreator.new.call(feedback, requestor_email: email)
          if result.success?
            ticket_id = result.ticket_id
            flash[:notice] = 'Thank you for your feedback. A support ticket has been created.' if request.format.html?
          else
            Rails.logger.warn("TDX ticket creation failed: #{result.error}")
            flash[:alert] = 'Thank you for your feedback. (Ticket creation failed.)' if request.format.html?
          end
        end
        respond_to do |format|
          format.html { redirect_to main_app.root_path, notice: flash[:notice] || 'Thank you for your feedback.' }
          format.json { render json: { id: feedback.id, ticket_id: ticket_id }, status: :created }
        end
      else
        respond_to do |format|
          format.html do
            @feedback = feedback
            render :new, status: :unprocessable_entity
          end
          format.json { render json: { errors: feedback.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    private

    def feedback_params
      params.require(:feedback).permit(:message, :context)
    end

    def ensure_authenticated
      return unless TdxFeedbackGem.config.require_authentication

      head :unauthorized unless respond_to?(:current_user, true) && current_user
    end
  end
end
