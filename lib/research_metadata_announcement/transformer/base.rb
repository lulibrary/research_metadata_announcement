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

      # @param id [String] Pure ID.
      # @param uuid [String] Pure UUID.
      # @param permutation [Array<Symbol>] Metadata presentation sequence e.g. [:new, :title, :hashtags, :uri].
      # @param max_length [Fixnum] Maximum length of announcement.
      # @param max_descriptors [Fixnum] Maximum number of descriptors (common name for keywords, tags, hashtags).
      # @return [String, nil] Announcement returned if the metadata is available and the announcement length does not exceed the max_length argument.
      def transform(uuid: nil, id: nil, permutation: [:new, :title, :hashtags, :uri],
                    max_length: nil, max_descriptors: 2)
        permutation.uniq!
        extract uuid: uuid, id: id
        return nil unless @resource
        if permutation.include? :uri
          return nil unless prepare_uri
        end
        title = @resource.title
        keywords = @resource.keywords

        # sizing
        if length_constrained? max_length
          chars_needed = 0
          chars_component_end = 2
          permutation.each do |component|
            case component
              when :new
                resource = self.class.name.sub('ResearchMetadataAnnouncement::Transformer::', '')
                phrase = "New research #{resource.downcase}"
                chars_needed += phrase.size + chars_component_end
              when :title
                chars_needed += title.size + chars_component_end
              when :keywords
                chars_needed += build_keywords(keywords, max_descriptors).size + chars_component_end if !keywords.empty?
              when :hashtags
                chars_needed += build_hashtags(keywords, max_descriptors).size + chars_component_end if !keywords.empty?
              when :uri
                uri = prepare_uri
                chars_needed += uri.size if uri
            end
          end

          # determine if title needs truncating/removing before combining
          if chars_needed > max_length
            # truncate title
            if permutation.include? :title
              excess_chars = chars_needed - max_length
              truncated_title_length = title.size - excess_chars
              truncated_title_length = 0 if truncated_title_length < 0
              title = title[0..truncated_title_length - 2].strip + '..'
              permutation -= [:title] if title.size <= 5 # give up on title if just too small
            end
          end
        end

        # get data for combining
        buffer = []
        permutation.each do |component|
          case component
            when :new
              resource = self.class.name.sub('ResearchMetadataAnnouncement::Transformer::', '')
              phrase = "New #{resource.downcase}"
              buffer << phrase
            when :title
              buffer << title
            when :keywords
              buffer << build_keywords(keywords, max_descriptors) if !keywords.empty?
            when :hashtags
              buffer << build_hashtags(keywords, max_descriptors) if !keywords.empty?
            when :uri
              uri = prepare_uri
              buffer << uri if uri
          end
        end

        # combine, separate by period
        str = buffer.join('. ')

        # make phrase ending grammatically correct
        str = str.gsub('?.', '?')
        str = str.gsub('!.', '!')

        # terminate entire announcement
        str << '.'

        validate_string_length str, max_length unless str.empty?
      end

      private

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

      def strip_uri_scheme(uri)
        uri.sub %r{^.+//}, ''
      end

      def length_constrained?(max_length)
        max_length && max_length > 0
      end

      def validate_string_length(str, max_length)
        if length_constrained? max_length
          str if str.size <= max_length
        else
          str
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

      def make_extractor(resource_type)
        resource_class = "Puree::Extractor::#{resource_type.capitalize}"
        @resource_extractor = Object.const_get(resource_class).new @config
      end

    end
  end

end
