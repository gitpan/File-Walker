package File::Walker;

use strict;
use warnings;

use vars qw/$VERSION/;

$VERSION = '0.01';

sub SKIP_SYMLINKS ()	{ 0x1; }		# 'l'
sub SKIP_FILES ()	{ 0x2; }		# 'f'
sub SKIP_DIRS () 	{ 0x4; }		# 'd'
sub SKIP_ZEROS () 	{ 0x8; }		# '0'

sub SKIP_ALL ()		{ 0x7; }		# 'lfd'

BEGIN
  {
  *next = \&step;
  }

sub new
  {
  my $x = shift;
  my $c = ref($x) || $x;

  my $args = $_[0]; $args = { @_ } unless ref($args) eq 'HASH';

  my $self = bless {}, $c;

  $self->{start} = $args->{start} || '.';
  my $skip = $args->{skip}; 
  $skip = 'l' if !defined $skip;	# skip symlinks on default
 
  $self->{skip} += SKIP_FILES if $skip =~ /f/;
  $self->{skip} += SKIP_DIRS if $skip =~ /d/;
  $self->{skip} += SKIP_SYMLINKS if $skip =~ /l/;
  $self->{skip} += SKIP_ZEROS if $skip =~ /0/;

  $self->reset();
  }

sub reset
  {
  my $self = shift;

  $self->{cur} = $self->{start};
  $self->{curdir} = [ ];
  $self->{cur_dir} = '';

  $self->{dirs} = 0;
  $self->{files} = 0;
  $self->{level} = 0;
  $self->{steps} = 0;
  
  $self->{stack} = [ [ $self->{cur} ], ];

  $self;
  }

sub _exhausted
  {
  my $self = shift; 

  $self->{cur} = undef;
  $self->{curdir} = [];
  $self->{cur_dir} = '';
  undef;
  }

sub step
  {
  my $self = shift;

  return undef if ($self->{skip} & SKIP_ALL) == SKIP_ALL;

  my ($level,$item,$entry);

  my $skip = 0; 
  SKIP:
   while ($skip == 0)
    { 
    $level = $self->{level};

    return $self->_exhausted()
     if ($level == 0 && scalar @{$self->{stack}->[$level]} == 0);

    if ($self->{follow})
      {
      $item = $self->{follow};
      $self->{follow} = undef;
      }
    else
      {
      $item = shift @{$self->{stack}->[$level]};
      }

    next if $item =~ /^\.\.?\z/;	# skip these

    $entry = join('/', @{$self->{curdir}}, $item);
    $self->{cur_dir} = join('/', @{$self->{curdir}});

#    my @stat = stat($entry);
    stat($entry);		# set _

#                 0 dev      device number of filesystem
#                 1 ino      inode number
#                 2 mode     file mode  (type and permissions)
#                 3 nlink    number of (hard) links to the file
#                 4 uid      numeric user ID of file's owner
#                 5 gid      numeric group ID of file's owner
#                 6 rdev     the device identifier (special files only)
#                 7 size     total size of file, in bytes
#                 8 atime    last access time in seconds since the epoch
#                 9 mtime    last modify time in seconds since the epoch
#                10 ctime    inode change time in seconds since the epoch (*)
#                11 blksize  preferred block size for file system I/O
#                12 blocks   actual number of blocks allocated

#    if (!$self->{follow} && -l $entry)
#      { 
#      $self->{symlinks}++;
#      $self->{follow} = $item;
#      next SKIP if $self->{skip} & SKIP_SYMLINKS;
#      $self->{symlinks}++;
#      return $item;
#      }
    if (-f _)
      {
      next SKIP if $self->{skip} & SKIP_FILES;
      $self->{files}++;
      }
    elsif (-d _)
      {
      $self->{cur_dir} = $entry;
      $level ++;
      push @{$self->{curdir}}, $item;

      my $DIR;
      opendir ($DIR, $entry) or 
        warn ("Cannot open dir $entry: $!") && next;
      my @items = readdir ($DIR) or die ("Cannot read dir $entry: $!");
      $self->{stack}->[$level] = \@items; 
      closedir ($DIR) or die ("Cannot close dir $entry: $!");

      #foreach my $i (@items)
      #  {
      #  next if $i =~ /^\.\.?\z/;
      #  push @{$self->{stack}->[$level]}, $i;
      #  }

      next SKIP if $self->{skip} & SKIP_DIRS;
      $self->{dirs}++;
      }
#    else
#      {
#      # XXX todo special file?
#      }

    $skip = 1;

    }
    continue {
     # go upwards if exhausted current dir
      while ($level > 0 && scalar @{$self->{stack}->[$level]} == 0)
       {
       pop @{$self->{curdir}};
       $level --; 
       }
      $self->{level} = $level; 
      } 
  
  $self->{steps} ++;

  $self->{cur} = $item;

  $item;
  }

