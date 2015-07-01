# == Class: hosts::production::management
#
# Manage /etc/hosts entries specific to machines in the management vDC
#
# === Parameters:
#
# [*app_domain*]
#   Domain to be used in vhost aliases
#
# [*apt_mirror_internal*]
#   Point `apt.production.alphagov.co.uk` to `apt-1` within this
#   environment. Instead of going to the Production VSE.
#   Default: false
#
# [*hosts*]
#   Hosts used to create govuk::host resources (hostfile entries).
#
class hosts::production::management (
  $app_domain,
  $apt_mirror_internal = false,
  $hosts = {},
) {

  validate_bool($apt_mirror_internal)
  $apt_aliases = $apt_mirror_internal ? {
    true    => ['apt.production.alphagov.co.uk'],
    default => undef,
  }

  Govuk::Host {
    vdc => 'management',
  }

  create_resources('govuk::host', $hosts)

  govuk::host { 'apt-1':
    ip              => '10.0.0.75',
    legacy_aliases  => $apt_aliases,
    service_aliases => ['apt'],
  }
}
