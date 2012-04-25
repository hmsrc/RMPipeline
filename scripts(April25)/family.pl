#!/usr/local/bin/perl

#use strict;
use warnings;

my $mode;
do 
{
    print "\nPlease select mode:\n";
    print " 1) MasterFile\n";
    print " 2) RepeatMaskerFamily\n";
    print " 3) RepeatMaskerSuperFamily\n";
    print " 4) RepeatMaskerSubFamily\n";
    print " 5) Exit\n";
    print " Choose Mode: ";
    chomp ($mode = <STDIN>);
}   while ( $mode < 1 || $mode > 5);

my $MasterFileDir;
if ($mode == 1)
{
   &WriteMasterFile;
}


my $MasterFile;
my $RepeatMaskerFamily;
if ($mode == 2)
{
    &RepeatMaskerFamily;
}


if ($mode == 3)
{
    &RepeatMaskerSuperFamily;
}

if ($mode == 4)
{
    &RepeatMaskerSubFamily;
}

if ($mode == 5)
{
    exit;
}



###################################################################
### 1) Create MasterFile.out
### You will be asked RepeatMasker raw results directory
###################################################################
sub WriteMasterFile
{
    print "\nPlease input RepeatMasker raw results directory: \n";
    chomp ($RM_dir = <STDIN>);
    open (WRITEFILE, ">$RM_dir/MasterFile.out") or die "Directory not exists";
    opendir (DIR, $RM_dir) or die "Fail";
    foreach my $file (readdir DIR)
    {
        if ($file =~ /out$/ && $file !~ /MasterFile.out$/)
        {
            my $firstline = `head -1 $RM_dir/$file`; 
            # check the firstline to see if it's RM output
            if ( $firstline =~ /SW/ && $firstline =~ /perc/ && $firstline =~ /query/ )
            {
                $file = $RM_dir."/".$file;
                print $file."\n";
                open (FH, $file) or die "can't open $file";
                {
                    my $line = <FH>; ## remove the first 3 lines 
                    $line = <FH>;
                    $line = <FH>;
                    foreach my $line (<FH>)
                    {
                        print WRITEFILE $line;
                    }
                }
                close (FH);
            }
        }
    }
    close(DIR);
    close (WRITEFILE);
}

###################################################################
###  2)  RepeatMaskerFamily                             ###########
### (1) Create different families files  (2) Write into ###########
###################################################################
###  You will be asked source MasterFile.out ###
###  You will be asked output folder, e.g ./RepeatMaskerFamily

sub RepeatMaskerFamily
{
    print "\nPlease choose your source MasterFile.out file\n";
    chomp ($MasterFile = <STDIN>);
    
    print "\nPlease choose the output folder. e.g ./dir/RepeatMaskerFamily\n";
    chomp ($directory = <STDIN>);
    
    #my $MasterFile = "/groups/ritg/repeats/Under_Test/RepeatMasker/MasterFile.out";
    #my $directory  = "/groups/ritg/repeats/Under_Test/RepeatMaskerFamily";

    if ($MasterFile !~ /MasterFile/)
    { die "Invalid MasterFile"; }
    
    system ("mkdir $directory") ==0 or die "Invalid file path\n";
    ## create ~130 files, each file is for that family
    my %familyname_filehandle; ## the hash table for filenames and family names, undefined
    open (FH,$MasterFile) or die "can't open $MasterFile";
    foreach my $line (<FH>)
    {
        my @line        =  split(" ",$line);
        my $family_name =  $line[10];
        my $filehandle  =  $family_name;
        $filehandle  =~ s/\//_/g;   
        # filehandle name and real file name are the same
        # it won't allow me use strict
        
        #**  HashTable is very smart way:
        #**  (1) read the whole MasterFile once.
        #**  (2) total open file, 130 times.
        if ( exists $familyname_filehandle{$family_name} )
        {
            $filehandle = $familyname_filehandle{$family_name};
        }
        else
        {
            print "$family_name\n";
            $familyname_filehandle{$family_name} = $filehandle;
            open ( $filehandle, ">", "$directory/$filehandle");
            # open filehandles, filehandles names 
        }
        print $filehandle $line;
    }
    close (FH);
}

