#!/usr/bin/perl -w

use Test::More;

BEGIN
  {
  $| = 1;
  plan tests => 65;
  chdir 't' if -d 't';
  unshift @INC, '../lib';
  use_ok('File::Walker') 
  };

##############################################################################
# skip options

foreach my $op ( qw/d f l 0 df dl d0 fl f0 l0/)
  {
  my $walker = File::Walker->new( skip => $op );
  is ($walker->skip(), $op, "skip is $op");
  }

print "# skip file test\n";

my $walker = File::Walker->new( start => 'one_file', skip => 'f' );

do_test_run($walker);
$walker->reset();
# see if it still works after reset
do_test_run($walker);

print "# skip dir test\n";

$walker = File::Walker->new( start => 'one_dir_one_file', skip => 'd' );

do_test_run_dir($walker);
$walker->reset();
# see if it still works after reset
do_test_run_dir($walker);

##############################################################################

sub do_test_run
  {
  my $walker = shift;

  is ($walker->curdir(), '', 'curdir');

  my $cur = $walker->current();
  my $name = $walker->step();

  is ($name, 'one_file', 'first is one_file');
  is ($walker->current(), $name, 'one_file');
  is ($walker->current(), $cur, 'one_file');
  is ($walker->steps(), 1, '1st step');
  is ($walker->curdir(), 'one_file', 'curdir');

  is ($walker->files(), 0, '0 files');
  is ($walker->dirs(), 1, '1 dirs');

  $name = $walker->step();

  is ($name, undef, 'exhausted');
  is ($walker->current(), $name, 'exhausted');
  is ($walker->steps(), 1, '1 step');
  is ($walker->curdir(), '', 'curdir');

  is ($walker->files(), 0, '0 file');
  is ($walker->dirs(), 1, '1 dirs');
  }

sub do_test_run_dir
  {
  my $walker = shift;

  is ($walker->curdir(), '', 'curdir');

  my $cur = $walker->current();
  my $name = $walker->step();

  # we skip dirs and skip to the first file rightaway
  is ($name, 'test', 'first is test');
  is ($walker->current(), $name, 'test');
  is ($walker->steps(), 1, '1st step');
  is ($walker->curdir(), 'one_dir_one_file/testdir', 'curdir');

  is ($walker->files(), 1, '1 files');
  is ($walker->dirs(), 0, '0 dirs');

  $name = $walker->step();

  is ($name, undef, 'exhausted');
  is ($walker->current(), $name, 'exhausted');
  is ($walker->steps(), 1, '1 step');
  is ($walker->curdir(), '', 'curdir');

  is ($walker->files(), 1, '1 file');
  is ($walker->dirs(), 0, '0 dirs');
  }

