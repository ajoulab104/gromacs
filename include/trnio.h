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

#ifndef _trnio_h
#define _trnio_h

static char *SRCID_trnio_h = "$Id$";

/**************************************************************
 *
 * These routines handle trj (trajectory) I/O, they read and
 * write trj/trr files. The routines should be able to read single
 * and double precision files without the user noting it.
 * The files are backward compatible, therefore the header holds
 * some unused variables.
 *
 * The routines in the corresponding c-file trnio.c
 * are based on the lower level routines in gmxfio.c
 * The integer file pointer returned from open_trn
 * can also be used with the routines in gmxfio.h
 *
 **************************************************************/
	
#include "typedefs.h"

typedef struct		/* This struct describes the order and the	*/
  /* sizes of the structs in a trjfile, sizes are given in bytes.	*/
{
  int	ir_size;	/* Backward compatibility		        */
  int	e_size;		/* Backward compatibility		        */
  int	box_size;	/* Non zero if a box is present			*/
  int   vir_size;       /* Backward compatibility		        */
  int   pres_size;      /* Backward compatibility		        */
  int	top_size;	/* Backward compatibility		        */
  int	sym_size;	/* Backward compatibility		        */
  int	x_size;		/* Non zero if coordinates are present		*/
  int	v_size;		/* Non zero if velocities are present		*/
  int	f_size;		/* Non zero if forces are present		*/

  int	natoms;		/* The total number of atoms			*/
  int	step;		/* Current step number				*/
  int	nre;		/* Backward compatibility		        */
  real	t;		/* Current time					*/
  real	lambda;		/* Current value of lambda			*/
} t_trnheader;

extern int open_trn(char *fn,char *mode);
/* Open a trj / trr file */

extern void close_trn(int fp);
/* Close it */

extern bool fread_trnheader(int fp,t_trnheader *trn,bool *bOK);
/* Read the header of a trn file. Return FALSE if there is no frame.
 * bOK will be FALSE when the header is incomplete.
 */

extern void read_trnheader(char *fn,t_trnheader *header);
/* Read the header of a trn file from fn, and close the file afterwards. 
 */

extern void pr_trnheader(FILE *fp,int indent,char *title,t_trnheader *sh);
/* Print the header of a trn file to fp */

extern bool is_trn(FILE *fp);
/* Return true when the file is a trn file. File will be rewound
 * afterwards.
 */

extern void fwrite_trn(int fp,int step,real t,real lambda,
		       rvec *box,int natoms,rvec *x,rvec *v,rvec *f);
/* Write a trn frame to file fp, box, x, v, f may be NULL */

extern bool fread_htrn(int fp,t_trnheader *sh,
		       rvec *box,rvec *x,rvec *v,rvec *f);
/* Extern read a frame except the header (that should be pre-read,
 * using routine read_trnheader, see above) from a trn file.
 * Return FALSE on error
 */
 
extern bool fread_trn(int fp,int *step,real *t,real *lambda,
		      rvec *box,int *natoms,rvec *x,rvec *v,rvec *f);
/* Read a trn frame, including the header from fp. box, x, v, f may
 * be NULL, in which case the data will be skipped over.
 * return FALSE on error
 */
 
extern void write_trn(char *fn,int step,real t,real lambda,
		      rvec *box,int natoms,rvec *x,rvec *v,rvec *f);
/* Write a single trn frame to file fn, which is closed afterwards */

extern void read_trn(char *fn,int *step,real *t,real *lambda,
		     rvec *box,int *natoms,rvec *x,rvec *v,rvec *);
/* Read a single trn frame from file fn, which is closed afterwards 
 */

#endif
