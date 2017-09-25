# ResearchMetadataAnnouncement

Metadata extraction from the Pure Research Information System and transformation of the metadata into an announcement.

## Status

[![Gem Version](https://badge.fury.io/rb/research_metadata_announcement.svg)](https://badge.fury.io/rb/research_metadata_announcement)
[![Build Status](https://semaphoreci.com/api/v1/aalbinclark/research_metadata_announcement/branches/master/badge.svg)](https://semaphoreci.com/aalbinclark/research_metadata_announcement)
[![Code Climate](https://codeclimate.com/github/lulibrary/research_metadata_announcement/badges/gpa.svg)](https://codeclimate.com/github/lulibrary/research_metadata_announcement)

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
# Pure host with authentication.
config = {
  url:      ENV['PURE_URL'],
  username: ENV['PURE_USERNAME'],
  password: ENV['PURE_PASSWORD'],
}
```

```ruby
# Pure host without authentication.
config = {
  url: ENV['PURE_URL']
}
```

### Transformation

Create a metadata transformer for a Pure dataset.

```ruby
transformer = ResearchMetadataAnnouncement::Transformer::Dataset.new config
```

Give it a Pure identifier and optional announcement format arguments.

```ruby
transformer.transform uuid: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx',
                      max_length: 140,
                      max_descriptors: 3
```

The announcement is generated (in multiple formats) if the metadata is available and the
announcement length does not exceed the max_length argument. Announcement formats are
then available using instance attributes. Each example uses a different dataset for
illustrative purposes.

```ruby

transformer.title_uri
#=> "Operating Nanobeams in a Quantum Fluid. dx.doi.org/10.17635/lancaster/researchdata/139."

transformer.title_uri
#=> "Ruthenium Volatilisation from Reprocessed Spent Nuclear Fuel – Studying the Baseline Therm... dx.doi.org/10.17635/lancaster/researchdata/14."

transformer.uri_title
#=> "dx.doi.org/10.17635/lancaster/researchdata/29. Herpes simplex virus 1 (HSV-1) evolution."

transformer.keywords_uri
#=> "smart cities, sustainability. dx.doi.org/10.17635/lancaster/researchdata/35."

transformer.hashtags_uri
#=> "#treatedhypertension #microvascularbloodflow. dx.doi.org/10.17635/lancaster/researchdata/148."

transformer.uri_keywords
#=> "dx.doi.org/10.17635/lancaster/researchdata/134. metagenomics, deep sequencing."

transformer.uri_hashtags
#=> "dx.doi.org/10.17635/lancaster/researchdata/111. #influenza #nasopharynx #virology #virus."

```

