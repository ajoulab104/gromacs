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
static char *SRCID_TOMS_transpose_h = "$Id$";

#ifndef TOMS_TRANSPOSE_H
#define TOMS_TRANSPOSE_H

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include <fftw_mpi.h>

typedef TRANSPOSE_EL_TYPE TOMS_el_type;

short TOMS_transpose_2d(TOMS_el_type * a,
                        int nx, int ny,
                        char *move,
                        int move_size);

short TOMS_transpose_2d_arbitrary(TOMS_el_type * a,
                                  int nx, int ny,
                                  int el_size,
                                  char *move,
                                  int move_size);

#ifdef __cplusplus
} /* extern "C" */
#endif /* __cplusplus */

#endif /* TOMS_TRANSPOSE_H */