sub dirs
  {
  my $self = shift;

  $self->{dirs};
  }

sub files
  {
  my $self = shift;

  $self->{files};
  }

sub level
  {
  my $self = shift;

  $self->{level};
  }

sub start
  {
  my $self = shift;

  $self->{start};
  }

sub steps
  {
  my $self = shift;

  $self->{steps};
  }

sub skip
  {
  my $self = shift;

  my $skip = '';
  $skip .= 'd' if $self->{skip} & SKIP_DIRS;
  $skip .= 'f' if $self->{skip} & SKIP_FILES;
  $skip .= 'l' if $self->{skip} & SKIP_SYMLINKS;
  $skip .= '0' if $self->{skip} & SKIP_ZEROS;
  
  $skip;
  }

sub current
  {
  my $self = shift;

  $self->{cur};
  }

sub curdir
  {
  my $self = shift;

  $self->{cur_dir};
#  join ('/', @{$self->{curdir}});
  }

1;
__END__

=pod

=head1 NAME

File::Walker - Perl extension for blah blah blah

=head1 SYNOPSIS

	use File::Walker;

	my $walker = File::Walker->new( { start => $dir } );

	my $name;
	while (defined $name = $walker->step())
	  {
	  print "At $name\n";
	  }
	print "dirs: ", $walker->dirs()," files: ", $walker->files(),"\n";
	$walker->reset();
	while (defined $name = $walker->step())
	  {
	  plast if $name eq 'foo';	# find file/dir foo
	  }

=head1 DESCRIPTION

File::Walker is the complement to File::Find: instead of calling a
callback for each file system entry it let's you call an interator
function to step through the entries.

This allows for defered walking of the file tree, and also for early
abort (for instance, if you already found the file you were looking
for).

=head1 METHODS

=head2 new()

	my $walker = File::Walker->new( $args );

Creates a new File::Walker object with the following (optional) arguments
in a hash ref:

	start		Starting dir, defaults to '.'
	skip		String with list of items to skip as:
			  d - directories
			  f - files
			  l - symlinks
			  0 - zero-byte long files
			The skip option defaults to 'l'.

If you pass C<skip => 'fdl'>, all items would be actually skipped, so
C<step()> will return undef on the first call.

=head2 reset

	$walker->reset();

Resets the File::Walker object, e.g. resets the iterator to the starting dir,
sets the count of directories and files to 0 etc.

=head2 step

	my ($name) = $walker->step();

Walks the file tree one step and returns the name of the next entry. Returns
undef if there are no more entries.

=head2 dirs

	print "Seen so far: ", $walker->dirs(), " directories.\n";

Returns the number of directories (or folders) seen so far. C<.> and C<..>
do not count.

=head2 files

	print "Seen so far: ", $walker->files(), " files.\n";

Returns the number of files (as opposed to directories) seen so far.

=head2 level

	my $level = $walker->level();

Returns the current level we are in. Going into a sub-directory increases
the level by one, going up decreases the level.

=head2 start
	
	my $start = $walker->start();

Returns the start directory.

=head2 steps

	print "Did ", $walker->steps(), " steps so far.\n";

Returns the number of times C<step()> was called.

=head2 current
	
	my $item = $walker->current();

Returns the current item, e.g. the same name as the last call to
C<$walker->step()> did return. If C<step()> was not called before, will
return the same as C<$walker->start()>.

=head2 curdir
	
	my $item = $walker->curdir();

Returns the current directory we are in.

=head1 BUGS

=over 2

=item *

Does completely ignore symlinks.

=back

=head1 SEE ALSO

L<File:Find>

=head1 AUTHOR

Copyright (C) 2004 by Tels L<http://bloodgate.com/>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
