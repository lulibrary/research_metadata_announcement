module ResearchMetadataAnnouncement

  module Format

    # Descriptors format. Do not use this directly.
    #
    class Descriptors < ResearchMetadataAnnouncement::Format::Base
      attr_accessor :max_keywords

      def initialize(max_length: nil, max_keywords: 2)
        @max_length = max_length
        @max_keywords = max_keywords
      end
    end

  end
end