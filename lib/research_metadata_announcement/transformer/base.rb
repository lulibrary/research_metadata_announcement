module ResearchMetadataAnnouncement
  module Transformer

    # Base transformer
    #
    class Base

      # @param config [Hash]
      # @option config [String] :url URL of the Pure host
      # @option config [String] :username Username of the Pure host account
      # @option config [String] :password Password of the Pure host account
      # @option config [String] :api_key API key of the Pure host account
      def initialize(config)
        @config = config
      end

      # @param id [String] Pure identifier.
      # @param composition [Array<Symbol>] Metadata presentation sequence e.g. [:new, :title, :hashtags, :uri].
      # @param max_length [Fixnum] Maximum length of announcement.
      # @param max_descriptors [Fixnum] Maximum number of descriptors (common name for keywords, tags, hashtags).
      # @return [String, nil] Announcement returned if the metadata is available and the announcement length does not exceed the max_length argument.
      def transform(id:, composition: [:new, :title, :hashtags, :uri],
                    max_length: nil, max_descriptors: 2)
        composition.uniq!

        @resource = @resource_extractor.find id

        return nil unless @resource
        if composition.include? :uri
          return nil unless prepare_uri
        end
        title = remove_full_stop @resource.title
        keywords = @resource.keywords

        # sizing
        if length_constrained? max_length
          chars_needed = 0
          chars_component_end = 2
          composition.each do |component|
            case component
              when :new
                phrase =  new_phrase(@resource)
                chars_needed += phrase.size + chars_component_end
              when :title
                chars_needed += title.size + chars_component_end
              when :keywords
                chars_needed += build_keywords(keywords, max_descriptors).size + chars_component_end if !keywords.empty?
              when :hashtags
                chars_needed += build_hashtags(keywords, max_descriptors).size + chars_component_end if !keywords.empty?
              when :uri
                uri = prepare_uri
                chars_needed += uri.size + chars_component_end if uri
            end
          end

          # since the arrangement of the composition is unknown, after sizing
          # chars_needed has two extra spaces allocated
          # one is used for the terminating full stop
          # one is not needed
          chars_needed -= 1

          # determine if title needs truncating/removing before combining
          if chars_needed > max_length
            # truncate title
            if composition.include? :title
              excess_chars = chars_needed - max_length
              truncated_title_length = title.size - excess_chars
              truncated_title_length = 0 if truncated_title_length < 0
              title = title[0..truncated_title_length - 3].strip + '..'
              composition -= [:title] if title.size <= 5 # give up on title if just too small
            end
          end
        end

        # get data for combining
        buffer = []
        composition.each do |component|
          case component
            when :new
              buffer << new_phrase(@resource)
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

      def remove_full_stop(str)
        arr = str.split('')
        if arr.pop == '.' && arr.pop != '.'
          return str.chomp('.')
        else
          return str
        end
      end

      def new_phrase(resource)
        part_1 = 'New'
        part_2 = ''

        case resource.class.to_s
          when 'Puree::Model::Dataset'
            part_2 = 'dataset'
          when 'Puree::Model::ResearchOutput'
            part_2 = resource.type.downcase
        end
        if part_2.empty?
          return part_1
        else
          return "#{part_1} #{part_2}"
        end
      end

      def strip_uri_scheme(uri)
        uri.sub %r{^.+//}, ''
      end

      private

      def prepare_uri
        uri = strip_uri_scheme @resource.doi if @resource && @resource.doi
        return unless uri
        resolver = 'dx.doi.org'
        if uri.include? resolver
          uri
        else
          File.join resolver, uri
        end
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
        resource_class = "Puree::Extractor::#{Puree::Util::String.titleize(resource_type)}"
        @resource_extractor = Object.const_get(resource_class).new @config
      end

    end
  end

end
