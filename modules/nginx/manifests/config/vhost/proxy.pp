define nginx::config::vhost::proxy(
  $to,
  $aliases = [],
  $extra_config = '',
  $health_check_path = 'NOTSET',
  $health_check_port = 'NOTSET',
  $platform = $::govuk_platform,
  $protected = true,
  $root = "/data/vhost/${title}/current/public",
  $ssl_only = false
) {

  if $::govuk_provider == 'sky' {
    $proxy_vhost_template = 'nginx/proxy-vhost.conf.sky'
  } else {
    $proxy_vhost_template = 'nginx/proxy-vhost.conf'
  }

  nginx::config::ssl { $name: certtype => 'wildcard_alphagov' }
  nginx::config::site { $name:
    content => template($proxy_vhost_template),
  }

  case $protected {
    default: {
      file { "/etc/nginx/htpasswd/htpasswd.$name":
        ensure => present,
        source => [
          "puppet:///modules/nginx/htpasswd.$name",
          'puppet:///modules/nginx/htpasswd.default'
        ],
      }
    }
    false: {
      file { "/etc/nginx/htpasswd/htpasswd.$name":
        ensure => absent
      }
    }
  }

  @logster::cronjob { "nginx-vhost-${title}":
    args => "--metric-prefix ${title} NginxGangliaLogster /var/log/nginx/${title}-access.log",
  }

  @@nagios::check { "check_nginx_5xx_${title}_on_${::hostname}":
    check_command       => "check_ganglia_metric!${title}_nginx_http_5xx!0.05!0.1",
    service_description => "check nginx error rate for ${title}",
    host_name           => "${::govuk_class}-${::hostname}",
  }

}
