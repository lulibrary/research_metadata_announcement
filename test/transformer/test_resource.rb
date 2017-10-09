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
  permutations = []
  components_keywords.permutation.each { |i| permutations << i }
  components_hashtags.permutation.each { |i| permutations << i }

  resources.each do |resource|
    uuid = random_uuid(resource)
    permutations.each do |permutation|
      permutation_name = permutation.join('_')
      test_name = "test_#{resource}_#{uuid}_#{permutation_name}_format"
      define_method(test_name) do
        transformer = make_transformer resource
        max_length = random_max_length
        announcement = transformer.transform uuid: uuid,
                                             permutation: permutation,
                                             max_length: max_length,
                                             max_descriptors: random_max_descriptors
        asserts(announcement, max_length)
      end
    end
  end

end