# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TdxFeedbackGem::ApplicationHelper, type: :helper do
  describe '#feedback_link' do
    it 'includes the correct data attributes' do
      result = helper.feedback_link('Test Feedback')

      expect(result).to include('data-controller="tdx-feedback"')
      # In test output, Rails escapes -> to &gt;
      expect(result).to include('data-action="click-&gt;tdx-feedback#open"')
      expect(result).to include('data-tdx-feedback-target="trigger"')
    end

    it 'renders with custom text' do
      result = helper.feedback_link('Custom Text')
      expect(result).to include('Custom Text')
    end

    it 'merges custom data attributes' do
      result = helper.feedback_link('Test', data: { custom: 'value' })

      expect(result).to include('data-controller="tdx-feedback"')
      expect(result).to include('data-custom="value"')
    end
  end

  describe '#feedback_button' do
    it 'includes the correct data attributes' do
      result = helper.feedback_button('Test Button')

      expect(result).to include('data-controller="tdx-feedback"')
      # In test output, Rails escapes -> to &gt;
      expect(result).to include('data-action="click-&gt;tdx-feedback#open"')
      expect(result).to include('data-tdx-feedback-target="trigger"')
    end

    it 'renders as a button element' do
      result = helper.feedback_button('Test')
      expect(result).to include('<button')
      expect(result).to include('type="button"')
    end
  end

  describe '#feedback_icon' do
    it 'includes the correct data attributes' do
      result = helper.feedback_icon

      expect(result).to include('data-controller="tdx-feedback"')
      # In test output, Rails escapes -> to &gt;
      expect(result).to include('data-action="click-&gt;tdx-feedback#open"')
      expect(result).to include('data-tdx-feedback-target="trigger"')
    end

    it 'renders an SVG icon' do
      result = helper.feedback_icon
      expect(result).to include('<svg')
      expect(result).to include('viewBox="0 0 24 24"')
    end
  end

  describe '#feedback_system' do
    before do
      # Mock the render_feedback_modal method to avoid template issues in tests
      allow(helper).to receive(:render_feedback_modal).and_return('<div class="tdx-feedback-modal">Modal</div>')
    end

    it 'renders modal and trigger' do
      result = helper.feedback_system

      expect(result).to include('tdx-feedback-modal')
      expect(result).to include('data-controller="tdx-feedback"')
    end

    it 'renders button trigger when specified' do
      result = helper.feedback_system(trigger: :button)
      expect(result).to include('<button')
    end

    it 'renders icon trigger when specified' do
      result = helper.feedback_system(trigger: :icon)
      expect(result).to include('<svg')
    end
  end

  describe '#feedback_trigger' do
    it 'includes the correct data attributes' do
      result = helper.feedback_trigger

      expect(result).to include('data-controller="tdx-feedback"')
      # In test output, Rails escapes -> to &gt;
      expect(result).to include('data-action="click-&gt;tdx-feedback#open"')
    end

    it 'renders button when type is button' do
      result = helper.feedback_trigger(type: :button)
      expect(result).to include('<button')
    end

    it 'renders icon when type is icon' do
      result = helper.feedback_trigger(type: :icon)
      expect(result).to include('<svg')
    end
  end
end
