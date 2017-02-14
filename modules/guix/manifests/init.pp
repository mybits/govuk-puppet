#
# == Class: guix - installs the GNU Guix daemon and package manager
#
# === Parameters:
#
# [*version*]
# String, default '0.11.0'. Specify the version of Guix to install.
#
# [*base_url*]
# String, default ''ftp://alpha.gnu.org/gnu/guix'. Set the base URL to use
# for download URL.
#
# [*install_cwd*]
# String, default '/tmp'. Directory where you would like to download and
# extract the Guix binary installation.
#
# [*download_file*]
# String, default 'guix-binary.tar.xz'. Filename of the downloaded
# file regardless of version.
#
# [*extract_dir*]
# String, default 'guix-binary-unpack'. Subdirectory under
# *install_cwd* that the tarball will be extracted under.
#
# === Requires:
#
# None.
#
# === Examples
#
#    guix {
#      version  => '0.11.0',
#    }
#
class guix (
  $version        = '0.11.0',
  $base_url       = 'ftp://alpha.gnu.org/gnu/guix',
  $install_cwd    = '/tmp',
  $download_file  = 'guix-binary.tar.xz',
  $extract_dir    = 'guix-binary-unpack',
) {

  $system = $::osfamily ? {
    default   => 'x86_64-linux',
  }
  $url="${base_url}/guix-binary-${version}.${system}.tar.xz"

  $unpacked_tarball_path = "${install_cwd}/${extract_dir}"

  exec { "curl -sL -o ${install_cwd}/${download_file} ${url}":
    alias   => 'download-guix',
    cwd     => $install_cwd,
    creates => "${install_cwd}/${download_file}",
  }

  file { $unpacked_tarball_path:
    ensure => directory,
    alias  => 'unpacked_tarball_path',
  }

  exec { 'guix archive --authorize < /var/guix/profiles/per-user/root/guix-profile/share/guix/hydra.gnu.org.pub':
    alias     => 'authorize-gnu-hydra',
    require   => File['/root/.guix-profile'],
    user      => root,
    subscribe => File['/usr/local/bin/guix'],
  }

  exec { "tar xf ${install_cwd}/${download_file} -C ${install_cwd}/${extract_dir}":
    alias   => 'extract-guix-tarball',
    require => [
      Exec['download-guix'],
      File['unpacked_tarball_path'],
    ],
    cwd     => $install_cwd,
    creates => [
      "${unpacked_tarball_path}/gnu",
      "${unpacked_tarball_path}/var/guix",
    ],
  }

  exec { 'mv var/guix /var/':
    alias   => 'create /var/guix',
    require => Exec['extract-guix-tarball'],
    cwd     => $unpacked_tarball_path,
    creates => '/var/guix/',
  }

  exec { 'mv gnu /':
    alias   => 'create /gnu/',
    require => Exec['extract-guix-tarball'],
    cwd     => $unpacked_tarball_path,
    creates => '/gnu',
  }

  file { '/root/.guix-profile':
    ensure  => 'link',
    require => Exec['create /var/guix'],
    target  => '/var/guix/profiles/per-user/root/guix-profile',
  }

  file { '/usr/local/bin/guix':
    ensure  => 'link',
    require => Exec['create /var/guix'],
    target  => '/var/guix/profiles/per-user/root/guix-profile/bin/guix',
  }

  group { 'guixbuild':
    ensure => 'present',
    system => 'yes',
  }

  $build_usernames = [
      'guixbuilder01',
      'guixbuilder02',
      'guixbuilder03',
      'guixbuilder04',
      'guixbuilder05',
      'guixbuilder06',
      'guixbuilder07',
      'guixbuilder08',
      'guixbuilder09',
      'guixbuilder10',
  ]

  user { $build_usernames:
    ensure  => 'present',
    gid     => 'guixbuild',
    groups  => ['guixbuild'],
    home    => '/var/empty',
    shell   => '/usr/sbin/nologin',
    comment => 'Guix build user',
    system  => 'yes',
  }

  exec { 'cp /root/.guix-profile/lib/upstart/system/guix-daemon.conf /etc/init/guix-daemon.conf':
    alias   => 'guix-daemon.conf',
    require => File['/root/.guix-profile'],
    creates => '/etc/init/guix-daemon.conf',
    user    => root,
  }

  service { 'guix-daemon':
    ensure   => running,
    provider => 'upstart',
    require  => [
      Exec['guix-daemon.conf'],
    ],
  }
}
