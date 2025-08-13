# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TdxFeedbackGem::Feedback, type: :model do
  it 'is invalid without a message' do
    fb = described_class.new(message: nil)
    expect(fb.valid?).to be false
    expect(fb.errors[:message]).not_to be_empty
  end

  it 'is valid with a message' do
    fb = described_class.new(message: 'Hello')
    expect(fb.valid?).to be true
  end
end
