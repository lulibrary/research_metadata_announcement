module ResearchMetadataAnnouncement

  module Transformer

    # Extracts research output metadata from the Pure Research Information System and
    # converts it into an announcement
    #
    class ResearchOutput < ResearchMetadataAnnouncement::Transformer::Base

      # @option (see ResearchMetadataAnnouncement::Transformer::Base::Resource#initialize)
      def initialize(config)
        super
        make_extractor :research_output
      end

    end

  end

end
