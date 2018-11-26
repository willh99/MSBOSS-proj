static pte_t *walkpgdir(pde_t * pgdir, const void *va, int alloc);
static int mappages(pde_t * pgdir, void *va, uint size, uint pa, int perm);

struct shm{
	int name_length;
	char name[16];
	int numAccess;
	uint shmPhys;	
};

struct shm shm_arr[SHM_MAXNUM];

int used;

char* shm_init()
{
	used = 0;
	int count = 0;
	while(count<SHM_MAXNUM)
	{
		shm_arr[count].name_length = 0;
		safestrcpy(shm_arr[count].name, "DNE", sizeof(shm_arr[count].name)); 
		//cprintf("Initialize SHM: %s\n", &(shm_arr[count].name[0]));
		shm_arr[count].numAccess = 0;
		shm_arr[count].shmPhys = 0;
		count++;
	}
	return 0;
}

//Searches for matching shm string in array of shm and returns array index if found
//Returns -1 if no matching string was found
int shm_find(const char* str)
{
	int i = 0;
	int check = 0;

	for(i = 0; i<SHM_MAXNUM; i++)
	{
		check = strncmp(&(shm_arr[i].name[0]), str, sizeof(shm_arr[i].name));
		if(check == 0)
			return i;
	}
	return -1;
}

//finds first free block in shm_arr
int shm_findFree()
{
	int i = 0;
	char* tempSearch = "DNE";
	int check = 0;

	for(i = 0; i<SHM_MAXNUM; i++)
	{
		check = strncmp(&(shm_arr[i].name[0]), tempSearch, sizeof(shm_arr[i].name));
		if(check == 0)
			return i;
	}
	return -1;
}

//Each process stores SHM name, PA, and VA of SHM for each process in individual arrays. The indicies of these arrays correspond to
//each other. For example, The name for proc->shm_name[i] has a physical address that corresponds to proc->shm_phys[i], and a virtual
//address that corresponds to proc->shm_vir[i]. Therefore, if the name is found in one array, we can use that index that it was found
//at to get the physical address and virtual address for the corresponding name by simply using the same index value.
int procSHM_nameFind(const char* str)
{
	int i = 0;
	int check = 0;

	for(i = 0; i<SHM_MAXNUM; i++)
	{
		check = strncmp(&(proc->shm_name[i].name[0]), str, sizeof(proc->shm_name[i].name));
		if(check == 0)
			return i;
	}
	return -1;
}

//finds first free block in specified the proc->shm_name[] array. Used when giving a process access to an SHM
//returns index value to be used by caller to place SHM info for the process's mapped SHM Name, SHM PA, and SHM VA
//in that index
int procSHM_findFree()
{
	int i = 0;
	char* tempSearch = "DNE";
	int check = 0;

	for(i = 0; i<SHM_MAXNUM; i++)
	{
		check = strncmp(&(proc->shm_name[i].name[0]), tempSearch, sizeof(proc->shm_name[i].name));
		if(check == 0)
			return i;
	}
	return -1;
}

