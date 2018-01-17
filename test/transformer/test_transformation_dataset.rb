require 'test_helper'

class TestTransformationDataset < Minitest::Test

  def test_dataset_1
    # type: Dataset
    # id: a57aebd2-d984-4bf4-a687-bb34d691a4fc
    # title: Operating Nanobeams in a Quantum Fluid
    # keywords: None
    # uri: 10.17635/lancaster/researchdata/139
    id = 'a57aebd2-d984-4bf4-a687-bb34d691a4fc'
    transformer = ResearchMetadataAnnouncement::Transformer::Dataset.new config
    announcement = transformer.transform id: id, composition: [:new, :title, :uri]

    assert_equal 'New dataset. Operating Nanobeams in a Quantum Fluid. dx.doi.org/10.17635/lancaster/researchdata/139.', announcement
  end

  def test_dataset_2
    # type: Dataset
    # id: f61d1377-02ca-4c60-94bc-2fe9e37de51c
    # title: Herpes simplex virus 1 (HSV-1) evolution
    # keywords: herpes, HSV-1, HHV-1, virus, herpesviridae, herpesvirus, alpha-herpesvirinae, taxonomy, phylogenetics
    # uri: 10.17635/lancaster/researchdata/29
    id = 'f61d1377-02ca-4c60-94bc-2fe9e37de51c'
    transformer = ResearchMetadataAnnouncement::Transformer::Dataset.new config
    announcement = transformer.transform id: id, composition: [:uri, :title]

    assert_equal 'dx.doi.org/10.17635/lancaster/researchdata/29. Herpes simplex virus 1 (HSV-1) evolution.', announcement
  end

  def test_dataset_3
    # type: Dataset
    # id: a6a03e05-d762-4032-8f6f-8816d6d4ca3d
    # title: Combined transcripts for "Where's Wally?"
    # keywords: smart cities, sustainability
    # uri: 10.17635/lancaster/researchdata/35
    id = 'a6a03e05-d762-4032-8f6f-8816d6d4ca3d'
    transformer = ResearchMetadataAnnouncement::Transformer::Dataset.new config
    announcement = transformer.transform id: id, composition: [:keywords, :uri]

    assert_equal 'smart cities, sustainability. dx.doi.org/10.17635/lancaster/researchdata/35.', announcement
  end

  def test_dataset_4
    # type: Dataset
    # id: e44cbfa2-91e2-4548-992a-bfd47a3138e8
    # title: Cardiovascular ageing hypertension
    # keywords: treated hypertension , microvascular blood flow, ageing, cardiovascular signals, respiration, electrocardiography
    # uri: 10.17635/lancaster/researchdata/148
    id = 'e44cbfa2-91e2-4548-992a-bfd47a3138e8'
    transformer = ResearchMetadataAnnouncement::Transformer::Dataset.new config
    announcement = transformer.transform id: id, composition: [:hashtags, :uri]

    assert_equal '#treatedhypertension #microvascularbloodflow. dx.doi.org/10.17635/lancaster/researchdata/148.', announcement
  end

  def test_dataset_5
    # type: Dataset
    # id: ca47ec2d-fc71-46e0-9a6d-c720bac652c2
    # title: Human papillomavirus type 23 in Lancaster, winter 2014-2015
    # keywords: metagenomics, deep sequencing, nasopharynx, human papillomaviruses, HPV-23
    # uri: 10.17635/lancaster/researchdata/134
    id = 'ca47ec2d-fc71-46e0-9a6d-c720bac652c2'
    transformer = ResearchMetadataAnnouncement::Transformer::Dataset.new config
    announcement = transformer.transform id: id, composition: [:uri, :keywords]

    assert_equal 'dx.doi.org/10.17635/lancaster/researchdata/134. metagenomics, deep sequencing.', announcement
  end

  def test_dataset_6
    # type: Dataset
    # id: a762a8a2-a9ed-4abb-ba91-a67752b1c54d
    # title: Influenza C in Lancaster, winter 2014-2015
    # keywords: influenza, nasopharynx, virology, virus, respiratory disease, infectious disease, flu season, metagenomics, deep sequencing
    # uri: 10.17635/lancaster/researchdata/134
    id = 'a762a8a2-a9ed-4abb-ba91-a67752b1c54d'
    transformer = ResearchMetadataAnnouncement::Transformer::Dataset.new config
    announcement = transformer.transform id: id, composition: [:uri, :hashtags], max_descriptors: 4

    assert_equal 'dx.doi.org/10.17635/lancaster/researchdata/111. #influenza #nasopharynx #virology #virus.', announcement
  end

end