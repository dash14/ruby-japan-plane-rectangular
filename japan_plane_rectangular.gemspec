
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "japan_plane_rectangular/version"

Gem::Specification.new do |spec|
  spec.name          = "japan_plane_rectangular"
  spec.version       = JapanPlaneRectangular::VERSION
  spec.authors       = ["dash14"]
  spec.email         = ["dash14.ack@gmail.com"]

  spec.summary       = %q{Conversion between WGS and Japan plane rectangular CS}
  spec.homepage      = "https://github.com/dash14/ruby-japan-plane-rectangular"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
