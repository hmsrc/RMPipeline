RMPipeline
==========

RepeatMasker Analysis Pipeline

Authors: Quan Fang, Chris Botka, Amir Karger, Greg Cavanagh

Affiliation: 

The Research Information Technology Group (RITG), Harvard Medical School

107 Avenue Louis Pasteur, Room 105, Boston MA 02115-5701

Contact: Christopher_Botka@hms.harvard.edu


======================
1, General background
======================



======================
2, Functional scripts 
======================

2.1 family_cli.pl 

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








