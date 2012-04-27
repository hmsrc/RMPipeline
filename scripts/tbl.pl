#!/usr/local/bin/perl

use strict;
use warnings;
#Command line processing.
use Getopt::Long;
Getopt::Long::Configure ('bundling');

# lower-case for naming variables
my $repeatmaskerfolder; 
my $help;

GetOptions (
'r|RepeatMasker=s' => \$repeatmaskerfolder,
);

if (!defined ($repeatmaskerfolder))
{   
    &Help;
    exit;
}

&TBLMasterFile($repeatmaskerfolder);

sub TBLMasterFile
{
    my %tblhash;
    my $RM_dir;
    my $length=0;   
    my @KeysArray;
    ##real length
    ## above are kind of global variables
    
    chomp ($RM_dir = $_[0]);
    print "RepeatMasker raw results directory: $RM_dir\n";
    opendir (DIR, $RM_dir) or die "Fail";
    my @tblfiles;
    foreach my $file (readdir DIR)
    {
        if ($file =~ /tbl$/ and $file !~ /MasterFile/)
        {push (@tblfiles,$file);}
    }
    close DIR;
    
    foreach my $tblfile (@tblfiles)
    {   $tblfile = "$RM_dir/$tblfile";
        #print $tblfile,"\n";
        open (FH, $tblfile) or die;
        while (<FH>)
        {
            if ($_ =~ /^sequences/)
            {   
                my $sequence;
                my @tmp;
                $_ =~ /^(sequences:)\s+(\d+)/;
                $sequence = $1;
                $tmp[0] = $2;
                if (exists $tblhash{$sequence})
                {$tblhash{$sequence}->[0] += $tmp[0];}
                else
                {
                    $tblhash{$sequence} = [@tmp];
                    push (@KeysArray,$sequence);
                }
                #print $sequence,"\t",$tblhash{$sequence},"\n";
            }

            if ($_ =~ /^total\s+length:/)
            {   
                my $totallength; ## label
                my @tmp;
                $_ =~ /^(total\s+length:)\s+(\d+)\s+bp\s+\((\d+)\s+bp.*/;
                $totallength = $1;$tmp[0] = $2; $tmp[1] = $3;
                $length = $tmp[0];
                if (exists $tblhash{$totallength})
                {
                    $tblhash{$totallength}->[0] += $tmp[0];
                    $tblhash{$totallength}->[1] += $tmp[1];
                }
                else
                { 
                    $tblhash{$totallength} = [@tmp];
                    push (@KeysArray,$totallength);
                }  ## 2 numbers needs an array
                #print $totallength,"\t",$tblhash{$totallength}[0],"\t",$tblhash{$totallength}[1],"\n";
            }

            
            if ($_ =~ /^GC\s+level/)
            {
                my $GClevel;
                my @tmp;
                $_ =~ /^(GC\s+level:)\s+(\d+\.\d+)\s+%/;
                $GClevel = $1;
                $tmp[0] = $length * $2/100;
                if (exists $tblhash{$GClevel})
                { $tblhash{$GClevel}->[0] += $tmp[0]; }
                else
                { 
                    $tblhash{$GClevel} = [@tmp]; 
                    push (@KeysArray,$GClevel);
                }
                #print $GClevel,"\t",$tblhash{$GClevel},"\n";
            }
            
            if ($_ =~ /^bases\s+masked:/)
            {
                my $basesmasked;
                my @tmp;
                $_ =~ /^(bases\s+masked:)\s+(\d+)\s+bp.*/;
                $basesmasked = $1; 
                $tmp[0] = $2;
                if (exists $tblhash{$basesmasked})
                { $tblhash{$basesmasked}->[0] += $tmp[0];}
                else
                { 
                    $tblhash{$basesmasked} = [@tmp]; 
                    push (@KeysArray,$basesmasked);
                }
                #print $basesmasked,"\t",$tblhash{$basesmasked},"\n";
            }

            
            if ( $_ =~ /.+bp.+%$/)
            {
                my $key;
                my @tmp;
                if ($_ =~ /^(.+\S)\s+(\d+)\s+(\d+)\s+bp\s+(\d+\.\d+)\s+%$/)
                {
                    $key = $1;
                    $tmp[0] = $2; $tmp[1] = $3; 
                    if (exists $tblhash{$key})
                    {   
                        $tblhash{$key}->[0] += $tmp[0];
                        $tblhash{$key}->[1] += $tmp[1];
                    }
                    else
                    {   $tblhash{$key} = [@tmp]; push (@KeysArray,$key); }
                    #print $1,"\n";
                }
                elsif ($_ =~ /^(.+\S)\s+(\d+)\s+bp\s+(\d+\.\d+)\s+%$/)
                {
                    $key = $1;
                    $tmp[0] = $2;
                    if (exists $tblhash{$key})
                    {   
                        $tblhash{$key}->[0] += $tmp[0];
                    }
                    else
                    {   $tblhash{$key} = [@tmp]; push (@KeysArray,$key); }
                    #print $1,"\n";
                }
            }
        }
        close FH;
    }
    
    #####################################
    #####################################
    # Write into the Masterfile.tbl
    
    #print scalar (keys %tblhash);
    
    open (WH,">$RM_dir/MasterFile.tbl") or die;
    my $sequences     = $KeysArray[0]; ## sequences
    my $total_length  = $KeysArray[1]; ## total length:
    my $GC_level      = $KeysArray[2]; ## GC level
    my $bases_masked  = $KeysArray[3]; ## bases masked
    
    printf WH "%10s\t%10d\n",$sequences,$tblhash{$sequences}->[0];
    print  WH $total_length,"\t",$tblhash{$total_length}->[0]," bp (",$tblhash{$total_length}->[1]," bp excl N/X-runs)\n";
    print  WH $GC_level,"\t",100*$tblhash{$GC_level}->[0]/$tblhash{$total_length}->[0]," %\n";
    print  WH $bases_masked,"\t",$tblhash{$bases_masked}->[0]," bp ( ",100*$tblhash{$bases_masked}->[0]/$tblhash{$total_length}->[0]," %)\n";
    
    print WH "==================================================================\n";
    print WH "(1)number of element\t(2)length occupied\t(3)percentage of sequence\n";
    print WH "------------------------------------------------------------------\n";
    for (my $i = 4; $i < scalar(@KeysArray); $i++)  ## scan the ids
    {
        my $temp = $KeysArray[$i];
        my @tmp  = @{$tblhash{$KeysArray[$i]}};
        printf WH "%30s",$temp;
        if (scalar(@tmp) == 2)
        {
            printf WH "%15s%15s bp %8.4f",$tmp[0],$tmp[1],100*$tmp[1]/$tblhash{$total_length}->[0];
            print WH " %";
        }
        
        elsif (scalar(@tmp) == 1)
        {
            printf WH "%30s bp %8.4f",$tmp[0],100*$tmp[0]/$tblhash{$total_length}->[0];
            print WH " %";
        }
        
        print WH "\n";
    }
}

###################################################################
sub Help 
{
    
=cut
     open (FH,"/groups/ritg/repeats/scripts/Chrysemys_picta/RepeatMasker/cpicta_qf_1k_22.tbl") or die;
     while (<FH>)
     {
     if ( $_ =~ /.+bp.+%$/)
     {
     if ($_ =~ /^(.+)\s+(\d+)\s+(\d+)\s+bp\s+(\d+\.\d+)\s+%$/)
     {
     print $1,"\n";
     
     }
     elsif ($_ =~ /^(.+)\s+(\d+)\s+bp\s+(\d+\.\d+)\s+%$/)
     {
     print $1,"\n";
     }
     }
     }
=cut 
    
    
    print "
    .tbl files Parser,
    Component of RepeatMasker Data Analyzer, Version 1.00
    
    Copyright (C) 
    Quan Fang, Christopher Botka
    Research Information Technology Group
    Havard Medical School
    
    All rights reserved.
    
    Basic options:
    user\@orchestra\$ ./tbl.pl -r RepeatMasker  
    
    RepeatMasker = RepeatMasker raw outputs directory
                 MasterFile.tbl will be created under the RepeatMasker directory
    
";
}
###################################################################







