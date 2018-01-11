# ResearchMetadataAnnouncement

Metadata extraction from the Pure Research Information System and transformation of the metadata into an announcement.

## Status

[![Gem Version](https://badge.fury.io/rb/research_metadata_announcement.svg)](https://badge.fury.io/rb/research_metadata_announcement)
[![Maintainability](https://api.codeclimate.com/v1/badges/79ba809b90fc85508aa6/maintainability)](https://codeclimate.com/github/lulibrary/research_metadata_announcement/maintainability)

## Installation

Add this line to your application's Gemfile:

    gem 'research_metadata_announcement'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install research_metadata_announcement

## Usage

### Configuration

Create a hash for passing to a transformer.

```ruby
config = {
  url:      'https://YOUR_HOST/ws/api/59',
  username: 'YOUR_USERNAME',
  password: 'YOUR_PASSWORD',
  api_key:  'YOUR_API_KEY'
}
```

### Transformation

Create a metadata transformer for a Pure dataset.

```ruby
transformer = ResearchMetadataAnnouncement::Transformer::Dataset.new config
```

Give it a Pure identifier and get an announcement.

```ruby
transformer.transform id: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
```

Optionally, use the ```:composition``` keyword argument to pass in an array of
components (duplicates are ignored). The order of the components determines the
order of the metadata in the announcement.

Possible components:

```ruby
:new, :title, :keywords, :hashtags, :uri
```

Ideally, an announcement will be obtained using all the requested components,
with the following exceptions:

+ If the composition includes ```:keywords``` or ```:hashtags``` and the
resource does not have any descriptors, the metadata is simply omitted.

+ If the composition includes ```:uri```, the resource must have a URI for an
announcement to be returned.

+ If, after ```:title``` truncation/removal, the length still exceeds the
optional ```:max_length``` keyword argument, an announcement will not be returned.

If the composition includes ```:new```, a phrase based upon the resource type
is generated e.g. New dataset. However, this gem does not determine whether
the resource is deemed to be new.

Each example uses a different resource for illustrative purposes.

```ruby

transformer.transform id: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
#=> "New journal article. Can poly-parameter linear-free energy relationships (pp-LFERs) improve modelling bioaccumulation in fish? #partitioncoefficients #pplfer. dx.doi.org/10.1016/j.chemosphere.2017.10.007."

transformer.transform id: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', max_length: 140
#=> "New journal article. The Parting of Burroughs and... #americancounterculture #arthurrimbaud. dx.doi.org/10.1179/1477570013Z.00000000045."

transformer.transform id: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', composition: [:new, :title, :hashtags] # research output has no descriptors
#=> "New conference paper. Deductive and inductive data collection for agent-based modelling."

transformer.transform id: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', composition: [:new, :title, :keywords, :uri]
#=> "New journal article. Torsion pairs in a triangulated category generated by a spherical object. Auslander–Reiten theory, Calabi–Yau triangulated category. dx.doi.org/10.1016/j.jalgebra.2015.09.011."

transformer.transform id: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', composition: [:new, :title, :uri]
#=> "New dataset. Operating Nanobeams in a Quantum Fluid. dx.doi.org/10.17635/lancaster/researchdata/139."

transformer.transform id: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', composition: [:uri, :title]
#=> "dx.doi.org/10.17635/lancaster/researchdata/29. Herpes simplex virus 1 (HSV-1) evolution."

transformer.transform id: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', composition: [:keywords, :uri]
#=> "smart cities, sustainability. dx.doi.org/10.17635/lancaster/researchdata/35."

transformer.transform id: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', composition: [:hashtags, :uri]
#=> "#treatedhypertension #microvascularbloodflow. dx.doi.org/10.17635/lancaster/researchdata/148."

transformer.transform id: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', composition: [:uri, :keywords]
#=> "dx.doi.org/10.17635/lancaster/researchdata/134. metagenomics, deep sequencing."

transformer.transform id: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx', composition: [:uri, :hashtags], max_descriptors: 4
#=> "dx.doi.org/10.17635/lancaster/researchdata/111. #influenza #nasopharynx #virology #virus."

```