//This function, deallocshm does not work properly
//The implementation desired is that if the shm_rem() was called from a process, deallocshm would determine how to deallocate it.
//If there were still references to the SHM Region being removed, the SHM would only be unmapped from the calling process.
//If no other references are made to the SHM Region, the SHM would be unmapped from the calling process and the physical memory freed.
//While the theory is straight forward, our implementation called for two different unmappings, or remappings rather.
//If the SHM was at the end of the calling process, the process size would simply shrink after dereference.
//If the SHM was somewhere in the middle of the calling process, all of the virtual address spaces would be remapped to exclude the 
//SHM region, and the process size would shrink.
//Remapping causes random problems that would need more time for debugging.
int deallocshm(pde_t * pgdir, uint oldsz, uint newsz, int ref, uint shmMap)
{
//Commented region was a simplified version...no time to tweak, so commented out.
/*
	pte_t *SHMpte = 0;
	//uint pa;
	//int a = 0;
	
	if (newsz >= oldsz)
		return oldsz;
	

	if(shmMap == 0) //if only process is dereferencing, physical memory still stays
	{			
		cprintf("\nDEALLOCSHM: Dereferencing SHM for process only.\n");
		SHMpte = walkpgdir(pgdir, (char*)proc->shm_vir[ref], 0); //finds PTE for SHM region in page table
		if(!SHMpte)
		{
			cprintf("\nCannot Deallocate Region. PTE Reference doesn't exist\n");
			return -1;
		}
		*SHMpte = 0;
		
		proc->shm_vir[ref]  = 0;
		proc->shm_phys[ref] = 0;
		safestrcpy(proc->shm_name[ref].name, "DNE", sizeof(proc->shm_name[ref].name));
		return 0;
	}

	if(shmMap != 0)
	{
		cprintf("\nDEALLOCSHM: Dereferencing SHM for process and removing SHM.\n");
		SHMpte = walkpgdir(pgdir, (char*)proc->shm_vir[ref], 0); //finds PTE for SHM region in page table
		if(!SHMpte)
		{
			cprintf("\nCannot Deallocate Region. PTE Reference doesn't exist\n");
			return -1;
		}
		*SHMpte = 0;
		
		char *v = p2v(shmMap); //changes PA to a VA that kernel can read. different VA from process VA
		kfree(v);//frees memory

		proc->shm_vir[ref] = 0;
		proc->shm_phys[ref] = 0;
		safestrcpy(proc->shm_name[ref].name, "DNE", sizeof(proc->shm_name[ref].name));
		return 0;
	}
	return -1
*/

	pte_t *pte = 0, *SHMpte = 0;
	uint pa;
	int a = 0;
	
	if (newsz >= oldsz)
		return oldsz;

	SHMpte = walkpgdir(pgdir, (char*)proc->shm_vir[ref], 0); //finds PTE for SHM region in page table
	if(!SHMpte)
	{
		cprintf("\nCannot Deallocate Region. PTE Reference doesn't exist\n");
		return -1;
	}

	if(shmMap == 0) //if only process is dereferencing, physical memory still stays
	{			
		if(proc->shm_vir[ref] == (proc->sz - PGSIZE)) //if last page of process
		{
			cprintf("\nOnly removing reference from end of process and remapping VM.\n");

			*SHMpte = 0;

			proc->shm_vir[ref]  = 0;
			proc->shm_phys[ref] = 0;
			safestrcpy(proc->shm_name[ref].name, "DNE", sizeof(proc->shm_name[ref].name));
			proc->sz = (proc->sz) - PGSIZE;
		}

		else //if SHM is in middle of process
		{	
			//virtual addresses after SHM are going to be updated to overwrite the VA of the SHM Region...moving VA up a page
			cprintf("\nOnly removing reference from middle of process and remapping VM.\n");
			
			*SHMpte = 0;

			for(a = proc->shm_vir[ref]+PGSIZE ; a < proc->sz ; a += PGSIZE)
			{
				pte = walkpgdir(pgdir, (char*)a, 0);
				if (!pte)
					a += (NPTENTRIES - 1) * PGSIZE;
				pa = PTE_ADDR(*pte);

				mappages(pgdir, (char*)(a-PGSIZE), PGSIZE, pa, PTE_W | PTE_U);
			}
			proc->sz = ((proc->sz) - PGSIZE);

			proc->shm_vir[ref] = 0;
			proc->shm_phys[ref] = 0;
			safestrcpy(proc->shm_name[ref].name, "DNE", sizeof(proc->shm_name[ref].name));
		}
	}

	else if (((*pte & PTE_P) != 0) && (shmMap != 0)) //if last reference and removing physical memory
	{
		cprintf("\nRemoving Physical Memory given to SHM\n");
		if(proc->shm_vir[ref] == (proc->sz - PGSIZE)) //if last page of process
		{
			cprintf("\nRemoving Physical Mapping and reference from end process.\n");
			
			*SHMpte = 0;

			char *v = p2v(shmMap); //changes PA to a VA that kernel can read. different VA from process VA
			kfree(v);//frees memory

			proc->shm_vir[ref] = 0;
			proc->shm_phys[ref] = 0;
			safestrcpy(proc->shm_name[ref].name, "DNE", sizeof(proc->shm_name[ref].name));
		}

		else//if SHM is in middle of process
		{
			cprintf("\nRemoving Physical Mapping and reference from middle process.\n");
		}
	}
	return newsz;

}

