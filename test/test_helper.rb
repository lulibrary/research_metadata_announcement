require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib)

require 'research_metadata_announcement'

def config
  {
      url:      ENV['PURE_URL_TEST_59'],
      username: ENV['PURE_USERNAME'],
      password: ENV['PURE_PASSWORD'],
      api_key:  ENV['PURE_API_KEY']
  }
end

def make_transformer(resource)
  resource_class = "ResearchMetadataAnnouncement::Transformer::#{Puree::Util::String.titleize(resource)}"
  Object.const_get(resource_class).new config
end

def random_max_length
  rand(100..200)
end

def random_max_descriptors
  rand(1..5)
end