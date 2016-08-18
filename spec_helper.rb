require 'rspec-puppet'
require 'puppet'
require 'puppetlabs_spec_helper/module_spec_helper'

HERE = File.expand_path(File.dirname(__FILE__))

RSpec.configure do |c|
  c.mock_framework = :rspec
  c.hiera_config = 'spec/fixtures/hiera/hiera.yaml'

  c.manifest    = File.join(HERE, 'manifests')
  c.module_path = [
    File.join(HERE, 'modules'),
    File.join(HERE, 'vendor', 'modules')
  ].join(':')

  c.order = 'rand'

  possible_releases = {
    'precise' => '12.04',
    'trusty'  => '14.04',
  }

  dist_preferred = ENV.fetch('DIST_PREFERRED', 'trusty')

  unless possible_releases.has_key?(dist_preferred)
    raise "DIST_PREFERRED must be one of " + possible_releases.keys.join(', ')
  end

  # Sensible defaults to satisfy modules that perform OS checking. These
  # keys can be overridden by more specific `let(:facts)` in spec contexts.
  c.default_facts = {
    :osfamily                => 'Debian',
    :operatingsystem         => 'Ubuntu',
    :operatingsystemrelease  => possible_releases[dist_preferred],
    :lsbdistid               => 'Debian',
    :lsbdistcodename         => dist_preferred.capitalize,
  }
end

if ENV['DEBUG']
  Puppet::Util::Log.level = :debug
  Puppet::Util::Log.newdestination(:console)
end
