#!d:/Programme/Perl/bin/perl -w
##*****************************************************************************
## $Id: L2H.pl,v 1.5 2010-01-10 15:52:15 gene Exp $
##*****************************************************************************
## Author: Gerd Neugebauer
##=============================================================================

use File::Basename;
use lib dirname($0);
use lib dirname($0).'/lib';

use strict;
use L2H;
use L2H_file;

sub usage
{ print STDERR <<__EOF__;
$0 [options] [files]
	Translate (La)Tex to HTML.
	The following options are supported:
	-author=<s>	Set the author information.
	-debug <s>	Set the debug flags.
	-dir=<s>	Set the base dir for HTML files.
	-email=<s>	Set the email address for the HTML pages.
	-ext=<s>	Set the extension for the HTML pages.
			The default is '.html'.
	-h
	-help		Show this information.
	-load <s>	Load the given file with macro definitions.
	-main=<s>	Set the name for the topmost HTML file.
	-prefix=<s>	Set the prefix for the generated HTML files.
	-title=<s>	Set the title information for the HTML pages.
	-v	
	-verbose	Turn on verbose output about file operations.
	-year=<s>	Set the copyright year.
__EOF__
    exit(0);
}

my $trans = new L2H_file;

$trans->load('LaTeX.lh');
$trans->load('BibTool.lh');

my $verbose = 0;
my $debug   = 0;
my @debug   = ();
my %debug_map = ( all     => 255,
		  verbose => 1,
		  files   => 2,
		  passes  => 128,
		);
my $profile = 'profile';
my $dirname = $trans->opt('dirname');
my $author  = $trans->opt('author');
my $title   = $trans->opt('title');
my $prefix  = $trans->opt('prefix');

use Getopt::Long;
GetOptions ('author=s'	=> \$author,
	    'd=s'	=> \@debug,
	    'debug=s'	=> \@debug,
	    'dir=s'	=> \$dirname,
	    'email=s'	=> \$L2H::opt->{email},
	    'ext=s'	=> \$L2H::opt->{ext},
	    'h'		=> \&usage,
	    'help'	=> \&usage,
	    'load=s'	=> \&load,
	    'main=s'	=> \$L2H::opt->{main},
	    'prefix=s'	=> \$prefix,
	    'profile=s'	=> \$profile,
	    'title=s'	=> \$title,
	    'v'		=> \$verbose,
	    'verbose'	=> \$verbose,
	    'year'	=> \$L2H::opt->{year},
	   );

$trans->set_opt('author', $author);
$trans->set_opt('dirname', $dirname);
$trans->set_opt('title', $title);
$trans->set_opt('prefix', $prefix);

foreach $_ (@debug)
{ my $k;
  foreach $k (split(/,/,$_)) { $debug |= $debug_map{$k}; }
}
$debug |= 1 if $verbose;

$trans->{'debug'} = $debug;

{ local $/ = undef;
  my $contents;
  while (<>) { $contents .= $_; }
  $_ = $contents;
}

print STDERR "--- Pass 1\n" if $debug > 1;

$trans->restart();
$trans->LaTeX2HTML($_);
$trans->redirect(undef, 1);

print STDERR "--- Pass 2\n" if $debug >  1;
print STDERR "\n"           if $debug == 1;

$trans->{'debug'} &= 1 if ($debug & 128) == 0;
$trans->restart('message:p' => 1);
$trans->LaTeX2HTML($_);
$trans->redirect(undef, 1);

print STDERR "\n" if $debug & 1;

exit(0);

#------------------------------------------------------------------------------
# Local Variables: 
# mode: perl
# End: 