//allocshm maps a new page of physical memory to the virtual address space of the
//calling process. The function itself returns the new size of the process. However,
//it also updates an array within the calling process that stores the virtual and 
//physical addresses within it that correspond to shared memory regions
//mapType is used to specify which type of allocation is wanted. If shmMap==0, map to new physical address.
//If shmMap != 0, the mapType will be the value of the physical location of SHM being passed into function
int allocshm(pde_t * pgdir, uint oldsz, uint newsz, int ref, uint shmMap)
{
	char *mem;
	uint a;

	if (newsz >= KERNBASE)
		return 0;
	if (newsz < oldsz)
		return oldsz;

	a = PGROUNDUP(oldsz); //sets a to top of page
	cprintf("\nStarting Point of Grown Region = %d\n", a);
	//loops mapping va space to pa until the wanted new size is achieved
	for (; a < newsz; a += PGSIZE) 
	{
		if(shmMap == 0)
		{
			mem = kalloc(); //allocates a page of unmapped data and returns pointer to physical address of page
			if (mem == 0) 
			{
				cprintf("allocuvm out of memory\n");
				deallocshm(pgdir, newsz, oldsz, 0, 0);
				return 0;
			}
			memset(mem, 0, PGSIZE);
			mappages(pgdir, (char *)a, PGSIZE, v2p(mem), PTE_W | PTE_U); 
			//maps virtual address of new pages to physical address just allocated
		}

		if(shmMap !=0)
		{
			mappages(pgdir, (char*)a, PGSIZE, shmMap, PTE_W | PTE_U); //mapping range of VA to previously existing PA, creating SHM
		}
	}

	//proc->shm_vir[ref] = (char*)(a-PGSIZE); //works, but want to try something else
	proc->shm_vir[ref] = (a - (newsz - oldsz));

	//we want count number for va
	//pgsize added already after for loop ended
	//need to subtract pgsize for proper va pointer to top of SHM page
	proc->shm_phys[ref] = v2p(mem);

	//cprintf("Process SHM Num = %d\n", ref);
	//cprintf("SHM pgdir = %p\n", pgdir);
	//cprintf("SHM Physical Address = %p\n", proc->shm_phys[ref]);
	//cprintf("SHM Virtual Address = %p\n", proc->shm_vir[ref]);

	return newsz;
}

//similar to the growproc command, it takes in the desired process size shift, and
//picks the appropriate function to call based on whether it wants to grow the
//process or shrink it. Ref is used to pass in the array value of the SHM tracking
//within the process so that it can update the proper values for the processes's
//future reference
int shm_alloc(int n, int ref, uint shmMap)
{
	uint sz;

	sz = proc->sz;
	//cprintf("\nOriginal Process Size = %d\n", sz);
	if (n > 0) 
	{
		if ((sz = allocshm(proc->pgdir, sz, sz + n, ref, shmMap)) == 0)
			return -1;
	} 
	else if (n < 0) 
	{
		if ((sz = deallocshm(proc->pgdir, sz, sz + n, ref, shmMap)) == -1)
			return -1;
	}
	proc->sz = sz;
	//cprintf("New Process Size = %d\n", sz);
	switchuvm(proc);
	return 0;
}

//assigns an already existing SHM to a calling process. It searches through the page directory
//that was sent in and trys to find the matching VA location of the PA sent in.
//the VA is then assigned to that PA 
int shm_assign(pde_t* pgdir, uint sz, uint physLoc) //really only used in fork() maybe rename shm_inherit()
{
	pte_t * pte;
	uint pa;
	//char* virLoc = 0;
	int found = 0;

	int i = 0;
	for(i = 0; i<sz; i += PGSIZE)
	{
		pte = walkpgdir(pgdir, (void*)i, 0);
		pa = PTE_ADDR(*pte);
		if(pa == physLoc)
		{
			found = 1;
			break;
		}
	}
	
	if(found == 1)
	{	
		cprintf("\nFound SHM Phys in Mapping...making VA\n");
		//cprintf("SHM Proc PA = %d\n", pa);
		//cprintf("SHM Proc VA = %d\n", i);
		//not finding because fork is making new physical mem for SHM within child...Needs fixing
		
		return i;
	}

	//cprintf("\nSHM Phys in NOT Found Mapping\n");
	return -1;
}

