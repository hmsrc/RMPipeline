RMPipeline
==========

RepeatMasker Analysis Pipeline

Authors: Andrew Shedlock, Quan Fang, Chris Botka, Amir Karger, Greg Cavanagh

Affiliation: 

College of Charleston, Department of Biology 
Hollings Science Center 58 Coming Street, Room 216B
Charleston, SC 29401 USA

Research Computing, Harvard Medical School
107 Avenue Louis Pasteur, Room 105, Boston MA 02115-5701

Contact: botka@hms.harvard.edu, shedlockam@cofc.edu, fangquans@gmail.com


======================
1, General background
======================

RepeatMasker is a program that screens DNA sequences for interspersed repeats and low complexity DNA sequences. We developed RMPipeline, as a secondary level repeats analysis pipeline. 


======================
2, Functional scripts 
======================

2.1 family_cli.pl
----------------------------------------------------

(1) concatenates repeatmasker .out resutls into a master file, named MasterFile.out

(2) categorize repeats into families, superfamilies and subfamilies. 
    
    usage:
        user@orchestra$ perl family_cli.pl -r RepeatMasker -f RMFamily -S RMSuper -s RMSub         
                RepeatMasker = RepeatMasker raw outputs directory
                RMFamily     = Directory to place repeat families
                RMSuper      = Directory to place repeat super families
                RMSub        = Directory to place repeat sub families            
    logfile:
    
        RepeatMasker raw results directory: RepeatMasker_orchestra/
        MasterFile.out done
        Your source MasterFile.out file
        Output folder: RMFamily/
        RMFamily done
        
        Your source RepeatMaskerFamily directory: RMFamily/
        Your output RepeatMaskerSuperFamily directory: RMSuper
        RMSuperFamily done

        Your source RepeatMaskerFamily directory: RMFamily/
        Your output RepeatMaskerSubFamily directory: RMSub        
        RMSubFamily done

2.2 GC_cli.pl
----------------------------------------------

Extracts all the repeats sequence from original supercontigs. Mainly for GC contents. The design diagram is attached as GC_cli.pdf

    usage:
    
        user@orchestra$ perl GC_cli.pl -M Masterfile -F Superfasta -f FamilyCategory -O Output 
            Masterfile          = Masterfile of the species, under RM raw directory
            Superfasta          = Source genome data, in fasta Format
            FamilyCategory      = [Optional] Editable family categorization file, based on user's knowledge
            Output              = [Optional] Output directory
        
    FamilyCategory.txt is strictly a tab delimited file, "family    super-family    sub-family", for example:
    
        DNA     DNA ELEMENTS	D-OTHER
        DNA	    DNA ELEMENTS	D-OTHER
        DNA_Academ  DNA ELEMENTS	D-OTHER
        DNA_Chapaev	DNA ELEMENTS	D-OTHER
    
2.3 tbl.pl
-----------------------------------------------

Summarize RepeatMasker raw data, concatenates into a MasterFile.tbl. The design diagram is attached as tbl.pdf
    
    usage:
    
        user@orchestra$ perl tbl.pl -r RepeatMasker  
            RepeatMasker = RepeatMasker raw outputs directory
            MasterFile.tbl will be created under the RepeatMasker directory
        
    MasterFile.tbl:
    
        sequences:        393681
        total length:	2187967980 bp (1941067579 bp excl N/X-runs)
        GC level:	43.6973309922616 %
        bases masked:	131962953 bp ( 6.0313018383386 %)
        ==================================================================
        (1)number of element	(2)length occupied	(3)percentage of sequence
        ------------------------------------------------------------------
                 Retroelements         420205      111474566 bp   5.0949 %
                        SINEs:          92706       10798749 bp   0.4936 %
                      Penelope            381          30186 bp   0.0014 %
                        LINEs:         300463       94280632 bp   4.3090 %
                     CRE/SLACS              0              0 bp   0.0000 %
                    L2/CR1/Rex         275225       86629285 bp   3.9593 %
                 R1/LOA/Jockey           2359         928603 bp   0.0424 %
                    R2/R4/NeSL             80           9535 bp   0.0004 %
                     RTE/Bov-B          15922        5300324 bp   0.2422 %
                       L1/CIN4           5651        1213003 bp   0.0554 %
                 LTR elements:          27036        6395185 bp   0.2923 %
                       BEL/Pao            520          27999 bp   0.0013 %
                     Ty1/Copia             65           4575 bp   0.0002 %
                   Gypsy/DIRS1          12673        5240062 bp   0.2395 %
                    Retroviral          11009         853484 bp   0.0390 %
               DNA transposons          83672        7572146 bp   0.3461 %
                hobo-Activator          42532        2858794 bp   0.1307 %
                Tc1-IS630-Pogo          15192        1735841 bp   0.0793 %
                        En-Spm              2            153 bp   0.0000 %
                    MuDR-IS905              0              0 bp   0.0000 %
                      PiggyBac           4412         724574 bp   0.0331 %
             Tourist/Harbinger            362          30309 bp   0.0014 %
                Other (Mirage,             30           1907 bp   0.0001 %
               Rolling-circles              0              0 bp   0.0000 %
                 Unclassified:           9471        1465230 bp   0.0670 %
    Total interspersedrepeats:                     120511942 bp   5.5079 %
                    Small RNA:          20136        2745203 bp   0.1255 %
                   Satellites:           2069         166911 bp   0.0076 %
               Simple repeats:         115056        4668582 bp   0.2134 %
               Low complexity:         200688        6490805 bp   0.2967 %


======================
3, Reference 
======================

[Poster:](https://github.com/hmsrc/RMPipeline/blob/master/Asilomar_022412.pdf) 
Quan Fang, Christopher Botka and Andrew Shedlock. Global annotation and molecular evolutionary analysis
of genomic repeats in the Painted Turtle, Chrysemys picta. 3rd International Conference/Workshop on Genomic Impact of Eukaryotic Transposable Elements. 