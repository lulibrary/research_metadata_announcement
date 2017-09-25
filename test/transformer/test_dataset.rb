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

  def random_max_descriptors
    rand(1..10)
  end

  def asserts(announcement, max_length)
    if announcement
      assert_instance_of String, announcement
      assert announcement.size > 0
      assert announcement.size <= max_length
    end
  end

   def asserts_title_format(format_method)
    transformer = make_transformer
    max_length = random_max_length
    announcement = transformer.send format_method, uuid: random_uuid,
                                                   max_length: max_length
    asserts(announcement, max_length)
  end

  def asserts_descriptors_format(format_method)
    transformer = make_transformer
    max_length = random_max_length
    max_descriptors = random_max_descriptors
    announcement = transformer.send format_method, uuid: random_uuid,
                                                   max_length: max_length,
                                                   max_descriptors: max_descriptors
    asserts(announcement, max_length)
  end



  title_format_methods = %i(title_uri uri_title)
  descriptors_format_methods = %i(keywords_uri hashtags_uri uri_keywords uri_hashtags)

  # Title formats
  title_format_methods.each do |i|
    test_name = "test_#{i.to_s}_title_format"
    define_method(test_name) do
      asserts_title_format(i)
    end
  end

  # Descriptors formats
  descriptors_format_methods.each do |i|
    test_name = "test_#{i.to_s}_descriptors_format"
    define_method(test_name) do
      asserts_descriptors_format(i)
    end
  end

end