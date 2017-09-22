module ResearchMetadataAnnouncement

  module Format

    # Base announcement format. Do not use this directly.
    #
    class Base
      attr_accessor :max_length

      # @param max_length [Fixnum]
      def initialize(max_length: nil)
        @max_length = max_length
      end

      # Does the format specify a maximum length?
      #
      # @return [Boolean]
      def length_constrained?
        @max_length && @max_length > 0
      end

    end

  end
end