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

#ifndef _wnblist_h
#define _wnblist_h

static char *SRCID_wnblist_h = "$Id$";

#ifdef HAVE_IDENT
#ident	"@(#) wnblist.h 1.1 23 Oct 1994"
#endif /* HAVE_IDENT */
#include "stdio.h"
#include "typedefs.h"

extern void dump_nblist(FILE *out,t_forcerec *fr,int nDNL);

extern void read_nblist(FILE *in,FILE *out,int **mat,int natoms);

#endif	/* _wnblist_h */
