Amir Shahmoradi, Wilke Lab., University of Texas Austin, 6:03 PM Friday July 19, 2013.

This directory contains all input structures, input parameter files and some of the important (but small size) output data from "Amber" explicit solvent MD simulations & postprocessing analyses.

Structure of the directory:
	
	- job: Contains all Amber job submission files (*.job) on TACC for this project, also the corresponding echo files (*.o).
	- mdin: Contains all Amber MD input files and prepared (ionized & solvated) pdb structures, except parameter_topology (prmtop) and input_coordinate (inpcrd) files that are excluded due to their large sizes.
	- mdout: Idealy should contain all Amber MD output files. Currently, no file is present due to their large sizes.
	- postproc: Contains all postprocessing analyses (RMSD, RMSF, RSA,...) done on Amber MD trajectories using either ptraj or cpptraj or other Amber modules.

The following pdb files are either taken directly from Daria's table, or are one of their close families:

	- Hemaglutinin Precursor (HP) --> 1RD8_AB.pdb (503 residues) (Stephanie's corresponding fasta file: aln_aa_H1N1_HA.fasta)
	- Crimean Congo Hemorrhagic Fever Nucleocapsid (CCHFN) --> 4AQF_B.pdb (474 residues) (Stephanie's corresponding fasta file: aln_aa_crimean_congo.Nucleoprotein.fasta)
	- Dengue Protease Helicase (DPH) --> 2JLY.pdb (451 residues) (Stephanie's corresponding fasta file: aln_aa_dengue_ns3.fasta)
	- Hepatitis C Protease (HCP) --> 3GOL.pdb (557 residues), 3GSZ.pd (558 residues), 3I5K.pdb (566 residues) (Stephanie's corresponding fasta file: aln_aa_HCV_NS5B.fasta)
	- Influenza Nucleoprotein (INP) --> 4IRY.pdb (404 residues) (Stephanie's corresponding fasta file: aln_aa_H1N1_NP.fasta)
	- Japanese Encephalitis Helicase/Nucleoside (JEHN) --> 2Z83.pdb (426 residues) (Stephanie's corresponding fasta file: aln_aa_JEV.fasta)
	- Marburg RNA Binding Domain (MRNABD) --> 4GHA_A.pdb (122 residues) (Stephanie's corresponding fasta file: aln_aa_marburg.vp35.fasta)
	- Rift Valley Fever Virus NucleoProtein (RVFVNP) --> 3LYF.pdb (244 residues) (Stephanie's corresponding fasta file: ?.fasta, no alignmet)

As of today, each structure has the following steps for its MS simulations by Amber, all available on Lonestar, TACC:

	- A short 2000 step initial energy minimization of the structure.
	- 100ps weakly-constrained heating to 300K.
	- 100ps weakly-constrained density equilibration at temp~300K.
	- 5ns unconstrained NPT equilibration.
	- 15ns of NPT MD trajectories (The output from this section is what will be used for MD postprocessing: RMSD, RMSF, RSA, ...).
