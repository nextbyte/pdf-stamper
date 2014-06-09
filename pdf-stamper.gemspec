# -*- encoding: utf-8 -*-

$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require 'pdf/stamper/version'

$platform ||= RUBY_PLATFORM[/java/] || 'ruby'

Gem::Specification.new do |s|
  s.name = %q{tv-pdf-stamper}
  s.version = PDF::Stamper::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Schreiber", "Wes Morgan"]
  s.platform    = $platform
  s.date = %q{2013-01-21}
  s.description = %q{Fill out PDF forms (templates) using iText's PdfStamper.  == CAVEAT:  You have to use JRuby or RJB. You need Adobe LiveCycle Designer or Acrobat Professional to create the templates.  == EXAMPLE: pdf = PDF::Stamper.new("my_template.pdf") pdf.text :first_name, "Jason" pdf.text :last_name, "Yates" pdf.image :photo, "photo.jpg" pdf.checkbox :hungry pdf.save_as "my_output.pdf"}
  s.email = ['paulschreiber@gmail.com', 'wes@turbovote.org']
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- spec/*`.split("\n")
  s.homepage = %q{http://github.com/turbovote/pdf-stamper/}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib", "ext"]
  s.rubyforge_project = %q{pdf-stamper}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{PDF templates using iText's PdfStamper.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    s.add_dependency "rjb-loader" if $platform.to_s != 'java'
    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<newgem>, [">= 1.2.3"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
