require 'test_helper'

class TestResourceTransform < Minitest::Test

  def asserts(announcement, max_length)
    return unless announcement
    assert_instance_of String, announcement
    assert !announcement.empty?
    assert announcement.size <= max_length
  end

  # must have doi to be added
  resources = [
      {
        # The 2014 Ebola virus disease outbreak in West Africa
        type: :dataset,
        id: 'b050f4b5-e272-4914-8cac-3bdc1e673c58'
      },
      {
        # Doctoral thesis
        # Nanoscale imaging and characterisation of Amyloid-β
        type: :research_output,
        id: '9d3ad4d1-3d46-4551-9139-f783fd4e5123'
      },
      {
        # Journal article
        # A theoretical framework for estimation of AUCs in complete and incomplete sampling designs
        type: :research_output,
        id: 'a7c104d0-e243-463e-a2a4-b4e07bcfde3f'
      }
  ]

  components_keywords = [:new, :title, :keywords, :uri]
  components_hashtags = [:new, :title, :hashtags, :uri]
  compositions = []
  components_keywords.permutation.each { |i| compositions << i }
  components_hashtags.permutation.each { |i| compositions << i }

  resources.each do |resource|
    id = resource[:id]
    compositions.each do |composition|
      composition_name = composition.join('_')
      test_name = "test_#{resource[:type]}_#{id}_#{composition_name}_format"
      define_method(test_name) do
        transformer = make_transformer resource[:type]
        max_length = random_max_length

        announcement = transformer.transform id: id,
                                             composition: composition,
                                             max_length: max_length,
                                             max_descriptors: random_max_descriptors

        # puts announcement

        asserts(announcement, max_length)
      end
    end
  end

  # TO DO
  def test_ellipsis
    # Ellipsis when truncating title is sometimes only two periods
    # e.g.
    # research_output
    # 'a7c104d0-e243-463e-a2a4-b4e07bcfde3f'
    # A theoretical framework for estimation of AUCs in complete and incomplete sampling designs

    # resource_type = :dataset
    # id = 'b050f4b5-e272-4914-8cac-3bdc1e673c58'

    resource_type = :research_output
    # id = '9d3ad4d1-3d46-4551-9139-f783fd4e5123'
    id = 'a7c104d0-e243-463e-a2a4-b4e07bcfde3f'
    transformer = make_transformer resource_type
    max_length = random_max_length

    announcement = transformer.transform id: id,
                                         composition: [:new, :title, :uri],
                                         max_length: max_length,
                                         max_descriptors: random_max_descriptors

    # puts announcement
  end

end