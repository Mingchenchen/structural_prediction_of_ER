Amir Shahmoradi, Thursday 10:54 PM, Jan 30 2014, Wilke Lab., University of Texas Austin

	ATTN:
		Today I noticed that the original 2JLY_A.pdb file has two identical residues at the position 321 (ASER & BSER). Because of this there were 452 CA atoms in the corresponding bfactor file, which did not match the 451 residue numbers in the Amber modified pdb file 2JLY_A_amber.pdb. To resolve this problem, I removed the second residue (BSER) from the original pdb file. The corresponding bfactors were however very similar to each other differing by only <0.1%.

Amir Shahmoradi, Monday 8:51 PM, Jan 27 2014, Wilke Lab., University of Texas Austin
	
	This directory contains b-factors for CA atoms of each amino acid in each pdb structure for which MD simulations were run.
	The *.bfactor files are obtained using the Fortran (2008) source codes that are in the subdirectory 'src'.
	
	To compile the Fortran code and create the executable on TACC, use the following command:
	
		> ifort main_bfactor.f90 -o main_bfactor.o
	
	To run the code type:
	
		> main_bfactor.o
		
	The code will automatically inform the user about the required command-line input file names in order to generate the cn13 values.
	
	ATTN-ATTN-ATTN-ATTN-ATTN-ATTN-ATTN-ATTN-ATTN-ATTN-ATTN-ATTN:
	
		The input pdb file to the code must be the modified pdb file taken directly from Protein Data Bank. The Amber modified pdb files (*_amber.pdb, *_bres.pdb, *_X.pdb) have all b-factors set to zero, since Amber adds the missing atoms to the original pdb file.