#!/usr/local/bin/perl

#use strict;
use warnings;
#Command line processing.
use Getopt::Long;
Getopt::Long::Configure ('bundling');

# lower-case for naming variables
my $helloworld;
my $someone;

GetOptions (
'h|hello=s' => \$helloworld,
'H|world=s' => \$someone,
);

&help;

#print "$masterfile\n";
=cut
open (MF, $file) or die ("$masterfile not exists\n");
my @master = <MF>;
close MF;

foreach my $repeat (@master)
{
    chomp ($repeat);
    $repeat =~ /(\S+)\s+(\d+)\s+(\d+).*?(C|\+)\s+\S+\s+(\S+)/;  ## I have question here
    # "?(C|\+)" means the first C or "+"; "\s+" means one or more spaces; "\S+" means one or more non-spaces;
    # basically, masterfile.out is able to be parsed simply by \s+\S+
    my $Sequence_contig = $1;   # $2 is the contig name, with out ">" here
    my $Sequence_begin  = $2;   # $4 is the query begin position
    my $Sequence_end    = $3;   # $6 is the query end position
    my $strand          = $4;
    my $repeatfamily    = $5;       
    my $value = $Sequence_begin."QuanFang".$Sequence_end."QuanFang".$repeatfamily;
    #print $value;print "\n";
    #push (@{$bighash{$Sequence_contig}},$value);
    #6762458QuanFang6762486QuanFangSimple_repeat 
    print $Sequence_contig;
    print "\n";
}
=cut

sub help
{
    # reference type
    my @array = (1, 2, 3);
    my $reference = \@array;
    
    if (ref $reference) 
    {
        print "This is a reference\n";
        if (ref $reference eq 'SCALAR') {
            print "This is a reference to a scalar (variable)\n";
        }
        elsif (ref $reference eq 'ARRAY') {  
            print "This is a reference to an array\n";
        }
        elsif (ref $reference eq 'HASH') {  
            print "This is a reference to a hash\n";
        }
        elsif (ref $reference eq 'CODE') {  
            print "This is a reference to a subroutine\n";
        }
        elsif (ref $reference eq 'REF') {  
            print "This is a reference to another reference\n";
        }
    }
    else 
    {
        print "This is a normal variable\n";
    }
    
    ### Advanced data structure ###
    ## Array of arrays ##
    #&ArrayOfArray;
    ## Hash of arrays ##
    #&HashOfArray;
    ## Array of hashes ##
    #&ArrayOfHash
    ## Hashes of hashes ##
    #&HashOfHash
    
    }

sub ArrayOfArray
{
    #####################
    ## Array of arrays ##
    #####################
    my @AoA = ([1,2,3], ['John', 'Joe', 'Ib'], ['Eat', 2]);
    print $AoA[1][2]; # prints Ib
    print "xxx\t",$#AoA;
    print "\n";
    
    open (IN, "./test.pl") or die;
    while (defined (my $line = <IN>)) 
    {
        my @tmp = split(' ', $line); 
        push(@AoA, [@tmp]); 
    } # Add anonumous array (row) to @AoA
    
    foreach my $a (@AoA)
    {
        my @aa = @{$a};  # $a is the address of array (row)
        foreach my $b (@aa)
        {
            print $b;
            print " ";
        }
        print "\n";
    }
    
    # Printing/accessing the AoA
    for (my $x = 0; $x <= $#AoA; $x++) 
    {
        for (my $y = 0; $y <= $#{$AoA[$x]}; $y++) 
        {
            #print "At X=$x, Y=$y is ", $AoA[$x][$y], "\n"; 
        } 
    }
    
    print "xxx\t",$#AoA;        ## $#AoA is the size of array
    print "\n";
    print "xxx\t",scalar(@AoA);
    print "\n";

}

sub HashOfArray
{
    # Simple assignment
    %HoA = ('Numbers' => [1, 2, 3], 'Names' => ['John', 'Joe', 'Ib']);
    my $line = "Algorithms\tData Structures\tOperating System";
    my @tmp = split ("\t",$line);
    $HoA{'Courses'} = [@tmp]; ## this is a reference
    push (@{$HoA{'Courses'}}, "Databases");
    ##############
    print $HoA{'Courses'}[2],"\n";
    print $HoA{'Courses'}->[3],"\n";
}

sub ArrayOfHash
{
    # Simple assignment
    @AoH = 
    (
        {'key1' => 'value1', 'key2' => 'value2'},
        {'newhashkey1' => 'value1', 'key2' => 'value2'},
        {'anotherhashkey1' => 'value1', 'key2' => 'value2'}
    );
    push (@AoH,{'key' => 'val', 'xkey' => 'xval'});
    
    for (my $i = 0; $i < scalar (@AoH); $i++)
    {
        print "###############\n";
        while( my( $key, $value ) = each %{$AoH[$i]} )
        {print "$key: $value\n";}
    }
    
}

sub HashOfHash
{
    # Simple assignment
    %HoH = (
    'Masterkey1' => {'Key1' => 'Value1', 'Key2' => 'Value2' }, 
    'Masterkey2' => {'Key1' => 'Value1', 'Key2again' => 'Value2again'} 
    );
    
    # Adding an anonymous hash to the hash
    $HoH{'NewMasterKey'} = {'NewKey1' => 'NewValue1', 'NewKey2' => 'NewValue2'}; 

    print length (%HoH);
    print "\n";

    # Accessing the structure
    foreach my $firstkey (keys %HoH)
    {
        print "First Level: $firstkey\n";
        print "######################\n";
        foreach my $secondkey (keys %{$HoH{$firstkey}})
        {
            print " $secondkey => $HoH{$firstkey}{$secondkey} \n";
        }
    }
}








