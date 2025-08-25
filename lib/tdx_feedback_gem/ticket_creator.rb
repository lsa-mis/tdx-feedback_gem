# frozen_string_literal: true

module TdxFeedbackGem
  class TicketCreator
    Result = Struct.new(:success?, :ticket_id, :response, :error)

    def initialize(config: TdxFeedbackGem.config, client: nil)
      @config = config
      @client = client || build_client_from_config(config)
    end

    # Creates a ticket using the TDX API based on a Feedback record
    # Returns Result(success?, ticket_id, response, error)
    def call(feedback, requestor_email: nil, extra_attributes: {})
      return Result.new(false, nil, nil, 'Ticket creation disabled') unless @config.enable_ticket_creation

      title = [@config.title_prefix, feedback.message.to_s.tr("\n", " ")[0, 80]].compact.join(' ')
      description = build_description(feedback)

      payload = {
        'TypeID' => @config.type_id,
        'StatusID' => @config.status_id,
        'SourceID' => @config.source_id,
        'ServiceID' => @config.service_id,
        'ResponsibleGroupID' => @config.responsible_group_id,
        'Title' => title,
        'Description' => description,
        'IsRichHtml' => false
      }

      req_email = requestor_email || @config.default_requestor_email
      payload['RequestorEmail'] = req_email if req_email

      # Merge any extra attributes (e.g., Attributes array etc.)
      payload.merge!(stringify_keys(extra_attributes)) if extra_attributes && !extra_attributes.empty?

      resp = @client.create_ticket(app_id: @config.app_id, payload: payload)
      ticket_id = resp['ID'] || resp.dig('data', 'ID')
      Result.new(true, ticket_id, resp, nil)
    rescue StandardError => e
      Result.new(false, nil, nil, e)
    end

    private

    def build_description(feedback)
      parts = []
      parts << feedback.message.to_s
      if feedback.context && !feedback.context.to_s.strip.empty?
        parts << "\n--- Context ---\n"
        parts << feedback.context.to_s
      end
      parts.join
    end

    def build_client_from_config(config)
      Client.new(
        base_url: config.tdx_base_url,
        token_url: config.oauth_token_url,
        client_id: config.client_id,
        client_secret: config.client_secret,
        scope: config.oauth_scope || 'tdxticket'
      )
    end

    def stringify_keys(hash)
      hash.each_with_object({}) { |(k, v), h| h[k.to_s] = v }
    end
  end
end
