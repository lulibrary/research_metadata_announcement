require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib)

gem 'research_metadata_announcement', '~>0.4.2'
require 'research_metadata_announcement'

def config
  {
      url:      ENV['PURE_URL'],
      username: ENV['PURE_USERNAME'],
      password: ENV['PURE_PASSWORD']
  }
end

def make_transformer(resource)
  resource_class = "ResearchMetadataAnnouncement::Transformer::#{resource.capitalize}"
  Object.const_get(resource_class).new config
end

def random_uuid(resource)
  collection_extractor = Puree::Extractor::Collection.new config:   config,
                                                          resource: resource
  random_resource = collection_extractor.random_resource
  random_resource.uuid
end

def random_max_length
  rand(100..200)
end

def random_max_descriptors
  rand(1..5)
end