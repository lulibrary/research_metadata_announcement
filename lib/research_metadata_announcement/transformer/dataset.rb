module ResearchMetadataAnnouncement

  module Transformer

    # Extracts dataset metadata from the Pure Research Information System and
    # converts it into an announcement
    #
    class Dataset < ResearchMetadataAnnouncement::Transformer::Base

      # @option (see ResearchMetadataAnnouncement::Transformer::Base::Resource#initialize)
      def initialize(config)
        super
        make_extractor :dataset
      end

    end

  end

end
