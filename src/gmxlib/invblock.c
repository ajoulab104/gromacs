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
static char *SRCID_invblock_c = "$Id$";

#include "typedefs.h"
#include "smalloc.h"
#include "invblock.h"

atom_id *make_invblock(t_block *block,int nr)
{
  int i,j;
  atom_id *invblock;
  
  snew(invblock,nr);
  for (i=0; i<nr; i++) invblock[i]=NO_ATID; /* Mark unused numbers */
  j=1;
  for (i=0; i<block->nr; i++)
    for (j=block->index[i]; j<(int)block->index[i+1]; j++) 
      invblock[block->a[j]]=i;
  return invblock;
}

