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
 * Great Red Oystrich Makes All Chemists Sane
 */
static char *SRCID_gendr_c = "$Id$";

#include <stdio.h>
#include <math.h>
#include <string.h>
#include "string2.h"
#include "strdb.h"
#include "typedefs.h"
#include "macros.h"
#include "copyrite.h"
#include "smalloc.h"
#include "statutil.h"
#include "confio.h"
#include "genhydro.h"

typedef struct {
  char *key;
  int  nexp;
  char **exp;
} t_expansion;

t_expansion *read_expansion_map(char *fn,int *nexpand)
{
  char        ibuf[12],buf[12][10];
  char        **ptr;
  t_expansion *exp;
  int         i,k,nexp,nn;
  
  nexp=get_lines(fn,&ptr);
  
  snew(exp,nexp);
  for(i=0; (i<nexp); i++) {
    /* Let scanf do the counting... */
    nn=sscanf(ptr[i],"%s%s%s%s%s%s%s%s%s%s%s",
	      ibuf,buf[0],buf[1],buf[2],buf[3],buf[4],
	      buf[5],buf[6],buf[7],buf[8],buf[9]);
    if (nn <= 1)
      break;
    exp[i].key=strdup(ibuf);
    exp[i].nexp=nn-1;
    snew(exp[i].exp,nn-1);
    for(k=0; (k<nn-1); k++)
      exp[i].exp[k]=strdup(buf[k]);
  }
  fprintf(stderr,"I found %d expansion mapping entries!\n",i);
  
  /* Clean up */
  for(i=0; (i<nexp); i++)
    sfree(ptr[i]);
  sfree(ptr);
  
  *nexpand=nexp;
  return exp;  
}

char **get_exp(int NEXP,t_expansion expansion[],char **ai,int *nexp)
{
  int  i;

  for(i=0; (i<NEXP); i++)
    if (strcmp(*ai,expansion[i].key) == 0) {
      *nexp=expansion[i].nexp;
      return expansion[i].exp;
    }
  *nexp=1;

  return ai;
}

int find_atom(char *ai,char *ri,
	      int resi,int r0,
	      int natoms,char ***aname,t_atom atom[],
	      int linec)
{
  int i;

  /* Locate residue */
  for(i=0; (i<natoms) && (atom[i].resnr != resi); i++)
    ;
  if (i == natoms)
    return -1;
    
  /* Compare atom names */
  for(   ; (i<natoms) && (atom[i].resnr == resi); i++)
    if (strcmp(*(aname[i]),ai) == 0)
      return i;
      
  /* Not found?! */
  fprintf(stderr,"Warning: atom %s not found in res %s%d (line %d)\n",
	  ai,ri,resi+r0,linec);
  
  return -1;
}

