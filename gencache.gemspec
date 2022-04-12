require_relative "lib/version"

Gem::Specification.new do |spec|
  spec.name = "gencache"
  spec.version = GenCache::VERSION
  spec.authors = ["Martin Simpson"]
  spec.email = ["martin@newstore.com"]
  spec.summary = "Generational Cache Gem"
  spec.required_ruby_version = ">= 2.4.0"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  
  spec.require_paths = ["lib"]
  spec.add_dependency "json", ">= 1"
end
