#!/usr/bin/perl

# Exit code:
#   0 - success
#   1 - missing parameter
#   2 - invalid files or size parameters
#   3 - unable to write logrotate config

use strict;

my $log_file = "";
my $log_conf = "";
my $file = "global";
my $cfg_dir = "/opt/vyatta/etc/logrotate";
if ($#ARGV == 3) {
  $file = shift;
  $log_file = "/var/log/user/$file";
  $log_conf = "${cfg_dir}/file_$file";
}
my $files = shift;
my $size = shift;
my $set = shift;

if (!defined($files) || !defined($size) || !defined($set)) {
  exit 1;
}

if (!($files =~ m/^\d+$/) || !($size =~ m/^\d+$/)) {
  exit 2;
}

if ($file =~ /global/) {
  my %defaults = ("global" => "/var/log/messages",
                  "defaultauthlog" => "/var/log/auth.log");

  foreach my $conf_name (keys(%defaults)) {
    $log_conf = "$cfg_dir/$conf_name";
    write_config($log_conf, $set, $defaults{$conf_name}, $files, $size);
  }
} else {
  write_config($log_conf, $set, $log_file, $files, $size);
}

sub write_config() {
  my ($log_conf, $set, $log_file, $files, $size) = @_;
  
  # just remove it and make a new one below
  # (the detection mechanism in XORP doesn't work anyway)
  unlink $log_conf;

  open my $out, '>', $log_conf
      or exit 3;
  if ($set == 1) {
    print $out <<EOF;
$log_file {
  missingok
  notifempty
  create
  rotate $files
  size=${size}k
}
EOF
}
  close $out;

}

exit 0;
