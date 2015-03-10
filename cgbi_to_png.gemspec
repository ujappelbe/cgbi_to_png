# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cgbi_to_png/version'

Gem::Specification.new do |spec|
  spec.name          = "cgbi_to_png"
  spec.version       = OptimizedPngs::VERSION
  spec.authors       = ["Jon Appelberg"]
  spec.summary       = %q{Convert Apple optimized PNG images to standard PNG images}
  spec.description   = %q{This Gem allows converting CgBI (Apple's optimized PNG) images into 'standard' PNG images. See http://iphonedevwiki.net/index.php/CgBI_file_format}
  spec.homepage      = "http://github.com/jappelbe/cgbi_to_png"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
