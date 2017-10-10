require 'test_helper'

class TestResourceTransform < Minitest::Test

  def asserts(announcement, max_length)
    return unless announcement
    assert_instance_of String, announcement
    assert !announcement.empty?
    assert announcement.size <= max_length
  end

  resources = [:dataset, :publication]

  components_keywords = [:new, :title, :keywords, :uri]
  components_hashtags = [:new, :title, :hashtags, :uri]
  compositions = []
  components_keywords.permutation.each { |i| compositions << i }
  components_hashtags.permutation.each { |i| compositions << i }

  resources.each do |resource|
    uuid = random_uuid(resource)
    compositions.each do |composition|
      composition_name = composition.join('_')
      test_name = "test_#{resource}_#{uuid}_#{composition_name}_format"
      define_method(test_name) do
        transformer = make_transformer resource
        max_length = random_max_length
        announcement = transformer.transform uuid: uuid,
                                             composition: composition,
                                             max_length: max_length,
                                             max_descriptors: random_max_descriptors
        asserts(announcement, max_length)
      end
    end
  end

end