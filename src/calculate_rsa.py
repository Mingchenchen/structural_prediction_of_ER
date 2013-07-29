#!/usr/bin/python
import sys, subprocess, os
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord
from Bio.PDB.Polypeptide import *
from Bio.PDB import PDBParser
from Bio.PDB import PDBIO
from Bio.PDB import Dice
import math
import numpy

# Amir Shahmoradi, 12:46 PM, Monday July 29, 2013, Wilke Lab, ICMB, University of Texas at Austin.
# This is a novice python code that takes in a pdb filename, the dssp ASA output filename, and the output RSA filename as the command line arguments and calculates the relative solvent accessibility (RSA) of the the residues. The accessible surface areas are normalized according to the new normalization calculations of Tien et al. (2013).

#This is a dictionary that relates the three letter amino acid abbreviation with its one letter abbreviation
resdict = { 'ALA': 'A', 'CYS': 'C', 'ASP': 'D', 'GLU': 'E', 'PHE': 'F', \
            'GLY': 'G', 'HIS': 'H', 'ILE': 'I', 'LYS': 'K', 'LEU': 'L', \
            'MET': 'M', 'ASN': 'N', 'PRO': 'P', 'GLN': 'Q', 'ARG': 'R', \
            'SER': 'S', 'THR': 'T', 'VAL': 'V', 'TRP': 'W', 'TYR': 'Y' }

#This is a dictionary that has the amino acid for the key and the max solvent accessibility for this amino acid
#THIS HAS BEEN UPDATED. I AM USING THE NEW THEORETICAL NUMBERS FROM THE 2013 AUSTIN, STEPHANIE, MATT, WILKE PAPER. 
residue_max_acc = {'A': 129.0, 'R': 274.0, 'N': 195.0, 'D': 193.0, \
                   'C': 158.0, 'Q': 223.0, 'E': 224.0, 'G': 104.0, \
                   'H': 209.0, 'I': 197.0, 'L': 201.0, 'K': 237.0, \
                   'M': 218.0, 'F': 239.0, 'P': 159.0, 'S': 151.0, \
                   'T': 172.0, 'W': 282.0, 'Y': 263.0, 'V': 174.0}
#This calculates the RSA values for a PDB using DSSP. It returns a list of the Amino Acids and a list of their RSA values. 
def get_values(pdb_path,output_dssp):
    processString = 'dssp' + ' -i ' + pdb_path + ' -o ' + output_dssp
    process = subprocess.Popen(processString, shell = True, stdout = subprocess.PIPE)
    process.wait() # Wait until dssp is done processing the file and calculating the Solvent Acessiblility  values
    input = open(output_dssp, 'r')    
    fileContents = input.readlines()	
    string = fileContents[25]
    SAValue1 = string[13]
    SAList = [] #This is is the list which will store the SA values for each site
    AAList = [] #This is the list which will store the amino acid values for each site
    index = 0
    NoRSA = 0
    for line in fileContents:
        if index<25: #This skips the first few lines that do not have the SA value data
            index = index + 1
            continue
        else:  #Goes through each line with has the SA for each amino acid in order
            string = line #This stores the current line in the string "string"
            SAValue = string[35:39] #This stores the SA value for the current 
            AA = string[13] #This stores what the amino acid type is at the current  position
            number = int(SAValue)  #This turns the string fir the SA into an int type
            if AA !=( '!' or '*'): #This takes out the missing gaps that dssp might put in
                max_acc = residue_max_acc[AA] #This uses the dictionary to find the max SA for the amino acid at the current position (site)
                SAList.append(number/max_acc) #This divides the SA value for that position by the amx SA value position for tha amino acid. This normalizes the values and gives us the Relative Solvent Accessability (RSA) value. We this appends this value to the list of RSA values
                AAList.append(AA) #This appends the amino acid to the list
            else:
           	NoRSA = NoRSA + 1 #Counts the number of residues that did not have SA values
	    index = index + 1
    input.close() #Close the file with the dssp output file
    #os.remove('pdbOutput.txt') #Deletes the dssp output file 
    return (AAList, SAList) #Return the RSA values and the SAList

def main():
    if len( sys.argv ) != 4:
        print '''
  
  Usage:'''
        print "     ", sys.argv[0], "<input pdb file>", "<output dssp ASA>", "<output RSA>"
    else:
        pdb_path = sys.argv[1]
        output_dssp = sys.argv[2]
        output_rsa = sys.argv[3]
	[AA_List, RSA] = get_values(pdb_path,output_dssp)
	#print len(RSA)
	rsa_outputfile=open(output_rsa,'w')
	for i, aa in enumerate(AA_List):
		rsa_outputfile.write(str(i) + '\t' + str(aa) + '\t' + str(RSA[i]))
	return

main()