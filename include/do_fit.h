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
 * Good ROcking Metal Altar for Chronical Sinners
 */

#ifndef _do_fit_h
#define _do_fit_h

static char *SRCID_do_fit_h = "$Id$";

#ifdef HAVE_IDENT
#ident	"@(#) do_fit.h 1.8 2/2/97"
#endif /* HAVE_IDENT */
extern real rmsdev_ind(int nind,atom_id index[],real mass[],
		       rvec x[],rvec xp[]);
/* Returns the RMS Deviation betweem x and xp over all atoms in index */

extern real rmsdev(int natoms,real mass[],rvec x[],rvec xp[]);
/* Returns the RMS Deviation betweem x and xp over all atoms */

extern void do_fit(int natoms,real *w_rls,rvec *xp,rvec *x);
/* Do a least squares fit of x to xp. Atoms which have zero mass
 * (w_rls[i]) are not take into account in fitting.
 * This makes is possible to fit eg. on Calpha atoms and orient
 * all atoms. The routine only fits the rotational part,
 * therefore both xp and x should be centered round the origin.
 */

extern void reset_x(int ncm,atom_id ind_cm[],
		    int nrms,atom_id ind_rms[],rvec x[],real mass[]);
/* Put the center of mass of atoms in the origin 
 * The center of mass is computed from the index ind_cm, while
 * the atoms in ind_rms are reset.
 */

#endif	/* _do_fit_h */
