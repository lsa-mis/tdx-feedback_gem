# frozen_string_literal: true

module TdxFeedbackGem
  module ApplicationHelper
    # Renders the feedback modal HTML (hidden by default)
    def render_feedback_modal
      render partial: 'tdx_feedback_gem/feedbacks/modal',
             locals: { feedback: TdxFeedbackGem::Feedback.new }
    end

    # Renders a feedback link that opens the modal
    def feedback_link(text = 'Feedback', options = {})
      options = options.merge(
        href: '#',
        data: {
          controller: 'tdx-feedback',
          action: 'click->tdx-feedback#open',
          'tdx-feedback-target': 'trigger'
        }.merge(options[:data] || {}),
        class: "tdx-feedback-link #{options[:class]}".strip
      )

      content_tag(:a, text, options)
    end

    # Renders a feedback button that opens the modal
    def feedback_button(text = 'Send Feedback', options = {})
      options = options.merge(
        type: 'button',
        data: {
          controller: 'tdx-feedback',
          action: 'click->tdx-feedback#open',
          'tdx-feedback-target': 'trigger'
        }.merge(options[:data] || {}),
        class: "tdx-feedback-button #{options[:class]}".strip
      )

      content_tag(:button, text, options)
    end

    # Renders a feedback icon/link (useful for headers/footers)
    def feedback_icon(options = {})
      options = options.merge(
        href: '#',
        data: {
          controller: 'tdx-feedback',
          action: 'click->tdx-feedback#open',
          'tdx-feedback-target': 'trigger'
        }.merge(options[:data] || {}),
        class: "tdx-feedback-icon #{options[:class]}".strip,
        title: 'Send Feedback'
      )

      content_tag(:a, options) do
        content_tag(:svg,
                   viewBox: '0 0 24 24',
                   fill: 'currentColor',
                   class: 'tdx-feedback-icon-svg') do
          content_tag(:path, '',
                     d: 'M20 2H4c-1.1 0-1.99.9-1.99 2L2 22l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-7 12h-2v-2h2v2zm0-4h-2V6h2v4z')
        end
      end
    end

    # Renders a complete feedback section (modal + trigger)
    def feedback_system(options = {})
      trigger_type = options[:trigger] || :link
      trigger_text = options[:text] || 'Feedback'
      trigger_class = options[:class] || ''

      safe_join([
        render_feedback_modal,
        case trigger_type
        when :button
          feedback_button(trigger_text, class: trigger_class)
        when :icon
          feedback_icon(class: trigger_class)
        else
          feedback_link(trigger_text, class: trigger_class)
        end
      ])
    end

    # Renders a feedback link suitable for a footer
    def feedback_footer_link
      feedback_link('Feedback', class: 'tdx-feedback-footer-link')
    end

    # Renders a feedback button suitable for a header
    def feedback_header_button
      feedback_button('Feedback', class: 'tdx-feedback-header-button')
    end

    # Renders a feedback trigger with Stimulus controller
    def feedback_trigger(options = {})
      options = options.merge(
        data: {
          controller: 'tdx-feedback',
          action: 'click->tdx-feedback#open'
        }.merge(options[:data] || {})
      )

      case options[:type]&.to_sym
      when :button
        feedback_button(options[:text] || 'Feedback', options)
      when :icon
        feedback_icon(options)
      else
        feedback_link(options[:text] || 'Feedback', options)
      end
    end
  end
end
