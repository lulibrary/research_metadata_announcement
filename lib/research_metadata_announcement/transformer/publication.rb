module ResearchMetadataAnnouncement

  module Transformer

    # Extracts publication metadata from the Pure Research Information System and
    # converts it into an announcement
    #
    class Publication < ResearchMetadataAnnouncement::Transformer::Base

      # @param config [Hash]
      # @option config [String] :url The URL of the Pure host.
      # @option config [String] :username The username of the Pure host account.
      # @option config [String] :password The password of the Pure host account.
      def initialize(config)
        super
        make_extractor :publication
      end

      private

      def prepare_uri
        uri = strip_uri_scheme @resource.dois[0] if @resource && @resource.dois[0]
        handle_resolver uri
      end

    end

  end

end
