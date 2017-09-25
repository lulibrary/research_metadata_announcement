module ResearchMetadataAnnouncement

  module Transformer

    # Extracts dataset metadata from the Pure Research Information System and
    # converts it into an announcement
    #
    class Dataset < ResearchMetadataAnnouncement::Transformer::Base

      # @return [String] Title followed by uri format.
      attr_reader :title_uri

      # @return [String] Uri followed by title format.
      attr_reader :uri_title

      # @return [String] Keywords followed by uri format.
      attr_reader :keywords_uri

      # @return [String] Hashtags followed by uri format.
      attr_reader :hashtags_uri

      # @return [String] Uri followed by keywords format.
      attr_reader :uri_keywords

      # @return [String] Uri followed by hashtags format.
      attr_reader :uri_hashtags

      # @param config [Hash]
      # @option config [String] :url The URL of the Pure host.
      # @option config [String] :username The username of the Pure host account.
      # @option config [String] :password The password of the Pure host account.
      def initialize(config)
        super
        @resource_extractor = Puree::Extractor::Dataset.new config
      end

      # Preprocessing of all announcement formats.
      #
      # @param max_length [Fixnum] Maximum length of announcement.
      # @param max_descriptors [Fixnum] Maximum number of descriptors, the common name for both keywords and hashtags.
      def transform(uuid: nil, id: nil, max_length: nil, max_descriptors: 2)
        extract uuid: uuid, id: id
        return if !@resource
        @uri = prepare_uri
        @title_uri = prepare_title_uri max_length: max_length
        @uri_title = prepare_uri_title max_length: max_length
        @keywords_uri = prepare_keywords_uri max_length: max_length, max_descriptors: max_descriptors
        @uri_keywords = prepare_uri_keywords max_length: max_length, max_descriptors: max_descriptors
        @uri_hashtags = prepare_uri_hashtags max_length: max_length, max_descriptors: max_descriptors
        @hashtags_uri = prepare_hashtags_uri max_length: max_length, max_descriptors: max_descriptors
        return
      end


      private

      # Keywords followed by uri format
      #
      # @param max_length [Fixnum]
      # @param max_descriptors [Fixnum]
      # @return [String, nil] Announcement returned if metadata is available and the announcement length does not exceed the max_length value in format.
      def prepare_keywords_uri(max_length:, max_descriptors:)
        return nil if !@resource
        keywords = @resource.keywords
        if @uri && !keywords.empty?
          return build_keywords_uri(keywords: keywords,
                                    uri: @uri,
                                    max_length: max_length,
                                    max_descriptors: max_descriptors)
        end
      end

      # Uri followed by keywords format
      #
      # @param max_length [Fixnum]
      # @param max_descriptors [Fixnum]
      # @return [String, nil] Announcement returned if metadata is available and the announcement length does not exceed the max_length value in format.
      def prepare_uri_keywords(max_length: nil, max_descriptors: 2)
        return nil if !@resource
        keywords = @resource.keywords
        if @uri && !keywords.empty?
          return build_uri_keywords(keywords: keywords,
                                    uri: @uri,
                                    max_length: max_length,
                                    max_descriptors: max_descriptors)
        end
        nil
      end

      # Uri followed by hashtags format
      #
      # @param max_length [Fixnum]
      # @param max_descriptors [Fixnum]
      # @return [String, nil] Announcement returned if metadata is available and the announcement length does not exceed the max_length value in format.
      def prepare_uri_hashtags(max_length: nil, max_descriptors: 2)
        return nil if !@resource
        keywords = @resource.keywords
        if @uri && !keywords.empty?
          return build_uri_hashtags(keywords: keywords,
                                    uri: @uri,
                                    max_length: max_length,
                                    max_descriptors: max_descriptors)
        end
        nil
      end

      # Hashtags followed by uri format
      #
      # @param max_length [Fixnum]
      # @param max_descriptors [Fixnum]
      # @return [String, nil] Announcement returned if metadata is available and the announcement length does not exceed the max_length value in format.
      def prepare_hashtags_uri(max_length: nil, max_descriptors: 2)
        return nil if !@resource
        keywords = @resource.keywords
        if @uri && !keywords.empty?
          return build_hashtags_uri(keywords: keywords,
                                    uri: @uri,
                                    max_length: max_length,
                                    max_descriptors: max_descriptors)
        end
        nil
      end

      # Title followed by uri format
      #
      # @param max_length [Fixnum]
      # @return [String, nil] Announcement returned if metadata is available and the announcement length does not exceed the max_length value in format.
      def prepare_title_uri(max_length: nil)
        return nil if !@resource
        title = @resource.title
        if @uri
          return build_title_uri(uri: @uri, title: title, max_length: max_length)
        end
        nil
      end

      # Uri followed by title format
      #
      # @param max_length [Fixnum]
      # @return [String, nil] Announcement returned if metadata is available and the announcement length does not exceed the max_length value in format.
      def prepare_uri_title(max_length: nil)
        return nil if !@resource
        title = @resource.title
        if @uri
          return build_uri_title(uri: @uri, title: title, max_length: max_length)
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
