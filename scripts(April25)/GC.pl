#!/usr/local/bin/perl

#use warnings;
#Command line processing.
use Getopt::Long;
Getopt::Long::Configure ('bundling');

# lower-case for naming variables
my $GCFolder;       # this variable is able to pass into subroutine
my $sourcefasta;    # this variable is able to pass into subroutine

GetOptions (
'G|GCFolder=s' => \$GCFolder,
'F|fasta=s'  => \$sourcefasta,
'S|RMSuper=s' => \$SuperFamilyDirectory,
);

if (!defined($GCFolder) || !defined($sourcefasta) || !defined($SuperFamilyDirectory))
{
   die ("./GC.pl -G GCFolder -F fasta -S RMSuper");
}

my @time = split (" ", scalar localtime());
my $tempfolder = join ("_",@time);    # this variable is able to pass into subroutine

system ("mkdir $GCFolder") == 0 or die ("Fail to create $GCFolder");
system ("mkdir $tempfolder") == 0 or die;

&SequenceLocationIndex;

&ExtractSequence($tempfolder);

#&SplitAndMerge;

## This function is to generate index file which hashes sequences to its file-system location
sub SequenceLocationIndex
{
    print "$sourcefasta\n";
    ## every split file has only 1 contig
    &splitfasta($sourcefasta,"$tempfolder/temp",1); 
    
    ## create an index file, place it under the temporary folder
    my $Index_File = "$tempfolder"; 
    open (WRITE,">$tempfolder/index.txt") or die "Can't write into index.txt";
    opendir (FH, "$tempfolder") or die "Can't open $tempfolder";
    foreach my $file (readdir FH)
    {        
        if ($file !~ /temp/) {next;}
        $file = "$tempfolder/$file";
        my $contigs =  `grep '>' $file`;        ## return all the contigs in that split file
        $contigs =~ s/\n//;
        if ($contigs =~ /^>/)
        {   
            $contigs =~ s/>//; print WRITE $contigs."\t".$file."\n";  
        }
    }
    close (FH);
    close (WRITE);
}


sub ExtractSequence
{
    ########################################
    ## build the hash table of index file ##
    ########################################
    my %Index = ();
    
    my $tempfolder = $_[0];
    #my $tempfolder = "Wed_Mar_21_13:33:48_2012";

    open (FILE, "$tempfolder/index.txt") or die "Index file doesn't exist any longer !";
    my (@lines) = <FILE>; 
    close FILE;
    
    if (scalar(@lines) == 1)
    {     
        open (FILE, "$tempfolder/index.txt") or die "Index file doesn't exist any longer !";
        @lines = split "\n",<FILE>; 
        close FILE;
    }
    
    foreach my $index_line (@lines)
    {
        chomp($index_line);
        my @line = split("\t",$index_line);
        $Index{$line[0]} = $line[1];
    }
    
    
    while( my ($k, $v) = each %Index ) 
    {
        print "key: $k, value: $v.\n";
    }

    ##################################
    ## Create 9 SuperFamiliesRepeat ##
    ##################################
    
    my @SuperFamiliesGC = (
    "DNA_ELEMENTS_Repeat.fa",
    "LINEs_Repeat.fa",
    "LTR_ELEMENTS_Repeat.fa",
    "ROLLING_CIRCLES_Repeat.fa",
    "SMALL_RNAs_Repeat.fa",
    "SINEs_Repeat.fa",
    "UNCLASSIFIED_Repeat.fa",
    "SATELLITES_Repeat.fa",
    "SIMPLE_REPEATS_Repeat.fa",
    );
    
    foreach my $SuperGC (@SuperFamiliesGC)
    {
        open (DIR, '>',"$GCFolder/$SuperGC") or die  $!;
        print DIR "";
        close (DIR);
    }
    ############################
    ## read from super family ## 
    ############################

    my @SuperFamilies = (
    "DNA_ELEMENTS",
    "LINEs",
    "LTR_ELEMENTS",
    "ROLLING_CIRCLES",
    "SMALL_RNAs",
    "SINEs",
    "UNCLASSIFIED",
    "SATELLITES",
    "SIMPLE_REPEATS",
    );
 
    # test
    #my @SuperFamilies = (
    #"ROLLING_CIRCLES",
    #);
    
    foreach my $superfamily (@SuperFamilies)
    {
        open (SUPERREPEAT,">>$GCFolder/$superfamily\_Repeat.fa"); ## write GC_content.fa into _Repeat.fa
        open (SUPER,      "$SuperFamilyDirectory/$superfamily");   ## repeats are in the superfamily files
        my @Super = <SUPER>;
        close (SUPER);

        if( scalar (@Super) == 1)
        {
            open (SUPER,      "$SuperFamilyDirectory/$superfamily");   ## repeats are in the superfamily files
            @Super = split "\n",<SUPER>;
            close (SUPER);
        }    
        
        foreach my $line (@Super)
        {
            chomp($line);
            $line =~ /([^A-Za-z]+)([A-Za-z\d]+)(\s+)(\d+)(\s+)(\d+)/ ;  
            my $Sequence_contig = $2;   # $2 is the contig name 
            my $Sequence_begin  = $4;   # $4 is the query begin position        
            my $Sequence_end    = $6;   # $6 is the query end position
            
            my $Sequence_Loc = $Index{"$Sequence_contig"};    # $Sequence_Loc is the corresponding fasta file  
            print "$superfamily\t$Sequence_contig\t$Sequence_Loc\n";
            my $Sequence = `grep "$Sequence_contig" $Sequence_Loc -A 1` or next;
            ## system call, return to a variable, "-A 1" print 1 sequence after the pattern
            my @Sequence_FA = split("\n",$Sequence);
            my $Sequence_FA     = $Sequence_FA[1];
            my $Sequence_Repeat = substr ($Sequence_FA,int($Sequence_begin) - 1, int($Sequence_end) - int ($Sequence_begin) + 1 );  # substr EXPR, OFFSET, LEN
            print SUPERREPEAT ">$Sequence_contig\_$Sequence_begin\_$Sequence_end\n";
            print SUPERREPEAT "$Sequence_Repeat\n";
        }
        close (SUPER);
        close (SUPERREPEAT);        
    }
}