//used in copyuvm to see if the physical address in a process about to be copied is a SHM Region. If it is, it won't allocate
//a new page for the process. Instead, it will map the following virtual address spaces to the SHM Region.
//used in deallocuvm to skip freeing physical addresses of SHM regions
//added functionality to either add or subtract refrence count when using function because functions calling this function
//don't have access to the shm tracking array
uint shm_arr_findPA(uint pa, int refChange)
{
	int i = 0;
	for(i = 0; i<SHM_MAXNUM; i++)
	{
		if(pa == shm_arr[i].shmPhys)
		{
			//if the process is mapping to this region, we also have to increment the numAccess count
			shm_arr[i].numAccess = (shm_arr[i].numAccess) + refChange;
			return shm_arr[i].shmPhys;
			//fix exit dealloc here...
		}
	}
	return -1;
}
//BAD CODE: Never gets called by exit
//Called by exit(). Supposed to check for any single-referenced SHM regions in the process so that it can clean them up and free
//them.
int shmExitClean()
{
	cprintf("\nEntering Exit Clean.\n");
	int i = 0;
	int check = 0;
	int findSHMarr = 0;

	for(i=0; i<SHM_MAXNUM; i++)
	{
		check = strncmp(&(proc->shm_name[i].name[0]), "DNE", sizeof(proc->shm_name[i].name));
		if(check != 0)
		{
			cprintf("\nExit: SHM in Process found\n");
			findSHMarr = shm_find(&(proc->shm_name[i].name[0]));
			if(findSHMarr != -1)
			{
				if(shm_arr[findSHMarr].numAccess == 1) //you are the only process using this, so it can be deleted
				{
					cprintf("\nExit: Removing SHM Region [%p]", shm_arr[findSHMarr].shmPhys);
					check = shm_alloc(-4096, i, shm_arr[findSHMarr].shmPhys);
					if(check == -1)
					{
						cprintf("Error Deleting SHM Region on Exit\n");
						return -1;
					}
					else
						return 0;
				}
			}
		}
		check = 0;	
	}
	return -1;
}

void print_shmNames()
{
	int i = 0;
	cprintf("\n");
	for(i=0; i<5; i++)
	{
		cprintf("shm_get: SHM i = %s, %d, %p\n", &(shm_arr[i].name[0]), shm_arr[i].numAccess, shm_arr[i].shmPhys);
	}
	cprintf("\n");
}

//******************************************************************************
//******************************************************************************

//checks shared memory tracking array to see if that region already exists. If it does, then it returns 
//the location of that region. If it doesn't exist, then it grows the current process the size of a 
//page table and returns the location of the new thing.
char* shm_get(char *name, int name_length)
{
	int check = 0;
	int found = 0;
	int firstFree = 0;
	int procfirstFree = 0; //returns first free block in SHM array for process
	int procFound = 0; //retuns index of found name in process array

	//cprintf("Character = %s", name);

	procFound = procSHM_nameFind(name);
	if(procFound != -1)
	{
		cprintf("\nSHM Region Already Mapped to Calling Process. Mapping previous VA to variable\n");

		//disgard stared region
		//****************************************************************************************************************
		//changes definition of SHM_MAXNUM from being maximum number of SHM Regions to maximum number of access to SHM Regions
		//we don't want to overwrite existing mapping of VA in processes's shm_...[] arrays, so we make a new reference to same
		//PA within the same process array
		//****************************************************************************************************************

		//return value of virtual address of the already mapped SHM Region
		//this might be where mutexes would come into play in SHM Test
		//multiple variables being mapped to same location
		
		cprintf("\nProcess pgdir = %p\n", proc->pgdir);
		cprintf("SHM Proc Found Index = %d\n", procFound);
		cprintf("SHM Proc Name = %s\n", &(proc->shm_name[procFound].name[0]));
		cprintf("SHM Proc PA = %p\n", proc->shm_phys[procFound]);
		cprintf("SHM Proc VA = %d\n", proc->shm_vir[procFound]);

		print_shmNames();
		return (char*)proc->shm_vir[procFound];
	}

	procfirstFree = procSHM_findFree(); //searches process shm indexes for first free index
	if(procfirstFree == -1)
	{
		cprintf("\nMax Number of Shared Regions used by Process\n");
		print_shmNames();
		return 0;
	}

	//below if statement is activated if shm_find cannot find a matching name and if the number of shared memory spaces hasn't
	//reached the max number the system can have
	found = shm_find(name);
	cprintf("\nFound Value = %d\n", found);

	if((found == -1) && (used < SHM_MAXNUM))
	{
		cprintf("\nName Not found...Making new SHM Space\n");
		
		check = shm_alloc(4096, procfirstFree, 0);
		if(check == -1)
			return 0;

		cprintf("\nProcess pgdir = %p\n", proc->pgdir);
		
		safestrcpy(proc->shm_name[procfirstFree].name, name, sizeof(proc->shm_name[procfirstFree].name));

		firstFree = shm_findFree();
		
		shm_arr[firstFree].name_length = name_length;
		strncpy(shm_arr[firstFree].name, name, sizeof(shm_arr[firstFree].name));
		shm_arr[firstFree].numAccess = (shm_arr[firstFree].numAccess) + 1;
		shm_arr[firstFree].shmPhys = proc->shm_phys[procfirstFree];
		used++;

		char* retVal = (char*) proc->shm_vir[procfirstFree];
		//changing mapping to physical, user still interacting with virtual address.

		print_shmNames();
		return retVal;
	}

	if(found != -1)
	{
		//would only be in here if SHM is being asking for access to an SHM that it hasn't inherited
		//Requires mapping to current process

		cprintf("SHM_GET: SHM Region Already Exists. Mapping SHM to Calling Process\n");

		check = shm_alloc(4096, procfirstFree, shm_arr[found].shmPhys);
		if(check == -1)
			return 0;

		strncpy(&(proc->shm_name[procfirstFree].name[0]), name, sizeof(proc->shm_name[procfirstFree].name));
		shm_arr[found].numAccess = (shm_arr[found].numAccess) + 1;
		
		print_shmNames();
		return (char*) proc->shm_vir[procfirstFree]; 
	}
	return 0;
}
//******************************************************************************
//******************************************************************************

