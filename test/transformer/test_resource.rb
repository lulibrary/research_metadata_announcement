require 'test_helper'

class TestResourceTransform < Minitest::Test

  def asserts(announcement, max_length)
    return unless announcement
    assert_instance_of String, announcement
    assert !announcement.empty?
    assert announcement.size <= max_length
  end

  resources = [:dataset, :publication]

  title_formats = %i(title_uri uri_title)
  descriptors_formats = %i(uri_keywords keywords_uri uri_hashtags hashtags_uri)

  resources.each do |resource|
    title_formats.each do |i|
      test_name = "test_#{resource}_#{i}_format"
      define_method(test_name) do
        transformer = make_transformer resource
        max_length = random_max_length
        transformer.extract uuid: random_uuid(resource)
        announcement = transformer.public_send i, max_length: max_length
        asserts(announcement, max_length)
      end
    end
  end

  resources.each do |resource|
    descriptors_formats.each do |i|
      test_name = "test_#{resource}_#{i}_format"
      define_method(test_name) do
        transformer = make_transformer resource
        max_length = random_max_length
        max_descriptors = random_max_descriptors
        transformer.extract uuid: random_uuid(resource)
        announcement = transformer.public_send i, max_length: max_length,
                                               max_descriptors: max_descriptors
        asserts(announcement, max_length)
      end
    end
  end

end