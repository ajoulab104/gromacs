/*
 * $Id: pdtest.c,v 1.5 2009/04/05 11:46:58 spoel Exp $
 * 
 *                This source code is part of
 * 
 *                 G   R   O   M   A   C   S
 * 
 *          GROningen MAchine for Chemical Simulations
 * 
 *                        VERSION 4.0.99
 * Written by David van der Spoel, Erik Lindahl, Berk Hess, and others.
 * Copyright (c) 1991-2000, University of Groningen, The Netherlands.
 * Copyright (c) 2001-2008, The GROMACS development team,
 * check out http://www.gromacs.org for more information.

 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * If you want to redistribute modifications, please consider that
 * scientific software is very special. Version control is crucial -
 * bugs must be traceable. We will be happy to consider code for
 * inclusion in the official distribution, but derived work must not
 * be called official GROMACS. Details are found in the README & COPYING
 * files - if they are missing, get the official version at www.gromacs.org.
 * 
 * To help us fund GROMACS development, we humbly ask that you cite
 * the papers on the package - you can find them in the top README file.
 * 
 * For more info, check our website at http://www.gromacs.org
 * 
 * And Hey:
 * Groningen Machine for Chemical Simulation
 */
#include <stdlib.h>
#include "typedefs.h"
#include "poldata_xml.hpp"
#include "atomprop.h"

int alex_poldata_test(int argc,char*argv[])
{
  gmx_poldata_t pd;
  gmx_atomprop_t aps;
    
  if (argc < 3) {
    fprintf(stderr,"Usage: %s infile outfile\n",argv[0]);
    exit(1);
  }
  aps = gmx_atomprop_init();
  pd = gmx_poldata_read(argv[1],aps);
  gmx_poldata_write(argv[2],pd,0);
  
  return 0;
}