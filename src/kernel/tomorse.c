/*
 * $Id$
 * 
 *       This source code is part of
 * 
 *        G   R   O   M   A   C   S
 * 
 * GROningen MAchine for Chemical Simulations
 * 
 *               VERSION 2.0
 * 
 * Copyright (c) 1991-1999
 * BIOSON Research Institute, Dept. of Biophysical Chemistry
 * University of Groningen, The Netherlands
 * 
 * Please refer to:
 * GROMACS: A message-passing parallel molecular dynamics implementation
 * H.J.C. Berendsen, D. van der Spoel and R. van Drunen
 * Comp. Phys. Comm. 91, 43-56 (1995)
 * 
 * Also check out our WWW page:
 * http://md.chem.rug.nl/~gmx
 * or e-mail to:
 * gromacs@chem.rug.nl
 * 
 * And Hey:
 * GRowing Old MAkes el Chrono Sweat
 */
static char *SRCID_tomorse_c = "$Id$";

#include <stdlib.h>
#include <math.h>
#include <ctype.h>
#include "typedefs.h"
#include "string2.h"
#include "grompp.h"
#include "futil.h"
#include "smalloc.h"
#include "fatal.h"

typedef struct {
  char *ai,*aj;
  real e_diss;
} t_2morse;

static t_2morse *read_dissociation_energies(int *n2morse)
{
  FILE     *fp;
  char     ai[32],aj[32];
  double   e_diss;
  char     *fn="edissoc.dat";
  t_2morse *t2m=NULL;
  int      maxn2m=0,n2m=0;
  int      nread;
  
  /* Open the file with dissociation energies */
  fp = libopen(fn);
  do {
    /* Try and read two atom names and an energy term from it */
    nread = fscanf(fp,"%s%s%lf",ai,aj,&e_diss);
    if (nread == 3) {
      /* If we got three terms, it probably was OK, no further checking */
      if (n2m >= maxn2m) {
	/* Increase memory for 16 at once, some mallocs are stupid */
	maxn2m += 16;
	srenew(t2m,maxn2m);
      }
      /* Copy the values */
      t2m[n2m].ai = strdup(ai);
      t2m[n2m].aj = strdup(aj);
      t2m[n2m].e_diss = e_diss;
      /* Increment counter */
      n2m++;
    }
    /* If we did not read three items, quit reading */
  } while (nread == 3);
  ffclose(fp);
  
  /* Set the return values */
  *n2morse = n2m;
  
  return t2m;
}

static int nequal(char *a1,char *a2)
{
  int i;
  
  /* Count the number of (case insensitive) characters that are equal in 
   * two strings. If they are equally long their respective null characters are
   * counted also.
   */
  for(i=0; (a1[i] != '\0') && (a2[i] != '\0'); i++)
    if (toupper(a1[i]) != toupper(a2[i]))
      break;
  if ((a1[i] == '\0') && (a2[i] == '\0'))
    i++;
  
  return i;
}

static real search_e_diss(int n2m,t_2morse t2m[],char *ai,char *aj)
{
  int i;
  int ibest=-1;
  int nii,njj,nbstii=0,nbstjj=0;
  real ediss = 400;
  
  /* Do a best match search for dissociation energies */
  for(i=0; (i<n2m); i++) {
    /* Check for a perfect match */
    if (((strcasecmp(t2m[i].ai,ai) == 0) && (strcasecmp(t2m[i].aj,aj) == 0)) ||
	((strcasecmp(t2m[i].aj,ai) == 0) && (strcasecmp(t2m[i].ai,aj) == 0))) {
      ibest = i;
      break;
    }
    else {
      /* Otherwise count the number of equal characters in the strings ai and aj
       * and the ones from the file
       */
      nii = nequal(t2m[i].ai,ai);
      njj = nequal(t2m[i].aj,aj);
      if (((nii >  nbstii) && (njj >= nbstjj)) ||
	  ((nii >= nbstii) && (njj >  nbstjj))) {
	if ((nii > 0) && (njj > 0)) {
	  ibest  = i;
	  nbstii = nii;
	  nbstjj = njj;
	}
      }
      else {
	/* Swap ai and aj (at least in counting the number of equal chars) */
	nii = nequal(t2m[i].ai,aj);
	njj = nequal(t2m[i].aj,ai);
	if (((nii >  nbstii) && (njj >= nbstjj)) ||
	    ((nii >= nbstii) && (njj >  nbstjj))) {
	  if ((nii > 0) && (njj > 0)) {
	    ibest  = i;
	    nbstii = nii;
	    nbstjj = njj;
	  }
	}
      }
    }
  }
  /* Return the dissocation energy corresponding to the best match, if we have
   * found one. Do some debug output anyway.
   */
  if (ibest == -1) {
    if (debug)
      fprintf(debug,"MORSE: Couldn't find E_diss for bond %s - %s, using default %g\n",ai,aj,ediss);
    return ediss;
  }
  else {
    if (debug)
      fprintf(debug,"MORSE: Dissoc. E (%10.3f) for bond %4s-%4s taken from bond %4s-%4s\n",
	      t2m[ibest].e_diss,ai,aj,t2m[ibest].ai,t2m[ibest].aj);
    return t2m[ibest].e_diss;
  }
}

