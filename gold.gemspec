# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gold}
  s.version = "0.4.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gaspard Bucher"]
  s.date = %q{2010-06-15}
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
  s.extra_rdoc_files = ["History.txt", "README.rdoc", "bin/gold"]
  s.files = ["History.txt", "README.rdoc", "bin/gold", "lib/gold.rb"]
  s.homepage = %q{http://zenadmin.org/574}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{gold}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Gold is a simple executable that helps git teamwork.}
end
