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
    return unless announcement
    assert_instance_of String, announcement
    assert !announcement.empty?
    assert announcement.size <= max_length
  end

  title_formats = %i(title_uri uri_title)
  descriptors_formats = %i(uri_keywords keywords_uri uri_hashtags hashtags_uri)

  title_formats.each do |i|
    test_name = "test_#{i}_format"
    define_method(test_name) do
      transformer = make_transformer
      max_length = random_max_length
      transformer.extract uuid: random_uuid
      announcement = transformer.send i, max_length: max_length
      asserts(announcement, max_length)
    end
  end

  descriptors_formats.each do |i|
    test_name = "test_#{i}_format"
    define_method(test_name) do
      transformer = make_transformer
      max_length = random_max_length
      max_descriptors = random_max_descriptors
      transformer.extract uuid: random_uuid
      announcement = transformer.send i, max_length: max_length,
                                         max_descriptors: max_descriptors
      asserts(announcement, max_length)
    end
  end


end