void conv_dr(FILE *in,FILE *out,char *map,t_atoms *atoms,int r0)
{
  static char *format="%s%d%s%s%d%s%lf%lf";
  int    i,j,nc,nindex,ni,nj,nunres;
  int    atomi,atomj,resi,resj;
  char   **aiexp,**ajexp;
  char   *ai,*aj;
  char   ri[10],rj[10];
  char   buf[1024];
  double ub,lb;
  int    linec;
  int    NEXP;
  t_expansion *exp;
  
  exp=read_expansion_map(map,&NEXP);
  
  nc=0;
  nindex=0;
  nunres=0;
  snew(ai,10);
  snew(aj,10);
  fprintf(out,"[ distance_restraints ]\n");
  linec=1;
  
  while (fgets2(buf,1023,in) != NULL) {
    /* Parse the input string. If your file format is different,
     * modify it here...
     * If your file contains no spaces but colon (:) for separators
     * it may be easier to just replace those by a space using a
     * text editor.
     */
    sscanf(buf,format,ri,&resi,ai,rj,&resj,aj,&lb,&ub);
    aiexp=get_exp(NEXP,exp,&ai,&ni);
    ajexp=get_exp(NEXP,exp,&aj,&nj);
    
    /* Turn bounds into nm */
    ub*=0.1;
    lb*=0.1;
    
    /* Subtract starting residue to match topology */
    resi-=r0;
    resj-=r0;
    
    /* Test whether residue names match 
     * Again, if there is a mismatch between GROMACS names
     * and your file (eg. HIS vs. HISH) it may be easiest to
     * use your text editor...
     */
    if (strcmp(*atoms->resname[resi],ri) != 0) {
      fprintf(stderr,"Warning resname in disres file %s%d, in tpx file %s%d\n",
	      ri,resi+r0,*atoms->resname[resi],resi+r0);
      nunres++;
    }
    /* Residue j */
    else if (strcmp(*atoms->resname[resj],rj) != 0) {
      fprintf(stderr,"Warning resname in disres file %s%d, in tpx file %s%d\n",
	      rj,resj+r0,*atoms->resname[resj],resj+r0);
      nunres++;
    }
    else {
      /* Here, both residue names match ! */
      for(i=0; (i<ni); i++) {
	if ((atomi=find_atom(aiexp[i],ri,resi,r0,atoms->nr,
			     atoms->atomname,atoms->atom,linec)) == -1)
	  nunres++;
	else {
	  /* First atom is found now... */
	  for(j=0; (j<nj); j++) {
	    if ((atomj=find_atom(ajexp[j],ri,resj,r0,atoms->nr,
				 atoms->atomname,atoms->atom,linec)) == -1)
	      nunres++;
	    else {
	      /* BOTH atoms are found now! */
	      fprintf(out,"%5d  %5d  1  %5d  1  %8.3f  %8.3f  %8.3f  %8.3f\n",
		      1+atomi,1+atomj,nindex,ub,ub+0.1,0.0,0.0);
	      nc++;
	    }
	  }
	}
      }
    }
    nindex++;
    linec++;
  }
  fprintf(stderr,"Total number of NOES: %d\n",nindex);
  fprintf(stderr,"Total number of restraints: %d\n",nc);
  fprintf(stderr,"Total number of unresolved atoms: %d\n",nunres);
  if (nunres+nc != nindex) 
    fprintf(stderr,"Holy Cow! some lines have disappeared.\n");
}

int main (int argc,char *argv[])
{
  static char *desc[] = {
    "gendr generates a distance restraint entry for a gromacs topology",
    "from another format. The format of the input file must be:[BR]",
    "resnr-i resname-i atomnm-i resnr-j resname-j atomnm-j lower upper[BR]"  ,
    "where lower and upper are the distance bounds.",
    "The entries must be separated by spaces, but may be otherwise in",
    "free format. Some expansion of templates like MB -> HB1, HB2 is done",
    "but this is not really well tested."
  };
  
  static int r0=1;
  t_pargs pa[] = {
    { "-r", FALSE, etINT, {&r0}, "starting residue number" }
  };

  FILE        *in,*out;
  t_topology  *top;
  
  t_filenm fnm[] = {
    { efTPX, "-s", NULL, ffREAD  },
    { efDAT, "-d", NULL, ffREAD  },
    { efITP, "-o", NULL, ffWRITE },
    { efDAT, "-m", "expmap", ffREAD }
  };
#define NFILE asize(fnm)

  CopyRight(stderr,argv[0]);
  parse_common_args(&argc,argv,0,FALSE,NFILE,fnm,asize(pa),pa,asize(desc),desc,
		    0,NULL);

  fprintf(stderr,"Will subtract %d from res numbers in %s\n",
	  r0,ftp2fn(efDAT,NFILE,fnm));
    
  top=read_top(ftp2fn(efTPX,NFILE,fnm));

  in=opt2FILE("-d",NFILE,fnm,"r");
  out=ftp2FILE(efITP,NFILE,fnm,"w");
  conv_dr(in,out,opt2fn("-m",NFILE,fnm),&(top->atoms),r0);
  fclose(in);
  fclose(out);
  
  thanx(stdout);
  
  return 0;
}


