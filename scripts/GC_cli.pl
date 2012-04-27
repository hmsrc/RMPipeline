#!/usr/local/bin/perl
#
# 
#   Quan Fang
#   fangquan@bu.edu
#   April 27
#
#

use warnings;
use strict;
use FindBin qw($Bin);
#Command line processing.
use List::MoreUtils qw(uniq);
use Getopt::Long;
Getopt::Long::Configure ('bundling');

# lower-case for naming variables
my $output;         # this variable is able to pass into subroutine
my $sourcefasta;    # this variable is able to pass into subroutine
my $masterfile;
my $category;

GetOptions (
'O|Output=s'   => \$output,
'F|Fasta=s'    => \$sourcefasta,
'M|Masterfile=s' => \$masterfile, 
'f|FamilyCategory=s' => \$category
);

my %bighash;    ### global variables
my %SuperHash;
my %SubHash;

my $process_called = 0;


#&Help;
&BigHash;
&ExtractRepeats;

print "\nProcess_called\n$process_called\n";

# This function is to generate hash table, which 

sub BigHash
{
    if (!defined($masterfile) || !defined($sourcefasta))
    {
        &Help();
        die;
    }
    if (defined($output))
    {
        system("mkdir $output") == 0 or die "$output exist";
    }
    else 
    {
        $output = "\.";
    }
    
    #print "$masterfile\n";
    open (MF, $masterfile) or die ("$masterfile not exists\n");
    my @master = <MF>;
    close MF;

    foreach my $repeat (@master)
    {
       chomp ($repeat);
       $repeat =~ /(\S+)\s+(\d+)\s+(\d+).*?(C|\+)\s+\S+\s+(\S+)/;  
       ## I have question here ? $1
       # "?(C|\+)" means the first C or "+"; "\s+" means one or more spaces; "\S+" means one or more non-spaces;
       # basically, masterfile.out is able to be parsed simply by \s+\S+
       my $Sequence_contig = $1;   # $2 is the contig name, with out ">" here
       my $Sequence_begin  = $2;   # $4 is the query begin position
       my $Sequence_end    = $3;   # $6 is the query end position
       my $strand          = $4;
       my $repeatfamily    = $5;       
       my $value = $Sequence_begin."QuanFang".$Sequence_end."QuanFang".$repeatfamily;
       #print $value;print "\n";
       push (@{$bighash{$Sequence_contig}},$value);
       #6762458QuanFang6762486QuanFangSimple_repeat
    }
    print "bighash built\n";
    my $size=0;
    while( my ($k, $v) = each %bighash)
        {
            #print "key: $k, value: $v   ";
            #print scalar(@$v);
            #print "\n";
            $size += scalar(@$v);
        }
    print $size,"\t repeats","\n";
    print scalar (keys %bighash),"\t contigs","\n";
}

