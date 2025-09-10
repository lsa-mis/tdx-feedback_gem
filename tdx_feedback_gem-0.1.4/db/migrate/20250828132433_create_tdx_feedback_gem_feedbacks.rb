# frozen_string_literal: true

class CreateTdxFeedbackGemFeedbacks < ActiveRecord::Migration[6.1]
  def change
    create_table :tdx_feedback_gem_feedbacks do |t|
      t.text :message, null: false
      t.text :context
      t.timestamps
    end

    add_index :tdx_feedback_gem_feedbacks, :created_at
  end
end
