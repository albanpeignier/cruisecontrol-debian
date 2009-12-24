require 'rubygems'

require 'debian/build'
include Debian::Build

require 'debian/build/config'

namespace "package" do
  Package.new("cruisecontrol") do |t|
    t.version = '2.8.2'
    t.debian_increment = 1

    t.source_provider = ZipSourceProvider.new 'http://downloads.sourceforge.net/project/cruisecontrol/CruiseControl/#{version}/cruisecontrol-src-#{version}.zip?use_mirror=freefr'
  end
end

require 'debian/build/tasks'