###################################################################
### 3) Create RepeatMaskerSuperFamily
### Write 130 families into superfamilies
### You will be asked source RepeatMaskerFamily directory
### You will be asked output RepeatMaskerSuperFamily directory
###################################################################
sub RepeatMaskerSuperFamily
{   
    print "\nPlease choose your source RepeatMaskerFamily directory\n";
    chomp ( my $Families_directory = <STDIN> );
    print "\nPlease choose your output RepeatMaskerSuperFamily directory\n";
    chomp ( my $SuperFamilyDirectory = <STDIN> );
    
    ## check user input
    ## 
    
    
    system ("mkdir $SuperFamilyDirectory") ==0 or die "Invalid file path\n";
    
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
    "SKip"
    );
    
    ## Create 9 SuperFamiliesFiles
    foreach (@SuperFamilies)
    {
        open (DIR, ">$SuperFamilyDirectory/$_") or die "Can't write";
        print DIR "";
        close (DIR);
    }
    ## Write 9 SuperFamiliesFiles 
    my $SuperFamily_Name;
    opendir (FH,$Families_directory);
    foreach my $Family_Name ( readdir FH )   ## This loops goes 130 times
    {
        if ($Family_Name =~ /^DNA/)
        {
            $SuperFamily_Name = $SuperFamilies[0];
        }
        
        elsif ($Family_Name =~ /^LINE/)
        {
            $SuperFamily_Name = $SuperFamilies[1];
        } 
        
        elsif ($Family_Name =~ /^LTR/)
        {
            $SuperFamily_Name = $SuperFamilies[2];
        } 
        
        elsif ($Family_Name =~ /^RC/)
        {
            $SuperFamily_Name = $SuperFamilies[3];
        }
        
        elsif ($Family_Name =~ /^(RNA|rRNA|scRNA|snRNA|srpRNA|tRNA)/)
        {
            $SuperFamily_Name = $SuperFamilies[4];
        }
        
        elsif ($Family_Name =~ /^SINE/)
        {
            $SuperFamily_Name = $SuperFamilies[5];
        }
        
        elsif ($Family_Name =~ /^(Unknown|Unknown_Y-chromosome|Segmental|Other)/)
        {
            $SuperFamily_Name = $SuperFamilies[6];
        }
        
        elsif ($Family_Name =~ /^Satellite/)
        {
            $SuperFamily_Name = $SuperFamilies[7];
        }
        
        elsif ($Family_Name =~ /^Simple_repeat/)
        {
            $SuperFamily_Name = $SuperFamilies[8];
        }
        else
        {
            $SuperFamily_Name = $SuperFamilies[9];
        }
        
        ## Open a family file each time
        print "$Family_Name\t$SuperFamily_Name\n";
        ### Write one family into its SuperFamily
        open (SRC,"$Families_directory/$Family_Name") or die "Can't open this family";
        open (WI,">>$SuperFamilyDirectory/$SuperFamily_Name") or die "Can't write into this superfamily";
        foreach my $line (<SRC>)
        {print WI $line;}
        close (WI);
        close (SRC);
    }
    close (FH);
}

