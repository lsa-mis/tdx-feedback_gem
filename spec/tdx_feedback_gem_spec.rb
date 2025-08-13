# frozen_string_literal: true

require 'tdx_feedback_gem'

RSpec.describe TdxFeedbackGem do
  it 'has a version number' do
    expect(TdxFeedbackGem::VERSION).not_to be nil
  end

  it 'has a configurable setting' do
    original = TdxFeedbackGem.config.require_authentication
    begin
      TdxFeedbackGem.configure { |c| c.require_authentication = true }
      expect(TdxFeedbackGem.config.require_authentication).to be true
    ensure
      TdxFeedbackGem.configure { |c| c.require_authentication = original }
    end
  end
end
