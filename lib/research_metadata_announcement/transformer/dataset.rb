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

      # Keywords followed by uri format
      #
      # @param max_length [Fixnum] Maximum length of announcement.
      # @param max_descriptors [Fixnum] Maximum number of descriptors (common name for keywords, tags, hashtags).
      # @return [String, nil] Announcement returned if the metadata is available and the announcement length does not exceed the max_length argument.
      def keywords_uri(max_length: nil, max_descriptors: 2)
        return nil if !@resource
        keywords = @resource.keywords
        uri = prepare_uri
        if uri
          return build_keywords_uri(keywords: keywords,
                                    uri: uri,
                                    max_length: max_length,
                                    max_descriptors: max_descriptors)
        end
        nil
      end

      # Uri followed by keywords format
      #
      # @see #keywords_uri
      def uri_keywords(max_length: nil, max_descriptors: 2)
        return nil if !@resource
        keywords = @resource.keywords
        uri = prepare_uri
        if uri
          return build_uri_keywords(keywords: keywords,
                                    uri: uri,
                                    max_length: max_length,
                                    max_descriptors: max_descriptors)
        end
        nil
      end

      # Uri followed by hashtags format
      #
      # @see #keywords_uri
      def uri_hashtags(max_length: nil, max_descriptors: 2)
        return nil if !@resource
        keywords = @resource.keywords
        uri = prepare_uri
        if uri
          return build_uri_hashtags(keywords: keywords,
                                    uri: uri,
                                    max_length: max_length,
                                    max_descriptors: max_descriptors)
        end
        nil
      end

      # Hashtags followed by uri format
      #
      # @see #keywords_uri
      def hashtags_uri(max_length: nil, max_descriptors: 2)
        return nil if !@resource
        keywords = @resource.keywords
        uri = prepare_uri
        if uri
          return build_hashtags_uri(keywords: keywords,
                                    uri: uri,
                                    max_length: max_length,
                                    max_descriptors: max_descriptors)
        end
        nil
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

      private

      def title_formats(format:, max_length: nil)
        return nil if !@resource
        uri = prepare_uri
        title = @resource.title
        if uri
          case format
            when :title_uri_format
              return build_title_uri(uri: uri,
                                     title: title,
                                     max_length: max_length)
            when :uri_title_format
              return build_uri_title(uri: uri,
                                     title: title,
                                     max_length: max_length)
          end
        end
        nil
      end

      def prepare_uri
        if @resource && @resource.doi
          return strip_uri_scheme @resource.doi
        end
        nil
      end

      def build_keywords_uri(keywords:, uri:, max_length:, max_descriptors:)
        if !keywords.empty?
          str = append_sentence(build_keywords(keywords, max_descriptors), uri)
          if length_constrained? max_length
            return str if str.size <= max_length
          else
            return str
          end
        end
        nil
      end

      def build_uri_keywords(keywords:, uri:, max_length:, max_descriptors:)
        if !keywords.empty?
          str = append_sentence(uri, build_keywords(keywords, max_descriptors))
          if length_constrained? max_length
            return str if str.size <= max_length
          else
            return str
          end
        end
        nil
      end

      def build_uri_hashtags(keywords:, uri:, max_length:, max_descriptors:)
        if !keywords.empty?
          str = append_sentence(uri, build_hashtags(keywords, max_descriptors))
          if length_constrained? max_length
            return str if str.size <= max_length
          else
            return str
          end
        end
        nil
      end

      def build_hashtags_uri(keywords:, uri:, max_length:, max_descriptors:)
        if !keywords.empty?
          str = append_sentence(build_hashtags(keywords, max_descriptors), uri)
          if length_constrained? max_length
            return str if str.size <= max_length
          else
            return str
          end
        end
        nil
      end

      def build_title_uri(title:, uri:, max_length:)
        if length_constrained? max_length
          available_chars = max_length - (uri.size + 3)
          available_chars = 0 if available_chars < 0
          if title.size <= available_chars
            return append_sentence title, uri
          end
          if available_chars-3 > 0
            truncated_title = title[0..available_chars-3].strip + '...'
            return "#{truncated_title} #{uri}."
          end
        else
          return append_sentence title, uri
        end
      end

      def build_uri_title(uri:, title:, max_length:)
        if length_constrained? max_length
          available_chars = max_length - (uri.size + 3)
          available_chars = 0 if available_chars < 0
          if title.size <= available_chars
            return append_sentence uri, title
          end
          if available_chars-3 > 0
            truncated_title = title[0..available_chars-3].strip + '...'
            return "#{uri}. #{truncated_title}"
          end
        else
          return append_sentence uri, title
        end
      end

      def build_keywords(keywords, max)
        return keywords[0..max-1].join ', ' if keywords
        nil
      end

      def build_hashtags(keywords, max)
        a = keywords[0..max-1].map { |i| i.downcase }
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
