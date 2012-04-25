#!/usr/local/bin/perl

use strict;
use warnings;

#Command line processing.
use Getopt::Long;
Getopt::Long::Configure ('bundling');

my $mode;
do 
{
    print "\nPlease select working mode:\n";
    print " 1) RepeatMasker Mode\n";
    print " 2) WGA Mode\n";
    print " 3) Repeat Families Analysis Mode\n";
    print " 4) Exit\n";
    print "Your mode: ";
    chomp ($mode = <STDIN>);
}   while ( $mode != 1 && $mode != 2 && $mode != 3 &&  $mode != 4);

if    ($mode == 1)
{ print "\nRepeatMasker Mode...\n"; }
elsif ($mode == 2 ) 
{ print "\nWGA Mode...\n"; }
elsif ($mode == 3) 
{ 
    print "\nRepeat Families Analysis Mode...\n"; 
    system ("perl family.pl");
}
else  {print "ByeBye\n";}








=begin comment
 my $fasta;	# option variable with default value (false)
 
 GetOptions (
 'f|fasta=s'  => \$fasta,
 );
 
 if (!defined($fasta) || $fasta !~ /fa$/ )
 {die "You have to specify a fasta file path.\n";}
 
 if (!defined($OutDir))
 {die "You have to specify a Output directory for split fasta files.\n";}
 
=end comment



print "$fasta\n";



=pod

=head1 
 Fang,Quan fangquan@bu.edu
 
=head2 
 Basic Command-Lines:
 
 -f or --fasta: path of the fasta files. For multiple fasta files, please seperate by ",". 
 For example: --fasta  ./dir/1.fa, ./dir/2.fa, ... ./dir/n.fa
 
 
=cut 