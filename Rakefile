begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

PROJ.name = 'gold'
PROJ.summary = 'Gold is a simple executable that helps git teamwork.'
PROJ.authors = 'Gaspard Bucher'
PROJ.email = 'gaspard@teti.ch'
PROJ.url = 'http://zenadmin.org/574'
PROJ.version = '0.3.0'
PROJ.rubyforge.name = 'gold'

PROJ.spec.opts << '--color'
PROJ.gem.files = ['History.txt', 'README.txt', 'bin/gold', 'Rakefile', 'lib/gold.rb']
