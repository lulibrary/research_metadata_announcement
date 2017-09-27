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

      # Title followed by uri format
      #
      # @param max_length [Fixnum]
      # @return [String, nil] Announcement returned if the metadata is available and the announcement length does not exceed the max_length argument.
      def title_uri(max_length: nil)
        title_formats format: :title_uri_format,
                      max_length: max_length
      end

      # Uri followed by title format
      #
      # @see #title_uri
      def uri_title(max_length: nil)
        title_formats format: :uri_title_format,
                      max_length: max_length
      end

      # Keywords followed by uri format
      #
      # @param max_length [Fixnum] Maximum length of announcement.
      # @param max_descriptors [Fixnum] Maximum number of descriptors (common name for keywords, tags, hashtags).
      # @return [String, nil] Announcement returned if the metadata is available and the announcement length does not exceed the max_length argument.
      def keywords_uri(max_length: nil, max_descriptors: 2)
        descriptors_formats format: :keywords_uri_format,
                            max_length: max_length,
                            max_descriptors: max_descriptors
      end

      # Uri followed by keywords format
      #
      # @see #keywords_uri
      def uri_keywords(max_length: nil, max_descriptors: 2)
        descriptors_formats format: :uri_keywords_format,
                            max_length: max_length,
                            max_descriptors: max_descriptors
      end

      # Hashtags followed by uri format
      #
      # @see #keywords_uri
      def hashtags_uri(max_length: nil, max_descriptors: 2)
        descriptors_formats format: :hashtags_uri_format,
                            max_length: max_length,
                            max_descriptors: max_descriptors
      end

      # Uri followed by hashtags format
      #
      # @see #keywords_uri
      def uri_hashtags(max_length: nil, max_descriptors: 2)
        descriptors_formats format: :uri_hashtags_format,
                            max_length: max_length,
                            max_descriptors: max_descriptors
      end

      private

      def title_formats(format:, max_length:)
        return nil unless @resource
        uri = prepare_uri
        return nil unless uri
        title = @resource.title
        build_title_formats(format: format,
                            uri: uri,
                            title: title,
                            max_length: max_length)
      end

      def descriptors_formats(format:, max_length:, max_descriptors:)
        return nil unless @resource
        uri = prepare_uri
        return nil unless uri
        keywords = @resource.keywords
        return nil if keywords.empty?
        build_descriptors_formats(format: format,
                                  keywords: keywords,
                                  uri: uri,
                                  max_length: max_length,
                                  max_descriptors: max_descriptors)
      end

      def prepare_uri
        strip_uri_scheme @resource.doi if @resource && @resource.doi
      end

      def validate_string_length(str, max_length)
        if length_constrained? max_length
          str if str.size <= max_length
        else
          str
        end
      end

      def build_descriptors_formats(format:, keywords:, uri:, max_length:, max_descriptors:)
        case format
          when :keywords_uri_format
            str = append_sentence(build_keywords(keywords, max_descriptors), uri)
          when :uri_keywords_format
            str = append_sentence(uri, build_keywords(keywords, max_descriptors))
          when :hashtags_uri_format
            str = append_sentence(build_hashtags(keywords, max_descriptors), uri)
          when :uri_hashtags_format
            str = append_sentence(uri, build_hashtags(keywords, max_descriptors))
        end
        validate_string_length str, max_length
      end

      def build_title_format(format:, title:, uri:)
        case format
          when :title_uri_format
            append_sentence title, uri
          when :uri_title_format
            append_sentence uri, title
        end
      end

      def build_title_format_truncated(format:, title:, uri:, available_chars:)
        truncated_title = title[0..available_chars-3].strip + '...'
        case format
          when :title_uri_format
            "#{truncated_title} #{uri}."
          when :uri_title_format
            "#{uri}. #{truncated_title}"
        end
      end

      def build_title_formats(format:, title:, uri:, max_length:)
        if length_constrained? max_length
          available_chars = max_length - (uri.size + 3)
          available_chars = 0 if available_chars < 0
          if title.size <= available_chars
            return build_title_format(format: format,
                                      title: title,
                                      uri: uri)
          end
          if available_chars - 3 > 0
            return build_title_format_truncated(format: format,
                                                title: title,
                                                uri: uri,
                                                available_chars: available_chars)
          end
        else
          build_title_format(format: format,
                             title: title,
                             uri: uri)
        end
      end

      def build_keywords(keywords, max)
        keywords[0..max - 1].join ', '
      end

      def build_hashtags(keywords, max)
        a = keywords[0..max - 1].map(&:downcase)
        a = a.map { |i| i.gsub(/[^a-zA-Z0-9]/, '') }
        a = a.map { |i| i.gsub(/\s+/, '') }
        a = a.map { |i| "##{i}" }
        a.join ' '
      end

    end

  end

end
