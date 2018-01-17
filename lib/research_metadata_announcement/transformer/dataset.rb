module ResearchMetadataAnnouncement

  module Transformer

    # Extracts dataset metadata from the Pure Research Information System and
    # converts it into an announcement
    #
    class Dataset < ResearchMetadataAnnouncement::Transformer::Base

      # @param config [Hash]
      # @option config [String] :url The URL of the Pure host.
      # @option config [String] :username The username of the Pure host account.
      # @option config [String] :password The password of the Pure host account.
      def initialize(config)
        super
        make_extractor :dataset
      end

      private

      def prepare_uri
        uri = strip_uri_scheme @resource.doi if @resource && @resource.doi
        handle_resolver uri
      end

    end

  end

end
