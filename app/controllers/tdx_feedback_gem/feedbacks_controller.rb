# frozen_string_literal: true

module TdxFeedbackGem
  class FeedbacksController < ActionController::Base
    protect_from_forgery with: :exception, unless: -> { request.format.json? }

    # Skip CSRF protection for these actions
    skip_forgery_protection only: [:new, :create]

    # Class method to check which actions skip forgery protection (for testing)
    def self.skip_forgery_protection_actions
      [:new, :create]
    end

    before_action :ensure_authenticated

    def new
      @feedback = Feedback.new
      render json: {
        html: render_to_string(partial: 'modal', locals: { feedback: @feedback }, formats: [:html])
      }
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
            flash_message = 'Thank you for your feedback. A support ticket has been created.'
          else
            Rails.logger.warn("TDX ticket creation failed: #{result.error}")
            flash_message = 'Thank you for your feedback. (Ticket creation failed.)'
          end
        else
          flash_message = 'Thank you for your feedback.'
        end

        render json: {
          success: true,
          message: flash_message,
          feedback_id: feedback.id,
          ticket_id: ticket_id
        }, status: :created
      else
        render json: {
          success: false,
          errors: feedback.errors.full_messages,
          html: render_to_string(partial: 'form', locals: { feedback: feedback }, formats: [:html])
        }, status: :unprocessable_entity
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
