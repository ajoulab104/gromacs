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
 * Green Red Orange Magenta Azure Cyan Skyblue
 */
static char *SRCID_nrama_c = "$Id$";

#include <math.h>
#include "assert.h"
#include "sysstuff.h"
#include "smalloc.h"
#include "string2.h"
#include "assert.h"
#include "typedefs.h"
#include "random.h"
#include "bondf.h"
#include "futil.h"
#include "fatal.h"
#include "nrama.h"
#include "rmpbc.h"

static char *pp_pat[] = { "C", "N", "CA", "C", "N" };
#define NPP (sizeof(pp_pat)/sizeof(pp_pat[0]))

static int d_comp(const void *a,const void *b)
{
  t_dih *da,*db;

  da=(t_dih *)a;
  db=(t_dih *)b;

  if (da->ai[1] < db->ai[1])
    return -1;
  else if (da->ai[1] == db->ai[1])
    return (da->ai[2] - db->ai[2]);
  else
    return 1;
}


static void calc_dihs(t_xrama *xr)
{
  int    i;
  rvec   r_ij,r_kj,r_kl,m,n;
  real   cos_phi,sign;
  t_dih  *dd;

  rm_pbc(xr->idef,xr->natoms,xr->box,xr->x,xr->x);

  for(i=0; (i<xr->ndih); i++) {
    dd=&(xr->dih[i]);
    dd->ang=dih_angle(xr->box,
		      xr->x[dd->ai[0]],xr->x[dd->ai[1]],
		      xr->x[dd->ai[2]],xr->x[dd->ai[3]],
		      r_ij,r_kj,r_kl,m,n,&cos_phi,&sign);
  }
}

bool new_data(t_xrama *xr)
{
  if (!read_next_x(xr->traj,&xr->t,xr->natoms,xr->x,xr->box))
    return FALSE;

  calc_dihs(xr);

  return TRUE;
}

static int find_atom(char *find,char ***names,int start,int nr)
{
  int i;

  for(i=start; (i<nr); i++)
    if (strcmp(find,*names[i]) == 0)
      return i;
  return -1;
}

static void add_xr(t_xrama *xr,int ff[5],t_atoms *atoms)
{
  char buf[12];
  int i;

  srenew(xr->dih,xr->ndih+2);
  for(i=0; (i<4); i++)
    xr->dih[xr->ndih].ai[i]=ff[i];
  for(i=0; (i<4); i++)
    xr->dih[xr->ndih+1].ai[i]=ff[i+1];
  xr->ndih+=2;

  srenew(xr->pp,xr->npp+1);
  xr->pp[xr->npp].iphi=xr->ndih-2;
  xr->pp[xr->npp].ipsi=xr->ndih-1;
  xr->pp[xr->npp].bShow=FALSE;
  sprintf(buf,"%s-%d",*atoms->resname[atoms->atom[ff[1]].resnr],
	  atoms->atom[ff[1]].resnr+1);
  xr->pp[xr->npp].label=strdup(buf);
  xr->npp++;
}

static void get_dih(t_xrama *xr,t_atoms *atoms)
{
  int found,ff[NPP];
  int i,j;

  for(i=0; (i<atoms->nr); ) {
    found=i;
    for(j=0; (j<NPP); j++) {
      if ((ff[j]=find_atom(pp_pat[j],atoms->atomname,found,atoms->nr)) == -1)
	break;
      found=ff[j]+1;
    }
    if (j != NPP)
      break;
    add_xr(xr,ff,atoms);
    i=ff[0]+1;
  }
  fprintf(stderr,"Found %d phi-psi combinations\n",xr->npp);
}

static int search_ff(int thisff[NPP],int ndih,int **ff)
{
  int  j,k;
  bool bFound=FALSE;
  
  for(j=0; (j<ndih); j++) {
    bFound=TRUE;
    for(k=1; (k<=3); k++)
      bFound = bFound && (thisff[k]==ff[j][k]);
    if (bFound) {
      if (thisff[0] == -1) 
	ff[j][4]=thisff[4];
      else
	ff[j][0]=thisff[0];
      break;
    }
  }
  if (!bFound) {
    for(k=0; (k<5); k++)
      ff[ndih][k]=thisff[k];
    ndih++;
  }
  return ndih;
}