sub SplitAndMerge 
{
    my $SuperFamilyDirectory = "/groups/ritg/repeats/Chrysemys_picta/303/RepeatMaskerSuperFamily";
    my @SuperFamilies = 
    (
    "DNA_ELEMENTS",
    "LINEs",
    "LTR_ELEMENTS",
    "ROLLING_CIRCLES",
    "SMALL_RNAs",
    "SINEs",
    "UNCLASSIFIED",
    "SATELLITES",
    "SIMPLE_REPEATS",
    );

    foreach my $SuperFamily(@SuperFamilies)
    {
        print $SuperFamily."\n";
        my $cmd1 = "split $SuperFamilyDirectory/$SuperFamily $SuperFamilyDirectory/$SuperFamily -l 400  -a 4 -d"; 
        system ($cmd1);
    }
}

sub splitfasta
{
    $inputFile = $_[0];
    $outputFile = $_[1];
    $numberToCopy = $_[2];
    
    #count the number of sequences in the file
    #read each record from the input file
    
    my $seqCount = 0;
    my $fileCount = 0;
    my $seqThisFile = 0;
    
    
    open (OUTFILE, ">" . $outputFile . "_" . $fileCount) or die ("Cannot open file for output: $!");
    
    open (SEQFILE, $inputFile) or die( "Cannot open file : $!" );
    $/ = ">";
    
    while (my $sequenceEntry = <SEQFILE>) 
    {
        
        if ($sequenceEntry =~ m/^\s*>/){
            #print $sequenceEntry."\n";
            next;
        }
        
        my $sequenceTitle = "";
        if ($sequenceEntry =~ m/^([^\n]+)/){
            $sequenceTitle = $1;
        }
        else {
            $sequenceTitle = "No title was found!";
        }
        
        $sequenceEntry =~ s/^[^\n]+//;
        $sequenceEntry =~ s/[^A-Za-z]//g;
        
        #write record to file
        print (OUTFILE ">$sequenceTitle\n");
        print (OUTFILE "$sequenceEntry\n");
        $seqCount++;
        $seqThisFile++;
        
        if ($seqThisFile == $numberToCopy) {
            $fileCount++;
            $seqThisFile = 0;
            close (OUTFILE) or die( "Cannot close file : $!");
            print	$outputFile."_".$fileCount."\n";
            open (OUTFILE, ">" . $outputFile . "_" . $fileCount) or die ("Cannot open file for output: $!");	
        }
    }#end of while loop
    close (SEQFILE) or die( "Cannot close file : $!");    
    close (OUTFILE) or die( "Cannot close file : $!");
}






