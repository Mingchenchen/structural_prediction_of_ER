! Amir Shahmoradi, Friday 12:25 PM, November 22, 2013, WilkeLab, UT Austin.
! ATTN: This version of the code only recognizes Na+ (or SOD) and Cl- (or CLA) as the ions in the pdb file. The pdb file must not contain any other ion!
! Given a pdb structure (normally a bres output file from Amber suit) and the corresponding mdcrd file,
! this code calculates the contact number (WCN) for each amino acid in the protein chain, defined as the number of alpha-carbon (CA) atoms closer than 13 Angstroms to
! the CA atom of the amino acid. The number 13 (A), is taken from Fransoza et al (2009).
! ATTN: It is recommended to consider the bres format of Amber pdb files as the input for this code. The bres pdb files conform with the Protein Databas convention for amino acid names. An example is HIS which Amber denotes it sometimes by HIE, depending on its charge.  

! Amir Shahmoradi, Monday 3:48 PM, January 20, 2013, WilkeLab, UT Austin.

! ATTN-ATTN-ATTN-ATTN-ATTN-ATTN-ATTN-ATTN-ATTN-ATTN-ATTN-ATTN:
	
!		The input pdb file to the code must be the modified pdb file generated by Amber that has ALL the atoms added to the original pdb structure prior to the MD simulation. A qualified pdb file is the one with a file name that ends with either *_bres.pdb or *_amber.pdb. The former is preferred as the input, since the generated output pdb file by the code will then have three-letter amino acid names that are consistent with and recognized by other software packages such as VMD.

!module aa_dictionary
!implicit none
!integer, parameter :: aa_num = 20
!character(len=1), dimension(aa_num) :: aa_dict = ['A','R','N','D','C','Q','E','G','H','I','L','K','M','F','P','S','T','W','Y','V']
!real*8, dimension(aa_num) :: max_rsa = [129.,274.,195.,193.,167.,225.,223.,104.,224.,197.,201.,236.,224.,240.,159.,155.,172.,285.,263.,174.]
!end module aa_dictionary

program dynamic_wcn
implicit none
integer :: i,j,ios=0,frame=0
integer :: natoms=0,nions=0,nres	    ! total number of protein atoms and ions and residues in the amber pdb file
character(len=300) :: pdb_in			! pdb file must be free of any non amino acid atoms, except na+ and cl- ions that are automatically handled by the code.
character(len=300) :: crd_in			! the correspodning amber mdcrd file for the given pdb file .
character(len=300) :: pdb_out			! pdb file must be free of any non amino acid atoms, except na+ and cl- ions that are automatically handled by the code.
character(len=300) :: wcn_out			! the output file that contains the wcn information from md trajectory for each frame.
character(len=300) :: command			! the command to be executed in shell.
character(len=6) :: record
character(len=4) :: atom_name
character(len=3), dimension(:), allocatable :: res_name
character(len=1), dimension(:), allocatable :: chain_id
integer, dimension(:), allocatable :: res_num
character(len=1) :: alt_loc_ind,res_code
integer :: atom_num
real*8  :: occupancy,bfactor,dummy
real*8, dimension(3) :: crd
real*8, dimension(3) :: box
real*8, dimension(:,:), allocatable :: mdcrd
real*8, dimension(:,:), allocatable :: CAcrd	! this vector will contain the coordinates of the c-alpha carbons in the md crd file. dimension is (nres,3). 
real*8, dimension(:),   allocatable :: wcn		! The array of contact numbers for each each CA atom.
integer,dimension(:),   allocatable :: CApos	! this vector contains the index of ca atoms in the md crd file. dimension is (nres)
logical :: protein_stat=.true.
integer :: wcn_file_unit=22
character(len=6) :: dummy_char
character(len=100) :: wcn_output_format,res_output_format,resnum_output_format

call random_seed()

if (command_argument_count()/=4) then
	write(*,*)
	write(*,*) "Incorrect number of input arguments on the command line."
	write(*,*) "Correct use:"
	write(*,'(1A100)') "./a.out <input pdb file> <input mdcrd file> <output pdb file without ions> <output WCN file>"
	write(*,*)
	stop