#############################################
sub ExtractRepeats
{
    if (!defined($masterfile) || !defined($sourcefasta))
    {  
        &Help();
        die;
    }

    if (!defined($category))
    {
        $category = "$Bin/FamilyCategorization.txt";
    }
    
    print $category."\n";
    
    ###################################################
    #######  the editable family category file     ####
    ###################################################
    #my @keys = keys %bighash;   ## test if bighash passed in this subroutine
    #print scalar (@keys);
    #foreach my $key (@keys)
    #{
    #print $key; print "\n";
    #      foreach my $line (@{$bighash{$key}})
    #      {print $line; print "\n";}
    #}
    
    open (FML, $category) or die ("$category not exist");
    while(<FML>)
    {
        chomp($_);
        if ($_ =~ /^#/)    ## “#” is not a normal sign
        {
            next;
        }
        my @temp = split("\t",$_);
        my $temp_super = $temp[1];   ## values are superfamilies
        my $temp_sub   = $temp[2];   ## values are subfamilies 
        $temp_super =~ s/\s/_/;
        $SuperHash{$temp[0]} = $temp_super;
        $SubHash{$temp[0]} = $temp_sub;
    }
    close FML;
    #while( my ($k, $v) = each %SuperHash)
    #{print "key: $k, value: $v\n";}
    #while( my ($k, $v) = each %SubHash)
    #{print "key: $k, value: $v\n";}
    
    #print scalar (values %SuperHash);
    ###################################################
    #######  filehandles are superfamilies     ########
    ########  open multiple filehandles       #########
    ###################################################

    # create  9 filehandles
    my @superfamilies = values (%SuperHash);
    @superfamilies = uniq(@superfamilies); ## filehandles in an array, they are the same name with superfamily names
    my %filehandles;
    foreach my $superfamily (@superfamilies)
    {
        my $filename = $output."/".$superfamily."_repeats.fa";
        open ( my $handle, ">", "$filename") or die;   
        $filehandles{$superfamily} = $handle;
        ## filehandles can be visiable variables
        ## "my $handle" is new in every iteration
    }
    while( my ($k, $v) = each %filehandles)
    {print "key: $k, value: $v\n";}
    
    ###################################################
    #######  process every contig in superfasta   #####
    #######  call process when encounting ">"    ######
    ###################################################
    open (SUPERFASTA, $sourcefasta);
    my $sequence = "";
    my $contigname = "";
    while(defined(my $line = <SUPERFASTA>)) 
    {
        if ($line =~ /^>(\S+)/) {
            my $newname = $1;
            if ($contigname) {
                if (exists $bighash{$contigname})
                {
                    &process($contigname,$sequence,\%filehandles);   
                    ## pass hashtable by reference
                }
            }
            # Now that we processed the previous contig, set the new contig name
            $contigname = $newname;
            $sequence = "";
        }
        else {
            $line =~ s/\s*//g; # get rid of newline and any spaces
            $sequence .= $line;
        }
    }
    # Don't forget to do the last sequence
    if (exists $bighash{$contigname})
    {
        &process($contigname,$sequence,\%filehandles);              
        ## pass hashtable by reference
    }
}

sub process
{
    my $contig    = $_[0];
    my $sequence  = $_[1];
    my $hashreference      = $_[2];  ## $hashreference is the address of a passed hashtable
    my %hash      = %$hashreference;
    
    #print "hashxxxxxxxxx/n";
    #while( my ($k, $v) = each %hash)
    #{print "key: $k, value: $v\n";}
    #print "hashxxxxxxxxx/n";
        
    ## test if bighash passed in this subroutine
    #my @keys = keys %SuperHash;   ## test if bighash passed in this subroutine
    #print scalar (@keys);    
    #print "process: $contig\n";
    my @bighashvalues = @{$bighash{$contig}};       ## contig-->%bighash%-->coordinates information

    $process_called = $process_called + scalar(@bighashvalues);

    while (defined(my $item = shift @bighashvalues))
    {
        my @position = split ("QuanFang",$item);
        my $superfamily;
        if ( exists $SuperHash{$position[2]} )
        {
            $superfamily = $SuperHash{$position[2]};
        }
        else 
        {
            $superfamily = "SKIP_THESE";
        }
        #print "\nsuperfamily\n";
        #print $superfamily."\t".$position[2];
        #print "\nsuperfamily\n";
        
        ## real family-->SuperHash-->filehandle
        ## masterfile raw family maynot necessarily exist in SuperHash
        
        my $Sequence_begin = $position[0];
        my $Sequence_end   = $position[1];
        my $Sequence_Repeat = substr ($sequence,int($Sequence_begin) - 1, int($Sequence_end) - int ($Sequence_begin) + 1 );  
        
        ###  How to pass opening filehandles in to subroutine ???
        
        # substr EXPR, OFFSET, LEN
        my $handle;
        if (exists $hash{$superfamily})
        {
            $handle = $hash{$superfamily};
        }
        else 
        { 
            $handle = $hash{"SKIP_THESE"};
        }
        #print "dddddd\n";
        #print $superfamily."\t".$handle."\n";
        #print "\ndddddd\n";
        
        #print "dddddd\n";
        #while( my ($k, $v) = each %hash ) 
        #{print "key: ($k), value: ($v)\n";}
        #print "dddddd\n";

        print $handle ">$contig\_$Sequence_begin\_$Sequence_end\n";
        print $handle "$Sequence_Repeat\n";
        
        #print  ">$contig\_$Sequence_begin\_$Sequence_end\n";
        #print  "$Sequence_Repeat\n";
    }
}

sub Help
{
    
    print "
    RepeatMasker Data Analyzer, Version 1.00
    GC content extractor
    
    Copyright (C) 
    Quan Fang, Christopher Botka
    Research Information Technology Group
    Havard Medical School
    
    All rights reserved.
    
    Basic options:
    user\@orchestra\$ ./GC_cli.pl -M Masterfile -F Superfasta -f FamilyCategory -O Output 
    
    Masterfile          = Masterfile of the species, under RM raw directory
    Superfasta          = Source genome data, in fasta Format
    FamilyCategory      = [Optional] Editable family categorization file, based on user\'s knowledge
    Output              = [Optional] Output directory
";
    
}













