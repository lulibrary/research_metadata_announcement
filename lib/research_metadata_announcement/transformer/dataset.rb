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
        @resource_extractor = Puree::Extractor::Dataset.new config
      end

      # Dataset transformation
      #
      # @param id [String]
      # @param uuid [String]
      # @param format [ResearchMetadataAnnouncement::Format subclass]
      # @return [String, nil] Announcement returned if metadata is available and the announcement length does not exceed the max_length value in format.
      def transform(id: nil, uuid: nil, format: ResearchMetadataAnnouncement::Format::TitleUri.new)
        # fallback option if format cannot be honoured (e.g. no or too many keywords)?
        # space for phrase?
        @resource = extract uuid: uuid, id: id
        return nil if !@resource

        @title = @resource.title
        @uri = @resource.doi if @resource.doi
        @schemeless_uri = strip_uri_scheme @uri if @uri
        @keywords = @resource.keywords if !@resource.keywords.empty?

        return nil if !@uri

        result = nil

        # UriTitleKeywords?
        # UriTitleHashtags?
        case format
          when ResearchMetadataAnnouncement::Format::KeywordsUri
            result = build_keywords_uri(format)
          when ResearchMetadataAnnouncement::Format::HashtagsUri
            result = build_hashtags_uri(format)
          when ResearchMetadataAnnouncement::Format::UriKeywords
            result = build_uri_keywords(format)
          when ResearchMetadataAnnouncement::Format::UriHashtags
            result = build_uri_hashtags(format)
          when ResearchMetadataAnnouncement::Format::TitleUri
            result = build_title_uri(format)
          when ResearchMetadataAnnouncement::Format::UriTitle
            result = build_uri_title(format)
        end

        result
      end

      private

      def build_keywords_uri(format)
        if @keywords
          str = append_sentence build_keywords(format.max_keywords), @schemeless_uri
          if format.length_constrained?
            return str if str.size <= format.max_length
          end
        end
        nil
      end

      def build_hashtags_uri(format)
        if @keywords
          str = append_sentence build_hashtags(format.max_keywords), @schemeless_uri
          if format.length_constrained?
            return str if str.size <= format.max_length
          end
        end
        nil
      end

      def build_uri_keywords(format)
        if @keywords
          str = append_sentence @schemeless_uri, build_keywords(format.max_keywords)
          if format.length_constrained?
            return str if str.size <= format.max_length
          end
        end
        nil
      end

      def build_uri_hashtags(format)
        if @keywords
          str = append_sentence @schemeless_uri, build_hashtags(format.max_keywords)
          if format.length_constrained?
            return str if str.size <= format.max_length
          end
        end
        nil
      end

      def build_title_uri(format)
        if format.length_constrained?
          available_chars = format.max_length - (@schemeless_uri.size + 3)
          available_chars = 0 if available_chars < 0
          if @title.size <= available_chars
            return append_sentence @title, @schemeless_uri
          end
          if available_chars-3 > 0
            truncated_title = @title[0..available_chars-3].strip + '...'
            return "#{truncated_title} #{@schemeless_uri}."
          end
        else
          return append_sentence @title, @schemeless_uri
        end
      end

      def build_uri_title(format)
        if format.length_constrained?
          available_chars = format.max_length - (@schemeless_uri.size + 3)
          available_chars = 0 if available_chars < 0
          if @title.size <= available_chars
            return append_sentence @schemeless_uri, @title
          end
          if available_chars-3 > 0
            truncated_title = @title[0..available_chars-3].strip + '...'
            return "#{@schemeless_uri}. #{truncated_title}"
          end
        else
          return append_sentence @schemeless_uri, @title
        end
      end

      def build_keywords(max)
        return @keywords[0..max-1].join ', ' if @keywords
        nil
      end

      def build_hashtags(max)
        a = @keywords[0..max-1].map { |i| i.downcase }
        a = a.map { |i| i.gsub(/[^a-zA-Z0-9]/,'') }
        a = a.map { |i| i.gsub(/\s+/, '')  }
        a = a.map { |i| "##{i}" }
        if a.size > 0
          return a.join ' '
        else
          return nil
        end
      end

    end

  end

end
