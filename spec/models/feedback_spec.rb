# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TdxFeedbackGem::Feedback, type: :model do
  describe 'validations' do
    describe 'message' do
      it 'is invalid without a message' do
        feedback = described_class.new(message: nil)
        expect(feedback.valid?).to be false
        expect(feedback.errors[:message]).to include("can't be blank")
      end

      it 'is invalid with an empty message' do
        feedback = described_class.new(message: '')
        expect(feedback.valid?).to be false
        expect(feedback.errors[:message]).to include("can't be blank")
      end

      it 'is invalid with a whitespace-only message' do
        feedback = described_class.new(message: '   ')
        expect(feedback.valid?).to be false
        expect(feedback.errors[:message]).to include("can't be blank")
      end

      it 'is valid with a message' do
        feedback = described_class.new(message: 'Hello world')
        expect(feedback.valid?).to be true
      end

      it 'is valid with a long message' do
        feedback = described_class.new(message: 'A' * 1000)
        expect(feedback.valid?).to be true
      end
    end

    describe 'context' do
      it 'is valid without context' do
        feedback = described_class.new(message: 'Hello', context: nil)
        expect(feedback.valid?).to be true
      end

      it 'is valid with empty context' do
        feedback = described_class.new(message: 'Hello', context: '')
        expect(feedback.valid?).to be true
      end

      it 'is valid with short context' do
        feedback = described_class.new(message: 'Hello', context: 'Test context')
        expect(feedback.valid?).to be true
      end

      it 'is valid with context at maximum length' do
        feedback = described_class.new(message: 'Hello', context: 'A' * 10_000)
        expect(feedback.valid?).to be true
      end

      it 'is invalid with context exceeding maximum length' do
        feedback = described_class.new(message: 'Hello', context: 'A' * 10_001)
        expect(feedback.valid?).to be false
        expect(feedback.errors[:context]).to include('is too long (maximum is 10000 characters)')
      end
    end
  end

  describe 'database operations' do
    it 'can be created and saved' do
      feedback = described_class.create!(message: 'Test feedback', context: 'Test context')
      expect(feedback.persisted?).to be true
      expect(feedback.id).to be_present
    end

    it 'can be found by id' do
      feedback = described_class.create!(message: 'Test feedback')
      found_feedback = described_class.find(feedback.id)
      expect(found_feedback.message).to eq('Test feedback')
    end

    it 'can be updated' do
      feedback = described_class.create!(message: 'Original message')
      feedback.update!(message: 'Updated message')
      expect(feedback.reload.message).to eq('Updated message')
    end

    it 'can be deleted' do
      feedback = described_class.create!(message: 'Test feedback')
      feedback_id = feedback.id
      feedback.destroy
      expect { described_class.find(feedback_id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'table name' do
    it 'uses the correct table name' do
      expect(described_class.table_name).to eq('tdx_feedback_gem_feedbacks')
    end
  end

  describe 'timestamps' do
    it 'automatically sets created_at and updated_at' do
      feedback = described_class.create!(message: 'Test feedback')
      expect(feedback.created_at).to be_present
      expect(feedback.updated_at).to be_present
    end

    it 'updates updated_at when record is modified' do
      feedback = described_class.create!(message: 'Test feedback')
      original_updated_at = feedback.updated_at
      sleep(0.1) # Ensure time difference
      feedback.update!(message: 'Updated message')
      expect(feedback.updated_at).to be > original_updated_at
    end
  end
end
