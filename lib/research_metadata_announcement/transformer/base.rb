module ResearchMetadataAnnouncement
  module Transformer

    # Base transformer
    #
    class Base

      # @param config [Hash]
      # @option config [String] :url The URL of the Pure host.
      # @option config [String] :username The username of the Pure host account.
      # @option config [String] :password The password of the Pure host account.

      def initialize(config)
        @config = config
      end

      # Extract metadata from Pure
      #
      # @param id [String]
      # @param uuid [String]
      def extract(uuid: nil, id: nil)
        if !uuid.nil?
          @resource = @resource_extractor.find uuid: uuid
        else
          @resource = @resource_extractor.find id: id
        end
      end

      private

      def append_sentence(str, str_to_append)
        if str_to_append && str_to_append.size > 0
          if str
            if str.size > 0
              "#{str}. #{str_to_append}."
            else
              "#{str_to_append}."
            end
          end
        else
          str
        end
      end

      def strip_uri_scheme(uri)
        uri.sub /^.+\/\//, ''
      end

      def length_constrained?(max_length)
        max_length && max_length > 0
      end

    end
  end

end