end if
call get_command_argument(1,pdb_in)
call get_command_argument(2,crd_in)
call get_command_argument(3,pdb_out)
call get_command_argument(4,wcn_out)

open(unit=11,file=trim(adjustl(pdb_in)),status='old')
open(unit=12,file=trim(adjustl(crd_in)),status='old')
open(unit=21,file=trim(adjustl(pdb_out)),status='replace')
open(unit=wcn_file_unit,file=trim(adjustl(wcn_out)),status='replace')

! FIRST DETERMINE THEW NUMBER OF ATOMS IN THE PDB FILE (EXCLUDING THE IONS: ONLY Na+ & Cl- ARE CONSIDERED AT THE MOMENT).
	
	do
		read(11,'(1A4)') record
		if (trim(adjustl(record))=='ATOM') exit
		!write(*,'(1A4)') record
		cycle
	end do
	
	backspace(unit=11)
	
	allocate(res_num(1),res_name(1),chain_id(1))
	
	do
		read(11,'(A6,I5,1X,A4,A1,A3,1X,A1,I4,A1,3X,3F8.3,2F6.2)',iostat=ios) record,atom_num,atom_name,alt_loc_ind,res_name(1),chain_id(1),res_num(1),res_code,(crd(j),j=1,3),occupancy,bfactor
		if (ios<0) then
			exit
		elseif (ios>0) then
			write(*,*) 'Sum Tin Wong! : PDB file broken.'; stop
		else
			if (trim(adjustl(atom_name))=='Na+' .or. trim(adjustl(atom_name))=='Cl-' .or. trim(adjustl(atom_name))=='SOD' .or. trim(adjustl(atom_name))=='CLA') then
				nions = nions + 1
				protein_stat = .false.
			elseif (trim(adjustl(record))=='TER' .and. protein_stat) then
				write(21,'(A3)') 'TER'
			elseif (trim(adjustl(record))=='END') then
				write(21,'(A3)') 'END'
				exit
			elseif (protein_stat) then
				if (chain_id(1) == " ") chain_id(1) = 'X'
				write(21,'(A6,I5,1X,A4,A1,A3,1X,A1,I4,A1,3X,3F8.3,2F6.2)') record,atom_num,atom_name,alt_loc_ind,res_name(1),chain_id(1),res_num(1),res_code,(crd(j),j=1,3),occupancy,bfactor
				nres = res_num(1)
				natoms = natoms + 1
			end if
			cycle
		end if
	end do

	deallocate(res_num,res_name,chain_id)
	close(11); close(21)
	write(*,*); write(*,'(1A8,1I8)') "natoms: ",natoms; write(*,'(1A8,1I8)') "nions: ",nions
	write(*,'(1A8,1I8)') "ntot: ",natoms+nions; write(*,'(1A8,1I8)') "nres: ",nres

