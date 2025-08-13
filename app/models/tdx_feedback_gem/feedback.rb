# frozen_string_literal: true

module TdxFeedbackGem
  class Feedback < ActiveRecord::Base
    self.table_name = 'tdx_feedback_gem_feedbacks'

    validates :message, presence: true
    validates :context, length: { maximum: 10_000 }, allow_nil: true
  end
end
