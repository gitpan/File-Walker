#!/usr/bin/perl -w

use Test::More;

BEGIN
  {
  $| = 1;
  plan tests => 61;
  chdir 't' if -d 't';
  unshift @INC, '../lib';
  use_ok('File::Walker') 
  };

can_ok ('File::Walker', qw/new reset dirs files step level start steps next/);

my $walker = File::Walker->new();

is (ref($walker), 'File::Walker', 'new seemed to work');

is ($walker->start(), '.', 'start dir');
is ($walker->current(), '.', 'current dir');
is ($walker->steps(), 0, '0 steps');
is ($walker->dirs(), 0, '0 dirs');
is ($walker->files(), 0, '0 files');
is ($walker->level(), 0, 'level 0');
is ($walker->skip(), 'l', 'skip is l');
is ($walker->curdir(), '', 'curdir');

##############################################################################
# skip options

foreach my $op ( qw/d f l 0 df dl d0 fl f0 l0/)
  {
  my $walker = File::Walker->new( skip => $op );
  is ($walker->skip(), $op, "skip is $op");
  }

$walker = File::Walker->new( start => 'one_file');

do_test_run($walker);
$walker->reset();
# see if it still works after reset
do_test_run($walker);

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

  is ($name, 'test', 'seccond is test');
  is ($walker->current(), $name, 'test');
  is ($walker->steps(), 2, '2nd step');
  is ($walker->curdir(), 'one_file', 'curdir');

  is ($walker->files(), 1, '1 files');
  is ($walker->dirs(), 1, '1 dirs');

  $name = $walker->step();

  is ($name, undef, 'exhausted');
  is ($walker->current(), $name, 'exhausted');
  is ($walker->steps(), 2, '2nd step');
  is ($walker->curdir(), '', 'curdir');

  is ($walker->files(), 1, '1 file');
  is ($walker->dirs(), 1, '1 dirs');
  }