! NOW CALCULATE THE WCN FOR THE ORIGINAL PDB FILE (WITH THE CRYSTAL STRUCTURE COORDINATES).

	open(unit=21,file=trim(adjustl(pdb_out)),status='old')
	allocate(CApos(nres),CAcrd(nres,3),wcn(nres))
	allocate(res_num(nres),res_name(nres),chain_id(nres))
	i = 1
	do
		read(21,'(A6,I5,1X,A4,A1,A3,1X,A1,I4,A1,3X,3F8.3,2F6.2)',iostat=ios) record,atom_num,atom_name,alt_loc_ind,res_name(i),chain_id(i),res_num(i),res_code,(crd(j),j=1,3),occupancy,bfactor
		if (ios<0) then
			write(*,'(1A100)') 'Sum Tin Wong! : reached the end of output PDB file, while expecting further reading from the file.'; stop
		elseif (ios>0) then
			write(*,*) 'Sum Tin Wong! : output PDB file broken.'; stop
		elseif (trim(adjustl(atom_name))=='Na+' .or. trim(adjustl(atom_name))=='Cl-' .or. trim(adjustl(atom_name))=='SOD' .or. trim(adjustl(atom_name))=='CLA') then
			write(*,*) 'Sum Tin Wong! : output PDB file contains ions!'; stop
		elseif (trim(adjustl(record))=='TER') then
			!write(21,'(A3)') 'TER'	! write(*,'(A6,I5,1X,A4,A1,A3,1X,A1,I4,A1,3X,3F8.3,2F6.2)',iostat=ios) record,atom_num,atom_name,alt_loc_ind,res_name,chain_id,res_num,res_code,(crd(j),j=1,3),occupancy,bfactor
			cycle
		elseif (trim(adjustl(record))=='END') then
			if (i<=nres) then
				write(*,'(1A100)') 'Sum Tin Wong! : reached the end of output PDB file, while expecting further reading from the file.'
				write(*,*) 'number of residues read: ', i
				stop
			end if
			exit
		else	!if (protein_stat) then
			if (trim(adjustl(atom_name))=='CA') then
				CAcrd(i,1:3) = crd
				CApos(i) = atom_num
				i = i + 1
			end if
		end if
		if (i > nres) exit
		cycle
	end do; close(21)

	write(*,*) 'number of CA atoms in the pdb file: ', i-1

	call wcn_finder(nres,CAcrd,wcn)

	! NOW WRITE OUT THE FIRST FOUR LINES OF THE OUTPUT WCN FILE
		write(dummy_char,'(1I6)') nres
		res_output_format = trim(adjustl('(1A15,' // trim(adjustl(dummy_char)) // 'A15)'))
		wcn_output_format = trim(adjustl('(1I15,' // trim(adjustl(dummy_char)) // 'E15.5)'))
		resnum_output_format = trim(adjustl('(1A15,' // trim(adjustl(dummy_char)) // 'I15)'))
		write(wcn_file_unit,res_output_format) 'res_name',(res_name(i),i=1,nres)
		write(wcn_file_unit,resnum_output_format) 'res_num',(res_num(i),i=1,nres)
		write(wcn_file_unit,res_output_format) 'chain_id',(chain_id(i),i=1,nres)
		write(wcn_file_unit,wcn_output_format) frame,(wcn(i),i=1,nres)
	
! NOW READ AMBER MD TRAJECTORIES.

	allocate(mdcrd(natoms+nions,3))
	read(12,*)
	
	do
		frame = frame + 1
		read(12,'(10F8.3)',iostat=ios) ((mdcrd(i,j),j=1,3), i = 1,natoms+nions)
		if (ios < 0) then
			exit
		elseif (ios > 0) then
			write(*,*) 'Sum Tin Wong! : Amber MDCRD file broken.'; stop
		else
			forall (j=1:nres) CAcrd(j,1:3) = mdcrd(CApos(j),1:3)
			call wcn_finder(nres,CAcrd,wcn)
			write(wcn_file_unit,wcn_output_format) frame,(wcn(i),i=1,nres)
		end if
		read(12,'(10F8.3)') (box(j),j=1,3)
		if (mod(frame,100)==0) then
			write(*,'(1A6,1I6)') 'frame:',frame
			write(*,'(1A9,10F8.3)') 'box size:',(box(j),j=1,3)
		end if
		cycle
	end do

END PROGRAM dynamic_wcn

subroutine wcn_finder(nres,CAcrd,wcn)
	implicit none
	integer, intent(in) :: nres
	real*8, intent(in) :: CAcrd(nres,3)
	real*8, intent(out) :: wcn(nres)
	integer :: i,j
	real*8 :: distance_sq
	
	wcn = 0.d0
	
	do i=1,nres
		do j=1,nres
			if (j/=i) then
				distance_sq = (CAcrd(i,1)-CAcrd(j,1))**2 + (CAcrd(i,2)-CAcrd(j,2))**2 + (CAcrd(i,3)-CAcrd(j,3))**2
				wcn(i) = wcn(i) + 1.d0/distance_sq
			end if
		end do
	end do

end subroutine wcn_finder
	