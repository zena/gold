require 'fileutils'
require 'tempfile'
require 'yaml'

# Sending mail not working on mac os x ?
# http://www.macosxhints.com/article.php?story=20081217161612647

# install
# > sudo cp gold /usr/local/bin/
# > chmod a+x /usr/local/bin/gold

# TODO: move Settings inside each project ?

class Gold

  DefaultSettings = {
    'gold_branch'     => 'gold',                  # name of local branch tracking gold master (in developer's local git)
    'gold_remote'     => 'zena',                  # name of remote 'gold' reference project
    'gold_repository' => 'git://github.com/zena/zena.git',
    'developer_name'  => 'john',                  # developer's name (same as github account)
    'developer_email' => 'developer@example.com', # developer's email
    'reviewer'        => 'reviewer@example.com'   # reviewer's email
  }

  SettingsMessages = {
    '1. gold_branch'     => 'name of local branch that will track gold master',
    '2. gold_remote'     => 'name of remote gold master',
    '3. gold_repository' => 'remote repository',
    '4. developer_name'  => 'developer\'s account on remote repository',
    '5. developer_email' => 'developer\'s email',
    '6. reviewer'        => 'reviewer\'s email'
  }

  DefaultSettings.keys.each do |k|
    define_method(k) do
      settings[k]
    end
  end

  def self.run(args)
    self.new.run(args)
  end

  def run(args)
    case args[0]
    when 'add_dev'
      add_dev args[1], args[2]
    when 'check', 'review'
      review args[1]
    when 'propose'
      propose args[1]
    when 'settings'
      create_settings_file
    else
      if args[0] && self.respond_to?(args[0])
        send(args[0])
      else
        show_usage
      end
    end
  end

  def setup
    return error("Could not create settings file #{settings_path.inspect}.") unless create_settings_file
    return error("Could create remote #{gold_remote}.") unless system("git remote add #{gold_remote} #{gold_repository}")
    return error("Could not fetch #{gold_remote}.") unless system("git fetch #{gold_remote}")
    return error("Could not create #{gold_branch} branch.") unless system("git checkout --track -b #{gold_branch} #{gold_remote}/master")
  end

  def rebase
    return error("Could not find current branch.") unless branch
    return error("You cannot rebase the #{gold_branch} branch !") if branch == gold_branch
    return error("You cannot rebase the master branch !") if branch == 'master'
    return error("Could not checkout #{gold_branch}.") unless system("git checkout #{gold_branch}")
    return error("Could not pull #{gold_branch}.") unless system("git pull")
    return error("Could not checkout #{branch}.") unless system("git checkout #{branch}")
    return error("Could not rebase --interactive #{gold_branch}.") unless system("git rebase --interactive #{gold_branch}")
  end

  def propose(msg)
    branch = current_branch
    return error("Could not find current branch.") unless branch
    return error("You cannot propose the #{gold_branch} branch !") if branch == gold_branch
    return error("You cannot propose the master branch !") if branch == 'master'
    return error("Could not checkout #{gold_branch}.") unless system("git checkout #{gold_branch}")
    return error("Could not pull #{gold_branch}.") unless system("git pull")
    return error("Could not checkout #{branch}.") unless system("git checkout #{branch}")
    return error("Could not rebase #{branch} with #{gold_branch}.") unless system("git rebase #{gold_branch}")
    return error("Could not push #{branch} to origin.") unless system("git push origin +#{branch}")
    subject = "#{gold_remote}: review #{developer_name}/#{branch}"
    tmpf = Tempfile.new('gold_msg')
    tmpf.write %Q{From:#{developer_email}
Subject:#{subject}

============
gold review #{developer_name}/#{branch}
============

#{msg}
}
    tmpf.close
    return error("Could not send email to #{reviewer}.") unless system("sendmail -F '#{developer_name}' #{reviewer} < #{tmpf.path}")
    tmpf.delete
    puts "Mail sent to #{reviewer}"
  end

  def add_dev(name, repo = nil)
    return error("Missing 'developer name' parameter.") unless name
    repo ||= "#{gold_repository.split('/')[0..2].join('/')}/#{name}/#{gold_remote}.git"
    return error("Could add developer #{name} (#{repo}).") unless system("git remote add #{name} #{repo}")
    return error("Could not fetch #{name}.") unless system("git fetch #{name}")
  end

  def review(remote_branch)
    return error("Missing 'remote_branch' parameter.") unless remote_branch
    return error("'remote_branch' format should be remote/branch.") unless remote_branch =~ /^(.+)\/(.+)$/
    remote, branch = $1, $2
    return error("Could not checkout master.") unless system("git co master")
    return error("Could not checkout #{remote}_#{branch}.") unless system("git co -b #{remote}_#{branch}")
    return error("Could not pull #{remote_branch}.") unless system("git pull #{remote} #{branch}")
    return error("Could not rebase.") unless system("git rebase master")
    system("git diff master | $EDITOR")
    true
  end

  def ok
    branch = current_branch
    return error("Could not find current branch.") unless branch
    return error("Could not rebase.") unless system("git rebase master")
    return error("Could not checkout master.") unless system("git co master")
    return error("Could not fast-forward merge #{branch} into master.") unless system("git merge --ff #{branch}")
    return error("Could not delete #{branch}.") unless system("git branch -d #{branch}")
    puts "-------------------\n\nSuccessfully applied #{branch} to golden master !\n\nPlease git push when you are ready."
  end

  def fail
    branch = current_branch
    return error("Could not find current branch.") unless branch
    return error("You cannot 'fail' master !") unless branch != 'master'
    return error("Could not checkout master.") unless system("git co master")
    return nil unless remove(branch, true)
  end

  def cleanup
    branch = current_branch
    return error("Could not find current branch.") unless branch
    return error("You cannot 'cleanup' master or #{gold_branch} !") if branch == 'master' || branch == gold_branch
    return error("Could not checkout #{gold_branch}.") unless system("git co #{gold_branch}")
    return error("Could not pull #{gold_remote}.") unless system("git pull #{gold_remote}")
    return error("Could not checkout #{branch}.") unless system("git co #{branch}")
    return error("Could rebase on top of #{gold_branch}.") unless system("git rebase #{gold_branch}")
    return error("Could not checkout #{gold_branch}.") unless system("git co #{gold_branch}")
    return nil unless remove(branch)
    return error("Could not clear remote branch.") unless system("git push origin :#{branch}")
  end


  private

    def error(msg)
      puts msg
      nil
    end

    def current_branch
      branch = nil
      `git branch`.split("\n").each do |b|
        if b =~ /^\*\s+(.+)$/
          branch = $1
          break
        end
      end
      branch
    end

    def remove(branch, force=false)
      print "Remove branch #{branch} ? (y,N) "
      yn = STDIN.gets
      if yn.downcase.strip == 'y'
        return error("Could not delete #{branch}.") unless system("git branch -#{force ? 'D' : 'd'} #{branch}")
        true
      else
        return error("Could not checkout #{branch}.") unless system("git co #{branch}")
        false
      end
    end

    def create_settings_file
      FileUtils::mkpath(File.dirname(settings_path)) unless File.exist?(File.dirname(settings_path))
      defaults = settings
      new_settings = {}
      SettingsMessages.keys.sort.each do |key|
        real_key = key.gsub(/\A.*? /,'')
        print "#{SettingsMessages[key]} (#{defaults[real_key]}): "
        value = STDIN.gets.chomp
        new_settings[real_key] = value == '' ? DefaultSettings[real_key] : value
      end
      File.open(settings_path, 'wb') do |f|
        f.puts YAML::dump(new_settings)
      end
      puts "New settings written to '#{settings_path}'"
      true
    end

    def settings
      @settings ||= begin
        if File.exist?(settings_path)
          YAML::load(File.read(settings_path))
        else
          DefaultSettings
        end
      end
    end

    def settings_path
      @settings_path ||= begin
        path = File.expand_path('.').split('/')
        while path != []
          if File.exist?(File.join(path + ['.git']))
            break
          else
            path.pop
          end
        end
        (path + ['.git', 'gold.yml']).flatten.join('/')
      end
    end

    def show_usage
      error(%Q{
Usage:

Reviewer
========

Add a new developer reference
-----------------------------
> gold add_dev john
or
> gold add_dev john git://github.com/john/foo.git

Checkout a remote branch and view diff
--------------------------------------
> gold check john/floppy

Include commits into master branch
----------------------------------
(on the new feature branch created by previous 'review')
> gold ok

The code is not ready yet, cleanup
----------------------------------
(on the new feature branch created by previous 'review')
> gold fail

Developer
=========

Setup
-----
> gold setup
> gold settings

Rebase on top of latest gold
----------------------------
(on the new feature branch)
> gold rebase

Propose branch
--------------
(on the new feature branch)
> gold propose

Cleanup after commit acceptation
--------------------------------
(on the new feature branch)
> gold cleanup

})
    end
end