###################################################################
### 4) Create RepeatMaskerSubFamily
### Write 130 families into subfamilies
### You will be asked source RepeatMaskerFamily directory
### You will be asked output RepeatMaskerSubFamily directory
###################################################################
sub RepeatMaskerSubFamily
{
    
    print "\nPlease choose your source RepeatMaskerFamily directory\n";
    chomp ( my $Families_directory = <STDIN> );
    print "\nPlease choose your output RepeatMaskerSubFamily directory\n";
    chomp ( my $SubFamilyDirectory = <STDIN> );

    system ("mkdir $SubFamilyDirectory") == 0 or die "Invalid file path\n";
    
    my @SubFamilies = (
    "DNA_ELEMENTS/D-OTHER",
    "DNA_ELEMENTS/hAT",
    "DNA_ELEMENTS/Tc-Group",
    "LINEs/L-OTHER",
    "LINEs/L[1-2]",
    "LINEs/RTE",
    "LINEs/CR1",
    "LTR_ELEMENTS/LTR",
    "ROLLING_CIRCLES/RC",
    "SMALL_RNAs/smRNA",
    "SINEs/SINE",
    "UNCLASSIFIED/UNC",
    "SATELLITES/SAT",
    "SIMPLE_REPEATS/SSR",
    "ERVs/ERV",
    "Skip/Skip"
    );
    
    my @SubFamiliesFirstLayer = (
    "DNA_ELEMENTS",
    "LINEs",
    "LTR_ELEMENTS",
    "ROLLING_CIRCLES",
    "SMALL_RNAs",
    "SINEs",
    "UNCLASSIFIED",
    "SATELLITES",
    "SIMPLE_REPEATS",
    "ERVs",
    "Skip"
    );
    
    foreach (@SubFamiliesFirstLayer)
    {
        system ("mkdir $SubFamilyDirectory/$_") == 0 or die "Can't make directory\n";  
    }   
    
    ## Create 10+ SubFamiliesFiles
    foreach (@SubFamilies)
    {
        open (DIR, ">$SubFamilyDirectory/$_") or die "Can't write $_ \n";
        print DIR "";
        close (DIR);
    }
    
    
    ## Write 10+ SuperFamiliesFiles
    my $SubFamily_Name;
    opendir (FH,$Families_directory);
    foreach my $Family_Name ( readdir FH )
    {
        
        ##########    DNA_ELEMENTS
        if ($Family_Name =~ /^DNA/  && $Family_Name !~ /hAT/  && $Family_Name !~ /TcMar/ )
        {
            $SubFamily_Name = $SubFamilies[0];
        }
        
        elsif ($Family_Name =~ /^DNA/  && $Family_Name =~ /hAT/)
        {
            $SubFamily_Name = $SubFamilies[1];
        }
        
        elsif ($Family_Name =~ /^DNA/  && $Family_Name =~ /TcMar/)
        {
            $SubFamily_Name = $SubFamilies[2];
        }
        
        
        ##########    LINEs
        elsif ($Family_Name =~ /^LINE/ && $Family_Name !~ /L1|L2/ && $Family_Name !~ /RTE/ && $Family_Name !~ /CR1/  )
        {
            $SubFamily_Name = $SubFamilies[3];
        } 
        
        
        elsif ($Family_Name =~ /^LINE/ && $Family_Name =~ /L1|L2/ )
        {
            $SubFamily_Name = $SubFamilies[4];
        } 
        
        
        elsif ($Family_Name =~ /^LINE/ && $Family_Name =~ /RTE/)
        {
            $SubFamily_Name = $SubFamilies[5];
        } 
        
        elsif ($Family_Name =~ /^LINE/ && $Family_Name =~ /CR1/ )
        {
            $SubFamily_Name = $SubFamilies[6];
        } 
        
        
        ##########    "LTR_ELEMENTS/LTR"
        elsif ($Family_Name =~ /^LTR/  && $Family_Name !~ /ERV/)
        {
            $SubFamily_Name = $SubFamilies[7];
        } 
        
        ##########    "ROLLING_CIRCLES/RC"
        elsif ($Family_Name =~ /^RC/)
        {
            $SubFamily_Name = $SubFamilies[8];
        }
        
        ##########    "SMALL_RNAs/smRNA"
        elsif ($Family_Name =~ /^(RNA|rRNA|scRNA|snRNA|srpRNA|tRNA)/)
        {
            $SubFamily_Name = $SubFamilies[9];
        }
        
        #########     "SINEs/SINE"
        elsif ($Family_Name =~ /^SINE/)
        {
            $SubFamily_Name = $SubFamilies[10];
        }
        
        
        #########     "UNCLASSIFIED/UNC"
        elsif ($Family_Name =~ /^(Unknown|Unknown_Y-chromosome|Segmental|Other)/)
        {
            $SubFamily_Name = $SubFamilies[11];
        }
        
        #########     "SATELLITES/SAT"
        elsif ($Family_Name =~ /^Satellite/)
        {
            $SubFamily_Name = $SubFamilies[12];
        }
        
        #########     "SIMPLE_REPEATS/SSR"
        elsif ($Family_Name =~ /^Simple_repeat/)
        {
            $SubFamily_Name = $SubFamilies[13];
        }
        
        #########     "ERVs/ERV"
        elsif ($Family_Name =~ /ERV/)
        {
            $SubFamily_Name = $SubFamilies[14];
        }
        
        else
        {
            $SubFamily_Name = $SubFamilies[15];
        }
        ## Open a family file each time
        print "$Family_Name\t$SubFamily_Name\n";
        
        ### Write one family into its SuperFamily
        open (SRC,"$Families_directory/$Family_Name") or die "Can't open this family";
        open (WI,">>$SubFamilyDirectory/$SubFamily_Name") or die "Can't write into this superfamily";
        foreach my $line (<SRC>)
        {print WI $line;}
        close (WI);
        close (SRC);
    }
    close (FH);
}















