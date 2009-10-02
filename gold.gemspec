# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gold}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gaspard Bucher"]
  s.date = %q{2009-10-02}
  s.default_executable = %q{gold}
  s.description = %q{This is the workflow we use when developing zena.

The main idea is that developers work on feature branches on their fork and send an
email to the reviewer when work is ready. The reviewer pulls from these branches,
checks that all is good and either apply the commits to the gold master or abort.

There is a script called 'gold' that helps use this workflow once the remote references
are added.

Any questions ? Ask zena's mailing list: http://zenadmin.org/en/community

                                     ~~}
  s.email = %q{gaspard@teti.ch}
  s.executables = ["gold"]
  s.extra_rdoc_files = ["History.txt", "README.txt", "bin/gold"]
  s.files = ["History.txt", "README.txt", "bin/gold", "Rakefile", "lib/gold.rb"]
  s.homepage = %q{http://zenadmin.org/574}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{gold}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Gold is a simple executable that helps git teamwork.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bones>, [">= 2.5.1"])
    else
      s.add_dependency(%q<bones>, [">= 2.5.1"])
    end
  else
    s.add_dependency(%q<bones>, [">= 2.5.1"])
  end
end
