require 'test_helper'

class TestCompositionPermutations < Minitest::Test

  def asserts(announcement, max_length)
    return unless announcement
    assert_instance_of String, announcement
    assert !announcement.empty?
    assert announcement.size <= max_length
  end

  # must have doi to be added
  resources = [
      {
        # title: The 2014 Ebola virus disease outbreak in West Africa
        # keywords: Ebolavirus, evolution, phylogenetics, virulence, Filoviridae, positive selection
        type: :dataset,
        id: 'b050f4b5-e272-4914-8cac-3bdc1e673c58'
      },
      {
        # Doctoral thesis
        # title: Nanoscale imaging and characterisation of Amyloid-β
        type: :research_output,
        id: '9d3ad4d1-3d46-4551-9139-f783fd4e5123'
      },
      {
        # Journal article
        # title: A theoretical framework for estimation of AUCs in complete and incomplete sampling designs
        type: :research_output,
        id: 'a7c104d0-e243-463e-a2a4-b4e07bcfde3f'
      },
      {
        # Journal article
        # title: The effect of humic substances on barite precipitation-dissolution behaviour in natural and synthetic lake waters
        # keywords: Barite, solubility, precipitation, inhibition, humic, fulvic
        type: :research_output,
        id: 'ce76dbda-8b22-422b-9bb6-8143820171b8'
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

        asserts(announcement, max_length)
      end
    end
  end

end