//******************************************************************************
//******************************************************************************
int shm_rem(char *name, int name_length)
{
	int check = 0;
	int found = 0;
	int procFound = 0;
	int i = 0;

	found = shm_find(name);
	procFound = procSHM_nameFind(name);

	if(found == -1)
	{
		cprintf("\nA SHM Region with the specified name doesn't exist.\n"); 
		return -1;
	}
	else if(procFound == -1)
	{
		cprintf("\nThis Process doesn't have access to the SHM Region specified.\n");
		cprintf("Process only has access to the following: ");
		for(i=0; i<5; i++)
		{
			cprintf(", [SHM %d = %s, %p]", i+1, &(proc->shm_name[i].name[0]), proc->shm_phys[i]);
		}
		cprintf("\n");
		return -1;
	}

	//still need to fix this
	else if(shm_arr[found].numAccess > 1) //still in use by other processes, remove mapping for current proc only
	{
		cprintf("\nThis SHM Region is still in use by other processes.\n");

		if((check = shm_alloc(-4096, procFound, 0)) == -1)
			return -1;

		shm_arr[found].numAccess = (shm_arr[found].numAccess) - 1;

		return 1;
	}
	//stil need to fix this
	else
	{
		//removing traces of SHM Region
		cprintf("\nSHM Region Physical Memory is Safe to Derefence...Removing SHM Region\n");
		check = shm_alloc(-4096, procFound, shm_arr[found].shmPhys);
		if(check == -1)
		{
			cprintf("DEALLOCATION: FAILED\n");
			return 0;
		}

		shm_arr[found].name_length = 0;
		safestrcpy(shm_arr[found].name, "DNE", sizeof(shm_arr[found].name)); 
		shm_arr[found].numAccess = 0;
		shm_arr[found].shmPhys = 0;
		used--;	
		
		return 1;
	}	
}

//following functions in stared region are copied verbatim from vm.c. Couldn't include
//static functions in defs.h, and the group wanted to keep each part in separate C files
//for organization, so writing in vm.c wasn't an option. The only solution I could think
//of was to copy the functions into here

//*****************************************************************************
//*****************************************************************************

// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *walkpgdir(pde_t * pgdir, const void *va, int alloc)
{
	pde_t *pde;
	pte_t *pgtab;

	pde = &pgdir[PDX(va)]; //finds page directory corresponding to virtual address

	if (*pde & PTE_P) //if virtual address exists in mapping
	{
		pgtab = (pte_t *) p2v(PTE_ADDR(*pde));
	} 

	else //if virtual address doesn't exist in mapping
	{
		if (!alloc || (pgtab = (pte_t *) kalloc()) == 0)
			return 0;
		// Make sure all those PTE_P bits are zero.
		memset(pgtab, 0, PGSIZE);
		// The permissions here are overly generous, but they can
		// be further restricted by the permissions in the page table 
		// entries, if necessary.
		*pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
	}
	return &pgtab[PTX(va)]; //returns page location
}

// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int mappages(pde_t * pgdir, void *va, uint size, uint pa, int perm)
{
	char *a, *last;
	pte_t *pte;

	a = (char *)PGROUNDDOWN((uint) va);
	last = (char *)PGROUNDDOWN(((uint) va) + size - 1);
	for (;;) {
		if ((pte = walkpgdir(pgdir, a, 1)) == 0)
			return -1;
		if (*pte & PTE_P)
			panic("remap");
		*pte = pa | perm | PTE_P;
		if (a == last)
			break;
		a += PGSIZE;
		pa += PGSIZE;
	}
	return 0;
}

//*****************************************************************************
//*****************************************************************************