static void get_dih2(t_xrama *xr,t_functype functype[],
		     t_ilist *bondeds,t_atoms *atoms)
{
  int     found,**ff,thisff[NPP];
  int     i,j,k,type,ftype,nat,ai,aj,ak,al;
  char    *cai,*caj,*cak,*cal;
  int     ndih,maxdih;
  t_iatom *iatoms;

  ndih=0;
  maxdih=1+(bondeds->nr/5);
  snew(ff,maxdih);
  for(j=0; (j<maxdih); j++) {
    snew(ff[j],NPP);
  }
  fprintf(stderr,"There may be as many as %d dihedrals...\n",maxdih);
  
  iatoms=bondeds->iatoms;
  for(i=0; (i<bondeds->nr); ) {
    type=iatoms[0];
    ftype=functype[type];
    nat=interaction_function[ftype].nratoms+1;
    
    if (ftype == F_PDIHS) {
      ai=iatoms[1]; cai=*atoms->atomname[ai];
      aj=iatoms[2]; caj=*atoms->atomname[aj];
      ak=iatoms[3]; cak=*atoms->atomname[ak];
      al=iatoms[4]; cal=*atoms->atomname[al];
      
      for(j=0; (j<NPP); j++)
	thisff[j]=-1;
      if (strcasecmp(cai,"C") == 0) {
	/* May be a Phi angle */
	if ((strcasecmp(caj,"N") == 0) &&
	    (strcasecmp(cak,"CA") == 0) &&
	    (strcasecmp(cal,"C") == 0))
	  thisff[0]=ai,thisff[1]=aj,thisff[2]=ak,thisff[3]=al;
      }
      else if (strcasecmp(cai,"N") == 0) {
	/* May be a Psi angle */
	if ((strcasecmp(caj,"CA") == 0) &&
	    (strcasecmp(cak,"C") == 0) &&
	    (strcasecmp(cal,"N") == 0))
	  thisff[1]=ai,thisff[2]=aj,thisff[3]=ak,thisff[4]=al;
      }
      if (thisff[1] != -1) {
	ndih=search_ff(thisff,ndih,ff);
	if (ndih > maxdih)
	  fatal_error(0,"More than %n dihedrals found. SEGV?",maxdih);
      }
      else {
	fprintf(stderr,"No Phi or Psi, atoms: %s %s %s %s\n",
		cai,caj,cak,cal);
      }
    }
    i+=nat;
    iatoms+=nat;
  }
  for(j=0; (j<ndih); j++) {
    if ((ff[j][0] != -1) && (ff[j][4] != -1))
      add_xr(xr,ff[j],atoms);
    else {
      fprintf(stderr,"Incomplete dihedral(%d) atoms: ",j);
      for(k=0; (k<NPP); k++)
	fprintf(stderr,"%2s ",
		ff[j][k] == -1 ? "-1" : *atoms->atomname[ff[j][k]]);
      fprintf(stderr,"\n");
    }
  }
  fprintf(stderr,"Found %d phi-psi combinations\n",xr->npp);
}

static void min_max(t_xrama *xr)
{
  int ai,i,j;

  xr->amin=xr->natoms;
  xr->amax=0;
  for(i=0; (i<xr->ndih); i++)
    for(j=0; (j<4); j++) {
      ai=xr->dih[i].ai[j];
      if (ai < xr->amin)
	xr->amin = ai;
      else if (ai > xr->amax)
	xr->amax = ai;
    }
}

static void get_dih_props(t_xrama *xr,t_idef *idef)
{
  int     i,ft,ftype,nra;
  t_iatom *ia;
  t_dih   *dd,key;
  
  ia=idef->il[F_PDIHS].iatoms;
  for (i=0; (i<idef->il[F_PDIHS].nr); ) {
    ft=ia[0];
    ftype=idef->functype[ft];
    nra=interaction_function[ftype].nratoms;

    assert (ftype == F_PDIHS);
    
    key.ai[1]=ia[2];
    key.ai[2]=ia[3];
    if ((dd = bsearch(&key,xr->dih,xr->ndih,(size_t)sizeof(key),d_comp))
	!= NULL) {
      dd->mult=idef->iparams[ft].pdihs.mult;
      dd->phi0=idef->iparams[ft].pdihs.phiA;
    }
    
    i+=nra+1;
    ia+=nra+1;
  }
  /* Check */
  for(i=0; (i<xr->ndih); i++)
    if (xr->dih[i].mult == 0) 
      fatal_error(0,"Dihedral around %d,%d not found in topology",
		  xr->dih[i].ai[1],xr->dih[i].ai[2]);
}

void init_rama(char *infile,char *topfile,t_xrama *xr)
{
  static t_topology *top;
  real   t;

  top=read_top(topfile);
  
  /*get_dih2(xr,top->idef.functype,&(top->idef.bondeds),&(top->atoms));*/
  get_dih(xr,&(top->atoms));
  get_dih_props(xr,&(top->idef));
  xr->natoms=read_first_x(&xr->traj,infile,&t,&(xr->x),xr->box);
  xr->idef=&(top->idef);
  
  min_max(xr);
  calc_dihs(xr);
}

