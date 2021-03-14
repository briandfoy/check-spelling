#!/usr/bin/perl
# This script takes null delimited files as input
# it drops paths that match the listed exclusions
# output is null delimited to match input
use File::Basename;
use File::Spec::Functions;

my $dirname = dirname(__FILE__);

*DEBUG = *STDERR;

sub items_from_file {
  my ($file, $fallback) = @_;
  my @items;
  if (-e $file) {
    open FILE, '<', $file;
    local $/=undef;
    my $file=<FILE>;
    for (split /\R+/, $file) {
      next if /^\s*#/;
      s/^\s*(.*)\s*$/$1/;
      push @items, $_;
    }
  }
}

sub items_to_re {
  my @items = @_;
  my $pattern = scalar @items ? join "|", @items : $fallback;
  return $pattern;
}

say DEBUG "Filtering file paths";

my $exclude_file = catfile( $dirname, 'excludes.txt' );
my $exclude_pattern = do {
	if( -e $exclude_file ) {
	  print DEBUG "Found <$exclude_file>\n";
	  my @items = items_from_file( $exclude_file );
	  items_to_re( @items, '^$');
	}
	else {
	  print DEBUG "No file <$exclude_file>, so skipping that\n";
	  qr/^$/;
	}
};

my $only_file = catfile( $dirname, 'only.txt' );
my $only_pattern = do {
	if( -e $exclude_file ) {
	  print DEBUG "Found <$only_file>\n";
	  my @items = items_from_file( $only_file );
	  items_to_re( @items, '.');
	}
	else {
	  print DEBUG "No file <$only_file>, so skipping that\n";
	  qr/./;
	}
};

my $only    = items_to_re( $only_file,     '.');

while (<>) {
  chomp;
  if( m{$exclude_pattern} ) {
    say DEBUG "File <$_> excluded by exclude pattern";
    next;
  }
  elsif( ! m{$only_pattern} ) {
    say DEBUG "File <$_> excluded by exclude pattern";
    next;
  }
  else {
    say DEBUG "File <$_> included";
  }

  print "$_\0";
}
