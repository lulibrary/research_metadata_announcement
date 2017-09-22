require 'test_helper'

class TestDatasetTransform < Minitest::Test

  def config
    {
        url:      ENV['PURE_URL'],
        username: ENV['PURE_USERNAME'],
        password: ENV['PURE_PASSWORD']
    }
  end

  def make_transformer
    ResearchMetadataAnnouncement::Transformer::Dataset.new config
  end

  def random_uuid
    collection_extractor = Puree::Extractor::Collection.new config:   config,
                                                            resource: :dataset
    resource = collection_extractor.random_resource
    resource.uuid
  end

  def random_max_length
    rand(100..200)
  end

  def random_max_keywords
    rand(1..10)
  end

  def make_announcement_title_format(format, params)
    transformer = make_transformer
    format_class = "ResearchMetadataAnnouncement::Format::#{format.to_s}"
    format = Object.const_get(format_class).new(max_length: params[:max_length])
    transformer.transform uuid: random_uuid,
                          format: format
  end

  def make_announcement_keywords_format(format, params)
    transformer = make_transformer
    format_class = "ResearchMetadataAnnouncement::Format::#{format.to_s}"
    format = Object.const_get(format_class).new(max_length: params[:max_length],
                                                max_keywords: params[:max_keywords])
    transformer.transform uuid: random_uuid,
                          format: format
  end

  def asserts(announcement, max_length)
    if announcement
      assert_instance_of String, announcement
      assert announcement.size > 0
      assert announcement.size <= max_length
    end
  end

  def asserts_title_format(format)
    max_length = random_max_length
    params = {max_length: max_length}
    announcement = make_announcement_title_format(format, params)
    asserts(announcement, max_length)
  end

  def asserts_keywords_format(format)
    max_length = random_max_length
    max_keywords = random_max_keywords
    params = {max_length: max_length,
              max_keywords: max_keywords}
    announcement = make_announcement_keywords_format(format, params)
    asserts(announcement, max_length)
  end



  title_formats = %i(TitleUri UriTitle)
  keywords_formats = %i(KeywordsUri HashtagsUri UriKeywords UriHashtags)

  # Title formats
  title_formats.each do |i|
    test_name = "test_#{i.downcase}_title_format"
    define_method(test_name) do
      asserts_title_format(i)
    end
  end

  # Keyword formats
  keywords_formats.each do |i|
    test_name = "test_#{i.downcase}_keyword_format"
    define_method(test_name) do
      asserts_keywords_format(i)
    end
  end

end