void convert_harmonics(int nrmols,t_molinfo mols[],t_atomtype *atype)
{
  int      n2m;
  t_2morse *t2m;
  
  int  i,j,k,last,ni,nj;
  int  nrharm,nrmorse,bb;
  real edis,kb,b0,beta;
  bool *bRemoveHarm;

  /* First get the data */
  t2m = read_dissociation_energies(&n2m);
  if (debug)
    fprintf(debug,"MORSE: read %d dissoc energies\n",n2m);
  if (n2m <= 0) {
    fprintf(stderr,"No dissocation energies read\n");
    return;
  }
  
  /* For all the molecule types */
  for(i=0; (i<nrmols); i++) {
    /* Check how many morse and harmonic BONDSs there are, increase size of
     * morse with the number of harmonics 
     */
    nrmorse = mols[i].plist[F_MORSE].nr;
    
    for(bb=0; (bb < F_NRE); bb++) {
      if ((interaction_function[bb].flags & IF_BTYPE) && (bb != F_MORSE)) {
	nrharm  = mols[i].plist[bb].nr;
	srenew(mols[i].plist[F_MORSE].param,nrmorse+nrharm);
	snew(bRemoveHarm,nrharm);
	
	/* Now loop over the harmonics, trying to convert them */
	for(j=0; (j<nrharm); j++) {
	  ni   = mols[i].plist[bb].param[j].AI;
	  nj   = mols[i].plist[bb].param[j].AJ;
	  edis = search_e_diss(n2m,t2m,
			       *atype->atomname[mols[i].atoms.atom[ni].type],
			       *atype->atomname[mols[i].atoms.atom[nj].type]);
	  if (edis != 0) {
	    bRemoveHarm[j] = TRUE;
	    b0   = mols[i].plist[bb].param[j].c[0];
	    kb   = mols[i].plist[bb].param[j].c[1];
	    beta = sqrt(kb/(2*edis));
	    mols[i].plist[F_MORSE].param[nrmorse].a[0] = ni;
	    mols[i].plist[F_MORSE].param[nrmorse].a[1] = nj;
	    mols[i].plist[F_MORSE].param[nrmorse].c[0] = b0; 
	    mols[i].plist[F_MORSE].param[nrmorse].c[1] = edis;
	    mols[i].plist[F_MORSE].param[nrmorse].c[2] = beta;
	    nrmorse++; 
	  }
	}
	mols[i].plist[F_MORSE].nr = nrmorse;
	
	/* Now remove the harmonics */
	for(j=last=0; (j<nrharm); j++) {
	  if (!bRemoveHarm[j]) {
	    /* Copy it to the last position */
	    for(k=0; (k<MAXATOMLIST); k++)
	      mols[i].plist[bb].param[last].a[k] = 
		mols[i].plist[bb].param[j].a[k];
	    for(k=0; (k<MAXFORCEPARAM); k++)
	      mols[i].plist[bb].param[last].c[k] = 
		mols[i].plist[bb].param[j].c[k];
	    last++;
	  }
	}
	sfree(bRemoveHarm);
	fprintf(stderr,"Converted %d out of %d %s to morse bonds for mol %d\n",
		nrharm-last,nrharm,interaction_function[bb].name,i);
	mols[i].plist[bb].nr = last;
      }
    }
  }
  sfree(t2m);
}
