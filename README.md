RMPipeline
==========

RepeatMasker Analysis Pipeline

Authors: Quan Fang, Chris Botka, Amir Karger, Greg Cavanagh

Affiliation: The Research Information Technology Group (RITG), Harvard Medical School, 
107 Avenue Louis Pasteur, Room 105, Boston MA 02115-5701

Contact: Christopher_Botka@hms.harvard.edu


======================
1, General background
======================



======================
2, Functionality 
======================

2.1 family_cli.pl concatenates 


user@orchestra$ perl family_cli.pl -r RepeatMasker -f RMFamily -S RMSuper -s RMSub 
        
    RepeatMasker = RepeatMasker raw outputs directory
    RMFamily     = Directory to place repeat families
    RMSuper      = Directory to place repeat super families
    RMSub        = Directory to place repeat sub families
