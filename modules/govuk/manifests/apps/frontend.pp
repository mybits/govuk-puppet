# == Class: govuk::apps::frontend
#
# Application to serve mainstream formats, the homepage, and search.
#
# === Parameters
#
# [*vhost*]
#   Virtual host used by the application.
#   Default: 'frontend'
#
# [*port*]
#   The port that the app is served on.
#   Default: 3005
#
# [*vhost_protected*]
#   Should this vhost be protected with HTTP Basic auth?
#   Default: undef
#
# [*publishing_api_bearer_token*]
#   The bearer token to use when communicating with Publishing API.
#   Default: undef
#
# [*nagios_memory_warning*]
#   Memory use at which Nagios should generate a warning.
#
# [*nagios_memory_critical*]
#   Memory use at which Nagios should generate a critical alert.
#
class govuk::apps::frontend(
  $vhost = 'frontend',
  $port = '3005',
  $vhost_protected = false,
  $publishing_api_bearer_token = undef,
  $nagios_memory_warning = undef,
  $nagios_memory_critical = undef,
) {

  govuk::app { 'frontend':
    app_type               => 'rack',
    port                   => $port,
    vhost_aliases          => ['private-frontend'],
    vhost_protected        => $vhost_protected,
    health_check_path      => '/',
    log_format_is_json     => true,
    asset_pipeline         => true,
    asset_pipeline_prefix  => 'frontend',
    nagios_memory_warning  => $nagios_memory_warning,
    nagios_memory_critical => $nagios_memory_critical,
    vhost                  => $vhost,
  }

  govuk::app::envvar { "${title}-PUBLISHING_API_BEARER_TOKEN":
    app     => 'frontend',
    varname => 'PUBLISHING_API_BEARER_TOKEN',
    value   => $publishing_api_bearer_token,
  }
}
