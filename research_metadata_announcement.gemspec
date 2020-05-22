# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "research_metadata_announcement/version"

Gem::Specification.new do |spec|
  spec.name          = "research_metadata_announcement"
  spec.version       = ResearchMetadataAnnouncement::VERSION
  spec.authors       = ["Adrian Albin-Clark"]
  spec.email         = ["a.albin-clark@lancaster.ac.uk"]

  spec.summary       = %q{Metadata extraction from the Pure Research Information System and transformation of the metadata into an announcement.}

  spec.license       = 'MIT'

  spec.homepage      = "https://github.com/lulibrary/research_metadata_announcement"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ["lib"]

  spec.required_ruby_version = '~> 2.1'

  spec.add_runtime_dependency "puree", "~> 2.0"

  spec.add_development_dependency "minitest-reporters", "~> 1.1"
end
