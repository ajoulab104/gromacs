/*
 *                This source code is part of
 *				
 *                 G   R   O   M   A   C   S
 *
 *          GROningen MAchine for Chemical Simulations
 *
 *                        VERSION 3.0
 *
 * Copyright (c) 1991-2001
 * Dept. of Biophysical Chemistry
 * University of Groningen, The Netherlands
 *
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
 * Do check out http://www.gromacs.org , or mail us at gromacs@gromacs.org .
 *
 * And Hey:
 * GROup of MAchos and Cynical Suckers
 */
.intel_syntax noprefix

/* NB: We prefix all local variables with underscore, to avoid stupid
 * bugs. Otherwise, dx will e.g. be interpreted as a register,
 * without any further warning!
 */
	
.text
.align 16
	
sse_minushalf:	
	.long 0xbf000000
	.long 0xbf000000
	.long 0xbf000000
	.long 0xbf000000
sse_half:	
	.long 0x3f000000
	.long 0x3f000000
	.long 0x3f000000
	.long 0x3f000000
sse_two:	
	.long 0x40000000
	.long 0x40000000
	.long 0x40000000
	.long 0x40000000
sse_three:	
	.long 0x40400000
	.long 0x40400000
	.long 0x40400000
	.long 0x40400000
sse_six:
	.long 0x40c00000
	.long 0x40c00000
	.long 0x40c00000
	.long 0x40c00000
sse_twelve:	
	.long 0x41400000
	.long 0x41400000
	.long 0x41400000
	.long 0x41400000



.globl checksse	 /* try to issue a SSE instruction */
	.type checksse,@function
checksse:
	emms
	xorps xmm0,xmm0
	emms
	ret

.align 16
	
.globl vecinvsqrt_sse
	.type vecinvsqrt_sse,@function
vecinvsqrt_sse:	
	push ebp
	mov ebp,esp	
	push eax
	push ebx
	push ecx
	push edx

	mov eax, [ebp + 8]
	mov ebx, [ebp + 12]	
	mov ecx, [ebp + 16]
        mov edx, ecx
	movups xmm6,[sse_three]
	movups xmm7,[sse_minushalf]
        shr ecx, 3
        jecxz .vecinvsqrt_iter4
        emms	
.vecinvsqrt_loop8:	
	movaps xmm0,[eax]
	add eax,  16
	rsqrtps xmm1,xmm0
	movaps xmm2,[eax]
	add eax,  16
	rsqrtps xmm3,xmm2
	mulps xmm0,xmm1
        mulps xmm2,xmm3
	mulps xmm0,xmm1
        mulps xmm2,xmm3
	subps xmm0,xmm6
	subps xmm2,xmm6
	mulps xmm0,xmm1
	mulps xmm2,xmm3
	mulps xmm0,xmm7
	mulps xmm2,xmm7
	movaps [ebx],xmm0
	add ebx,  16
	movaps [ebx],xmm2
	add ebx,  16
        dec ecx
        jecxz .vecinvsqrt_iter4
        jmp .vecinvsqrt_loop8
.vecinvsqrt_iter4:
        mov ecx,edx
        and ecx,4
        jecxz .vecinvsqrt_iter2
	movaps xmm0,[eax]
	add eax,  16
	rsqrtps xmm1,xmm0
	mulps xmm0,xmm1
	mulps xmm0,xmm1
	subps xmm0,xmm6
	mulps xmm0,xmm1
	mulps xmm0,xmm7
	movaps [ebx],xmm0
	add ebx,  16        
.vecinvsqrt_iter2:
        mov ecx,edx
        and ecx,2
        jecxz .vecinvsqrt_iter1
	movlps xmm0,[eax]
	add eax,  8
	rsqrtps xmm1,xmm0
	mulps xmm0,xmm1
	mulps xmm0,xmm1
	subps xmm0,xmm6
	mulps xmm0,xmm1
	mulps xmm0,xmm7
	movlps [ebx],xmm0
	add ebx,  8     
.vecinvsqrt_iter1:
        mov ecx,edx
        and ecx,1
        jecxz .vecinvsqrt_end
	movss xmm0,[eax]
	rsqrtss xmm1,xmm0
	mulss xmm0,xmm1
	mulss xmm0,xmm1
	subss xmm0,xmm6
	mulss xmm0,xmm1
	mulss xmm0,xmm7
	movss [ebx],xmm0        
.vecinvsqrt_end:	
	emms
	pop edx
	pop ecx
	pop ebx
	pop eax
	leave
	ret
	
.globl vecrecip_sse
	.type vecrecip_sse,@function
vecrecip_sse:	
	push ebp
	mov ebp,esp	
	push eax
	push ebx
	push ecx
	push edx

	mov eax, [ebp + 8]
	mov ebx, [ebp + 12]	
	mov ecx, [ebp + 16]
        mov edx, ecx
	movups xmm6,[sse_two]
        shr ecx, 3
        jecxz .vecrecip_iter4
        emms	
.vecrecip_loop8:	
	movaps xmm0,[eax]
	add eax,  16
	rcpps xmm1,xmm0
	movaps xmm3,[eax]
	add eax,  16
	rcpps xmm4,xmm3
	movaps xmm2,xmm6
	mulps xmm0,xmm1
	movaps xmm5,xmm6	
	subps xmm2,xmm0
	mulps xmm3,xmm4
	mulps xmm2,xmm1	
	subps xmm5,xmm3	
	movaps [ebx],xmm2
	mulps xmm5,xmm4
	add ebx,  16
	movaps [ebx],xmm5
	add ebx,  16
        dec ecx
        jecxz .vecrecip_iter4
        jmp .vecrecip_loop8
.vecrecip_iter4:
        mov ecx,edx
        and ecx,4
        jecxz .vecrecip_iter2
	movaps xmm0,[eax]
	add eax,  16
	rcpps xmm1,xmm0
	movaps xmm2,xmm6
	mulps xmm0,xmm1		
	subps xmm2,xmm0
	mulps xmm2,xmm1
	movaps [ebx],xmm2
	add ebx,  16        
.vecrecip_iter2:
        mov ecx,edx
        and ecx,2
        jecxz .vecrecip_iter1
	movlps xmm0,[eax]
	add eax,  8
	rcpps xmm1,xmm0
	movaps xmm2,xmm6
	mulps xmm0,xmm1		
	subps xmm2,xmm0
	mulps xmm2,xmm1
	movlps [ebx],xmm2
	add ebx,  8     
.vecrecip_iter1:
        mov ecx,edx
        and ecx,1
        jecxz .vecrecip_end
	movss xmm0,[eax]
	rcpss xmm1,xmm0
	movss xmm2,xmm6
	mulss xmm0,xmm1		
	subss xmm2,xmm0
	mulss xmm2,xmm1
	movss [ebx],xmm2        
.vecrecip_end:	
	emms
	pop edx
	pop ecx
	pop ebx
	pop eax
	leave
	ret
	
	
.globl inl0100_sse
	.type inl0100_sse,@function
inl0100_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_type,		48
.equ		_ntype,		52
.equ		_nbfp,		56	
.equ		_Vnb,		60	
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ix,		0
.equ		_iy,	        16
.equ		_iz,            32
.equ		_dx,            48
.equ		_dy,            64
.equ		_dz,            80
.equ		_two,           96		
.equ		_c6,		112
.equ		_c12,		128
.equ		_six,		144
.equ		_twelve,	160		 
.equ		_vnbtot,	176
.equ		_fix,		192
.equ		_fiy,		208
.equ		_fiz,		224
.equ		_half,		240
.equ		_three,		256
.equ		_is3,		272
.equ		_ii3,		276
.equ		_ntia,		280	
.equ		_innerjjnr,     284
.equ		_innerk,        288
.equ		_salign,        292								
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 296		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm1, [sse_two]
	movups xmm2, [sse_six]
	movups xmm3, [sse_twelve]
	movaps [esp + _two], xmm1
	movaps [esp + _six],  xmm2
	movaps [esp + _twelve], xmm3

	/* assume we have at least one i particle - start directly */	
.i0100_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   dword ptr [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   dword ptr [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

        mov   edx, [ebp + _type] 
        mov   edx, [edx + ebx*4]
        imul  edx, [ebp + _ntype]
        shl   edx, 1
        mov   [esp + _ntia], edx
		
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]
	
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   [esp + _ii3], ebx
	
	/* clear vnbtot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vnbtot], xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   dword ptr [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	
	jge   .i0100_unroll_loop
	jmp   .i0100_finish_inner
.i0100_unroll_loop:
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   dword ptr [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	movd  mm2, ecx
	movd  mm3, edx
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	mulps xmm3, xmm2
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4 
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6

	/* rsq in xmm4 */
	rcpps xmm5, xmm4
	/* 1/x lookup seed in xmm5 */
	movaps xmm0, [esp + _two]
	mulps xmm4, xmm5
	subps xmm0, xmm4
	mulps xmm0, xmm5	/* xmm0=rinvsq */
	movaps xmm4, xmm0

	movaps xmm1, xmm0
	mulps  xmm1, xmm0
	mulps  xmm1, xmm0	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */

	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	mulps  xmm4, xmm2	/* xmm4=total fscal */

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vnbtot], xmm5

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   dword ptr [esp + _innerk],  4
	jl    .i0100_finish_inner
	jmp   .i0100_unroll_loop
.i0100_finish_inner:
	/* check if at least two particles remain */
	add   dword ptr [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i0100_dopair
	jmp   .i0100_checksingle
.i0100_dopair:	
        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   dword ptr [esp + _innerjjnr],  8

	mov esi, [ebp + _type]
	mov   ecx, eax
	mov   edx, ebx
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add ecx, edi
	add edx, edi
	movlps xmm6, [esi + ecx*4]
	movhps xmm6, [esi + edx*4]
	mov edi, [ebp + _pos]	
	xorps  xmm7,xmm7
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b1000 	
	shufps xmm6, xmm6, 0b1101
	movlhps xmm4, xmm7
	movlhps xmm6, xmm7
	
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
			
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	


	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move _ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */


	rcpps xmm5, xmm4
	/* 1/x lookup seed in xmm5 */
	movaps xmm0, [esp + _two]
	mulps xmm4, xmm5
	subps xmm0, xmm4
	mulps xmm0, xmm5	/* xmm0=rinvsq */
	movaps xmm4, xmm0
	
	movaps xmm1, xmm0
	mulps  xmm1, xmm0
	mulps  xmm1, xmm0	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */

	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	mulps  xmm4, xmm2	/* xmm4=total fscal */

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i0100_checksingle:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    .i0100_dosingle
	jmp    .i0100_updateouterdata
.i0100_dosingle:
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]		

	mov esi, [ebp + _type]
	mov ecx, eax
	mov ecx, [esi + ecx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1
	add ecx, [esp + _ntia]
	xorps  xmm6, xmm6
	movlps xmm6, [esi + ecx*4]
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b11111100
	shufps xmm6, xmm6, 0b11111101	
			
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	
	
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rcpps xmm5, xmm4
	/* 1/x lookup seed in xmm5 */
	movaps xmm0, [esp + _two]
	mulps xmm4, xmm5
	subps xmm0, xmm4
	mulps xmm0, xmm5	/* xmm0=rinvsq */
	movaps xmm4, xmm0
	
	movaps xmm1, xmm0
	mulps  xmm1, xmm0
	mulps  xmm1, xmm0	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */

	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addss  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	mulps  xmm4, xmm2	/* xmm4=total fscal */
	
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movss [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5
	
.i0100_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   dword ptr [ebp + _gid],  4  /* advance pointer */
	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6	

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 

	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i0100_end

	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i0100_outer
.i0100_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 296
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret

	
.globl inl0110_sse
	.type inl0110_sse,@function
inl0110_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_type,		48
.equ		_ntype,		52
.equ		_nbfp,		56	
.equ		_Vnb,		60	
.equ		_nsatoms,       64			
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ix,	        0
.equ		_iy,	        16
.equ		_iz,            32
.equ		_dx,            48
.equ		_dy,            64
.equ		_dz,            80
.equ		_two,           96		
.equ		_c6,            112
.equ		_c12,           128
.equ		_six,           144
.equ		_twelve,        160		 
.equ		_vnbtot,        176
.equ		_fix,           192
.equ		_fiy,           208
.equ		_fiz,           224
.equ		_half,          240
.equ		_three,         256
.equ		_is3,           272
.equ		_ii3,           276
.equ		_shX,	        280
.equ		_shY,           284
.equ		_shZ,           288
.equ		_ntia,          292	
.equ		_innerjjnr0,    296
.equ		_innerjjnr,     300
.equ		_innerk0,       304
.equ		_innerk,        308
.equ		_salign,        312			
.equ		_nsvdwc,        316
.equ		_nscoul,        320
.equ		_nsvdw,         324
.equ		_solnr,	        328		
	push ebp
	mov ebp,esp		
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 332		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm1, [sse_two]
	movups xmm2, [sse_six]
	movups xmm3, [sse_twelve]
	movaps [esp + _two], xmm1
	movaps [esp + _six],  xmm2
	movaps [esp + _twelve], xmm3

	/* assume we have at least one i particle - start directly */	
.i0110_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movlps xmm0, [eax + ebx*4]	/* getting the shiftvector */
	movss xmm1, [eax + ebx*4 + 8] 
	movlps [esp + _shX], xmm0
	movss [esp + _shZ], xmm1

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   eax, [ebp + _nsatoms]
	add   [ebp + _nsatoms],  12
	mov   ecx, [eax]	
	mov   edx, [eax + 4]
	mov   eax, [eax + 8]	
	sub   ecx, eax
	sub   eax, edx
	
	mov   [esp + _nsvdwc], edx
	mov   [esp + _nscoul], eax
	mov   [esp + _nsvdw], ecx

	/* clear vnbtot */
	xorps xmm4, xmm4
	movaps [esp + _vnbtot], xmm4
	mov   [esp + _solnr],  ebx
		
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr0], eax     /* pointer to jjnr[nj0] */

	mov   [esp + _innerk0], edx        /* number of innerloop atoms */

	mov   ecx, [esp + _nsvdwc]
	cmp   ecx,  0
	jnz   .i0110_mno_vdwc
	jmp   .i0110_testvdw
.i0110_mno_vdwc:
	mov   ebx,  [esp + _solnr]
	inc   dword ptr [esp + _solnr]

        mov   edx, [ebp + _type] 
        mov   edx, [edx + ebx*4]
        imul  edx, [ebp + _ntype]
        shl   edx, 1
        mov   [esp + _ntia], edx
		
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx

	movss xmm0, [esp + _shX]
	movss xmm1, [esp + _shY]
	movss xmm2, [esp + _shZ]

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]
	
	/* clear i forces */
	xorps xmm4, xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   ecx, [esp + _innerjjnr0]
	mov   [esp + _innerjjnr], ecx
	mov   edx, [esp + _innerk0]
        sub   edx,  4
        mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i0110_unroll_vdwc_loop
	jmp   .i0110_finish_vdwc_inner
.i0110_unroll_vdwc_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	movd  mm2, ecx
	movd  mm3, edx
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	mulps xmm3, xmm2
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move _ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rcpps xmm5, xmm4
	/* 1/x lookup seed in xmm5 */
	movaps xmm0, [esp + _two]
	mulps xmm4, xmm5
	subps xmm0, xmm4
	mulps xmm0, xmm5	/* xmm0=rinvsq */
	movaps xmm4, xmm0
	
	movaps xmm1, xmm0
	mulps  xmm1, xmm0
	mulps  xmm1, xmm0	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */

	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	mulps  xmm4, xmm2	/* xmm4=total fscal */

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vnbtot], xmm5

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i0110_finish_vdwc_inner
	jmp   .i0110_unroll_vdwc_loop
.i0110_finish_vdwc_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i0110_dopair_vdwc
	jmp   .i0110_checksingle_vdwc
.i0110_dopair_vdwc:	

        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8

	mov esi, [ebp + _type]
	mov   ecx, eax
	mov   edx, ebx
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add ecx, edi
	add edx, edi
	movlps xmm6, [esi + ecx*4]
	movhps xmm6, [esi + edx*4]
	mov edi, [ebp + _pos]	
	xorps  xmm7,xmm7
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b1000
	shufps xmm6, xmm6, 0b1101
	movlhps xmm4, xmm7
	movlhps xmm6, xmm7
	
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
			
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	


	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move _ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */


	rcpps xmm5, xmm4
	/* 1/x lookup seed in xmm5 */
	movaps xmm0, [esp + _two]
	mulps xmm4, xmm5
	subps xmm0, xmm4
	mulps xmm0, xmm5	/* xmm0=rinvsq */
	movaps xmm4, xmm0
	
	movaps xmm1, xmm0
	mulps  xmm1, xmm0
	mulps  xmm1, xmm0	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */

	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	mulps  xmm4, xmm2	/* xmm4=total fscal */

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i0110_checksingle_vdwc:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    .i0110_dosingle_vdwc
	jmp    .i0110_updateouterdata_vdwc
.i0110_dosingle_vdwc:			
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]		

	mov esi, [ebp + _type]
	mov ecx, eax
	mov ecx, [esi + ecx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1
	add ecx, [esp + _ntia]
	xorps  xmm6, xmm6
	movlps xmm6, [esi + ecx*4]
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b11111100
	shufps xmm6, xmm6, 0b11111101	
			
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	
	
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rcpps xmm5, xmm4
	/* 1/x lookup seed in xmm5 */
	movaps xmm0, [esp + _two]
	mulps xmm4, xmm5
	subps xmm0, xmm4
	mulps xmm0, xmm5	/* xmm0=rinvsq */
	movaps xmm4, xmm0
	
	movaps xmm1, xmm0
	mulps  xmm1, xmm0
	mulps  xmm1, xmm0	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */

	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addss  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	mulps  xmm4, xmm2	/* xmm4=total fscal */
	
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movss [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
.i0110_updateouterdata_vdwc:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5

	/* loop back to mno */
	dec dword ptr [esp + _nsvdwc]
	jz  .i0110_testvdw
	jmp .i0110_mno_vdwc
.i0110_testvdw:	
	mov  ebx,  [esp + _nscoul]
	add  [esp + _solnr],  ebx

	mov  ecx, [esp + _nsvdw]
	cmp  ecx,  0
	jnz  .i0110_mno_vdw
	jmp  .i0110_last_mno
.i0110_mno_vdw:
	mov   ebx,  [esp + _solnr]
	inc   dword ptr [esp + _solnr]

        mov   edx, [ebp + _type] 
        mov   edx, [edx + ebx*4]
        imul  edx, [ebp + _ntype]
        shl   edx, 1
        mov   [esp + _ntia], edx
		
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx

	movss xmm0, [esp + _shX]
	movss xmm1, [esp + _shY]
	movss xmm2, [esp + _shZ]

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]
	
	xorps xmm4, xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   ecx, [esp + _innerjjnr0]
	mov   [esp + _innerjjnr], ecx
	mov   edx, [esp + _innerk0]
        sub   edx,  4
        mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i0110_unroll_vdw_loop
	jmp   .i0110_finish_vdw_inner
.i0110_unroll_vdw_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	movd  mm2, ecx
	movd  mm3, edx
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	mulps xmm3, xmm2
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move _ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rcpps xmm5, xmm4
	/* 1/x lookup seed in xmm5 */
	movaps xmm0, [esp + _two]
	mulps xmm4, xmm5
	subps xmm0, xmm4
	mulps xmm0, xmm5	/* xmm0=rinvsq */
	movaps xmm4, xmm0
	
	movaps xmm1, xmm0
	mulps  xmm1, xmm0
	mulps  xmm1, xmm0	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */

	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	mulps  xmm4, xmm2	/* xmm4=total fscal */

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vnbtot], xmm5

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i0110_finish_vdw_inner
	jmp   .i0110_unroll_vdw_loop
.i0110_finish_vdw_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i0110_dopair_vdw
	jmp   .i0110_checksingle_vdw
.i0110_dopair_vdw:	

        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8

	mov esi, [ebp + _type]
	mov   ecx, eax
	mov   edx, ebx
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add ecx, edi
	add edx, edi
	movlps xmm6, [esi + ecx*4]
	movhps xmm6, [esi + edx*4]
	mov edi, [ebp + _pos]	
	xorps  xmm7,xmm7
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b1000 	
	shufps xmm6, xmm6, 0b1101
	movlhps xmm4, xmm7
	movlhps xmm6, xmm7
	
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
			
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	


	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move _ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */


	rcpps xmm5, xmm4
	/* 1/x lookup seed in xmm5 */
	movaps xmm0, [esp + _two]
	mulps xmm4, xmm5
	subps xmm0, xmm4
	mulps xmm0, xmm5	/* xmm0=rinvsq */
	movaps xmm4, xmm0
	
	movaps xmm1, xmm0
	mulps  xmm1, xmm0
	mulps  xmm1, xmm0	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */

	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	mulps  xmm4, xmm2	/* xmm4=total fscal */

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i0110_checksingle_vdw:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz   .i0110_dosingle_vdw
	jmp   .i0110_updateouterdata_vdw
.i0110_dosingle_vdw:			
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]		

	mov esi, [ebp + _type]
	mov ecx, eax
	mov ecx, [esi + ecx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1
	add ecx, [esp + _ntia]
	xorps  xmm6, xmm6
	movlps xmm6, [esi + ecx*4]
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b11111100	
	shufps xmm6, xmm6, 0b11111101	
			
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	
	
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rcpps xmm5, xmm4
	/* 1/x lookup seed in xmm5 */
	movaps xmm0, [esp + _two]
	mulps xmm4, xmm5
	subps xmm0, xmm4
	mulps xmm0, xmm5	/* xmm0=rinvsq */
	movaps xmm4, xmm0
	
	movaps xmm1, xmm0
	mulps  xmm1, xmm0
	mulps  xmm1, xmm0	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */

	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addss  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	mulps  xmm4, xmm2	/* xmm4=total fscal */
	
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movss [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
.i0110_updateouterdata_vdw:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5
	
	/* loop back to mno */
	dec dword ptr [esp + _nsvdw]
	jz  .i0110_last_mno
	jmp .i0110_mno_vdw
	
.i0110_last_mno:	

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i0110_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i0110_outer
.i0110_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 332
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret


.globl inl0300_sse
	.type inl0300_sse,@function
inl0300_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_type,		48
.equ		_ntype,		52
.equ		_nbfp,		56	
.equ		_Vnb,		60
.equ		_tabscale,	64
.equ		_VFtab,		68
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ix,	        0
.equ		_iy,		16
.equ		_iz,            32
.equ		_dx,            48
.equ		_dy,            64
.equ		_dz,            80
.equ		_two,	        96
.equ		_tsc,		112
.equ		_c6,            128
.equ		_c12,           144
.equ		_fscal,         160
.equ		_vnbtot,        176
.equ		_fix,           192
.equ		_fiy,           208
.equ		_fiz,           224
.equ		_half,          240
.equ		_three,         256
.equ		_is3,           272
.equ		_ii3,           276
.equ		_ntia,	        280	
.equ		_innerjjnr,     284
.equ		_innerk,        288
.equ		_salign,        292								
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 296		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_two]
	movups xmm2, [sse_three]
	movss xmm3, [ebp + _tabscale]
	movaps [esp + _half],  xmm0
	movaps [esp + _two], xmm1
	movaps [esp + _three],  xmm2
	shufps xmm3, xmm3, 0
	movaps [esp + _tsc], xmm3

	/* assume we have at least one i particle - start directly */	
.i0300_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

        mov   edx, [ebp + _type] 
        mov   edx, [edx + ebx*4]
        imul  edx, [ebp + _ntype]
        shl   edx, 1
        mov   [esp + _ntia], edx
		
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]
	
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   [esp + _ii3], ebx
	
	/* clear tot potential and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vnbtot], xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i0300_unroll_loop
	jmp   .i0300_finish_inner
.i0300_unroll_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	movd  mm2, ecx
	movd  mm3, edx
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move _ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	movhlps xmm5, xmm4
	cvttps2pi mm6, xmm4
	cvttps2pi mm7, xmm5	/* mm6/mm7 contain lu indices */
	cvtpi2ps xmm6, mm6
	cvtpi2ps xmm5, mm7
	movlhps xmm6, xmm5
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */
	pslld mm6, 3
	pslld mm7, 3

	movd mm0, eax	
	movd mm1, ebx
	movd mm2, ecx
	movd mm3, edx

	mov  esi, [ebp + _VFtab]
	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	/* dispersion */
	movlps xmm5, [esi + eax*4 + 0]
	movlps xmm7, [esi + ecx*4 + 0]
	movhps xmm5, [esi + ebx*4 + 0]
	movhps xmm7, [esi + edx*4 + 0] /* got half dispersion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101
	
	movlps xmm7, [esi + eax*4 + 8]
	movlps xmm3, [esi + ecx*4 + 8]
	movhps xmm7, [esi + ebx*4 + 8]
	movhps xmm3, [esi + edx*4 + 8] /* other half of dispersion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* dispersion table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */

	/* put scalar force on stack Update vnbtot directly */
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movaps [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm5, [esi + eax*4 + 16]
	movlps xmm7, [esi + ecx*4 + 16]
	movhps xmm5, [esi + ebx*4 + 16]
	movhps xmm7, [esi + edx*4 + 16] /* got half repulsion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101

	movlps xmm7, [esi + eax*4 + 24]
	movlps xmm3, [esi + ecx*4 + 24]
	movhps xmm7, [esi + ebx*4 + 24]
	movhps xmm3, [esi + edx*4 + 24] /* other half of repulsion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 
	mulps  xmm5, xmm4  
	addps  xmm7, [esp + _fscal] 
	
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movd eax, mm0	
	movd ebx, mm1
	movd ecx, mm2
	movd edx, mm3

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i0300_finish_inner
	jmp   .i0300_unroll_loop
.i0300_finish_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i0300_dopair
	jmp   .i0300_checksingle
.i0300_dopair:	
        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8	
	xorps xmm7, xmm7

	mov esi, [ebp + _type]
	mov   ecx, eax
	mov   edx, ebx
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add ecx, edi
	add edx, edi
	movlps xmm6, [esi + ecx*4]
	movhps xmm6, [esi + edx*4]
	mov edi, [ebp + _pos]	
	
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b1000 	
	shufps xmm6, xmm6, 0b1101
	movlhps xmm4, xmm7
	movlhps xmm6, xmm7
	
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
			
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move _ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 3

	mov  esi, [ebp + _VFtab]
	movd ecx, mm6
	psrlq mm6, 32
	movd edx, mm6

	/* dispersion */
	movlps xmm5, [esi + ecx*4 + 0]
	movhps xmm5, [esi + edx*4 + 0]/* got half dispersion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm4, 0b10001000
	shufps xmm5, xmm5, 0b11011101
	
	movlps xmm7, [esi + ecx*4 + 8]
	movhps xmm7, [esi + edx*4 + 8] /* other half of dispersion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 0b10001000
	shufps xmm7, xmm7, 0b11011101
	/* dispersion table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */

	/* put scalar force on stack Update vnbtot directly */
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movaps [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm5, [esi + ecx*4 + 16]
	movhps xmm5, [esi + edx*4 + 16] /* got half repulsion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101

	movlps xmm7, [esi + ecx*4 + 24]
	movhps xmm7, [esi + edx*4 + 24] /* other half of repulsion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
 	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 /* fijR */
	mulps  xmm5, xmm4 /* vnb12 */
	addps  xmm7, [esp + _fscal] 
	
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i0300_checksingle:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    .i0300_dosingle
	jmp    .i0300_updateouterdata
.i0300_dosingle:
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	xorps  xmm6, xmm6

	mov esi, [ebp + _type]
	mov ecx, eax
	mov ecx, [esi + ecx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1
	add ecx, [esp + _ntia]
	movlps xmm6, [esi + ecx*4]
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b11111100	
	shufps xmm6, xmm6, 0b11111101	
			
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	 
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */

	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 3

	mov  esi, [ebp + _VFtab]
	movd ebx, mm6
	
	/* dispersion */
	movlps xmm4, [esi + ebx*4 + 0]
	movlps xmm6, [esi + ebx*4 + 8]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */

	/* put scalar force on stack Update vnbtot directly */
	addss  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movss [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm4, [esi + ebx*4 + 16]
	movlps xmm6, [esi + ebx*4 + 24]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
 	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 /* fijR */
	mulps  xmm5, xmm4 /* vnb12 */
	addps  xmm7, [esp + _fscal] 
	
	addss  xmm5, [esp + _vnbtot]
	movss [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
.i0300_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i0300_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i0300_outer
.i0300_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 296
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret

	
.globl inl0310_sse
	.type inl0310_sse,@function
inl0310_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_type,		48
.equ		_ntype,		52
.equ		_nbfp,		56	
.equ		_Vnb,		60	
.equ		_tabscale,	64
.equ		_VFtab,		68
.equ		_nsatoms,	72
	/* stack offsets for local variables */ 
        /* bottom of stack is cache-aligned for sse use */
.equ		_ix,	        0
.equ		_iy,	        16
.equ		_iz,            32
.equ		_dx,            48
.equ		_dy,            64
.equ		_dz,            80
.equ		_two,           96   
.equ		_tsc,           112
.equ		_c6,            128
.equ		_c12,           144
.equ		_fscal,         160
.equ		_vnbtot,        176
.equ		_fix,           192
.equ		_fiy,           208
.equ		_fiz,           224
.equ		_half,          240
.equ		_three,         256
.equ		_is3,           272
.equ		_ii3,           276
.equ		_shX,           280
.equ		_shY,           284
.equ		_shZ,           288
.equ		_ntia,	        292	
.equ		_innerjjnr0,    296
.equ		_innerjjnr,     300
.equ		_innerk0,       304
.equ		_innerk,        308
.equ		_salign,        312
.equ		_nsvdwc,        316
.equ		_nscoul,        320
.equ		_nsvdw,         324
.equ		_solnr,         328
	push ebp
	mov ebp,esp	
        push eax      
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 332		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_two]
	movups xmm2, [sse_three]
	movss xmm3, [ebp + _tabscale]
	movaps [esp + _half],  xmm0
	movaps [esp + _two], xmm1
	movaps [esp + _three], xmm2
	shufps xmm3, xmm3, 0
	movaps [esp + _tsc], xmm3

	/* assume we have at least one i particle - start directly */	
.i0310_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movlps xmm0, [eax + ebx*4]	/* getting the shiftvector */
	movss xmm1, [eax + ebx*4 + 8] 
	movlps [esp + _shX], xmm0
	movss [esp + _shZ], xmm1

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   eax, [ebp + _nsatoms]
	add   [ebp + _nsatoms],  12
	mov   ecx, [eax]	
	mov   edx, [eax + 4]
	mov   eax, [eax + 8]	
	sub   ecx, eax
	sub   eax, edx
	
	mov   [esp + _nsvdwc], edx
	mov   [esp + _nscoul], eax
	mov   [esp + _nsvdw], ecx

	/* clear vnbtot */
	xorps xmm4, xmm4
	movaps [esp + _vnbtot], xmm4
	mov   [esp + _solnr],  ebx
		
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr0], eax     /* pointer to jjnr[nj0] */

	mov   [esp + _innerk0], edx        /* number of innerloop atoms */

	mov   ecx, [esp + _nsvdwc]
	cmp   ecx,  0
	jnz   .i0310_mno_vdwc
	jmp   .i0310_testvdw
.i0310_mno_vdwc:
	mov   ebx,  [esp + _solnr]
	inc   dword ptr [esp + _solnr]

        mov   edx, [ebp + _type] 
        mov   edx, [edx + ebx*4]
        imul  edx, [ebp + _ntype]
        shl   edx, 1
        mov   [esp + _ntia], edx
		
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx

	movss xmm0, [esp + _shX]
	movss xmm1, [esp + _shY]
	movss xmm2, [esp + _shZ]

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]
	
	/* clear i forces */
	xorps xmm4, xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   ecx, [esp + _innerjjnr0]
	mov   [esp + _innerjjnr], ecx
	mov   edx, [esp + _innerk0]
        sub   edx,  4
        mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i0310_unroll_vdwc_loop
	jmp   .i0310_finish_vdwc_inner
.i0310_unroll_vdwc_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	movd  mm2, ecx
	movd  mm3, edx
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move _ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	movhlps xmm5, xmm4
	cvttps2pi mm6, xmm4
	cvttps2pi mm7, xmm5	/* mm6/mm7 contain lu indices */
	cvtpi2ps xmm6, mm6
	cvtpi2ps xmm5, mm7
	movlhps xmm6, xmm5
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */
	pslld mm6, 3
	pslld mm7, 3

	movd mm0, eax	
	movd mm1, ebx
	movd mm2, ecx
	movd mm3, edx

	mov  esi, [ebp + _VFtab]
	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	/* dispersion */
	movlps xmm5, [esi + eax*4 + 0]
	movlps xmm7, [esi + ecx*4 + 0]
	movhps xmm5, [esi + ebx*4 + 0]
	movhps xmm7, [esi + edx*4 + 0] /* got half dispersion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101
	
	movlps xmm7, [esi + eax*4 + 8]
	movlps xmm3, [esi + ecx*4 + 8]
	movhps xmm7, [esi + ebx*4 + 8]
	movhps xmm3, [esi + edx*4 + 8] /* other half of dispersion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* dispersion table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */

	/* put scalar force on stack Update vnbtot directly */
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movaps [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm5, [esi + eax*4 + 16]
	movlps xmm7, [esi + ecx*4 + 16]
	movhps xmm5, [esi + ebx*4 + 16]
	movhps xmm7, [esi + edx*4 + 16] /* got half repulsion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101

	movlps xmm7, [esi + eax*4 + 24]
	movlps xmm3, [esi + ecx*4 + 24]
	movhps xmm7, [esi + ebx*4 + 24]
	movhps xmm3, [esi + edx*4 + 24] /* other half of repulsion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
 	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 /* fijR */
	mulps  xmm5, xmm4 /* vnb12 */
	addps  xmm7, [esp + _fscal] 
	
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movd eax, mm0	
	movd ebx, mm1
	movd ecx, mm2
	movd edx, mm3

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i0310_finish_vdwc_inner
	jmp   .i0310_unroll_vdwc_loop
.i0310_finish_vdwc_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i0310_dopair_vdwc
	jmp   .i0310_checksingle_vdwc
.i0310_dopair_vdwc:	
        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8	
	xorps xmm7, xmm7

	mov esi, [ebp + _type]
	mov   ecx, eax
	mov   edx, ebx
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add ecx, edi
	add edx, edi
	movlps xmm6, [esi + ecx*4]
	movhps xmm6, [esi + edx*4]
	mov edi, [ebp + _pos]	
	
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b1000 	
	shufps xmm6, xmm6, 0b1101
	movlhps xmm4, xmm7
	movlhps xmm6, xmm7
	
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
			
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move _ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 3

	mov  esi, [ebp + _VFtab]
	movd ecx, mm6
	psrlq mm6, 32
	movd edx, mm6

	/* dispersion */
	movlps xmm5, [esi + ecx*4 + 0]
	movhps xmm5, [esi + edx*4 + 0]/* got half dispersion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm4, 0b10001000
	shufps xmm5, xmm5, 0b11011101
	
	movlps xmm7, [esi + ecx*4 + 8]
	movhps xmm7, [esi + edx*4 + 8] /* other half of dispersion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 0b10001000
	shufps xmm7, xmm7, 0b11011101
	/* dispersion table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */

	/* put scalar force on stack Update vnbtot directly */
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movaps [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm5, [esi + ecx*4 + 16]
	movhps xmm5, [esi + edx*4 + 16] /* got half repulsion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm4, 0b10001000
	shufps xmm5, xmm5, 0b11011101

	movlps xmm7, [esi + ecx*4 + 24]
	movhps xmm7, [esi + edx*4 + 24] /* other half of repulsion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 0b10001000
	shufps xmm7, xmm7, 0b11011101
	/* table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
 	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 /* fijR */
	mulps  xmm5, xmm4 /* vnb12 */
	addps  xmm7, [esp + _fscal] 
	
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i0310_checksingle_vdwc:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    .i0310_dosingle_vdwc
	jmp    .i0310_updateouterdata_vdwc
.i0310_dosingle_vdwc:
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	xorps  xmm6, xmm6

	mov esi, [ebp + _type]
	mov ecx, eax
	mov ecx, [esi + ecx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1
	add ecx, [esp + _ntia]
	movlps xmm6, [esi + ecx*4]
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b11111100	
	shufps xmm6, xmm6, 0b11111101	
			
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	 
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */

	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 3

	mov  esi, [ebp + _VFtab]
	movd ebx, mm6
	
	/* dispersion */
	movlps xmm4, [esi + ebx*4 + 0]
	movlps xmm6, [esi + ebx*4 + 8]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */

	/* put scalar force on stack Update vnbtot directly */
	addss  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movss [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm4, [esi + ebx*4 + 16]
	movlps xmm6, [esi + ebx*4 + 24]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
 	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 /* fijR */
	mulps  xmm5, xmm4 /* vnb12 */
	addps  xmm7, [esp + _fscal] 
	
	addss  xmm5, [esp + _vnbtot]
	movss [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
.i0310_updateouterdata_vdwc:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5

	/* loop back to mno */
	dec  dword ptr [esp + _nsvdwc]
	jz  .i0310_testvdw
	jmp .i0310_mno_vdwc
.i0310_testvdw:	
	mov  ebx,  [esp + _nscoul]
	add  [esp + _solnr],  ebx

	mov  ecx, [esp + _nsvdw]
	cmp  ecx,  0
	jnz  .i0310_mno_vdw
	jmp  .i0310_last_mno
.i0310_mno_vdw:
	mov   ebx,  [esp + _solnr]
	inc   dword ptr [esp + _solnr]

        mov   edx, [ebp + _type] 
        mov   edx, [edx + ebx*4]
        imul  edx, [ebp + _ntype]
        shl   edx, 1
        mov   [esp + _ntia], edx
		
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx

	movss xmm0, [esp + _shX]
	movss xmm1, [esp + _shY]
	movss xmm2, [esp + _shZ]

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]
	
	xorps xmm4, xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   ecx, [esp + _innerjjnr0]
	mov   [esp + _innerjjnr], ecx
	mov   edx, [esp + _innerk0]
        sub   edx,  4
        mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i0310_unroll_vdw_loop
	jmp   .i0310_finish_vdw_inner
.i0310_unroll_vdw_loop:
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	movd  mm2, ecx
	movd  mm3, edx
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move _ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	movhlps xmm5, xmm4
	cvttps2pi mm6, xmm4
	cvttps2pi mm7, xmm5	/* mm6/mm7 contain lu indices */
	cvtpi2ps xmm6, mm6
	cvtpi2ps xmm5, mm7
	movlhps xmm6, xmm5
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */
	pslld mm6, 3
	pslld mm7, 3

	movd mm0, eax	
	movd mm1, ebx
	movd mm2, ecx
	movd mm3, edx

	mov  esi, [ebp + _VFtab]
	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	/* dispersion */
	movlps xmm5, [esi + eax*4 + 0]
	movlps xmm7, [esi + ecx*4 + 0]
	movhps xmm5, [esi + ebx*4 + 0]
	movhps xmm7, [esi + edx*4 + 0] /* got half dispersion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101
	
	movlps xmm7, [esi + eax*4 + 8]
	movlps xmm3, [esi + ecx*4 + 8]
	movhps xmm7, [esi + ebx*4 + 8]
	movhps xmm3, [esi + edx*4 + 8] /* other half of dispersion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* dispersion table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */

	/* put scalar force on stack Update vnbtot directly */
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movaps [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm5, [esi + eax*4 + 16]
	movlps xmm7, [esi + ecx*4 + 16]
	movhps xmm5, [esi + ebx*4 + 16]
	movhps xmm7, [esi + edx*4 + 16] /* got half repulsion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101

	movlps xmm7, [esi + eax*4 + 24]
	movlps xmm3, [esi + ecx*4 + 24]
	movhps xmm7, [esi + ebx*4 + 24]
	movhps xmm3, [esi + edx*4 + 24] /* other half of repulsion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
 	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 /* fijR */
	mulps  xmm5, xmm4 /* vnb12 */
	addps  xmm7, [esp + _fscal] 
	
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movd eax, mm0	
	movd ebx, mm1
	movd ecx, mm2
	movd edx, mm3

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i0310_finish_vdw_inner
	jmp   .i0310_unroll_vdw_loop
.i0310_finish_vdw_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i0310_dopair_vdw
	jmp   .i0310_checksingle_vdw
.i0310_dopair_vdw:	
        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8	
	xorps xmm7, xmm7

	mov esi, [ebp + _type]
	mov   ecx, eax
	mov   edx, ebx
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add ecx, edi
	add edx, edi
	movlps xmm6, [esi + ecx*4]
	movhps xmm6, [esi + edx*4]
	mov edi, [ebp + _pos]	
	
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b1000 	
	shufps xmm6, xmm6, 0b1101
	movlhps xmm4, xmm7
	movlhps xmm6, xmm7
	
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
			
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move _ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 3

	mov  esi, [ebp + _VFtab]
	movd ecx, mm6
	psrlq mm6, 32
	movd edx, mm6

	/* dispersion */
	movlps xmm5, [esi + ecx*4 + 0]
	movhps xmm5, [esi + edx*4 + 0]/* got half dispersion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm4, 0b10001000
	shufps xmm5, xmm5, 0b11011101
	
	movlps xmm7, [esi + ecx*4 + 8]
	movhps xmm7, [esi + edx*4 + 8] /* other half of dispersion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 0b10001000
	shufps xmm7, xmm7, 0b11011101
	/* dispersion table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */

	/* put scalar force on stack Update vnbtot directly */
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movaps [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm5, [esi + ecx*4 + 16]
	movhps xmm5, [esi + edx*4 + 16] /* got half repulsion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm4, 0b10001000
	shufps xmm5, xmm5, 0b11011101

	movlps xmm7, [esi + ecx*4 + 24]
	movhps xmm7, [esi + edx*4 + 24] /* other half of repulsion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 0b10001000
	shufps xmm7, xmm7, 0b11011101
	/* table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
 	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 /* fijR */
	mulps  xmm5, xmm4 /* vnb12 */
	addps  xmm7, [esp + _fscal] 
	
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i0310_checksingle_vdw:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    .i0310_dosingle_vdw
	jmp    .i0310_updateouterdata_vdw
.i0310_dosingle_vdw:
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	xorps  xmm6, xmm6

	mov esi, [ebp + _type]
	mov ecx, eax
	mov ecx, [esi + ecx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1
	add ecx, [esp + _ntia]
	movlps xmm6, [esi + ecx*4]
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b11111100	
	shufps xmm6, xmm6, 0b11111101	
			
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	 
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */

	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 3

	mov  esi, [ebp + _VFtab]
	movd ebx, mm6
	
	/* dispersion */
	movlps xmm4, [esi + ebx*4 + 0]
	movlps xmm6, [esi + ebx*4 + 8]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */

	/* put scalar force on stack Update vnbtot directly */
	addss  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movss [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm4, [esi + ebx*4 + 16]
	movlps xmm6, [esi + ebx*4 + 24]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
 	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 /* fijR */
	mulps  xmm5, xmm4 /* vnb12 */
	addps  xmm7, [esp + _fscal] 
	
	addss  xmm5, [esp + _vnbtot]
	movss [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5		
.i0310_updateouterdata_vdw:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5
	
	/* loop back to mno */
	dec  dword ptr [esp + _nsvdw]
	jz  .i0310_last_mno
	jmp .i0310_mno_vdw	
.i0310_last_mno:	

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i0310_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i0310_outer
.i0310_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 332
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret



.globl inl1000_sse
	.type inl1000_sse,@function
inl1000_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ix,            0
.equ		_iy,	        16
.equ		_iz,            32
.equ		_iq,            48
.equ		_dx,            64
.equ		_dy,            80
.equ		_dz,            96
.equ		_vctot,         112
.equ		_fix,           128
.equ		_fiy,           144
.equ		_fiz,           160
.equ		_half,          176
.equ		_three,         192
.equ		_is3,           208
.equ		_ii3,           212
.equ		_innerjjnr,     216
.equ		_innerk,        220		
.equ		_salign,        224							
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 228		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_three]
	movaps [esp + _half],  xmm0
	movaps [esp + _three], xmm1

	/* assume we have at least one i particle - start directly */	
i1000_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	mulss xmm3, [ebp + _facel]
	shufps xmm3, xmm3, 0
	
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]

	movaps [esp + _iq], xmm3
	
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   [esp + _ii3], ebx
	
	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   i1000_unroll_loop
	jmp   i1000_finish_inner
i1000_unroll_loop:	
	/* quad-unrolled innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	movaps xmm5, [esp + _iq]
	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0
	shufps xmm3, xmm4, 0b10001000	      
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	mulps xmm3, xmm5
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]	/* x1 y1 - - */
	movlps xmm5, [esi + ecx*4]	/* x3 y3 - - */
	movss xmm2, [esi + eax*4 + 8]	/* z1 -  - - */
	movss xmm6, [esi + ecx*4 + 8]   /* z3 -  - - */

	movhps xmm4, [esi + ebx*4]	/* x1 y1 x2 y2 */
	movhps xmm5, [esi + edx*4]	/* x3 y3 x4 y4 */

	movss xmm0, [esi + ebx*4 + 8]	/* z2 - - - */
	movss xmm1, [esi + edx*4 + 8]	/* z4 - - - */

	shufps xmm2, xmm0, 0		/* z1 z1 z2 z2 */
	shufps xmm6, xmm1, 0		/* z3 z3 z4 z4 */
	
	movaps xmm0, xmm4		/* x1 y1 x2 y2 */	
	movaps xmm1, xmm4		/* x1 y1 x2 y2 */

	shufps xmm2, xmm6, 0b10001000	/* z1 z2 z3 z4 */
	
	shufps xmm0, xmm5, 0b10001000	/* x1 x2 x3 x4 */
	shufps xmm1, xmm5, 0b11011101	/* y1 y2 y3 y4 */		

	mov    edi, [ebp + _faction]

	/* move _ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */

	movaps xmm5, [esp + _vctot]
	mulps  xmm3, xmm0	/* xmm3=vcoul */
	mulps  xmm4, xmm3	/* xmm4=fscal */
	addps  xmm5, xmm3

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vctot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    i1000_finish_inner
	jmp   i1000_unroll_loop
i1000_finish_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   i1000_dopair
	jmp   i1000_checksingle
i1000_dopair:	
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8

	movss xmm3, [esi + eax*4]		
	movss xmm6, [esi + ebx*4]
	shufps xmm3, xmm6, 0 
	shufps xmm3, xmm3, 0b00001000 /* xmm3(0,1) has the charges */

	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	mulps  xmm3, [esp + _iq]
	xorps  xmm7,xmm7
	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move _ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */

	movaps xmm5, [esp + _vctot]
	mulps  xmm3, xmm0	/* xmm3=vcoul */
	mulps  xmm4, xmm3	/* xmm4=fscal */
	addps  xmm5, xmm3

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vctot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */ 
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001
	
	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	
i1000_checksingle:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    i1000_dosingle
	jmp    i1000_updateouterdata
i1000_dosingle:			
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	movss xmm3, [esi + eax*4]	/* xmm3(0) has the charge */	
	
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	
 
	mulps  xmm3, [esp + _iq]
	
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	mov    edi, [ebp + _faction]
	movaps xmm5, [esp + _vctot]
	mulps  xmm3, xmm0	/* xmm3=vcoul */
	mulps  xmm4, xmm3	/* xmm4=fscal */
	addss  xmm5, xmm3

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vctot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
i1000_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec  ecx
	jecxz i1000_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp i1000_outer
i1000_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 228
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret



.globl inl1010_sse
	.type inl1010_sse,@function
inl1010_sse:	
.equ		_nri,		 8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56
.equ		_nsatoms,       60		
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ix,	        0
.equ		_iy,	        16
.equ		_iz,            32
.equ		_iq,            48
.equ		_dx,            64
.equ		_dy,            80
.equ		_dz,            96
.equ		_vctot,         112
.equ		_fix,           128
.equ		_fiy,           144
.equ		_fiz,           160
.equ		_half,          176
.equ		_three,         192
.equ		_is3,           208
.equ		_ii3,           212
.equ		_shX,	        216
.equ		_shY,           220
.equ		_shZ,           224
.equ		_ntia,	        228	
.equ		_innerjjnr0,    232
.equ		_innerk0,       236
.equ		_innerjjnr,     240
.equ		_innerk,        244		
.equ		_salign,        248
.equ		_nscoul,        252
.equ		_solnr,	        256		
	push ebp
	mov ebp,esp		
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 260		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_three]
	movaps [esp + _half],  xmm0
	movaps [esp + _three], xmm1
	add   [ebp + _nsatoms],  8

	/* assume we have at least one i particle - start directly */	
i1010_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 
	movss [esp + _shX], xmm0
	movss [esp + _shY], xmm1
	movss [esp + _shZ], xmm2

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   eax, [ebp + _nsatoms]
	mov   ecx, [eax]
	add   [ebp + _nsatoms],  12
	mov   [esp + _nscoul], ecx	

	/* clear vctot */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	mov   [esp + _solnr], ebx

	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr0], eax     /* pointer to jjnr[nj0] */
	mov   [esp + _innerk0], edx        /* number of innerloop atoms */

	mov   ecx, [esp + _nscoul]
	cmp   ecx,  0
	jnz   i1010_mno_coul
	jmp   i1010_last_mno
i1010_mno_coul:
	mov   ebx,  [esp + _solnr]
	inc   dword ptr [esp + _solnr]

	movss xmm0, [esp + _shX]
	movss xmm1, [esp + _shY]
	movss xmm2, [esp + _shZ]

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	mulss xmm3, [ebp + _facel]
	shufps xmm3, xmm3, 0
	
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]

	movaps [esp + _iq], xmm3
	
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   [esp + _ii3], ebx
	
	/* clear i forces */
	xorps xmm4, xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4

	mov   ecx, [esp + _innerjjnr0]
	mov   [esp + _innerjjnr], ecx
	mov   edx, [esp + _innerk0]
        sub   edx,  4
        mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   i1010_unroll_coul_loop
	jmp   i1010_finish_coul_inner

i1010_unroll_coul_loop:	
	/* quad-unrolled innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	movaps xmm5, [esp + _iq]
	shufps xmm3, xmm6, 0
	shufps xmm4, xmm7, 0
	shufps xmm3, xmm4, 0b10001000	      
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	mulps xmm3, xmm5
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	mov    edi, [ebp + _faction]

	/* move _ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */

	movaps xmm5, [esp + _vctot]
	mulps  xmm3, xmm0	/* xmm3=vcoul */
	mulps  xmm4, xmm3	/* xmm4=fscal */
	addps  xmm5, xmm3

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vctot], xmm5


	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    i1010_finish_coul_inner
	jmp   i1010_unroll_coul_loop
i1010_finish_coul_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   i1010_dopair_coul
	jmp   i1010_checksingle_coul
i1010_dopair_coul:	
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8

	movss xmm3, [esi + eax*4]		
	movss xmm6, [esi + ebx*4]
	shufps xmm3, xmm6, 0
	shufps xmm3, xmm3, 0b00001000 /* xmm3(0,1) has the charges */

	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	mulps  xmm3, [esp + _iq]
	xorps  xmm7,xmm7
	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */

	movaps xmm5, [esp + _vctot]
	mulps  xmm3, xmm0	/* xmm3=vcoul */
	mulps  xmm4, xmm3	/* xmm4=fscal */
	addps  xmm5, xmm3

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vctot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */ 
	movss xmm3, [edi + eax*4]
	movss xmm4, [edi + eax*4 + 4]
	movss xmm5, [edi + eax*4 + 8]
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	subps  xmm5, xmm2
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001
	
	movss xmm3, [edi + ebx*4]
	movss xmm4, [edi + ebx*4 + 4]
	movss xmm5, [edi + ebx*4 + 8]
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	subps  xmm5, xmm2
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5

i1010_checksingle_coul:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    i1010_dosingle_coul
	jmp    i1010_updateouterdata_coul
i1010_dosingle_coul:			
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	movss xmm3, [esi + eax*4]	/* xmm3(0) has the charge */	
	
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	
 
	mulps  xmm3, [esp + _iq]
	
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	mov    edi, [ebp + _faction]
	movaps xmm5, [esp + _vctot]
	mulps  xmm3, xmm0	/* xmm3=vcoul */
	mulps  xmm4, xmm3	/* xmm4=fscal */
	addss  xmm5, xmm3

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vctot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
        subss   xmm5, xmm2
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
i1010_updateouterdata_coul:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5

	/* loop back to mno */
	dec dword ptr [esp + _nscoul]
	jz  i1010_last_mno
	jmp i1010_mno_coul
	
i1010_last_mno:	
	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz i1010_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp i1010_outer
i1010_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 260
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret




.globl inl1020_sse
	.type inl1020_sse,@function
inl1020_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ixO,	        0
.equ		_iyO,	        16
.equ		_izO,           32
.equ		_ixH1,	        48
.equ		_iyH1,	        64
.equ		_izH1,          80
.equ		_ixH2,	        96
.equ		_iyH2,	        112
.equ		_izH2,          128
.equ		_iqO,           144 
.equ		_iqH,           160 
.equ		_dxO,           176
.equ		_dyO,           192
.equ		_dzO,           208	
.equ		_dxH1,          224
.equ		_dyH1,          240
.equ		_dzH1,          256	
.equ		_dxH2,          272
.equ		_dyH2,          288
.equ		_dzH2,          304	
.equ		_qqO,           320
.equ		_qqH,           336
.equ		_vctot,         352
.equ		_fixO,          368
.equ		_fiyO,          384
.equ		_fizO,          400
.equ		_fixH1,         416
.equ		_fiyH1,         432
.equ		_fizH1,         448
.equ		_fixH2,         464
.equ		_fiyH2,         480
.equ		_fizH2,         496
.equ		_fjx,	        512
.equ		_fjy,           528
.equ		_fjz,           544
.equ		_half,          560
.equ		_three,         576
.equ		_is3,           592
.equ		_ii3,           596
.equ		_innerjjnr,     600
.equ		_innerk,        604
.equ		_salign,        608								
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 612		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_three]
	movaps [esp + _half],  xmm0
	movaps [esp + _three], xmm1

	/* assume we have at least one i particle - start directly */
	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	movss xmm4, [edx + ebx*4 + 4]	
	movss xmm5, [ebp + _facel]
	mulss  xmm3, xmm5
	mulss  xmm4, xmm5

	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	movaps [esp + _iqO], xmm3
	movaps [esp + _iqH], xmm4
	
i1020_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2

	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx

	addss xmm3, [eax + ebx*4]
	addss xmm4, [eax + ebx*4 + 4]
	addss xmm5, [eax + ebx*4 + 8]		
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixO], xmm3
	movaps [esp + _iyO], xmm4
	movaps [esp + _izO], xmm5

	movss xmm3, xmm0
	movss xmm4, xmm1
	movss xmm5, xmm2
	addss xmm0, [eax + ebx*4 + 12]
	addss xmm1, [eax + ebx*4 + 16]
	addss xmm2, [eax + ebx*4 + 20]		
	addss xmm3, [eax + ebx*4 + 24]
	addss xmm4, [eax + ebx*4 + 28]
	addss xmm5, [eax + ebx*4 + 32]		

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixH1], xmm0
	movaps [esp + _iyH1], xmm1
	movaps [esp + _izH1], xmm2
	movaps [esp + _ixH2], xmm3
	movaps [esp + _iyH2], xmm4
	movaps [esp + _izH2], xmm5
	
	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _fixO], xmm4
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm4
	movaps [esp + _fixH1], xmm4
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm4
	movaps [esp + _fixH2], xmm4
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   i1020_unroll_loop
	jmp   i1020_odd_inner
i1020_unroll_loop:
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */

	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	shufps xmm3, xmm6, 0
	shufps xmm4, xmm7, 0
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	movaps xmm4, xmm3	     /* and in xmm4 */
	mulps  xmm3, [esp + _iqO]
	mulps  xmm4, [esp + _iqH]

	movaps  [esp + _qqO], xmm3
	movaps  [esp + _qqH], xmm4	

	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	
	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ixO-izO to xmm4-xmm6 */
	movaps xmm4, [esp + _ixO]
	movaps xmm5, [esp + _iyO]
	movaps xmm6, [esp + _izO]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dxO], xmm4
	movaps [esp + _dyO], xmm5
	movaps [esp + _dzO], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	movaps xmm7, xmm4
	/* rsqO in xmm7 */

	/* move ixH1-izH1 to xmm4-xmm6 */
	movaps xmm4, [esp + _ixH1]
	movaps xmm5, [esp + _iyH1]
	movaps xmm6, [esp + _izH1]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dxH1], xmm4
	movaps [esp + _dyH1], xmm5
	movaps [esp + _dzH1], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm6, xmm5
	addps xmm6, xmm4
	/* rsqH1 in xmm6 */

	/* move ixH2-izH2 to xmm3-xmm5 */ 
	movaps xmm3, [esp + _ixH2]
	movaps xmm4, [esp + _iyH2]
	movaps xmm5, [esp + _izH2]

	/* calc dr */
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2

	/* store dr */
	movaps [esp + _dxH2], xmm3
	movaps [esp + _dyH2], xmm4
	movaps [esp + _dzH2], xmm5
	/* square it */
	mulps xmm3,xmm3
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	addps xmm5, xmm4
	addps xmm5, xmm3
	/* rsqH2 in xmm5, rsqH1 in xmm6, rsqO in xmm7 */

	/* start with rsqO - seed in xmm2 */	
	rsqrtps xmm2, xmm7
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm7	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  xmm7, xmm4	/* rinvO in xmm7 */
	/* rsqH1 - seed in xmm2 */
	rsqrtps xmm2, xmm6
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm6	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  xmm6, xmm4	/* rinvH1 in xmm6 */
	/* rsqH2 - seed in xmm2 */
	rsqrtps xmm2, xmm5
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm5	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  xmm5, xmm4	/* rinvH2 in xmm5 */

	/* do O interactions */
	movaps  xmm4, xmm7	
	mulps   xmm4, xmm4	/* xmm7=rinv, xmm4=rinvsq */
	mulps  xmm7, [esp + _qqO]	/* xmm7=vcoul */
	
	mulps  xmm4, xmm7	/* total fsO in xmm4 */

	addps  xmm7, [esp + _vctot]
	
	movaps [esp + _vctot], xmm7

	movaps xmm0, [esp + _dxO]
	movaps xmm1, [esp + _dyO]
	movaps xmm2, [esp + _dzO]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

	/* update O forces */
	movaps xmm3, [esp + _fixO]
	movaps xmm4, [esp + _fiyO]
	movaps xmm7, [esp + _fizO]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixO], xmm3
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm7
	/* update j forces with water O */
	movaps [esp + _fjx], xmm0
	movaps [esp + _fjy], xmm1
	movaps [esp + _fjz], xmm2

	/* H1 interactions */
	movaps  xmm4, xmm6	
	mulps   xmm4, xmm4	/* xmm6=rinv, xmm4=rinvsq */
	mulps  xmm6, [esp + _qqH]	/* xmm6=vcoul */
	mulps  xmm4, xmm6		/* total fsH1 in xmm4 */
	
	addps  xmm6, [esp + _vctot]

	movaps xmm0, [esp + _dxH1]
	movaps xmm1, [esp + _dyH1]
	movaps xmm2, [esp + _dzH1]
	movaps [esp + _vctot], xmm6
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

	/* update H1 forces */
	movaps xmm3, [esp + _fixH1]
	movaps xmm4, [esp + _fiyH1]
	movaps xmm7, [esp + _fizH1]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixH1], xmm3
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm7
	/* update j forces with water H1 */
	addps  xmm0, [esp + _fjx]
	addps  xmm1, [esp + _fjy]
	addps  xmm2, [esp + _fjz]
	movaps [esp + _fjx], xmm0
	movaps [esp + _fjy], xmm1
	movaps [esp + _fjz], xmm2

	/* H2 interactions */
	movaps  xmm4, xmm5	
	mulps   xmm4, xmm4	/* xmm5=rinv, xmm4=rinvsq */
	mulps  xmm5, [esp + _qqH]	/* xmm5=vcoul */
	mulps  xmm4, xmm5		/* total fsH1 in xmm4 */
	
	addps  xmm5, [esp + _vctot]

	movaps xmm0, [esp + _dxH2]
	movaps xmm1, [esp + _dyH2]
	movaps xmm2, [esp + _dzH2]
	movaps [esp + _vctot], xmm5
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

	/* update H2 forces */
	movaps xmm3, [esp + _fixH2]
	movaps xmm4, [esp + _fiyH2]
	movaps xmm7, [esp + _fizH2]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixH2], xmm3
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm7

	mov edi, [ebp + _faction]
	/* update j forces */
	addps xmm0, [esp + _fjx]
	addps xmm1, [esp + _fjy]
	addps xmm2, [esp + _fjz]

	movlps xmm4, [edi + eax*4]
	movlps xmm7, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm7, [edi + edx*4]
	
	movaps xmm3, xmm4
	shufps xmm3, xmm7, 0b10001000
	shufps xmm4, xmm7, 0b11011101			      
	/* xmm3 has fjx, xmm4 has fjy */
	subps xmm3, xmm0
	subps xmm4, xmm1
	/* unpack them back for storing */
	movaps xmm7, xmm3
	unpcklps xmm7, xmm4
	unpckhps xmm3, xmm4	
	movlps [edi + eax*4], xmm7
	movlps [edi + ecx*4], xmm3
	movhps [edi + ebx*4], xmm7
	movhps [edi + edx*4], xmm3
	/* finally z forces */
	movss  xmm0, [edi + eax*4 + 8]
	movss  xmm1, [edi + ebx*4 + 8]
	movss  xmm3, [edi + ecx*4 + 8]
	movss  xmm4, [edi + edx*4 + 8]
	subss  xmm0, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm1, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm3, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm4, xmm2
	movss  [edi + eax*4 + 8], xmm0
	movss  [edi + ebx*4 + 8], xmm1
	movss  [edi + ecx*4 + 8], xmm3
	movss  [edi + edx*4 + 8], xmm4
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    i1020_odd_inner
	jmp   i1020_unroll_loop
i1020_odd_inner:	
	add   [esp + _innerk],  4
	jnz   i1020_odd_loop
	jmp   i1020_updateouterdata
i1020_odd_loop:
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	add   [esp + _innerjjnr],  4	

 	xorps xmm4, xmm4
	movss xmm4, [esp + _iqO]
	mov esi, [ebp + _charge] 
	movhps xmm4, [esp + _iqH]     
	movss xmm3, [esi + eax*4]	/* charge in xmm3 */
	shufps xmm3, xmm3, 0
	mulps xmm3, xmm4
	movaps [esp + _qqO], xmm3	/* use oxygen qq for storage */

	mov esi, [ebp + _pos]
	lea   eax, [eax + eax*2]  
	
	/* move j coords to xmm0-xmm2 */
	movss xmm0, [esi + eax*4]
	movss xmm1, [esi + eax*4 + 4]
	movss xmm2, [esi + eax*4 + 8]
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	
	movss xmm3, [esp + _ixO]
	movss xmm4, [esp + _iyO]
	movss xmm5, [esp + _izO]
		
	movlps xmm6, [esp + _ixH1]
	movlps xmm7, [esp + _ixH2]
	unpcklps xmm6, xmm7
	movlhps xmm3, xmm6
	movlps xmm6, [esp + _iyH1]
	movlps xmm7, [esp + _iyH2]
	unpcklps xmm6, xmm7
	movlhps xmm4, xmm6
	movlps xmm6, [esp + _izH1]
	movlps xmm7, [esp + _izH2]
	unpcklps xmm6, xmm7
	movlhps xmm5, xmm6

	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	
	movaps [esp + _dxO], xmm3
	movaps [esp + _dyO], xmm4
	movaps [esp + _dzO], xmm5

	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5

	addps  xmm4, xmm3
	addps  xmm4, xmm5
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	movaps xmm3, [esp + _qqO]

	mulps  xmm3, xmm0	/* xmm3=vcoul */
	mulps  xmm4, xmm3	/* xmm4=total fscal */
	addps  xmm3, [esp + _vctot]

	movaps xmm0, [esp + _dxO]
	movaps xmm1, [esp + _dyO]
	movaps xmm2, [esp + _dzO]

	movaps [esp + _vctot], xmm3

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	movss  xmm3, [esp + _fixO]	
	movss  xmm4, [esp + _fiyO]	
	movss  xmm5, [esp + _fizO]	
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esp + _fixO], xmm3	
	movss  [esp + _fiyO], xmm4	
	movss  [esp + _fizO], xmm5	/* updated the O force now do the H's */
	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2
	shufps xmm3, xmm3, 0b11100110	/* shift right */
	shufps xmm4, xmm4, 0b11100110
	shufps xmm5, xmm5, 0b11100110
	addss  xmm3, [esp + _fixH1]
	addss  xmm4, [esp + _fiyH1]
	addss  xmm5, [esp + _fizH1]
	movss  [esp + _fixH1], xmm3	
	movss  [esp + _fiyH1], xmm4	
	movss  [esp + _fizH1], xmm5	/* updated the H1 force */

	mov edi, [ebp + _faction]
	shufps xmm3, xmm3, 0b11100111	/* shift right */
	shufps xmm4, xmm4, 0b11100111
	shufps xmm5, xmm5, 0b11100111
	addss  xmm3, [esp + _fixH2]
	addss  xmm4, [esp + _fiyH2]
	addss  xmm5, [esp + _fizH2]
	movss  [esp + _fixH2], xmm3	
	movss  [esp + _fiyH2], xmm4	
	movss  [esp + _fizH2], xmm5	/* updated the H2 force */

	/* the fj's - start by accumulating the tx/ty/tz force in xmm0, xmm1 */
	xorps  xmm5, xmm5
	movaps xmm3, xmm0
	movlps xmm6, [edi + eax*4]
	movss  xmm7, [edi + eax*4 + 8]
	unpcklps xmm3, xmm1
	movlhps  xmm3, xmm5	
	unpckhps xmm0, xmm1		
	addps    xmm0, xmm3
	movhlps  xmm3, xmm0	
	addps    xmm0, xmm3	/* x,y sum in xmm0 */

	movhlps  xmm1, xmm2
	addss    xmm2, xmm1
	shufps   xmm1, xmm1, 1 
	addss    xmm2, xmm1    /* z sum in xmm2 */
	subps    xmm6, xmm0
	subss    xmm7, xmm2
	
	movlps [edi + eax*4],     xmm6
	movss  [edi + eax*4 + 8], xmm7

	dec   dword ptr [esp + _innerk]
	jz    i1020_updateouterdata
	jmp   i1020_odd_loop
i1020_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate Oi forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixO]
	movaps xmm1, [esp + _fiyO]
	movaps xmm2, [esp + _fizO]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	movaps xmm6, xmm0
	movss xmm7, xmm2
	movlhps xmm6, xmm1
	shufps  xmm6, xmm6, 0b1000	

	/* accumulate H1i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH1]
	movaps xmm1, [esp + _fiyH1]
	movaps xmm2, [esp + _fizH1]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 12]
	movss  xmm4, [edi + ecx*4 + 16]
	movss  xmm5, [edi + ecx*4 + 20]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 12], xmm3
	movss  [edi + ecx*4 + 16], xmm4
	movss  [edi + ecx*4 + 20], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* accumulate H2i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH2]
	movaps xmm1, [esp + _fiyH2]
	movaps xmm2, [esp + _fizH2]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 24]
	movss  xmm4, [edi + ecx*4 + 28]
	movss  xmm5, [edi + ecx*4 + 32]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 24], xmm3
	movss  [edi + ecx*4 + 28], xmm4
	movss  [edi + ecx*4 + 32], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* increment fshift force */ 
	movlps  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 8]
	addps  xmm3, xmm6
	addss  xmm4, xmm7
	movlps  [esi + edx*4],    xmm3
	movss  [esi + edx*4 + 8], xmm4

	mov   edx, [ebp + _gid]  
	mov   edx, [edx]
	add   [ebp + _gid],  4	

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		
        
	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 	
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz i1020_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp i1020_outer
i1020_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 612
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret


	
.globl inl1030_sse
	.type inl1030_sse,@function
inl1030_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */	
.equ		_ixO,	        0
.equ		_iyO,	        16
.equ		_izO,           32
.equ		_ixH1,	        48
.equ		_iyH1,	        64
.equ		_izH1,          80
.equ		_ixH2,	        96
.equ		_iyH2,	        112
.equ		_izH2,          128
.equ		_jxO,	        144
.equ		_jyO,	        160
.equ		_jzO,           176
.equ		_jxH1,	        192
.equ		_jyH1,	        208
.equ		_jzH1,          224
.equ		_jxH2,	        240
.equ		_jyH2,	        256
.equ		_jzH2,          272
.equ		_dxOO,          288
.equ		_dyOO,          304
.equ		_dzOO,          320	
.equ		_dxOH1,         336
.equ		_dyOH1,         352
.equ		_dzOH1,         368	
.equ		_dxOH2,         384
.equ		_dyOH2,         400
.equ		_dzOH2,         416	
.equ		_dxH1O,         432
.equ		_dyH1O,         448
.equ		_dzH1O,         464	
.equ		_dxH1H1,        480
.equ		_dyH1H1,        496
.equ		_dzH1H1,        512	
.equ		_dxH1H2,        528
.equ		_dyH1H2,        544
.equ		_dzH1H2,        560	
.equ		_dxH2O,         576
.equ		_dyH2O,         592
.equ		_dzH2O,         608	
.equ		_dxH2H1,        624
.equ		_dyH2H1,        640
.equ		_dzH2H1,        656	
.equ		_dxH2H2,        672
.equ		_dyH2H2,        688
.equ		_dzH2H2,        704
.equ		_qqOO,          720
.equ		_qqOH,          736
.equ		_qqHH,          752
.equ		_vctot,         768		
.equ		_fixO,          784
.equ		_fiyO,          800
.equ		_fizO,          816
.equ		_fixH1,         832
.equ		_fiyH1,         848
.equ		_fizH1,         864
.equ		_fixH2,         880
.equ		_fiyH2,         896
.equ		_fizH2,         912
.equ		_fjxO,	        928
.equ		_fjyO,          944
.equ		_fjzO,          960
.equ		_fjxH1,	        976
.equ		_fjyH1,         992
.equ		_fjzH1,         1008
.equ		_fjxH2,	        1024
.equ		_fjyH2,         1040
.equ		_fjzH2,         1056
.equ		_half,          1072
.equ		_three,         1088
.equ		_rsqOO,         1104
.equ		_rsqOH1,        1120
.equ		_rsqOH2,        1136
.equ		_rsqH1O,        1152
.equ		_rsqH1H1,       1168
.equ		_rsqH1H2,       1184
.equ		_rsqH2O,        1200
.equ		_rsqH2H1,       1216
.equ		_rsqH2H2,       1232
.equ		_rinvOO,        1248
.equ		_rinvOH1,       1264
.equ		_rinvOH2,       1280
.equ		_rinvH1O,       1296
.equ		_rinvH1H1,      1312
.equ		_rinvH1H2,      1328
.equ		_rinvH2O,       1344
.equ		_rinvH2H1,      1360
.equ		_rinvH2H2,      1376
.equ		_is3,           1392
.equ		_ii3,           1396
.equ		_innerjjnr,     1400
.equ		_innerk,        1404
.equ		_salign,        1408							
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 1412		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_three]
	movaps [esp + _half],  xmm0
	movaps [esp + _three], xmm1
	
	/* assume we have at least one i particle - start directly */
	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	movss xmm4, xmm3	
	movss xmm5, [edx + ebx*4 + 4]	
	movss xmm6, [ebp + _facel]
	mulss  xmm3, xmm3
	mulss  xmm4, xmm5
	mulss  xmm5, xmm5
	mulss  xmm3, xmm6
	mulss  xmm4, xmm6
	mulss  xmm5, xmm6
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _qqOO], xmm3
	movaps [esp + _qqOH], xmm4
	movaps [esp + _qqHH], xmm5

i1030_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx	
	
	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2
	addss xmm3, [eax + ebx*4]
	addss xmm4, [eax + ebx*4 + 4]
	addss xmm5, [eax + ebx*4 + 8]		
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixO], xmm3
	movaps [esp + _iyO], xmm4
	movaps [esp + _izO], xmm5

	movss xmm3, xmm0
	movss xmm4, xmm1
	movss xmm5, xmm2
	addss xmm0, [eax + ebx*4 + 12]
	addss xmm1, [eax + ebx*4 + 16]
	addss xmm2, [eax + ebx*4 + 20]		
	addss xmm3, [eax + ebx*4 + 24]
	addss xmm4, [eax + ebx*4 + 28]
	addss xmm5, [eax + ebx*4 + 32]		

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixH1], xmm0
	movaps [esp + _iyH1], xmm1
	movaps [esp + _izH1], xmm2
	movaps [esp + _ixH2], xmm3
	movaps [esp + _iyH2], xmm4
	movaps [esp + _izH2], xmm5

	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _fixO], xmm4
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm4
	movaps [esp + _fixH1], xmm4
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm4
	movaps [esp + _fixH2], xmm4
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   i1030_unroll_loop
	jmp   i1030_single_check
i1030_unroll_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */

	mov   eax, [edx]	
	mov   ebx, [edx + 4] 
	mov   ecx, [edx + 8]
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	
	
	/* move j coordinates to local temp variables */
	movlps xmm2, [esi + eax*4]
	movlps xmm3, [esi + eax*4 + 12]
	movlps xmm4, [esi + eax*4 + 24]

	movlps xmm5, [esi + ebx*4]
	movlps xmm6, [esi + ebx*4 + 12]
	movlps xmm7, [esi + ebx*4 + 24]

	movhps xmm2, [esi + ecx*4]
	movhps xmm3, [esi + ecx*4 + 12]
	movhps xmm4, [esi + ecx*4 + 24]

	movhps xmm5, [esi + edx*4]
	movhps xmm6, [esi + edx*4 + 12]
	movhps xmm7, [esi + edx*4 + 24]

	/* current state: */	
	/* xmm2= jxOa  jyOa  jxOc  jyOc */
	/* xmm3= jxH1a jyH1a jxH1c jyH1c */
	/* xmm4= jxH2a jyH2a jxH2c jyH2c */
	/* xmm5= jxOb  jyOb  jxOd  jyOd */
	/* xmm6= jxH1b jyH1b jxH1d jyH1d */
	/* xmm7= jxH2b jyH2b jxH2d jyH2d */
	
	movaps xmm0, xmm2
	movaps xmm1, xmm3
	unpcklps xmm0, xmm5	/* xmm0= jxOa  jxOb  jyOa  jyOb */
	unpcklps xmm1, xmm6	/* xmm1= jxH1a jxH1b jyH1a jyH1b */
	unpckhps xmm2, xmm5	/* xmm2= jxOc  jxOd  jyOc  jyOd */
	unpckhps xmm3, xmm6	/* xmm3= jxH1c jxH1d jyH1c jyH1d  */
	movaps xmm5, xmm4
	movaps   xmm6, xmm0
	unpcklps xmm4, xmm7	/* xmm4= jxH2a jxH2b jyH2a jyH2b */		
	unpckhps xmm5, xmm7	/* xmm5= jxH2c jxH2d jyH2c jyH2d */
	movaps   xmm7, xmm1
	movlhps  xmm0, xmm2	/* xmm0= jxOa  jxOb  jxOc  jxOd  */
	movaps [esp + _jxO], xmm0
	movhlps  xmm2, xmm6	/* xmm2= jyOa  jyOb  jyOc  jyOd */
	movaps [esp + _jyO], xmm2
	movlhps  xmm1, xmm3
	movaps [esp + _jxH1], xmm1
	movhlps  xmm3, xmm7
	movaps   xmm6, xmm4
	movaps [esp + _jyH1], xmm3
	movlhps  xmm4, xmm5
	movaps [esp + _jxH2], xmm4
	movhlps  xmm5, xmm6
	movaps [esp + _jyH2], xmm5

	movss  xmm0, [esi + eax*4 + 8]
	movss  xmm1, [esi + eax*4 + 20]
	movss  xmm2, [esi + eax*4 + 32]

	movss  xmm3, [esi + ecx*4 + 8]
	movss  xmm4, [esi + ecx*4 + 20]
	movss  xmm5, [esi + ecx*4 + 32]

	movhps xmm0, [esi + ebx*4 + 4]
	movhps xmm1, [esi + ebx*4 + 16]
	movhps xmm2, [esi + ebx*4 + 28]
	
	movhps xmm3, [esi + edx*4 + 4]
	movhps xmm4, [esi + edx*4 + 16]
	movhps xmm5, [esi + edx*4 + 28]
	
	shufps xmm0, xmm3, 0b11001100
	shufps xmm1, xmm4, 0b11001100
	shufps xmm2, xmm5, 0b11001100
	movaps [esp + _jzO],  xmm0
	movaps [esp + _jzH1],  xmm1
	movaps [esp + _jzH2],  xmm2

	movaps xmm0, [esp + _ixO]
	movaps xmm1, [esp + _iyO]
	movaps xmm2, [esp + _izO]
	movaps xmm3, [esp + _ixO]
	movaps xmm4, [esp + _iyO]
	movaps xmm5, [esp + _izO]
	subps  xmm0, [esp + _jxO]
	subps  xmm1, [esp + _jyO]
	subps  xmm2, [esp + _jzO]
	subps  xmm3, [esp + _jxH1]
	subps  xmm4, [esp + _jyH1]
	subps  xmm5, [esp + _jzH1]
	movaps [esp + _dxOO], xmm0
	movaps [esp + _dyOO], xmm1
	movaps [esp + _dzOO], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxOH1], xmm3
	movaps [esp + _dyOH1], xmm4
	movaps [esp + _dzOH1], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqOO], xmm0
	movaps [esp + _rsqOH1], xmm3

	movaps xmm0, [esp + _ixO]
	movaps xmm1, [esp + _iyO]
	movaps xmm2, [esp + _izO]
	movaps xmm3, [esp + _ixH1]
	movaps xmm4, [esp + _iyH1]
	movaps xmm5, [esp + _izH1]
	subps  xmm0, [esp + _jxH2]
	subps  xmm1, [esp + _jyH2]
	subps  xmm2, [esp + _jzH2]
	subps  xmm3, [esp + _jxO]
	subps  xmm4, [esp + _jyO]
	subps  xmm5, [esp + _jzO]
	movaps [esp + _dxOH2], xmm0
	movaps [esp + _dyOH2], xmm1
	movaps [esp + _dzOH2], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH1O], xmm3
	movaps [esp + _dyH1O], xmm4
	movaps [esp + _dzH1O], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqOH2], xmm0
	movaps [esp + _rsqH1O], xmm3

	movaps xmm0, [esp + _ixH1]
	movaps xmm1, [esp + _iyH1]
	movaps xmm2, [esp + _izH1]
	movaps xmm3, [esp + _ixH1]
	movaps xmm4, [esp + _iyH1]
	movaps xmm5, [esp + _izH1]
	subps  xmm0, [esp + _jxH1]
	subps  xmm1, [esp + _jyH1]
	subps  xmm2, [esp + _jzH1]
	subps  xmm3, [esp + _jxH2]
	subps  xmm4, [esp + _jyH2]
	subps  xmm5, [esp + _jzH2]
	movaps [esp + _dxH1H1], xmm0
	movaps [esp + _dyH1H1], xmm1
	movaps [esp + _dzH1H1], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH1H2], xmm3
	movaps [esp + _dyH1H2], xmm4
	movaps [esp + _dzH1H2], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqH1H1], xmm0
	movaps [esp + _rsqH1H2], xmm3

	movaps xmm0, [esp + _ixH2]
	movaps xmm1, [esp + _iyH2]
	movaps xmm2, [esp + _izH2]
	movaps xmm3, [esp + _ixH2]
	movaps xmm4, [esp + _iyH2]
	movaps xmm5, [esp + _izH2]
	subps  xmm0, [esp + _jxO]
	subps  xmm1, [esp + _jyO]
	subps  xmm2, [esp + _jzO]
	subps  xmm3, [esp + _jxH1]
	subps  xmm4, [esp + _jyH1]
	subps  xmm5, [esp + _jzH1]
	movaps [esp + _dxH2O], xmm0
	movaps [esp + _dyH2O], xmm1
	movaps [esp + _dzH2O], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH2H1], xmm3
	movaps [esp + _dyH2H1], xmm4
	movaps [esp + _dzH2H1], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm4, xmm3
	addps  xmm4, xmm5
	movaps [esp + _rsqH2O], xmm0
	movaps [esp + _rsqH2H1], xmm4

	movaps xmm0, [esp + _ixH2]
	movaps xmm1, [esp + _iyH2]
	movaps xmm2, [esp + _izH2]
	subps  xmm0, [esp + _jxH2]
	subps  xmm1, [esp + _jyH2]
	subps  xmm2, [esp + _jzH2]
	movaps [esp + _dxH2H2], xmm0
	movaps [esp + _dyH2H2], xmm1
	movaps [esp + _dzH2H2], xmm2
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2
	movaps [esp + _rsqH2H2], xmm0
		
	/* start doing invsqrt use rsq values in xmm0, xmm4 */
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] /* rinvH2H2 */
	mulps   xmm7, [esp + _half] /* rinvH2H1 */
	movaps  [esp + _rinvH2H2], xmm3
	movaps  [esp + _rinvH2H1], xmm7
	
	rsqrtps xmm1, [esp + _rsqOO]
	rsqrtps xmm5, [esp + _rsqOH1]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqOO]
	mulps   xmm5, [esp + _rsqOH1]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvOO], xmm3
	movaps  [esp + _rinvOH1], xmm7
	
	rsqrtps xmm1, [esp + _rsqOH2]
	rsqrtps xmm5, [esp + _rsqH1O]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqOH2]
	mulps   xmm5, [esp + _rsqH1O]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvOH2], xmm3
	movaps  [esp + _rinvH1O], xmm7
	
	rsqrtps xmm1, [esp + _rsqH1H1]
	rsqrtps xmm5, [esp + _rsqH1H2]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqH1H1]
	mulps   xmm5, [esp + _rsqH1H2]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvH1H1], xmm3
	movaps  [esp + _rinvH1H2], xmm7
	
	rsqrtps xmm1, [esp + _rsqH2O]
	movaps  xmm2, xmm1
	mulps   xmm1, xmm1
	movaps  xmm3, [esp + _three]
	mulps   xmm1, [esp + _rsqH2O]
	subps   xmm3, xmm1
	mulps   xmm3, xmm2
	mulps   xmm3, [esp + _half] 
	movaps  [esp + _rinvH2O], xmm3

	/* start with OO interaction */
	movaps xmm0, [esp + _rinvOO]
	movaps xmm7, xmm0
	mulps  xmm0, xmm0
	mulps  xmm7, [esp + _qqOO]
	mulps  xmm0, xmm7	
	addps  xmm7, [esp + _vctot] 
	movaps xmm1, xmm0
	movaps xmm2, xmm0

	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOO]
	mulps xmm1, [esp + _dyOO]
	mulps xmm2, [esp + _dzOO]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* O-H1 interaction */
	movaps xmm0, [esp + _rinvOH1]
	movaps xmm1, xmm0
	mulps xmm0, xmm0
	mulps xmm1, [esp + _qqOH]
	mulps xmm0, xmm1	/* fsOH1  */
	addps xmm7, xmm1	/* add to local vctot */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	
	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOH1]
	mulps xmm1, [esp + _dyOH1]
	mulps xmm2, [esp + _dzOH1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* O-H2 interaction */ 
	movaps xmm0, [esp + _rinvOH2]
	movaps xmm1, xmm0
	mulps xmm0, xmm0
	mulps xmm1, [esp + _qqOH]
	mulps xmm0, xmm1	/* fsOH2 */ 
	addps xmm7, xmm1	/* add to local vctot */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	
	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOH2]
	mulps xmm1, [esp + _dyOH2]
	mulps xmm2, [esp + _dzOH2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* H1-O interaction */
	movaps xmm0, [esp + _rinvH1O]
	movaps xmm1, xmm0
	mulps xmm0, xmm0
	mulps xmm1, [esp + _qqOH]
	mulps xmm0, xmm1	/* fsH1O */
	addps xmm7, xmm1	/* add to local vctot */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	movaps xmm3, [esp + _fjxO]
	movaps xmm4, [esp + _fjyO]
	movaps xmm5, [esp + _fjzO]
	mulps xmm0, [esp + _dxH1O]
	mulps xmm1, [esp + _dyH1O]
	mulps xmm2, [esp + _dzH1O]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H1-H1 interaction */
	movaps xmm0, [esp + _rinvH1H1]
	movaps xmm1, xmm0
	mulps xmm0, xmm0
	mulps xmm1, [esp + _qqHH]
	mulps xmm0, xmm1	/* fsH1H1 */
	addps xmm7, xmm1	/* add to local vctot */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	movaps xmm3, [esp + _fjxH1]
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	mulps xmm0, [esp + _dxH1H1]
	mulps xmm1, [esp + _dyH1H1]
	mulps xmm2, [esp + _dzH1H1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H1-H2 interaction */
	movaps xmm0, [esp + _rinvH1H2]
	movaps xmm1, xmm0
	mulps xmm0, xmm0
	mulps xmm1, [esp + _qqHH]
	mulps xmm0, xmm1	/* fsOH2 */ 
	addps xmm7, xmm1	/* add to local vctot */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	movaps xmm3, [esp + _fjxH2]
	movaps xmm4, [esp + _fjyH2]
	movaps xmm5, [esp + _fjzH2]
	mulps xmm0, [esp + _dxH1H2]
	mulps xmm1, [esp + _dyH1H2]
	mulps xmm2, [esp + _dzH1H2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H2-O interaction */
	movaps xmm0, [esp + _rinvH2O]
	movaps xmm1, xmm0
	mulps xmm0, xmm0
	mulps xmm1, [esp + _qqOH]
	mulps xmm0, xmm1	/* fsH2O */
	addps xmm7, xmm1	/* add to local vctot */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	movaps xmm3, [esp + _fjxO]
	movaps xmm4, [esp + _fjyO]
	movaps xmm5, [esp + _fjzO]
	mulps xmm0, [esp + _dxH2O]
	mulps xmm1, [esp + _dyH2O]
	mulps xmm2, [esp + _dzH2O]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	/* H2-H1 interaction */
	movaps xmm0, [esp + _rinvH2H1]
	movaps xmm1, xmm0
	mulps xmm0, xmm0
	mulps xmm1, [esp + _qqHH]
	mulps xmm0, xmm1	/* fsH2H1 */
	addps xmm7, xmm1	/* add to local vctot */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	movaps xmm3, [esp + _fjxH1]
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	mulps xmm0, [esp + _dxH2H1]
	mulps xmm1, [esp + _dyH2H1]
	mulps xmm2, [esp + _dzH2H1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	/* H2-H2 interaction */
	movaps xmm0, [esp + _rinvH2H2]
	movaps xmm1, xmm0
	mulps xmm0, xmm0
	mulps xmm1, [esp + _qqHH]
	mulps xmm0, xmm1	/* fsH2H2 */
	addps xmm7, xmm1	/* add to local vctot */
	movaps xmm1, xmm0
	movaps [esp + _vctot], xmm7
	movaps xmm2, xmm0
	movaps xmm3, [esp + _fjxH2]
	movaps xmm4, [esp + _fjyH2]
	movaps xmm5, [esp + _fjzH2]
	mulps xmm0, [esp + _dxH2H2]
	mulps xmm1, [esp + _dyH2H2]
	mulps xmm2, [esp + _dzH2H2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	mov edi, [ebp + _faction]
		
	/* Did all interactions - now update j forces */
	/* 4 j waters with three atoms each - first do a & b j particles */
	movaps xmm0, [esp + _fjxO] /* xmm0= fjxOa  fjxOb  fjxOc  fjxOd */
	movaps xmm1, [esp + _fjyO] /* xmm1= fjyOa  fjyOb  fjyOc  fjyOd */ 
	unpcklps xmm0, xmm1    	   /* xmm0= fjxOa  fjyOa  fjxOb  fjyOb */
	movaps xmm1, [esp + _fjzO]
	movaps xmm2, [esp + _fjxH1]
	movhlps  xmm3, xmm0	   /* xmm3= fjxOb  fjyOb */ 
	unpcklps xmm1, xmm2	   /* xmm1= fjzOa  fjxH1a fjzOb  fjxH1b */
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	unpcklps xmm4, xmm5	   /* xmm4= fjyH1a fjzH1a fjyH1b fjzH1b */
	movaps xmm5, [esp + _fjxH2]
	movaps xmm6, [esp + _fjyH2]
	movhlps  xmm7, xmm4	   /* xmm7= fjyH1b fjzH1b */
	unpcklps xmm5, xmm6	   /* xmm5= fjxH2a fjyH2a fjxH2b fjyH2b */
	movlhps  xmm0, xmm1    	   /* xmm0= fjxOa  fjyOa  fjzOa  fjxH1a */
	shufps   xmm3, xmm1, 0b11100100
                                   /* xmm3= fjxOb  fjyOb  fjzOb  fjxH1b */
	movlhps  xmm4, xmm5   	   /* xmm4= fjyH1a fjzH1a fjxH2a fjyH2a */
	shufps   xmm7, xmm5, 0b11100100
                                   /* xmm7= fjyH1b fjzH1b fjxH2b fjyH2b */
	movups   xmm1, [edi + eax*4]
	movups   xmm2, [edi + eax*4 + 16]
	movups   xmm5, [edi + ebx*4]
	movups   xmm6, [edi + ebx*4 + 16]
	addps    xmm1, xmm0
	addps    xmm2, xmm4
	addps    xmm5, xmm3
	addps    xmm6, xmm7
	movss    xmm0, [edi + eax*4 + 32]
	movss    xmm3, [edi + ebx*4 + 32]
	
	movaps   xmm4, [esp + _fjzH2]
	movaps   xmm7, xmm4
	shufps   xmm7, xmm7, 1
	
	movups   [edi + eax*4],     xmm1
	movups   [edi + eax*4 + 16],xmm2
	movups   [edi + ebx*4],     xmm5
	movups   [edi + ebx*4 + 16],xmm6	
	addss    xmm0, xmm4
	addss    xmm3, xmm7
	movss    [edi + eax*4 + 32], xmm0
	movss    [edi + ebx*4 + 32], xmm3	

	/* then do the second pair (c & d) */
	movaps xmm0, [esp + _fjxO] /* xmm0= fjxOa  fjxOb  fjxOc  fjxOd */
	movaps xmm1, [esp + _fjyO] /* xmm1= fjyOa  fjyOb  fjyOc  fjyOd */ 
	unpckhps xmm0, xmm1	   /* xmm0= fjxOc  fjyOc  fjxOd  fjyOd */
	movaps xmm1, [esp + _fjzO]
	movaps xmm2, [esp + _fjxH1]
	movhlps  xmm3, xmm0	   /* xmm3= fjxOd  fjyOd */ 
	unpckhps xmm1, xmm2	   /* xmm1= fjzOc  fjxH1c fjzOd  fjxH1d */
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	unpckhps xmm4, xmm5	   /* xmm4= fjyH1c fjzH1c fjyH1d fjzH1d	*/
	movaps xmm5, [esp + _fjxH2]
	movaps xmm6, [esp + _fjyH2]
	movhlps  xmm7, xmm4	   /* xmm7= fjyH1d fjzH1d */	 
	unpckhps xmm5, xmm6	   /* xmm5= fjxH2c fjyH2c fjxH2d fjyH2d */
	movlhps  xmm0, xmm1	   /* xmm0= fjxOc  fjyOc  fjzOc  fjxH1c */
	shufps   xmm3, xmm1, 0b11100100
                                   /* xmm3= fjxOd  fjyOd  fjzOd  fjxH1d */
	movlhps  xmm4, xmm5	   /* xmm4= fjyH1c fjzH1c fjxH2c fjyH2c  */
	shufps   xmm7, xmm5, 0b11100100
                                   /* xmm7= fjyH1d fjzH1d fjxH2d fjyH2d */
	movups   xmm1, [edi + ecx*4]
	movups   xmm2, [edi + ecx*4 + 16]
	movups   xmm5, [edi + edx*4]
	movups   xmm6, [edi + edx*4 + 16]
	addps    xmm1, xmm0
	addps    xmm2, xmm4
	addps    xmm5, xmm3
	addps    xmm6, xmm7
	movss    xmm0, [edi + ecx*4 + 32]
	movss    xmm3, [edi + edx*4 + 32]
	
	movaps   xmm4, [esp + _fjzH2]
	movaps   xmm7, xmm4
	shufps   xmm4, xmm4, 0b10
	shufps   xmm7, xmm7, 0b11
	movups   [edi + ecx*4],     xmm1
	movups   [edi + ecx*4 + 16],xmm2
	movups   [edi + edx*4],     xmm5
	movups   [edi + edx*4 + 16],xmm6	
	addss    xmm0, xmm4
	addss    xmm3, xmm7
	movss    [edi + ecx*4 + 32], xmm0
	movss    [edi + edx*4 + 32], xmm3	
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    i1030_single_check
	jmp   i1030_unroll_loop
i1030_single_check:
	add   [esp + _innerk],  4
	jnz   i1030_single_loop
	jmp   i1030_updateouterdata
i1030_single_loop:
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	add   [esp + _innerjjnr],  4	

	mov esi, [ebp + _pos]
	lea   eax, [eax + eax*2]  

	/* fetch j coordinates */
	xorps xmm3, xmm3
	xorps xmm4, xmm4
	xorps xmm5, xmm5
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + eax*4 + 4]
	movss xmm5, [esi + eax*4 + 8]

	movlps xmm6, [esi + eax*4 + 12]
	movhps xmm6, [esi + eax*4 + 24]	/* xmm6=jxH1 jyH1 jxH2 jyH2 */
	/* fetch both z coords in one go, to positions 0 and 3 in xmm7 */
	movups xmm7, [esi + eax*4 + 20] /* xmm7=jzH1 jxH2 jyH2 jzH2 */
	shufps xmm6, xmm6, 0b11011000    /* xmm6=jxH1 jxH2 jyH1 jyH2 */
	movlhps xmm3, xmm6      	/* xmm3= jxO   0  jxH1 jxH2 */
	movaps  xmm0, [esp + _ixO]     
	movaps  xmm1, [esp + _iyO]
	movaps  xmm2, [esp + _izO]	
	shufps  xmm4, xmm6, 0b11100100 /* xmm4= jyO   0   jyH1 jyH2 */
	shufps xmm5, xmm7, 0b11000100  /* xmm5= jzO   0   jzH1 jzH2 */
	/* store all j coordinates in jO */ 
	movaps [esp + _jxO], xmm3
	movaps [esp + _jyO], xmm4
	movaps [esp + _jzO], xmm5
	subps  xmm0, xmm3
	subps  xmm1, xmm4
	subps  xmm2, xmm5
	movaps [esp + _dxOO], xmm0
	movaps [esp + _dyOO], xmm1
	movaps [esp + _dzOO], xmm2
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2	/* have rsq in xmm0 */
	
	/* do invsqrt */
	rsqrtps xmm1, xmm0
	movaps  xmm2, xmm1	
	mulps   xmm1, xmm1
	movaps  xmm3, [esp + _three]
	mulps   xmm1, xmm0
	subps   xmm3, xmm1
	mulps   xmm3, xmm2							
	mulps   xmm3, [esp + _half] /* rinv iO - j water */

	xorps   xmm1, xmm1
	movaps  xmm0, xmm3
	xorps   xmm4, xmm4
	mulps   xmm0, xmm0	/* xmm0=rinvsq */
	/* fetch charges to xmm4 (temporary) */
	movss   xmm4, [esp + _qqOO]

	movhps  xmm4, [esp + _qqOH]

	mulps   xmm3, xmm4	/* xmm3=vcoul */
	mulps   xmm0, xmm3	/* total fscal */
	addps   xmm3, [esp + _vctot]
	movaps  [esp + _vctot], xmm3	

	movaps  xmm1, xmm0
	movaps  xmm2, xmm0
	mulps   xmm0, [esp + _dxOO]
	mulps   xmm1, [esp + _dyOO]
	mulps   xmm2, [esp + _dzOO]
	/* initial update for j forces */
	xorps   xmm3, xmm3
	xorps   xmm4, xmm4
	xorps   xmm5, xmm5
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixO]
	addps   xmm1, [esp + _fiyO]
	addps   xmm2, [esp + _fizO]
	movaps  [esp + _fixO], xmm0
	movaps  [esp + _fiyO], xmm1
	movaps  [esp + _fizO], xmm2

	
	/* done with i O Now do i H1 & H2 simultaneously first get i particle coords: */
	movaps  xmm0, [esp + _ixH1]
	movaps  xmm1, [esp + _iyH1]
	movaps  xmm2, [esp + _izH1]	
	movaps  xmm3, [esp + _ixH2] 
	movaps  xmm4, [esp + _iyH2] 
	movaps  xmm5, [esp + _izH2] 
	subps   xmm0, [esp + _jxO]
	subps   xmm1, [esp + _jyO]
	subps   xmm2, [esp + _jzO]
	subps   xmm3, [esp + _jxO]
	subps   xmm4, [esp + _jyO]
	subps   xmm5, [esp + _jzO]
	movaps [esp + _dxH1O], xmm0
	movaps [esp + _dyH1O], xmm1
	movaps [esp + _dzH1O], xmm2
	movaps [esp + _dxH2O], xmm3
	movaps [esp + _dyH2O], xmm4
	movaps [esp + _dzH2O], xmm5
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	mulps xmm3, xmm3
	mulps xmm4, xmm4
	mulps xmm5, xmm5
	addps xmm0, xmm1
	addps xmm4, xmm3
	addps xmm0, xmm2	/* have rsqH1 in xmm0 */
	addps xmm4, xmm5	/* have rsqH2 in xmm4 */

	/* do invsqrt */
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] /* rinv H1 - j water */
	mulps   xmm7, [esp + _half] /* rinv H2 - j water */ 

	/* assemble charges in xmm6 */
	xorps   xmm6, xmm6
	/* do coulomb interaction */
	movaps  xmm0, xmm3
	movss   xmm6, [esp + _qqOH]
	movaps  xmm4, xmm7
	movhps  xmm6, [esp + _qqHH]
	mulps   xmm0, xmm0	/* rinvsq */
	mulps   xmm4, xmm4	/* rinvsq */
	mulps   xmm3, xmm6	/* vcoul */
	mulps   xmm7, xmm6	/* vcoul */
	movaps  xmm2, xmm3
	addps   xmm2, xmm7	/* total vcoul */
	mulps   xmm0, xmm3	/* fscal */
	
	addps   xmm2, [esp + _vctot]
	mulps   xmm7, xmm4	/* fscal */
	movaps  [esp + _vctot], xmm2
	movaps  xmm1, xmm0
	movaps  xmm2, xmm0
	mulps   xmm0, [esp + _dxH1O]
	mulps   xmm1, [esp + _dyH1O]
	mulps   xmm2, [esp + _dzH1O]
	/* update forces H1 - j water */
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixH1]
	addps   xmm1, [esp + _fiyH1]
	addps   xmm2, [esp + _fizH1]
	movaps  [esp + _fixH1], xmm0
	movaps  [esp + _fiyH1], xmm1
	movaps  [esp + _fizH1], xmm2
	/* do forces H2 - j water */
	movaps xmm0, xmm7
	movaps xmm1, xmm7
	movaps xmm2, xmm7
	mulps   xmm0, [esp + _dxH2O]
	mulps   xmm1, [esp + _dyH2O]
	mulps   xmm2, [esp + _dzH2O]
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	mov     esi, [ebp + _faction]
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixH2]
	addps   xmm1, [esp + _fiyH2]
	addps   xmm2, [esp + _fizH2]
	movaps  [esp + _fixH2], xmm0
	movaps  [esp + _fiyH2], xmm1
	movaps  [esp + _fizH2], xmm2

	/* update j water forces from local variables */
	movlps  xmm0, [esi + eax*4]
	movlps  xmm1, [esi + eax*4 + 12]
	movhps  xmm1, [esi + eax*4 + 24]
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	movaps  xmm6, xmm5
	movaps  xmm7, xmm5
	shufps  xmm6, xmm6, 0b10
	shufps  xmm7, xmm7, 0b11
	addss   xmm5, [esi + eax*4 + 8]
	addss   xmm6, [esi + eax*4 + 20]
	addss   xmm7, [esi + eax*4 + 32]
	movss   [esi + eax*4 + 8], xmm5
	movss   [esi + eax*4 + 20], xmm6
	movss   [esi + eax*4 + 32], xmm7
	movaps   xmm5, xmm3
	unpcklps xmm3, xmm4
	unpckhps xmm5, xmm4
	addps    xmm0, xmm3
	addps    xmm1, xmm5
	movlps  [esi + eax*4], xmm0 
	movlps  [esi + eax*4 + 12], xmm1 
	movhps  [esi + eax*4 + 24], xmm1 
	
	dec   dword ptr [esp + _innerk]
	jz    i1030_updateouterdata
	jmp   i1030_single_loop
i1030_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate Oi forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixO]
	movaps xmm1, [esp + _fiyO] 
	movaps xmm2, [esp + _fizO]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	movaps xmm6, xmm0
	movss xmm7, xmm2
	movlhps xmm6, xmm1
	shufps  xmm6, xmm6, 0b1000	

	/* accumulate H1i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH1]
	movaps xmm1, [esp + _fiyH1]
	movaps xmm2, [esp + _fizH1]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 12]
	movss  xmm4, [edi + ecx*4 + 16]
	movss  xmm5, [edi + ecx*4 + 20]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 12], xmm3
	movss  [edi + ecx*4 + 16], xmm4
	movss  [edi + ecx*4 + 20], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* accumulate H2i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH2]
	movaps xmm1, [esp + _fiyH2]
	movaps xmm2, [esp + _fizH2]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 24]
	movss  xmm4, [edi + ecx*4 + 28]
	movss  xmm5, [edi + ecx*4 + 32]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 24], xmm3
	movss  [edi + ecx*4 + 28], xmm4
	movss  [edi + ecx*4 + 32], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* increment fshift force */ 
	movlps  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 8]
	addps  xmm3, xmm6
	addss  xmm4, xmm7
	movlps  [esi + edx*4],    xmm3
	movss  [esi + edx*4 + 8], xmm4

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 	

	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz i1030_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp i1030_outer
i1030_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 1412
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret







.globl inl1100_sse
	.type inl1100_sse,@function
inl1100_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_type,		60
.equ		_ntype,		64
.equ		_nbfp,		68	
.equ		_Vnb,		72	
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ix,	        0
.equ		_iy,	        16
.equ		_iz,            32
.equ		_iq,            48
.equ		_dx,            64
.equ		_dy,            80
.equ		_dz,            96	
.equ		_c6,            112
.equ		_c12,           128
.equ		_six,           144
.equ		_twelve,        160		 
.equ		_vctot,         176
.equ		_vnbtot,        192
.equ		_fix,           208
.equ		_fiy,           224
.equ		_fiz,           240
.equ		_half,          256
.equ		_three,         272
.equ		_is3,           288
.equ		_ii3,           292
.equ		_ntia,	        296	
.equ		_innerjjnr,     300
.equ		_innerk,        304
.equ		_salign,        308								
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp,  312		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_three]
	movups xmm2, [sse_six]
	movups xmm3, [sse_twelve]
	movaps [esp + _half],  xmm0
	movaps [esp + _three], xmm1
	movaps [esp + _six],  xmm2
	movaps [esp + _twelve], xmm3

	/* assume we have at least one i particle - start directly */	
i1100_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	mulss xmm3, [ebp + _facel]
	shufps xmm3, xmm3, 0

        mov   edx, [ebp + _type] 
        mov   edx, [edx + ebx*4]
        imul  edx, [ebp + _ntype]
        shl   edx, 1
        mov   [esp + _ntia], edx
		
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]

	movaps [esp + _iq], xmm3
	
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   [esp + _ii3], ebx
	
	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _vnbtot], xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   i1100_unroll_loop
	jmp   i1100_finish_inner
i1100_unroll_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	movaps xmm2, [esp + _iq]
	shufps xmm3, xmm6, 0
	shufps xmm4, xmm7, 0
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	movd  mm2, ecx
	movd  mm3, edx
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	mulps xmm3, xmm2
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	movaps xmm1, xmm4
	mulps  xmm1, xmm4
	mulps  xmm1, xmm4	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */
	mulps  xmm3, xmm0	/* xmm3=vcoul */
	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	addps  xmm2, xmm3
	mulps  xmm4, xmm2	/* xmm4=total fscal */
	addps  xmm3, [esp + _vctot]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vctot], xmm3
	movaps [esp + _vnbtot], xmm5

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    i1100_finish_inner
	jmp   i1100_unroll_loop
i1100_finish_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   i1100_dopair
	jmp   i1100_checksingle
i1100_dopair:	
	mov esi, [ebp + _charge]

        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8

	xorps xmm3, xmm3
	movss xmm3, [esi + eax*4]		
	movss xmm6, [esi + ebx*4]
	shufps xmm3, xmm6, 0b00001100 
	shufps xmm3, xmm3, 0b01011000 /* xmm3(0,1) has the charges */

	mov esi, [ebp + _type]
	mov   ecx, eax
	mov   edx, ebx
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add ecx, edi
	add edx, edi
	movlps xmm6, [esi + ecx*4]
	movhps xmm6, [esi + edx*4]
	mov edi, [ebp + _pos]	
	xorps  xmm7,xmm7
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b1000 	
	shufps xmm6, xmm6, 0b1101
	movlhps xmm4, xmm7
	movlhps xmm6, xmm7
	
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
			
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	mulps  xmm3, [esp + _iq]

	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	movaps xmm1, xmm4
	mulps  xmm1, xmm4
	mulps  xmm1, xmm4	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */

	mulps  xmm3, xmm0	/* xmm3=vcoul */
	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	addps  xmm2, xmm3
	mulps  xmm4, xmm2	/* xmm4=total fscal */
	addps  xmm3, [esp + _vctot]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vctot], xmm3
	movaps [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

i1100_checksingle:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    i1100_dosingle
	jmp    i1100_updateouterdata
i1100_dosingle:			
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	xorps xmm3, xmm3
	mov   eax, [ecx]
	movss xmm3, [esi + eax*4]	/* xmm3(0) has the charge */	

	mov esi, [ebp + _type]
	mov ecx, eax
	mov ecx, [esi + ecx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1
	add ecx, [esp + _ntia]
	xorps  xmm6, xmm6
	movlps xmm6, [esi + ecx*4]
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b11111100	
	shufps xmm6, xmm6, 0b11111101	
			
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	
 
	mulps  xmm3, [esp + _iq]
	
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	movaps xmm1, xmm4
	mulps  xmm1, xmm4
	mulps  xmm1, xmm4	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */
	mulps  xmm3, xmm0	/* xmm3=vcoul */
	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addss  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	addps  xmm2, xmm3
	mulps  xmm4, xmm2	/* xmm4=total fscal */
	addss  xmm3, [esp + _vctot]
	
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movss [esp + _vctot], xmm3
	movss [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
i1100_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz i1100_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp i1100_outer
i1100_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp,  312
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret




.globl inl2100_sse
	.type inl2100_sse,@function
inl2100_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_argkrf,	60	
.equ		_argcrf,	64	
.equ		_type,		68
.equ		_ntype,		72
.equ		_nbfp,		76	
.equ		_Vnb,		80	
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ix,	        0
.equ		_iy,	        16
.equ		_iz,            32
.equ		_iq,            48
.equ		_dx,            64
.equ		_dy,            80
.equ		_dz,            96	
.equ		_c6,            112
.equ		_c12,           128
.equ		_six,           144
.equ		_twelve,        160		 
.equ		_vctot,         176
.equ		_vnbtot,        192
.equ		_fix,           208
.equ		_fiy,           224
.equ		_fiz,           240
.equ		_half,          256
.equ		_three,         272
.equ		_two,           288
.equ		_krf,		304	 
.equ		_crf,		320	 
.equ		_is3,           336
.equ		_ii3,           340
.equ		_ntia,	        344
.equ		_innerjjnr,     348
.equ		_innerk,        352
.equ		_salign,        356								
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp,  360		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_three]
	movups xmm2, [sse_six]
	movups xmm3, [sse_twelve]
	movups xmm4, [sse_two]
	movss xmm5, [ebp + _argkrf]
	movss xmm6, [ebp + _argcrf]
	
	movaps [esp + _half],  xmm0
	movaps [esp + _three], xmm1
	movaps [esp + _six],  xmm2
	movaps [esp + _twelve], xmm3
	movaps [esp + _two], xmm4
	shufps xmm5, xmm5, 0
	shufps xmm6, xmm6, 0
	movaps [esp + _krf], xmm5
	movaps [esp + _crf], xmm6

	/* assume we have at least one i particle - start directly */	
.i2100_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	mulss xmm3, [ebp + _facel]
	shufps xmm3, xmm3, 0

        mov   edx, [ebp + _type] 
        mov   edx, [edx + ebx*4]
        imul  edx, [ebp + _ntype]
        shl   edx, 1
        mov   [esp + _ntia], edx
		
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]

	movaps [esp + _iq], xmm3
	
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   [esp + _ii3], ebx
	
	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _vnbtot], xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i2100_unroll_loop
	jmp   .i2100_finish_inner
.i2100_unroll_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	movaps xmm2, [esp + _iq]
	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	movd  mm2, ecx
	movd  mm3, edx
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	mulps xmm3, xmm2
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */
	
	movaps xmm7, [esp + _krf]
	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	mulps  xmm7, xmm4	/* xmm7=krsq */
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	movaps xmm6, xmm0
	addps  xmm6, xmm7	/* xmm6=rinv+ krsq */
	movaps xmm1, xmm4
	subps  xmm6, [esp + _crf]
	mulps  xmm1, xmm4
	mulps  xmm1, xmm4	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */
	mulps  xmm6, xmm3	/* xmm6=vcoul=qq*(rinv+ krsq) */
	mulps  xmm7, [esp + _two]
	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	subps  xmm0, xmm7
	mulps  xmm3, xmm0
	addps  xmm2, xmm3
	mulps  xmm4, xmm2	/* xmm4=total fscal */
	addps  xmm6, [esp + _vctot]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vctot], xmm6
	movaps [esp + _vnbtot], xmm5

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i2100_finish_inner
	jmp   .i2100_unroll_loop
.i2100_finish_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i2100_dopair
	jmp   .i2100_checksingle
.i2100_dopair:	
	mov esi, [ebp + _charge]

        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8

	xorps xmm3, xmm3
	movss xmm3, [esi + eax*4]		
	movss xmm6, [esi + ebx*4]
	shufps xmm3, xmm6, 0b00001100 
	shufps xmm3, xmm3, 0b01011000 /* xmm3(0,1) has the charges */

	mov esi, [ebp + _type]
	mov   ecx, eax
	mov   edx, ebx
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add ecx, edi
	add edx, edi
	movlps xmm6, [esi + ecx*4]
	movhps xmm6, [esi + edx*4]
	mov edi, [ebp + _pos]	
	xorps  xmm7,xmm7
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b1000 	
	shufps xmm6, xmm6, 0b1101
	movlhps xmm4, xmm7
	movlhps xmm6, xmm7
	
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
			
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	mulps  xmm3, [esp + _iq]

	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	movaps xmm7, [esp + _krf]
	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	mulps  xmm7, xmm4	/* xmm7=krsq */
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	movaps xmm6, xmm0
	addps  xmm6, xmm7	/* xmm6=rinv+ krsq */
	movaps xmm1, xmm4
	subps  xmm6, [esp + _crf]
	mulps  xmm1, xmm4
	mulps  xmm1, xmm4	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */
	mulps  xmm6, xmm3	/* xmm6=vcoul=qq*(rinv+ krsq-crf) */
	mulps  xmm7, [esp + _two]	
	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	subps  xmm0, xmm7
	mulps  xmm3, xmm0	
	addps  xmm2, xmm3
	mulps  xmm4, xmm2	/* xmm4=total fscal */
	addps  xmm6, [esp + _vctot]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vctot], xmm6
	movaps [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i2100_checksingle:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    .i2100_dosingle
	jmp    .i2100_updateouterdata
.i2100_dosingle:			
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	xorps xmm3, xmm3
	mov   eax, [ecx]
	movss xmm3, [esi + eax*4]	/* xmm3(0) has the charge */	

	mov esi, [ebp + _type]
	mov ecx, eax
	mov ecx, [esi + ecx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1
	add ecx, [esp + _ntia]
	xorps  xmm6, xmm6
	movlps xmm6, [esi + ecx*4]
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b11111100	
	shufps xmm6, xmm6, 0b11111101	
			
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	
 
	mulps  xmm3, [esp + _iq]
	
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	movaps xmm7, [esp + _krf]
	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	mulps  xmm7, xmm4	/* xmm7=krsq */
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	movaps xmm6, xmm0
	addps  xmm6, xmm7	/* xmm6=rinv+ krsq */
	movaps xmm1, xmm4
	subps  xmm6, [esp + _crf]	
	mulps  xmm1, xmm4
	mulps  xmm1, xmm4	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */
	mulps  xmm6, xmm3	/* xmm6=vcoul */
	mulps  xmm7, [esp + _two]
	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addss  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	subps  xmm0, xmm7
	mulps  xmm3, xmm0
	addps  xmm2, xmm3
	mulps  xmm4, xmm2	/* xmm4=total fscal */
	addss  xmm6, [esp + _vctot]
	
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movss [esp + _vctot], xmm6
	movss [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
.i2100_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i2100_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i2100_outer
.i2100_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp,  360
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret



.globl inl2000_sse
	.type inl2000_sse,@function
inl2000_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_argkrf,	60	
.equ		_argcrf,	64
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ix,	        0
.equ		_iy,	        16
.equ		_iz,            32
.equ		_iq,            48
.equ		_dx,            64
.equ		_dy,            80
.equ		_dz,            96	
.equ		_vctot,         112
.equ		_fix,           128
.equ		_fiy,           144
.equ		_fiz,           160
.equ		_half,          176
.equ		_three,         192
.equ		_two,           208
.equ		_krf,	        224	 
.equ		_crf,	        240	 
.equ		_is3,           256
.equ		_ii3,           260
.equ		_innerjjnr,     264
.equ		_innerk,        268
.equ		_salign,	272								
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp,  276		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_three]
	movups xmm4, [sse_two]
	movss xmm5, [ebp + _argkrf]
	movss xmm6, [ebp + _argcrf]
	
	movaps [esp + _half],  xmm0
	movaps [esp + _three], xmm1
	movaps [esp + _two], xmm4
	shufps xmm5, xmm5, 0
	movaps [esp + _krf], xmm5
	shufps xmm6, xmm6, 0
	movaps [esp + _crf], xmm6

	/* assume we have at least one i particle - start directly */	
.i2000_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	mulss xmm3, [ebp + _facel]
	shufps xmm3, xmm3, 0
		
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]

	movaps [esp + _iq], xmm3
	
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   [esp + _ii3], ebx
	
	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i2000_unroll_loop
	jmp   .i2000_finish_inner
.i2000_unroll_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	movaps xmm2, [esp + _iq]
	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 

	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	mulps xmm3, xmm2
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */
	
	movaps xmm7, [esp + _krf]
	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	mulps  xmm7, xmm4	/* xmm7=krsq */
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	movaps xmm6, xmm0
	addps  xmm6, xmm7	/* xmm6=rinv+ krsq */

	subps  xmm6, [esp + _crf] /* xmm6=rinv+ krsq-crf */

	mulps  xmm6, xmm3	/* xmm6=vcoul=qq*(rinv+ krsq) */
	mulps  xmm7, [esp + _two]

	subps  xmm0, xmm7
	mulps  xmm3, xmm0	
	mulps  xmm4, xmm3	/* xmm4=total fscal */
	addps  xmm6, [esp + _vctot]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vctot], xmm6

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i2000_finish_inner
	jmp   .i2000_unroll_loop
.i2000_finish_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i2000_dopair
	jmp   .i2000_checksingle
.i2000_dopair:	
	mov esi, [ebp + _charge]

        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8

	xorps xmm3, xmm3
	movss xmm3, [esi + eax*4]		
	movss xmm6, [esi + ebx*4]
	shufps xmm3, xmm6, 0b00001100 
	shufps xmm3, xmm3, 0b01011000 /* xmm3(0,1) has the charges */	

	mov edi, [ebp + _pos]	
				
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	mulps  xmm3, [esp + _iq]

	xorps  xmm7,xmm7
	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move ix-iz to xmm4-xmm6 */
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	movaps xmm7, [esp + _krf]
	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	mulps  xmm7, xmm4	/* xmm7=krsq */
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	movaps xmm6, xmm0
	addps  xmm6, xmm7	/* xmm6=rinv+ krsq */

	subps  xmm6, [esp + _crf] /* xmm6=rinv+ krsq-crf */

	mulps  xmm6, xmm3	/* xmm6=vcoul=qq*(rinv+ krsq-crf) */
	mulps  xmm7, [esp + _two]	

	subps  xmm0, xmm7
	mulps  xmm3, xmm0	

	mulps  xmm4, xmm3	/* xmm4=total fscal */
	addps  xmm6, [esp + _vctot]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vctot], xmm6

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i2000_checksingle:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    .i2000_dosingle
	jmp    .i2000_updateouterdata
.i2000_dosingle:			
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	xorps xmm3, xmm3
	mov   eax, [ecx]
	movss xmm3, [esi + eax*4]	/* xmm3(0) has the charge */		
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	
 
	mulps  xmm3, [esp + _iq]
	
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	movaps xmm7, [esp + _krf]
	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	mulps  xmm7, xmm4	/* xmm7=krsq */
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	movaps xmm6, xmm0
	addps  xmm6, xmm7	/* xmm6=rinv+ krsq */

	subps  xmm6, [esp + _crf] /* xmm6=rinv+ krsq-crf */

	mulps  xmm6, xmm3	/* xmm6=vcoul */
	mulps  xmm7, [esp + _two]

	subps  xmm0, xmm7
	mulps  xmm3, xmm0
	mulps  xmm4, xmm3	/* xmm4=total fscal */
	addss  xmm6, [esp + _vctot]
	
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movss [esp + _vctot], xmm6

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
.i2000_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i2000_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i2000_outer
.i2000_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp,  276
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret





.globl inl1110_sse
	.type inl1110_sse,@function
inl1110_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_type,		60
.equ		_ntype,		64
.equ		_nbfp,		68	
.equ		_Vnb,		72	
.equ		_nsatoms,       76		
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ix,	        0
.equ		_iy,	        16
.equ		_iz,            32
.equ		_iq,            48
.equ		_dx,            64
.equ		_dy,            80
.equ		_dz,            96	
.equ		_c6,            112
.equ		_c12,           128
.equ		_two,           144
.equ		_six,           160
.equ		_twelve,        176		 
.equ		_vctot,         192
.equ		_vnbtot,        208
.equ		_fix,           224
.equ		_fiy,           240
.equ		_fiz,           256
.equ		_half,          272
.equ		_three,         288
.equ		_is3,           304
.equ		_ii3,           308
.equ		_shX,	        312
.equ		_shY,           316
.equ		_shZ,           320
.equ		_ntia,	        324	
.equ		_innerjjnr0,    328
.equ		_innerk0,       332
.equ		_innerjjnr,     336
.equ		_innerk,        340
.equ		_salign,	344
.equ		_nsvdwc,        348
.equ		_nscoul,        352
.equ		_nsvdw,         356
.equ		_solnr,	        360		
	push ebp
	mov ebp,esp	
	push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 364		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_two]
	movups xmm2, [sse_three]
	movups xmm3, [sse_six]
	movups xmm4, [sse_twelve]
	movaps [esp + _half],  xmm0
	movaps [esp + _two], xmm1
	movaps [esp + _three], xmm2
	movaps [esp + _six],  xmm3
	movaps [esp + _twelve], xmm4

	/* assume we have at least one i particle - start directly */	
i1110_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movlps xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 8] 
	movlps [esp + _shX], xmm0
	movss [esp + _shZ], xmm1

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   eax, [ebp + _nsatoms]
	add   [ebp + _nsatoms],  12
	mov   ecx, [eax]	
	mov   edx, [eax + 4]
	mov   eax, [eax + 8]	
	sub   ecx, eax
	sub   eax, edx
	
	mov   [esp + _nsvdwc], edx
	mov   [esp + _nscoul], eax
	mov   [esp + _nsvdw], ecx
		
	/* clear potential */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _vnbtot], xmm4
	mov   [esp + _solnr],  ebx

	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr0], eax     /* pointer to jjnr[nj0] */
	mov   [esp + _innerk0], edx        /* number of innerloop atoms */

	mov   ecx, [esp + _nsvdwc]
	cmp   ecx,  0
	jnz   i1110_mno_vdwc
	jmp   i1110_testcoul
i1110_mno_vdwc:
	mov   ebx,  [esp + _solnr]
	inc   dword ptr [esp + _solnr]

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	mulss xmm3, [ebp + _facel]
	shufps xmm3, xmm3, 0

        mov   edx, [ebp + _type] 
        mov   edx, [edx + ebx*4]
        imul  edx, [ebp + _ntype]
        shl   edx, 1
        mov   [esp + _ntia], edx
		
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 

	movss xmm0, [esp + _shX]
	movss xmm1, [esp + _shY]
	movss xmm2, [esp + _shZ]
	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]

	movaps [esp + _iq], xmm3
	
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   [esp + _ii3], ebx
	
	/* clear i forces */
	xorps xmm4, xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4
	
	mov   ecx, [esp + _innerjjnr0]
	mov   [esp + _innerjjnr], ecx
	mov   edx, [esp + _innerk0]
        sub   edx,  4
        mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   i1110_unroll_vdwc_loop
	jmp   i1110_finish_vdwc_inner
i1110_unroll_vdwc_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	movaps xmm2, [esp + _iq]
	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	movd  mm2, ecx
	movd  mm3, edx
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	mulps xmm3, xmm2
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	movaps xmm1, xmm4
	mulps  xmm1, xmm4
	mulps  xmm1, xmm4	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */
	mulps  xmm3, xmm0	/* xmm3=vcoul */
	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	addps  xmm2, xmm3
	mulps  xmm4, xmm2	/* xmm4=total fscal */
	addps  xmm3, [esp + _vctot]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vctot], xmm3
	movaps [esp + _vnbtot], xmm5

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    i1110_finish_vdwc_inner
	jmp   i1110_unroll_vdwc_loop
i1110_finish_vdwc_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   i1110_dopair_vdwc
	jmp   i1110_checksingle_vdwc
i1110_dopair_vdwc:	
	mov esi, [ebp + _charge]

        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8

	movss xmm3, [esi + eax*4]		
	movss xmm6, [esi + ebx*4]
	shufps xmm3, xmm6, 0 
	shufps xmm3, xmm3, 0b00001000 /* xmm3(0,1) has the charges */

	mov esi, [ebp + _type]
	mov   ecx, eax
	mov   edx, ebx
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add ecx, edi
	add edx, edi
	movlps xmm6, [esi + ecx*4]
	movhps xmm6, [esi + edx*4]
	mov edi, [ebp + _pos]	
	xorps  xmm7,xmm7
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b1000 	
	shufps xmm6, xmm6, 0b1101
	movlhps xmm4, xmm7
	movlhps xmm6, xmm7
	
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
			
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	mulps  xmm3, [esp + _iq]

	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	movaps xmm1, xmm4
	mulps  xmm1, xmm4
	mulps  xmm1, xmm4	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */

	mulps  xmm3, xmm0	/* xmm3=vcoul */
	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	addps  xmm2, xmm3
	mulps  xmm4, xmm2	/* xmm4=total fscal */
	addps  xmm3, [esp + _vctot]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vctot], xmm3
	movaps [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

i1110_checksingle_vdwc:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    i1110_dosingle_vdwc
	jmp    i1110_updateouterdata_vdwc
i1110_dosingle_vdwc:			
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	movss xmm3, [esi + eax*4]	/* xmm3(0) has the charge */	

	mov esi, [ebp + _type]
	mov ecx, eax
	mov ecx, [esi + ecx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1
	add ecx, [esp + _ntia]
	xorps  xmm6, xmm6
	movlps xmm6, [esi + ecx*4]
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b11111100	
	shufps xmm6, xmm6, 0b11111101	
			
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	
 
	mulps  xmm3, [esp + _iq]
	
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	movaps xmm1, xmm4
	mulps  xmm1, xmm4
	mulps  xmm1, xmm4	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */
	mulps  xmm3, xmm0	/* xmm3=vcoul */
	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addss  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	addps  xmm2, xmm3
	mulps  xmm4, xmm2	/* xmm4=total fscal */
	addss  xmm3, [esp + _vctot]
	
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movss [esp + _vctot], xmm3
	movss [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
i1110_updateouterdata_vdwc:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5


	/* loop back to mno */
	dec dword ptr [esp + _nsvdwc]
	jz  i1110_testcoul
	jmp i1110_mno_vdwc
i1110_testcoul:
	mov  ecx, [esp + _nscoul]
	cmp  ecx,  0
	jnz  i1110_mno_coul
	jmp  i1110_testvdw
i1110_mno_coul:
	mov   ebx,  [esp + _solnr]
	inc   dword ptr [esp + _solnr]

	movss xmm0, [esp + _shX]
	movss xmm1, [esp + _shY]
	movss xmm2, [esp + _shZ]

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	mulss xmm3, [ebp + _facel]
	shufps xmm3, xmm3, 0
	
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]

	movaps [esp + _iq], xmm3
	
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   [esp + _ii3], ebx
	
	/* clear i forces */
	xorps xmm4, xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4

	mov   ecx, [esp + _innerjjnr0]
	mov   [esp + _innerjjnr], ecx
	mov   edx, [esp + _innerk0]
        sub   edx,  4
        mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   i1110_unroll_coul_loop
	jmp   i1110_finish_coul_inner

i1110_unroll_coul_loop:	
	/* quad-unrolled innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	movaps xmm5, [esp + _iq]
	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000	      
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	mulps xmm3, xmm5
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	mov    edi, [ebp + _faction]

	/* move ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */

	movaps xmm5, [esp + _vctot]
	mulps  xmm3, xmm0	/* xmm3=vcoul */
	mulps  xmm4, xmm3	/* xmm4=fscal */
	addps  xmm5, xmm3

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vctot], xmm5


	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    i1110_finish_coul_inner
	jmp   i1110_unroll_coul_loop
i1110_finish_coul_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   i1110_dopair_coul
	jmp   i1110_checksingle_coul
i1110_dopair_coul:	
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8

	movss xmm3, [esi + eax*4]		
	movss xmm6, [esi + ebx*4]
	shufps xmm3, xmm6, 0 
	shufps xmm3, xmm3, 0b00001000 /* xmm3(0,1) has the charges */

	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	mulps  xmm3, [esp + _iq]
	xorps  xmm7,xmm7
	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */

	movaps xmm5, [esp + _vctot]
	mulps  xmm3, xmm0	/* xmm3=vcoul */
	mulps  xmm4, xmm3	/* xmm4=fscal */
	addps  xmm5, xmm3

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vctot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */ 
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001
	
	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

i1110_checksingle_coul:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    i1110_dosingle_coul
	jmp    i1110_updateouterdata_coul
i1110_dosingle_coul:			
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	movss xmm3, [esi + eax*4]	/* xmm3(0) has the charge */	
	
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	
 
	mulps  xmm3, [esp + _iq]
	
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	mov    edi, [ebp + _faction]
	movss xmm5, [esp + _vctot]
	mulps  xmm3, xmm0	/* xmm3=vcoul */
	mulps  xmm4, xmm3	/* xmm4=fscal */
	addps  xmm5, xmm3

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movss [esp + _vctot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

i1110_updateouterdata_coul:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5

	/* loop back to mno */
	dec dword ptr [esp + _nscoul]
	jz  i1110_testvdw
	jmp i1110_mno_coul
i1110_testvdw:
	mov  ecx, [esp + _nsvdw]
	cmp  ecx,  0
	jnz  i1110_mno_vdw
	jmp  i1110_last_mno
i1110_mno_vdw:
	mov   ebx,  [esp + _solnr]
	inc   dword ptr [esp + _solnr]

        mov   edx, [ebp + _type] 
        mov   edx, [edx + ebx*4]
        imul  edx, [ebp + _ntype]
        shl   edx, 1
        mov   [esp + _ntia], edx
		
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx

	movss xmm0, [esp + _shX]
	movss xmm1, [esp + _shY]
	movss xmm2, [esp + _shZ]

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]
	
	xorps xmm4, xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   ecx, [esp + _innerjjnr0]
	mov   [esp + _innerjjnr], ecx
	mov   edx, [esp + _innerk0]
        sub   edx,  4
        mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   i1110_unroll_vdw_loop
	jmp   i1110_finish_vdw_inner
i1110_unroll_vdw_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	movd  mm2, ecx
	movd  mm3, edx
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rcpps xmm5, xmm4
	/* 1/x lookup seed in xmm5 */
	movaps xmm0, [esp + _two]
	mulps xmm4, xmm5
	subps xmm0, xmm4
	mulps xmm0, xmm5	/* xmm0=rinvsq */
	movaps xmm4, xmm0
	
	movaps xmm1, xmm0
	mulps  xmm1, xmm0
	mulps  xmm1, xmm0	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */

	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	mulps  xmm4, xmm2	/* xmm4=total fscal */

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vnbtot], xmm5

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    i1110_finish_vdw_inner
	jmp   i1110_unroll_vdw_loop
i1110_finish_vdw_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   i1110_dopair_vdw
	jmp   i1110_checksingle_vdw
i1110_dopair_vdw:	

        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8

	mov esi, [ebp + _type]
	mov   ecx, eax
	mov   edx, ebx
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add ecx, edi
	add edx, edi
	movlps xmm6, [esi + ecx*4]
	movhps xmm6, [esi + edx*4]
	mov edi, [ebp + _pos]	
	xorps  xmm7,xmm7
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b1000 	
	shufps xmm6, xmm6, 0b1101
	movlhps xmm4, xmm7
	movlhps xmm6, xmm7
	
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
			
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	


	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */


	rcpps xmm5, xmm4
	/* 1/x lookup seed in xmm5 */
	movaps xmm0, [esp + _two]
	mulps xmm4, xmm5
	subps xmm0, xmm4
	mulps xmm0, xmm5	/* xmm0=rinvsq */
	movaps xmm4, xmm0
	
	movaps xmm1, xmm0
	mulps  xmm1, xmm0
	mulps  xmm1, xmm0	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */

	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	mulps  xmm4, xmm2	/* xmm4=total fscal */

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

i1110_checksingle_vdw:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    i1110_dosingle_vdw
	jmp    i1110_updateouterdata_vdw
i1110_dosingle_vdw:			
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]		

	mov esi, [ebp + _type]
	mov ecx, eax
	mov ecx, [esi + ecx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1
	add ecx, [esp + _ntia]
	xorps  xmm6, xmm6
	movlps xmm6, [esi + ecx*4]
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b11111100	
	shufps xmm6, xmm6, 0b11111101	
			
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	
	
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rcpps xmm5, xmm4
	/* 1/x lookup seed in xmm5 */
	movaps xmm0, [esp + _two]
	mulps xmm4, xmm5
	subps xmm0, xmm4
	mulps xmm0, xmm5	/* xmm0=rinvsq */
	movaps xmm4, xmm0
	
	movaps xmm1, xmm0
	mulps  xmm1, xmm0
	mulps  xmm1, xmm0	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */

	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addss  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	mulps  xmm4, xmm2	/* xmm4=total fscal */
	
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movss [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
i1110_updateouterdata_vdw:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5
	
	/* loop back to mno */
	dec dword ptr [esp + _nsvdw]
	jz  i1110_last_mno
	jmp i1110_mno_vdw
i1110_last_mno:	
	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz i1110_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp i1110_outer
i1110_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 364
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret




.globl inl1120_sse
	.type inl1120_sse,@function
inl1120_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_type,		60
.equ		_ntype,		64
.equ		_nbfp,		68	
.equ		_Vnb,		72	
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ixO,	        0
.equ		_iyO,	        16
.equ		_izO,           32
.equ		_ixH1,	        48
.equ		_iyH1,	        64
.equ		_izH1,          80
.equ		_ixH2,	        96
.equ		_iyH2,	        112
.equ		_izH2,          128
.equ		_iqO,           144 
.equ		_iqH,           160 
.equ		_dxO,           176
.equ		_dyO,           192
.equ		_dzO,           208	
.equ		_dxH1,          224
.equ		_dyH1,          240
.equ		_dzH1,          256	
.equ		_dxH2,          272
.equ		_dyH2,          288
.equ		_dzH2,          304	
.equ		_qqO,           320
.equ		_qqH,           336
.equ		_c6,            352
.equ		_c12,           368
.equ		_six,           384
.equ		_twelve,        400		 
.equ		_vctot,         416
.equ		_vnbtot,        432
.equ		_fixO,          448
.equ		_fiyO,          464
.equ		_fizO,          480
.equ		_fixH1,         496
.equ		_fiyH1,         512
.equ		_fizH1,         528
.equ		_fixH2,         544
.equ		_fiyH2,         560
.equ		_fizH2,         576
.equ		_fjx,	        592
.equ		_fjy,           608
.equ		_fjz,           624
.equ		_half,          640
.equ		_three,         656
.equ		_is3,           672
.equ		_ii3,           676
.equ		_ntia,	        680	
.equ		_innerjjnr,     684
.equ		_innerk,        688
.equ		_salign,        692								
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 696		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_three]
	movups xmm2, [sse_six]
	movups xmm3, [sse_twelve]
	movaps [esp + _half],  xmm0
	movaps [esp + _three], xmm1
	movaps [esp + _six],  xmm2
	movaps [esp + _twelve], xmm3

	/* assume we have at least one i particle - start directly */
	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	movss xmm4, [edx + ebx*4 + 4]	
	movss xmm5, [ebp + _facel]
	mulss  xmm3, xmm5
	mulss  xmm4, xmm5

	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	movaps [esp + _iqO], xmm3
	movaps [esp + _iqH], xmm4
	
	mov   edx, [ebp + _type]
	mov   ecx, [edx + ebx*4]
	shl   ecx, 1
	imul  ecx, [ebp + _ntype]      /* ecx = ntia = 2*ntype*type[ii0] */
	mov   [esp + _ntia], ecx		
i1120_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2

	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx

	addss xmm3, [eax + ebx*4]
	addss xmm4, [eax + ebx*4 + 4]
	addss xmm5, [eax + ebx*4 + 8]		
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixO], xmm3
	movaps [esp + _iyO], xmm4
	movaps [esp + _izO], xmm5

	movss xmm3, xmm0
	movss xmm4, xmm1
	movss xmm5, xmm2
	addss xmm0, [eax + ebx*4 + 12]
	addss xmm1, [eax + ebx*4 + 16]
	addss xmm2, [eax + ebx*4 + 20]		
	addss xmm3, [eax + ebx*4 + 24]
	addss xmm4, [eax + ebx*4 + 28]
	addss xmm5, [eax + ebx*4 + 32]		

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixH1], xmm0
	movaps [esp + _iyH1], xmm1
	movaps [esp + _izH1], xmm2
	movaps [esp + _ixH2], xmm3
	movaps [esp + _iyH2], xmm4
	movaps [esp + _izH2], xmm5
	
	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _vnbtot], xmm4
	movaps [esp + _fixO], xmm4
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm4
	movaps [esp + _fixH1], xmm4
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm4
	movaps [esp + _fixH2], xmm4
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   i1120_unroll_loop
	jmp   i1120_odd_inner
i1120_unroll_loop:
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */

	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	movaps xmm4, xmm3	     /* and in xmm4 */
	mulps  xmm3, [esp + _iqO]
	mulps  xmm4, [esp + _iqH]

	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	movd  mm2, ecx
	movd  mm3, edx

	movaps  [esp + _qqO], xmm3
	movaps  [esp + _qqH], xmm4
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6

	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	
	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ixO-izO to xmm4-xmm6 */
	movaps xmm4, [esp + _ixO]
	movaps xmm5, [esp + _iyO]
	movaps xmm6, [esp + _izO]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dxO], xmm4
	movaps [esp + _dyO], xmm5
	movaps [esp + _dzO], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	movaps xmm7, xmm4
	/* rsqO in xmm7 */

	/* move ixH1-izH1 to xmm4-xmm6 */
	movaps xmm4, [esp + _ixH1]
	movaps xmm5, [esp + _iyH1]
	movaps xmm6, [esp + _izH1]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dxH1], xmm4
	movaps [esp + _dyH1], xmm5
	movaps [esp + _dzH1], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm6, xmm5
	addps xmm6, xmm4
	/* rsqH1 in xmm6 */

	/* move ixH2-izH2 to xmm3-xmm5 */ 
	movaps xmm3, [esp + _ixH2]
	movaps xmm4, [esp + _iyH2]
	movaps xmm5, [esp + _izH2]

	/* calc dr */
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2

	/* store dr */
	movaps [esp + _dxH2], xmm3
	movaps [esp + _dyH2], xmm4
	movaps [esp + _dzH2], xmm5
	/* square it */
	mulps xmm3,xmm3
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	addps xmm5, xmm4
	addps xmm5, xmm3
	/* rsqH2 in xmm5, rsqH1 in xmm6, rsqO in xmm7 */

	/* start with rsqO - seed in xmm2 */	
	rsqrtps xmm2, xmm7
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm7	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  xmm7, xmm4	/* rinvO in xmm7 */
	/* rsqH1 - seed in xmm2 */
	rsqrtps xmm2, xmm6
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm6	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  xmm6, xmm4	/* rinvH1 in xmm6 */
	/* rsqH2 - seed in xmm2 */
	rsqrtps xmm2, xmm5
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm5	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  xmm5, xmm4	/* rinvH2 in xmm5 */

	/* do O interactions */
	movaps  xmm4, xmm7	
	mulps   xmm4, xmm4	/* xmm7=rinv, xmm4=rinvsq */
	movaps xmm1, xmm4
	mulps  xmm1, xmm4
	mulps  xmm1, xmm4	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */
	mulps  xmm7, [esp + _qqO]	/* xmm7=vcoul */
	
	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm3, xmm2
	subps  xmm3, xmm1	/* vnb=vnb12-vnb6 */		
	addps  xmm3, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	addps  xmm2, xmm7	
	mulps  xmm4, xmm2	/* total fsO in xmm4 */

	addps  xmm7, [esp + _vctot]
	
	movaps [esp + _vnbtot], xmm3
	movaps [esp + _vctot], xmm7

	movaps xmm0, [esp + _dxO]
	movaps xmm1, [esp + _dyO]
	movaps xmm2, [esp + _dzO]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

	/* update O forces */
	movaps xmm3, [esp + _fixO]
	movaps xmm4, [esp + _fiyO]
	movaps xmm7, [esp + _fizO]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixO], xmm3
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm7
	/* update j forces with water O */
	movaps [esp + _fjx], xmm0
	movaps [esp + _fjy], xmm1
	movaps [esp + _fjz], xmm2

	/* H1 interactions */
	movaps  xmm4, xmm6	
	mulps   xmm4, xmm4	/* xmm6=rinv, xmm4=rinvsq */
	mulps  xmm6, [esp + _qqH]	/* xmm6=vcoul */
	mulps  xmm4, xmm6		/* total fsH1 in xmm4 */
	
	addps  xmm6, [esp + _vctot]

	movaps xmm0, [esp + _dxH1]
	movaps xmm1, [esp + _dyH1]
	movaps xmm2, [esp + _dzH1]
	movaps [esp + _vctot], xmm6
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

	/* update H1 forces */
	movaps xmm3, [esp + _fixH1]
	movaps xmm4, [esp + _fiyH1]
	movaps xmm7, [esp + _fizH1]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixH1], xmm3
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm7
	/* update j forces with water H1 */
	addps  xmm0, [esp + _fjx]
	addps  xmm1, [esp + _fjy]
	addps  xmm2, [esp + _fjz]
	movaps [esp + _fjx], xmm0
	movaps [esp + _fjy], xmm1
	movaps [esp + _fjz], xmm2

	/* H2 interactions */
	movaps  xmm4, xmm5	
	mulps   xmm4, xmm4	/* xmm5=rinv, xmm4=rinvsq */
	mulps  xmm5, [esp + _qqH]	/* xmm5=vcoul */
	mulps  xmm4, xmm5		/* total fsH1 in xmm4 */
	
	addps  xmm5, [esp + _vctot]

	movaps xmm0, [esp + _dxH2]
	movaps xmm1, [esp + _dyH2]
	movaps xmm2, [esp + _dzH2]
	movaps [esp + _vctot], xmm5
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

	/* update H2 forces */
	movaps xmm3, [esp + _fixH2]
	movaps xmm4, [esp + _fiyH2]
	movaps xmm7, [esp + _fizH2]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixH2], xmm3
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm7

	mov edi, [ebp + _faction]
	/* update j forces */
	addps xmm0, [esp + _fjx]
	addps xmm1, [esp + _fjy]
	addps xmm2, [esp + _fjz]

	movlps xmm4, [edi + eax*4]
	movlps xmm7, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm7, [edi + edx*4]
	
	movaps xmm3, xmm4
	shufps xmm3, xmm7, 0b10001000
	shufps xmm4, xmm7, 0b11011101			      
	/* xmm3 has fjx, xmm4 has fjy */
	subps xmm3, xmm0
	subps xmm4, xmm1
	/* unpack them back for storing */
	movaps xmm7, xmm3
	unpcklps xmm7, xmm4
	unpckhps xmm3, xmm4	
	movlps [edi + eax*4], xmm7
	movlps [edi + ecx*4], xmm3
	movhps [edi + ebx*4], xmm7
	movhps [edi + edx*4], xmm3
	/* finally z forces */
	movss  xmm0, [edi + eax*4 + 8]
	movss  xmm1, [edi + ebx*4 + 8]
	movss  xmm3, [edi + ecx*4 + 8]
	movss  xmm4, [edi + edx*4 + 8]
	subss  xmm0, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm1, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm3, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm4, xmm2
	movss  [edi + eax*4 + 8], xmm0
	movss  [edi + ebx*4 + 8], xmm1
	movss  [edi + ecx*4 + 8], xmm3
	movss  [edi + edx*4 + 8], xmm4
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    i1120_odd_inner
	jmp   i1120_unroll_loop
i1120_odd_inner:	
	add   [esp + _innerk],  4
	jnz   i1120_odd_loop
	jmp   i1120_updateouterdata
i1120_odd_loop:
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	add   [esp + _innerjjnr],  4	

 	xorps xmm4, xmm4
	movss xmm4, [esp + _iqO]
	mov esi, [ebp + _charge] 
	movhps xmm4, [esp + _iqH]     
	movss xmm3, [esi + eax*4]	/* charge in xmm3 */
	shufps xmm3, xmm3, 0
	mulps xmm3, xmm4
	movaps [esp + _qqO], xmm3	/* use oxygen qq for storage */

	xorps xmm6, xmm6
	mov esi, [ebp + _type]
	mov ebx, [esi + eax*4]
	mov esi, [ebp + _nbfp]
	shl ebx, 1	
	add ebx, [esp + _ntia]
	movlps xmm6, [esi + ebx*4]
	movaps xmm7, xmm6
	shufps xmm6, xmm6, 0b11111100
	shufps xmm7, xmm7, 0b11111101
	movaps [esp + _c6], xmm6
	movaps [esp + _c12], xmm7

	mov esi, [ebp + _pos]
	lea   eax, [eax + eax*2]  
	
	/* move j coords to xmm0-xmm2 */
	movss xmm0, [esi + eax*4]
	movss xmm1, [esi + eax*4 + 4]
	movss xmm2, [esi + eax*4 + 8]
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	
	movss xmm3, [esp + _ixO]
	movss xmm4, [esp + _iyO]
	movss xmm5, [esp + _izO]
		
	movlps xmm6, [esp + _ixH1]
	movlps xmm7, [esp + _ixH2]
	unpcklps xmm6, xmm7
	movlhps xmm3, xmm6
	movlps xmm6, [esp + _iyH1]
	movlps xmm7, [esp + _iyH2]
	unpcklps xmm6, xmm7
	movlhps xmm4, xmm6
	movlps xmm6, [esp + _izH1]
	movlps xmm7, [esp + _izH2]
	unpcklps xmm6, xmm7
	movlhps xmm5, xmm6

	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	
	movaps [esp + _dxO], xmm3
	movaps [esp + _dyO], xmm4
	movaps [esp + _dzO], xmm5

	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5

	addps  xmm4, xmm3
	addps  xmm4, xmm5
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	movaps xmm1, xmm4
	mulss  xmm1, xmm4
	movaps xmm3, [esp + _qqO]
	mulss  xmm1, xmm4	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulss  xmm2, xmm2	/* xmm2=rinvtwelve */
	mulps  xmm3, xmm0	/* xmm3=vcoul */
	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subss  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulss  xmm1, [esp + _six]
	mulss  xmm2, [esp + _twelve]
	subss  xmm2, xmm1
	addps  xmm2, xmm3
	mulps  xmm4, xmm2	/* xmm4=total fscal */
	addps  xmm3, [esp + _vctot]

	movaps xmm0, [esp + _dxO]
	movaps xmm1, [esp + _dyO]
	movaps xmm2, [esp + _dzO]

	movaps [esp + _vctot], xmm3
	movaps [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	movss  xmm3, [esp + _fixO]	
	movss  xmm4, [esp + _fiyO]	
	movss  xmm5, [esp + _fizO]	
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esp + _fixO], xmm3	
	movss  [esp + _fiyO], xmm4	
	movss  [esp + _fizO], xmm5	/* updated the O force now do the H's */
	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2
	shufps xmm3, xmm3, 0b11100110	/* shift right */
	shufps xmm4, xmm4, 0b11100110
	shufps xmm5, xmm5, 0b11100110
	addss  xmm3, [esp + _fixH1]
	addss  xmm4, [esp + _fiyH1]
	addss  xmm5, [esp + _fizH1]
	movss  [esp + _fixH1], xmm3	
	movss  [esp + _fiyH1], xmm4	
	movss  [esp + _fizH1], xmm5	/* updated the H1 force */

	mov edi, [ebp + _faction]
	shufps xmm3, xmm3, 0b11100111	/* shift right */
	shufps xmm4, xmm4, 0b11100111
	shufps xmm5, xmm5, 0b11100111
	addss  xmm3, [esp + _fixH2]
	addss  xmm4, [esp + _fiyH2]
	addss  xmm5, [esp + _fizH2]
	movss  [esp + _fixH2], xmm3	
	movss  [esp + _fiyH2], xmm4	
	movss  [esp + _fizH2], xmm5	/* updated the H2 force */

	/* the fj's - start by accumulating the tx/ty/tz force in xmm0, xmm1 */
	xorps  xmm5, xmm5
	movaps xmm3, xmm0
	movlps xmm6, [edi + eax*4]
	movss  xmm7, [edi + eax*4 + 8]
	unpcklps xmm3, xmm1
	movlhps  xmm3, xmm5	
	unpckhps xmm0, xmm1		
	addps    xmm0, xmm3
	movhlps  xmm3, xmm0	
	addps    xmm0, xmm3	/* x,y sum in xmm0 */

	movhlps  xmm1, xmm2
	addss    xmm2, xmm1
	shufps   xmm1, xmm1, 1 
	addss    xmm2, xmm1    /* z sum in xmm2 */
	subps    xmm6, xmm0
	subss    xmm7, xmm2
	
	movlps [edi + eax*4],     xmm6
	movss  [edi + eax*4 + 8], xmm7

	dec dword ptr [esp + _innerk]
	jz    i1120_updateouterdata
	jmp   i1120_odd_loop
i1120_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate  Oi forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixO]
	movaps xmm1, [esp + _fiyO]
	movaps xmm2, [esp + _fizO]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	movaps xmm6, xmm0
	movss xmm7, xmm2
	movlhps xmm6, xmm1
	shufps  xmm6, xmm6, 0b1000	

	/* accumulate H1i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH1]
	movaps xmm1, [esp + _fiyH1]
	movaps xmm2, [esp + _fizH1]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 12]
	movss  xmm4, [edi + ecx*4 + 16]
	movss  xmm5, [edi + ecx*4 + 20]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 12], xmm3
	movss  [edi + ecx*4 + 16], xmm4
	movss  [edi + ecx*4 + 20], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* accumulate H2i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH2]
	movaps xmm1, [esp + _fiyH2]
	movaps xmm2, [esp + _fizH2]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 24]
	movss  xmm4, [edi + ecx*4 + 28]
	movss  xmm5, [edi + ecx*4 + 32]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 24], xmm3
	movss  [edi + ecx*4 + 28], xmm4
	movss  [edi + ecx*4 + 32], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* increment fshift force */ 
	movlps  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 8]
	addps  xmm3, xmm6
	addss  xmm4, xmm7
	movlps  [esi + edx*4],    xmm3
	movss  [esi + edx*4 + 8], xmm4

	mov   edx, [ebp + _gid]  
	mov   edx, [edx]
	add   [ebp + _gid],  4	

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		
        
	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz i1120_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp i1120_outer
i1120_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 696
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret


	
.globl inl1130_sse
	.type inl1130_sse,@function
inl1130_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_type,		60
.equ		_ntype,		64
.equ		_nbfp,		68
.equ		_Vnb,		72
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ixO,		0
.equ		_iyO,		16
.equ		_izO,		32
.equ		_ixH1,		48
.equ		_iyH1,		64
.equ		_izH1,		80
.equ		_ixH2,		96
.equ		_iyH2,		112
.equ		_izH2,		128
.equ		_jxO,		144
.equ		_jyO,		160
.equ		_jzO,		176
.equ		_jxH1,		192
.equ		_jyH1,		208
.equ		_jzH1,		224
.equ		_jxH2,		240
.equ		_jyH2,		256
.equ		_jzH2,		272
.equ		_dxOO,		288
.equ		_dyOO,		304
.equ		_dzOO,		320	
.equ		_dxOH1,		336
.equ		_dyOH1,		352
.equ		_dzOH1,		368	
.equ		_dxOH2,		384
.equ		_dyOH2,		400
.equ		_dzOH2,		416	
.equ		_dxH1O,		432
.equ		_dyH1O,		448
.equ		_dzH1O,		464	
.equ		_dxH1H1,	480
.equ		_dyH1H1,	496
.equ		_dzH1H1,	512	
.equ		_dxH1H2,	528
.equ		_dyH1H2,	544
.equ		_dzH1H2,	560	
.equ		_dxH2O,		576
.equ		_dyH2O,		592
.equ		_dzH2O,		608	
.equ		_dxH2H1,	624
.equ		_dyH2H1,	640
.equ		_dzH2H1,	656	
.equ		_dxH2H2,	672
.equ		_dyH2H2,	688
.equ		_dzH2H2,	704
.equ		_qqOO,		720
.equ		_qqOH,		736
.equ		_qqHH,		752
.equ		_c6,		768
.equ		_c12,		784
.equ		_six,		800
.equ		_twelve,	816		 
.equ		_vctot,		832
.equ		_vnbtot,	848
.equ		_fixO,		864
.equ		_fiyO,		880
.equ		_fizO,		896
.equ		_fixH1,		912
.equ		_fiyH1,		928
.equ		_fizH1,		944
.equ		_fixH2,		960
.equ		_fiyH2,		976
.equ		_fizH2,		992
.equ		_fjxO,		1008
.equ		_fjyO,		1024
.equ		_fjzO,		1040
.equ		_fjxH1,		1056
.equ		_fjyH1,		1072
.equ		_fjzH1,		1088
.equ		_fjxH2,		1104
.equ		_fjyH2,		1120
.equ		_fjzH2,		1136
.equ		_half,		1152
.equ		_three,		1168
.equ		_rsqOO,		1184
.equ		_rsqOH1,	1200
.equ		_rsqOH2,	1216
.equ		_rsqH1O,	1232
.equ		_rsqH1H1,	1248
.equ		_rsqH1H2,	1264
.equ		_rsqH2O,	1280
.equ		_rsqH2H1,	1296
.equ		_rsqH2H2,	1312
.equ		_rinvOO,	1328
.equ		_rinvOH1,	1344
.equ		_rinvOH2,	1360
.equ		_rinvH1O,	1376
.equ		_rinvH1H1,	1392
.equ		_rinvH1H2,	1408
.equ		_rinvH2O,	1424
.equ		_rinvH2H1,	1440
.equ		_rinvH2H2,	1456
.equ		_is3,		1472
.equ		_ii3,		1476
.equ		_innerjjnr,	1480
.equ		_innerk,	1484
.equ		_salign,	1488							
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 1492		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_three]
	movups xmm2, [sse_six]
	movups xmm3, [sse_twelve]
	movaps [esp + _half],  xmm0
	movaps [esp + _three], xmm1
	movaps [esp + _six],  xmm2
	movaps [esp + _twelve], xmm3

	/* assume we have at least one i particle - start directly */
	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	movss xmm4, xmm3	
	movss xmm5, [edx + ebx*4 + 4]	
	movss xmm6, [ebp + _facel]
	mulss  xmm3, xmm3
	mulss  xmm4, xmm5
	mulss  xmm5, xmm5
	mulss  xmm3, xmm6
	mulss  xmm4, xmm6
	mulss  xmm5, xmm6
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _qqOO], xmm3
	movaps [esp + _qqOH], xmm4
	movaps [esp + _qqHH], xmm5
		
	xorps xmm0, xmm0
	mov   edx, [ebp + _type]
	mov   ecx, [edx + ebx*4]
	shl   ecx, 1
	mov   edx, ecx
	imul  ecx, [ebp + _ntype]      /* ecx = ntia = 2*ntype*type[ii0] */
	add   edx, ecx
	mov   eax, [ebp + _nbfp]
	movlps xmm0, [eax + edx*4] 
	movaps xmm1, xmm0
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0b01010101
	movaps [esp + _c6], xmm0
	movaps [esp + _c12], xmm1

i1130_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx	
	
	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2
	addss xmm3, [eax + ebx*4]
	addss xmm4, [eax + ebx*4 + 4]
	addss xmm5, [eax + ebx*4 + 8]		
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixO], xmm3
	movaps [esp + _iyO], xmm4
	movaps [esp + _izO], xmm5

	movss xmm3, xmm0
	movss xmm4, xmm1
	movss xmm5, xmm2
	addss xmm0, [eax + ebx*4 + 12]
	addss xmm1, [eax + ebx*4 + 16]
	addss xmm2, [eax + ebx*4 + 20]		
	addss xmm3, [eax + ebx*4 + 24]
	addss xmm4, [eax + ebx*4 + 28]
	addss xmm5, [eax + ebx*4 + 32]		

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixH1], xmm0
	movaps [esp + _iyH1], xmm1
	movaps [esp + _izH1], xmm2
	movaps [esp + _ixH2], xmm3
	movaps [esp + _iyH2], xmm4
	movaps [esp + _izH2], xmm5

	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _vnbtot], xmm4
	movaps [esp + _fixO], xmm4
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm4
	movaps [esp + _fixH1], xmm4
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm4
	movaps [esp + _fixH2], xmm4
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   i1130_unroll_loop
	jmp   i1130_single_check
i1130_unroll_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */

	mov   eax, [edx]	
	mov   ebx, [edx + 4] 
	mov   ecx, [edx + 8]
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	
	
	/* move j coordinates to local temp variables */
	movlps xmm2, [esi + eax*4]
	movlps xmm3, [esi + eax*4 + 12]
	movlps xmm4, [esi + eax*4 + 24]

	movlps xmm5, [esi + ebx*4]
	movlps xmm6, [esi + ebx*4 + 12]
	movlps xmm7, [esi + ebx*4 + 24]

	movhps xmm2, [esi + ecx*4]
	movhps xmm3, [esi + ecx*4 + 12]
	movhps xmm4, [esi + ecx*4 + 24]

	movhps xmm5, [esi + edx*4]
	movhps xmm6, [esi + edx*4 + 12]
	movhps xmm7, [esi + edx*4 + 24]

	/* current state: */	
	/* xmm2= jxOa  jyOa  jxOc  jyOc */
	/* xmm3= jxH1a jyH1a jxH1c jyH1c */
	/* xmm4= jxH2a jyH2a jxH2c jyH2c */
	/* xmm5= jxOb  jyOb  jxOd  jyOd */
	/* xmm6= jxH1b jyH1b jxH1d jyH1d */
	/* xmm7= jxH2b jyH2b jxH2d jyH2d */
	
	movaps xmm0, xmm2
	movaps xmm1, xmm3
	unpcklps xmm0, xmm5	/* xmm0= jxOa  jxOb  jyOa  jyOb */
	unpcklps xmm1, xmm6	/* xmm1= jxH1a jxH1b jyH1a jyH1b */
	unpckhps xmm2, xmm5	/* xmm2= jxOc  jxOd  jyOc  jyOd */
	unpckhps xmm3, xmm6	/* xmm3= jxH1c jxH1d jyH1c jyH1d */
	movaps xmm5, xmm4
	movaps   xmm6, xmm0
	unpcklps xmm4, xmm7	/* xmm4= jxH2a jxH2b jyH2a jyH2b */		
	unpckhps xmm5, xmm7	/* xmm5= jxH2c jxH2d jyH2c jyH2d */
	movaps   xmm7, xmm1
	movlhps  xmm0, xmm2	/* xmm0= jxOa  jxOb  jxOc  jxOd */
	movaps [esp + _jxO], xmm0
	movhlps  xmm2, xmm6	/* xmm2= jyOa  jyOb  jyOc  jyOd */
	movaps [esp + _jyO], xmm2
	movlhps  xmm1, xmm3
	movaps [esp + _jxH1], xmm1
	movhlps  xmm3, xmm7
	movaps   xmm6, xmm4
	movaps [esp + _jyH1], xmm3
	movlhps  xmm4, xmm5
	movaps [esp + _jxH2], xmm4
	movhlps  xmm5, xmm6
	movaps [esp + _jyH2], xmm5

	movss  xmm0, [esi + eax*4 + 8]
	movss  xmm1, [esi + eax*4 + 20]
	movss  xmm2, [esi + eax*4 + 32]

	movss  xmm3, [esi + ecx*4 + 8]
	movss  xmm4, [esi + ecx*4 + 20]
	movss  xmm5, [esi + ecx*4 + 32]

	movhps xmm0, [esi + ebx*4 + 4]
	movhps xmm1, [esi + ebx*4 + 16]
	movhps xmm2, [esi + ebx*4 + 28]
	
	movhps xmm3, [esi + edx*4 + 4]
	movhps xmm4, [esi + edx*4 + 16]
	movhps xmm5, [esi + edx*4 + 28]
	
	shufps xmm0, xmm3, 0b11001100
	shufps xmm1, xmm4, 0b11001100
	shufps xmm2, xmm5, 0b11001100
	movaps [esp + _jzO],  xmm0
	movaps [esp + _jzH1],  xmm1
	movaps [esp + _jzH2],  xmm2

	movaps xmm0, [esp + _ixO]
	movaps xmm1, [esp + _iyO]
	movaps xmm2, [esp + _izO]
	movaps xmm3, [esp + _ixO]
	movaps xmm4, [esp + _iyO]
	movaps xmm5, [esp + _izO]
	subps  xmm0, [esp + _jxO]
	subps  xmm1, [esp + _jyO]
	subps  xmm2, [esp + _jzO]
	subps  xmm3, [esp + _jxH1]
	subps  xmm4, [esp + _jyH1]
	subps  xmm5, [esp + _jzH1]
	movaps [esp + _dxOO], xmm0
	movaps [esp + _dyOO], xmm1
	movaps [esp + _dzOO], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxOH1], xmm3
	movaps [esp + _dyOH1], xmm4
	movaps [esp + _dzOH1], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqOO], xmm0
	movaps [esp + _rsqOH1], xmm3

	movaps xmm0, [esp + _ixO]
	movaps xmm1, [esp + _iyO]
	movaps xmm2, [esp + _izO]
	movaps xmm3, [esp + _ixH1]
	movaps xmm4, [esp + _iyH1]
	movaps xmm5, [esp + _izH1]
	subps  xmm0, [esp + _jxH2]
	subps  xmm1, [esp + _jyH2]
	subps  xmm2, [esp + _jzH2]
	subps  xmm3, [esp + _jxO]
	subps  xmm4, [esp + _jyO]
	subps  xmm5, [esp + _jzO]
	movaps [esp + _dxOH2], xmm0
	movaps [esp + _dyOH2], xmm1
	movaps [esp + _dzOH2], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH1O], xmm3
	movaps [esp + _dyH1O], xmm4
	movaps [esp + _dzH1O], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqOH2], xmm0
	movaps [esp + _rsqH1O], xmm3

	movaps xmm0, [esp + _ixH1]
	movaps xmm1, [esp + _iyH1]
	movaps xmm2, [esp + _izH1]
	movaps xmm3, [esp + _ixH1]
	movaps xmm4, [esp + _iyH1]
	movaps xmm5, [esp + _izH1]
	subps  xmm0, [esp + _jxH1]
	subps  xmm1, [esp + _jyH1]
	subps  xmm2, [esp + _jzH1]
	subps  xmm3, [esp + _jxH2]
	subps  xmm4, [esp + _jyH2]
	subps  xmm5, [esp + _jzH2]
	movaps [esp + _dxH1H1], xmm0
	movaps [esp + _dyH1H1], xmm1
	movaps [esp + _dzH1H1], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH1H2], xmm3
	movaps [esp + _dyH1H2], xmm4
	movaps [esp + _dzH1H2], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqH1H1], xmm0
	movaps [esp + _rsqH1H2], xmm3

	movaps xmm0, [esp + _ixH2]
	movaps xmm1, [esp + _iyH2]
	movaps xmm2, [esp + _izH2]
	movaps xmm3, [esp + _ixH2]
	movaps xmm4, [esp + _iyH2]
	movaps xmm5, [esp + _izH2]
	subps  xmm0, [esp + _jxO]
	subps  xmm1, [esp + _jyO]
	subps  xmm2, [esp + _jzO]
	subps  xmm3, [esp + _jxH1]
	subps  xmm4, [esp + _jyH1]
	subps  xmm5, [esp + _jzH1]
	movaps [esp + _dxH2O], xmm0
	movaps [esp + _dyH2O], xmm1
	movaps [esp + _dzH2O], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH2H1], xmm3
	movaps [esp + _dyH2H1], xmm4
	movaps [esp + _dzH2H1], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm4, xmm3
	addps  xmm4, xmm5
	movaps [esp + _rsqH2O], xmm0
	movaps [esp + _rsqH2H1], xmm4

	movaps xmm0, [esp + _ixH2]
	movaps xmm1, [esp + _iyH2]
	movaps xmm2, [esp + _izH2]
	subps  xmm0, [esp + _jxH2]
	subps  xmm1, [esp + _jyH2]
	subps  xmm2, [esp + _jzH2]
	movaps [esp + _dxH2H2], xmm0
	movaps [esp + _dyH2H2], xmm1
	movaps [esp + _dzH2H2], xmm2
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2
	movaps [esp + _rsqH2H2], xmm0
		
	/* start doing invsqrt use rsq values in xmm0, xmm4 */
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] /* rinvH2H2 */
	mulps   xmm7, [esp + _half] /* rinvH2H1 */
	movaps  [esp + _rinvH2H2], xmm3
	movaps  [esp + _rinvH2H1], xmm7
	
	rsqrtps xmm1, [esp + _rsqOO]
	rsqrtps xmm5, [esp + _rsqOH1]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqOO]
	mulps   xmm5, [esp + _rsqOH1]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvOO], xmm3
	movaps  [esp + _rinvOH1], xmm7
	
	rsqrtps xmm1, [esp + _rsqOH2]
	rsqrtps xmm5, [esp + _rsqH1O]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqOH2]
	mulps   xmm5, [esp + _rsqH1O]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvOH2], xmm3
	movaps  [esp + _rinvH1O], xmm7
	
	rsqrtps xmm1, [esp + _rsqH1H1]
	rsqrtps xmm5, [esp + _rsqH1H2]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqH1H1]
	mulps   xmm5, [esp + _rsqH1H2]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvH1H1], xmm3
	movaps  [esp + _rinvH1H2], xmm7
	
	rsqrtps xmm1, [esp + _rsqH2O]
	movaps  xmm2, xmm1
	mulps   xmm1, xmm1
	movaps  xmm3, [esp + _three]
	mulps   xmm1, [esp + _rsqH2O]
	subps   xmm3, xmm1
	mulps   xmm3, xmm2
	mulps   xmm3, [esp + _half] 
	movaps  [esp + _rinvH2O], xmm3

	/* start with OO interaction */
	movaps xmm0, [esp + _rinvOO]
	movaps xmm7, xmm0
	mulps  xmm0, xmm0
	movaps xmm1, xmm0
	mulps  xmm1, xmm0
	mulps  xmm1, xmm0	/* xmm1=rinvsix */
	mulps  xmm7, [esp + _qqOO]
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */
	mulps  xmm1, [esp + _c6]	
	mulps  xmm2, [esp + _c12]	
	movaps xmm3, xmm2
	subps  xmm3, xmm1	/* xmm3=vnb12-vnb6 */
	addps  xmm3, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	movaps [esp + _vnbtot], xmm3
	subps  xmm2, xmm1
	addps  xmm2, xmm7
	addps  xmm7, [esp + _vctot]
	mulps  xmm0, xmm2	
 
	movaps xmm1, xmm0
	movaps xmm2, xmm0

	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOO]
	mulps xmm1, [esp + _dyOO]
	mulps xmm2, [esp + _dzOO]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* O-H1 interaction */
	movaps xmm0, [esp + _rinvOH1]
	movaps xmm1, xmm0
	mulps xmm0, xmm0
	mulps xmm1, [esp + _qqOH]
	mulps xmm0, xmm1	/* fsOH1  */
	addps xmm7, xmm1	/* add to local vctot */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	
	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOH1]
	mulps xmm1, [esp + _dyOH1]
	mulps xmm2, [esp + _dzOH1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* O-H2 interaction */ 
	movaps xmm0, [esp + _rinvOH2]
	movaps xmm1, xmm0
	mulps xmm0, xmm0
	mulps xmm1, [esp + _qqOH]
	mulps xmm0, xmm1	/* fsOH2 */ 
	addps xmm7, xmm1	/* add to local vctot */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	
	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOH2]
	mulps xmm1, [esp + _dyOH2]
	mulps xmm2, [esp + _dzOH2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* H1-O interaction */
	movaps xmm0, [esp + _rinvH1O]
	movaps xmm1, xmm0
	mulps xmm0, xmm0
	mulps xmm1, [esp + _qqOH]
	mulps xmm0, xmm1	/* fsH1O */
	addps xmm7, xmm1	/* add to local vctot */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	movaps xmm3, [esp + _fjxO]
	movaps xmm4, [esp + _fjyO]
	movaps xmm5, [esp + _fjzO]
	mulps xmm0, [esp + _dxH1O]
	mulps xmm1, [esp + _dyH1O]
	mulps xmm2, [esp + _dzH1O]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H1-H1 interaction */
	movaps xmm0, [esp + _rinvH1H1]
	movaps xmm1, xmm0
	mulps xmm0, xmm0
	mulps xmm1, [esp + _qqHH]
	mulps xmm0, xmm1	/* fsH1H1 */
	addps xmm7, xmm1	/* add to local vctot */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	movaps xmm3, [esp + _fjxH1]
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	mulps xmm0, [esp + _dxH1H1]
	mulps xmm1, [esp + _dyH1H1]
	mulps xmm2, [esp + _dzH1H1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H1-H2 interaction */
	movaps xmm0, [esp + _rinvH1H2]
	movaps xmm1, xmm0
	mulps xmm0, xmm0
	mulps xmm1, [esp + _qqHH]
	mulps xmm0, xmm1	/* fsOH2 */ 
	addps xmm7, xmm1	/* add to local vctot */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	movaps xmm3, [esp + _fjxH2]
	movaps xmm4, [esp + _fjyH2]
	movaps xmm5, [esp + _fjzH2]
	mulps xmm0, [esp + _dxH1H2]
	mulps xmm1, [esp + _dyH1H2]
	mulps xmm2, [esp + _dzH1H2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H2-O interaction */
	movaps xmm0, [esp + _rinvH2O]
	movaps xmm1, xmm0
	mulps xmm0, xmm0
	mulps xmm1, [esp + _qqOH]
	mulps xmm0, xmm1	/* fsH2O */
	addps xmm7, xmm1	/* add to local vctot */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	movaps xmm3, [esp + _fjxO]
	movaps xmm4, [esp + _fjyO]
	movaps xmm5, [esp + _fjzO]
	mulps xmm0, [esp + _dxH2O]
	mulps xmm1, [esp + _dyH2O]
	mulps xmm2, [esp + _dzH2O]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	/* H2-H1 interaction */
	movaps xmm0, [esp + _rinvH2H1]
	movaps xmm1, xmm0
	mulps xmm0, xmm0
	mulps xmm1, [esp + _qqHH]
	mulps xmm0, xmm1	/* fsH2H1 */
	addps xmm7, xmm1	/* add to local vctot */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	movaps xmm3, [esp + _fjxH1]
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	mulps xmm0, [esp + _dxH2H1]
	mulps xmm1, [esp + _dyH2H1]
	mulps xmm2, [esp + _dzH2H1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	/* H2-H2 interaction */
	movaps xmm0, [esp + _rinvH2H2]
	movaps xmm1, xmm0
	mulps xmm0, xmm0
	mulps xmm1, [esp + _qqHH]
	mulps xmm0, xmm1	/* fsH2H2 */
	addps xmm7, xmm1	/* add to local vctot */
	movaps xmm1, xmm0
	movaps [esp + _vctot], xmm7
	movaps xmm2, xmm0
	movaps xmm3, [esp + _fjxH2]
	movaps xmm4, [esp + _fjyH2]
	movaps xmm5, [esp + _fjzH2]
	mulps xmm0, [esp + _dxH2H2]
	mulps xmm1, [esp + _dyH2H2]
	mulps xmm2, [esp + _dzH2H2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	mov edi, [ebp + _faction]
		
	/* Did all interactions - now update j forces */
	/* 4 j waters with three atoms each - first do a & b j particles */
	movaps xmm0, [esp + _fjxO] /* xmm0= fjxOa  fjxOb  fjxOc  fjxOd */
	movaps xmm1, [esp + _fjyO] /* xmm1= fjyOa  fjyOb  fjyOc  fjyOd */ 
	unpcklps xmm0, xmm1    	   /* xmm0= fjxOa  fjyOa  fjxOb  fjyOb */
	movaps xmm1, [esp + _fjzO]
	movaps xmm2, [esp + _fjxH1]
	movhlps  xmm3, xmm0	   /* xmm3= fjxOb  fjyOb */ 
	unpcklps xmm1, xmm2	   /* xmm1= fjzOa  fjxH1a fjzOb  fjxH1b */
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	unpcklps xmm4, xmm5	   /* xmm4= fjyH1a fjzH1a fjyH1b fjzH1b */
	movaps xmm5, [esp + _fjxH2]
	movaps xmm6, [esp + _fjyH2]
	movhlps  xmm7, xmm4	   /* xmm7= fjyH1b fjzH1b */
	unpcklps xmm5, xmm6	   /* xmm5= fjxH2a fjyH2a fjxH2b fjyH2b */
	movlhps  xmm0, xmm1    	   /* xmm0= fjxOa  fjyOa  fjzOa  fjxH1a */
	shufps   xmm3, xmm1, 0b11100100
                                   /* xmm3= fjxOb  fjyOb  fjzOb  fjxH1b */
	movlhps  xmm4, xmm5   	   /* xmm4= fjyH1a fjzH1a fjxH2a fjyH2a */
	shufps   xmm7, xmm5, 0b11100100
                                   /* xmm7= fjyH1b fjzH1b fjxH2b fjyH2b */
	movups   xmm1, [edi + eax*4]
	movups   xmm2, [edi + eax*4 + 16]
	movups   xmm5, [edi + ebx*4]
	movups   xmm6, [edi + ebx*4 + 16]
	addps    xmm1, xmm0
	addps    xmm2, xmm4
	addps    xmm5, xmm3
	addps    xmm6, xmm7
	movss    xmm0, [edi + eax*4 + 32]
	movss    xmm3, [edi + ebx*4 + 32]
	
	movaps   xmm4, [esp + _fjzH2]
	movaps   xmm7, xmm4
	shufps   xmm7, xmm7, 1
	
	movups   [edi + eax*4],     xmm1
	movups   [edi + eax*4 + 16],xmm2
	movups   [edi + ebx*4],     xmm5
	movups   [edi + ebx*4 + 16],xmm6	
	addss    xmm0, xmm4
	addss    xmm3, xmm7
	movss    [edi + eax*4 + 32], xmm0
	movss    [edi + ebx*4 + 32], xmm3	

	/* then do the second pair (c & d) */
	movaps xmm0, [esp + _fjxO] /* xmm0= fjxOa  fjxOb  fjxOc  fjxOd */
	movaps xmm1, [esp + _fjyO] /* xmm1= fjyOa  fjyOb  fjyOc  fjyOd */ 
	unpckhps xmm0, xmm1	   /* xmm0= fjxOc  fjyOc  fjxOd  fjyOd */
	movaps xmm1, [esp + _fjzO]
	movaps xmm2, [esp + _fjxH1]
	movhlps  xmm3, xmm0	   /* xmm3= fjxOd  fjyOd */ 
	unpckhps xmm1, xmm2	   /* xmm1= fjzOc  fjxH1c fjzOd  fjxH1d */
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	unpckhps xmm4, xmm5	   /* xmm4= fjyH1c fjzH1c fjyH1d fjzH1d	*/
	movaps xmm5, [esp + _fjxH2]
	movaps xmm6, [esp + _fjyH2]
	movhlps  xmm7, xmm4	   /* xmm7= fjyH1d fjzH1d */	 
	unpckhps xmm5, xmm6	   /* xmm5= fjxH2c fjyH2c fjxH2d fjyH2d */
	movlhps  xmm0, xmm1	   /* xmm0= fjxOc  fjyOc  fjzOc  fjxH1c */
	shufps   xmm3, xmm1, 0b11100100
                                   /* xmm3= fjxOd  fjyOd  fjzOd  fjxH1d */
	movlhps  xmm4, xmm5	   /* xmm4= fjyH1c fjzH1c fjxH2c fjyH2c  */
	shufps   xmm7, xmm5, 0b11100100
                                   /* xmm7= fjyH1d fjzH1d fjxH2d fjyH2d */
	movups   xmm1, [edi + ecx*4]
	movups   xmm2, [edi + ecx*4 + 16]
	movups   xmm5, [edi + edx*4]
	movups   xmm6, [edi + edx*4 + 16]
	addps    xmm1, xmm0
	addps    xmm2, xmm4
	addps    xmm5, xmm3
	addps    xmm6, xmm7
	movss    xmm0, [edi + ecx*4 + 32]
	movss    xmm3, [edi + edx*4 + 32]
	
	movaps   xmm4, [esp + _fjzH2]
	movaps   xmm7, xmm4
	shufps   xmm4, xmm4, 0b10
	shufps   xmm7, xmm7, 0b11
	movups   [edi + ecx*4],     xmm1
	movups   [edi + ecx*4 + 16],xmm2
	movups   [edi + edx*4],     xmm5
	movups   [edi + edx*4 + 16],xmm6	
	addss    xmm0, xmm4
	addss    xmm3, xmm7
	movss    [edi + ecx*4 + 32], xmm0
	movss    [edi + edx*4 + 32], xmm3	
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    i1130_single_check
	jmp   i1130_unroll_loop
i1130_single_check:
	add   [esp + _innerk],  4
	jnz   i1130_single_loop
	jmp   i1130_updateouterdata
i1130_single_loop:
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	add   [esp + _innerjjnr],  4	

	mov esi, [ebp + _pos]
	lea   eax, [eax + eax*2]  

	/* fetch j coordinates */
	xorps xmm3, xmm3
	xorps xmm4, xmm4
	xorps xmm5, xmm5
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + eax*4 + 4]
	movss xmm5, [esi + eax*4 + 8]

	movlps xmm6, [esi + eax*4 + 12]
	movhps xmm6, [esi + eax*4 + 24]	/* xmm6=jxH1 jyH1 jxH2 jyH2 */
	/* fetch both z coords in one go, to positions 0 and 3 in xmm7 */
	movups xmm7, [esi + eax*4 + 20] /* xmm7=jzH1 jxH2 jyH2 jzH2 */
	shufps xmm6, xmm6, 0b11011000    /* xmm6=jxH1 jxH2 jyH1 jyH2 */
	movlhps xmm3, xmm6      	/* xmm3= jxO   0  jxH1 jxH2 */
	movaps  xmm0, [esp + _ixO]     
	movaps  xmm1, [esp + _iyO]
	movaps  xmm2, [esp + _izO]	
	shufps  xmm4, xmm6, 0b11100100 /* xmm4= jyO   0   jyH1 jyH2 */
	shufps xmm5, xmm7, 0b11000100  /* xmm5= jzO   0   jzH1 jzH2 */
	/* store all j coordinates in jO */ 
	movaps [esp + _jxO], xmm3
	movaps [esp + _jyO], xmm4
	movaps [esp + _jzO], xmm5
	subps  xmm0, xmm3
	subps  xmm1, xmm4
	subps  xmm2, xmm5
	movaps [esp + _dxOO], xmm0
	movaps [esp + _dyOO], xmm1
	movaps [esp + _dzOO], xmm2
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2	/* have rsq in xmm0 */
	
	/* do invsqrt */
	rsqrtps xmm1, xmm0
	movaps  xmm2, xmm1	
	mulps   xmm1, xmm1
	movaps  xmm3, [esp + _three]
	mulps   xmm1, xmm0
	subps   xmm3, xmm1
	mulps   xmm3, xmm2							
	mulps   xmm3, [esp + _half] /* rinv iO - j water */

	xorps   xmm1, xmm1
	movaps  xmm0, xmm3
	xorps   xmm4, xmm4
	mulps   xmm0, xmm0	/* xmm0=rinvsq */
	/* fetch charges to xmm4 (temporary) */
	movss   xmm4, [esp + _qqOO]
	movss   xmm1, xmm0
	movhps  xmm4, [esp + _qqOH]
	mulss   xmm1, xmm0
	mulps   xmm3, xmm4	/* xmm3=vcoul */
	mulss   xmm1, xmm0	/* xmm1(0)=rinvsix */
	movaps  xmm2, xmm1	/* zero everything else in xmm2 */
	mulss   xmm2, xmm2	/* xmm2=rinvtwelve */

	mulss   xmm1, [esp + _c6]
	mulss   xmm2, [esp + _c12]
	movaps  xmm4, xmm2
	subss   xmm4, xmm1	/* vnbtot=vnb12-vnb6 */
	addps   xmm4, [esp + _vnbtot]
	mulss   xmm1, [esp + _six]
	mulss   xmm2, [esp + _twelve]	
	movaps  [esp + _vnbtot], xmm4
	subss   xmm2, xmm1	/* fsD+ fsR */
	addps   xmm2, xmm3	/* fsC+ fsD+ fsR */

	addps   xmm3, [esp + _vctot]
	mulps   xmm0, xmm2	/* total fscal */
	movaps  [esp + _vctot], xmm3	

	movaps  xmm1, xmm0
	movaps  xmm2, xmm0
	mulps   xmm0, [esp + _dxOO]
	mulps   xmm1, [esp + _dyOO]
	mulps   xmm2, [esp + _dzOO]
	/* initial update for j forces */
	xorps   xmm3, xmm3
	xorps   xmm4, xmm4
	xorps   xmm5, xmm5
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixO]
	addps   xmm1, [esp + _fiyO]
	addps   xmm2, [esp + _fizO]
	movaps  [esp + _fixO], xmm0
	movaps  [esp + _fiyO], xmm1
	movaps  [esp + _fizO], xmm2

	
	/* done with i O Now do i H1 & H2 simultaneously first get i particle coords: */
	movaps  xmm0, [esp + _ixH1]
	movaps  xmm1, [esp + _iyH1]
	movaps  xmm2, [esp + _izH1]	
	movaps  xmm3, [esp + _ixH2] 
	movaps  xmm4, [esp + _iyH2] 
	movaps  xmm5, [esp + _izH2] 
	subps   xmm0, [esp + _jxO]
	subps   xmm1, [esp + _jyO]
	subps   xmm2, [esp + _jzO]
	subps   xmm3, [esp + _jxO]
	subps   xmm4, [esp + _jyO]
	subps   xmm5, [esp + _jzO]
	movaps [esp + _dxH1O], xmm0
	movaps [esp + _dyH1O], xmm1
	movaps [esp + _dzH1O], xmm2
	movaps [esp + _dxH2O], xmm3
	movaps [esp + _dyH2O], xmm4
	movaps [esp + _dzH2O], xmm5
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	mulps xmm3, xmm3
	mulps xmm4, xmm4
	mulps xmm5, xmm5
	addps xmm0, xmm1
	addps xmm4, xmm3
	addps xmm0, xmm2	/* have rsqH1 in xmm0 */
	addps xmm4, xmm5	/* have rsqH2 in xmm4 */

	/* do invsqrt */
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1   /* do coulomb interaction */
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] /* rinv H1 - j water */
	mulps   xmm7, [esp + _half] /* rinv H2 - j water */ 

	/* assemble charges in xmm6 */
	xorps   xmm6, xmm6
	/* do coulomb interaction */
	movaps  xmm0, xmm3
	movss   xmm6, [esp + _qqOH]
	movaps  xmm4, xmm7
	movhps  xmm6, [esp + _qqHH]
	mulps   xmm0, xmm0	/* rinvsq */
	mulps   xmm4, xmm4	/* rinvsq */
	mulps   xmm3, xmm6	/* vcoul */
	mulps   xmm7, xmm6	/* vcoul */
	movaps  xmm2, xmm3
	addps   xmm2, xmm7	/* total vcoul */
	mulps   xmm0, xmm3	/* fscal */
	
	addps   xmm2, [esp + _vctot]
	mulps   xmm7, xmm4	/* fscal */
	movaps  [esp + _vctot], xmm2
	movaps  xmm1, xmm0
	movaps  xmm2, xmm0
	mulps   xmm0, [esp + _dxH1O]
	mulps   xmm1, [esp + _dyH1O]
	mulps   xmm2, [esp + _dzH1O]
	/* update forces H1 - j water */
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixH1]
	addps   xmm1, [esp + _fiyH1]
	addps   xmm2, [esp + _fizH1]
	movaps  [esp + _fixH1], xmm0
	movaps  [esp + _fiyH1], xmm1
	movaps  [esp + _fizH1], xmm2
	/* do forces H2 - j water */
	movaps xmm0, xmm7
	movaps xmm1, xmm7
	movaps xmm2, xmm7
	mulps   xmm0, [esp + _dxH2O]
	mulps   xmm1, [esp + _dyH2O]
	mulps   xmm2, [esp + _dzH2O]
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	mov     esi, [ebp + _faction]
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixH2]
	addps   xmm1, [esp + _fiyH2]
	addps   xmm2, [esp + _fizH2]
	movaps  [esp + _fixH2], xmm0
	movaps  [esp + _fiyH2], xmm1
	movaps  [esp + _fizH2], xmm2

	/* update j water forces from local variables */
	movlps  xmm0, [esi + eax*4]
	movlps  xmm1, [esi + eax*4 + 12]
	movhps  xmm1, [esi + eax*4 + 24]
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	movaps  xmm6, xmm5
	movaps  xmm7, xmm5
	shufps  xmm6, xmm6, 0b10
	shufps  xmm7, xmm7, 0b11
	addss   xmm5, [esi + eax*4 + 8]
	addss   xmm6, [esi + eax*4 + 20]
	addss   xmm7, [esi + eax*4 + 32]
	movss   [esi + eax*4 + 8], xmm5
	movss   [esi + eax*4 + 20], xmm6
	movss   [esi + eax*4 + 32], xmm7
	movaps   xmm5, xmm3
	unpcklps xmm3, xmm4
	unpckhps xmm5, xmm4
	addps    xmm0, xmm3
	addps    xmm1, xmm5
	movlps  [esi + eax*4], xmm0 
	movlps  [esi + eax*4 + 12], xmm1 
	movhps  [esi + eax*4 + 24], xmm1 
	
	dec dword ptr [esp + _innerk]
	jz    i1130_updateouterdata
	jmp   i1130_single_loop
i1130_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate  Oi forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixO]
	movaps xmm1, [esp + _fiyO] 
	movaps xmm2, [esp + _fizO]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	movaps xmm6, xmm0
	movss xmm7, xmm2
	movlhps xmm6, xmm1
	shufps  xmm6, xmm6, 0b1000	

	/* accumulate H1i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH1]
	movaps xmm1, [esp + _fiyH1]
	movaps xmm2, [esp + _fizH1]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 12]
	movss  xmm4, [edi + ecx*4 + 16]
	movss  xmm5, [edi + ecx*4 + 20]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 12], xmm3
	movss  [edi + ecx*4 + 16], xmm4
	movss  [edi + ecx*4 + 20], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* accumulate H2i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH2]
	movaps xmm1, [esp + _fiyH2]
	movaps xmm2, [esp + _fizH2]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 24]
	movss  xmm4, [edi + ecx*4 + 28]
	movss  xmm5, [edi + ecx*4 + 32]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 24], xmm3
	movss  [edi + ecx*4 + 28], xmm4
	movss  [edi + ecx*4 + 32], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* increment fshift force */ 
	movlps  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 8]
	addps  xmm3, xmm6
	addss  xmm4, xmm7
	movlps  [esi + edx*4],    xmm3
	movss  [esi + edx*4 + 8], xmm4

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz i1130_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp i1130_outer
i1130_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 1492
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret



.globl inl2120_sse
	.type inl2120_sse,@function
inl2120_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_argkrf,	60	
.equ		_argcrf,	64	
.equ		_type,		68
.equ		_ntype,		72
.equ		_nbfp,		76	
.equ		_Vnb,		80	
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ixO,		0
.equ		_iyO,		16
.equ		_izO,		32
.equ		_ixH1,		48
.equ		_iyH1,		64
.equ		_izH1,		80
.equ		_ixH2,		96
.equ		_iyH2,		112
.equ		_izH2,		128
.equ		_iqO,		144 
.equ		_iqH,		160 
.equ		_dxO,		176
.equ		_dyO,		192
.equ		_dzO,		208	
.equ		_dxH1,		224
.equ		_dyH1,		240
.equ		_dzH1,		256	
.equ		_dxH2,		272
.equ		_dyH2,		288
.equ		_dzH2,		304	
.equ		_qqO,		320
.equ		_qqH,		336
.equ		_c6,		352
.equ		_c12,		368
.equ		_six,		384
.equ		_twelve,	400		 
.equ		_vctot,		416
.equ		_vnbtot,	432
.equ		_fixO,		448
.equ		_fiyO,		464
.equ		_fizO,		480
.equ		_fixH1,		496
.equ		_fiyH1,		512
.equ		_fizH1,		528
.equ		_fixH2,		544
.equ		_fiyH2,		560
.equ		_fizH2,		576
.equ		_fjx,		592
.equ		_fjy,		608
.equ		_fjz,		624
.equ		_half,		640
.equ		_three,		656
.equ		_two,		672
.equ		_krf,		688
.equ		_crf,		704
.equ		_krsqO,		720
.equ		_krsqH1,	736
.equ		_krsqH2,	752	 		
.equ		_is3,		768
.equ		_ii3,		772
.equ		_ntia,		776	
.equ		_innerjjnr,	780
.equ		_innerk,	784
.equ		_salign,	788								
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 792		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_three]
	movups xmm2, [sse_six]
	movups xmm3, [sse_twelve]
	movups xmm4, [sse_two]
	movss xmm5, [ebp + _argkrf]
	movss xmm6, [ebp + _argcrf]

	movaps [esp + _half],  xmm0
	movaps [esp + _three], xmm1
	movaps [esp + _six],  xmm2
	movaps [esp + _twelve], xmm3
	movaps [esp + _two], xmm4
	shufps xmm5, xmm5, 0
	shufps xmm6, xmm6, 0
	movaps [esp + _krf], xmm5
	movaps [esp + _crf], xmm6
	
	/* assume we have at least one i particle - start directly */
	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	movss xmm4, [edx + ebx*4 + 4]	
	movss xmm5, [ebp + _facel]
	mulss  xmm3, xmm5
	mulss  xmm4, xmm5

	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	movaps [esp + _iqO], xmm3
	movaps [esp + _iqH], xmm4
	
	mov   edx, [ebp + _type]
	mov   ecx, [edx + ebx*4]
	shl   ecx, 1
	imul  ecx, [ebp + _ntype]      /* ecx = ntia = 2*ntype*type[ii0] */
	mov   [esp + _ntia], ecx		
.i2120_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2

	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx

	addss xmm3, [eax + ebx*4]
	addss xmm4, [eax + ebx*4 + 4]
	addss xmm5, [eax + ebx*4 + 8]		
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixO], xmm3
	movaps [esp + _iyO], xmm4
	movaps [esp + _izO], xmm5

	movss xmm3, xmm0
	movss xmm4, xmm1
	movss xmm5, xmm2
	addss xmm0, [eax + ebx*4 + 12]
	addss xmm1, [eax + ebx*4 + 16]
	addss xmm2, [eax + ebx*4 + 20]		
	addss xmm3, [eax + ebx*4 + 24]
	addss xmm4, [eax + ebx*4 + 28]
	addss xmm5, [eax + ebx*4 + 32]		

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixH1], xmm0
	movaps [esp + _iyH1], xmm1
	movaps [esp + _izH1], xmm2
	movaps [esp + _ixH2], xmm3
	movaps [esp + _iyH2], xmm4
	movaps [esp + _izH2], xmm5
	
	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _vnbtot], xmm4
	movaps [esp + _fixO], xmm4
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm4
	movaps [esp + _fixH1], xmm4
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm4
	movaps [esp + _fixH2], xmm4
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i2120_unroll_loop
	jmp   .i2120_odd_inner
.i2120_unroll_loop:
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */

	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	movaps xmm4, xmm3	     /* and in xmm4 */
	mulps  xmm3, [esp + _iqO]
	mulps  xmm4, [esp + _iqH]

	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	movd  mm2, ecx
	movd  mm3, edx

	movaps  [esp + _qqO], xmm3
	movaps  [esp + _qqH], xmm4
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6

	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	
	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ixO-izO to xmm4-xmm6 */
	movaps xmm4, [esp + _ixO]
	movaps xmm5, [esp + _iyO]
	movaps xmm6, [esp + _izO]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dxO], xmm4
	movaps [esp + _dyO], xmm5
	movaps [esp + _dzO], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	movaps xmm7, xmm4
	/* rsqO in xmm7 */

	/* move ixH1-izH1 to xmm4-xmm6 */
	movaps xmm4, [esp + _ixH1]
	movaps xmm5, [esp + _iyH1]
	movaps xmm6, [esp + _izH1]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dxH1], xmm4
	movaps [esp + _dyH1], xmm5
	movaps [esp + _dzH1], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm6, xmm5
	addps xmm6, xmm4
	/* rsqH1 in xmm6 */

	/* move ixH2-izH2 to xmm3-xmm5 */ 
	movaps xmm3, [esp + _ixH2]
	movaps xmm4, [esp + _iyH2]
	movaps xmm5, [esp + _izH2]

	/* calc dr */
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2

	/* store dr */
	movaps [esp + _dxH2], xmm3
	movaps [esp + _dyH2], xmm4
	movaps [esp + _dzH2], xmm5
	/* square it */
	mulps xmm3,xmm3
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	addps xmm5, xmm4
	addps xmm5, xmm3
	/* rsqH2 in xmm5, rsqH1 in xmm6, rsqO in xmm7 */

	movaps xmm0, xmm5
	movaps xmm1, xmm6
	movaps xmm2, xmm7

	mulps  xmm0, [esp + _krf]	
	mulps  xmm1, [esp + _krf]	
	mulps  xmm2, [esp + _krf]	

	movaps [esp + _krsqH2], xmm0
	movaps [esp + _krsqH1], xmm1
	movaps [esp + _krsqO], xmm2
	
	/* start with rsqO - seed in xmm2 */	
	rsqrtps xmm2, xmm7
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm7	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  xmm7, xmm4	/* rinvO in xmm7 */
	/* rsqH1 - seed in xmm2 */
	rsqrtps xmm2, xmm6
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm6	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  xmm6, xmm4	/* rinvH1 in xmm6 */
	/* rsqH2 - seed in xmm2 */
	rsqrtps xmm2, xmm5
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm5	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  xmm5, xmm4	/* rinvH2 in xmm5 */

	/* do O interactions */
	movaps  xmm4, xmm7	
	mulps   xmm4, xmm4	/* xmm7=rinv, xmm4=rinvsq */
	movaps xmm1, xmm4
	mulps  xmm1, xmm4
	mulps  xmm1, xmm4	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */
	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm3, xmm2
	subps  xmm3, xmm1	/* vnb=vnb12-vnb6 */		
	addps  xmm3, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1	/* nb part of fs */ 

	movaps xmm0, xmm7
	movaps xmm1, [esp + _krsqO]
	addps  xmm0, xmm1
	mulps  xmm1, [esp + _two]
	subps  xmm0, [esp + _crf] /* xmm0=rinv+ krsq-crf */
	subps  xmm7, xmm1
	mulps  xmm0, [esp + _qqO]
	mulps  xmm7, [esp + _qqO]
	addps  xmm2, xmm7

	mulps  xmm4, xmm2	/* total fsO in xmm4 */

	addps  xmm0, [esp + _vctot]
	movaps [esp + _vnbtot], xmm3
	movaps [esp + _vctot], xmm0

	movaps xmm0, [esp + _dxO]
	movaps xmm1, [esp + _dyO]
	movaps xmm2, [esp + _dzO]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

	/* update O forces */
	movaps xmm3, [esp + _fixO]
	movaps xmm4, [esp + _fiyO]
	movaps xmm7, [esp + _fizO]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixO], xmm3
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm7
	/* update j forces with water O */
	movaps [esp + _fjx], xmm0
	movaps [esp + _fjy], xmm1
	movaps [esp + _fjz], xmm2

	/* H1 interactions */
	movaps  xmm4, xmm6	
	mulps   xmm4, xmm4	/* xmm6=rinv, xmm4=rinvsq */
	movaps  xmm7, xmm6
	movaps  xmm0, [esp + _krsqH1]
	addps   xmm6, xmm0	/* xmm6=rinv+ krsq */
	mulps   xmm0, [esp + _two]
	subps   xmm6, [esp + _crf]
	subps   xmm7, xmm0	/* xmm7=rinv-2*krsq */
	mulps   xmm6, [esp + _qqH] /* vcoul */
	mulps   xmm7, [esp + _qqH]
	mulps  xmm4, xmm7		/* total fsH1 in xmm4 */
	
	addps  xmm6, [esp + _vctot]

	movaps xmm0, [esp + _dxH1]
	movaps xmm1, [esp + _dyH1]
	movaps xmm2, [esp + _dzH1]
	movaps [esp + _vctot], xmm6
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

	/* update H1 forces */
	movaps xmm3, [esp + _fixH1]
	movaps xmm4, [esp + _fiyH1]
	movaps xmm7, [esp + _fizH1]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixH1], xmm3
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm7
	/* update j forces with water H1 */
	addps  xmm0, [esp + _fjx]
	addps  xmm1, [esp + _fjy]
	addps  xmm2, [esp + _fjz]
	movaps [esp + _fjx], xmm0
	movaps [esp + _fjy], xmm1
	movaps [esp + _fjz], xmm2

	/* H2 interactions */
	movaps  xmm4, xmm5	
	mulps   xmm4, xmm4	/* xmm5=rinv, xmm4=rinvsq */
	movaps  xmm7, xmm5
	movaps  xmm0, [esp + _krsqH2]
	addps   xmm5, xmm0	/* xmm5=rinv+ krsq */
	mulps   xmm0, [esp + _two]
	subps   xmm5, [esp + _crf]
	subps   xmm7, xmm0	/* xmm7=rinv-2*krsq */
	mulps   xmm5, [esp + _qqH] /* vcoul */
	mulps   xmm7, [esp + _qqH]
	mulps  xmm4, xmm7		/* total fsH2 in xmm4 */
	
	addps  xmm5, [esp + _vctot]

	movaps xmm0, [esp + _dxH2]
	movaps xmm1, [esp + _dyH2]
	movaps xmm2, [esp + _dzH2]
	movaps [esp + _vctot], xmm5
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

	/* update H2 forces */
	movaps xmm3, [esp + _fixH2]
	movaps xmm4, [esp + _fiyH2]
	movaps xmm7, [esp + _fizH2]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixH2], xmm3
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm7

	mov edi, [ebp + _faction]
	/* update j forces */
	addps xmm0, [esp + _fjx]
	addps xmm1, [esp + _fjy]
	addps xmm2, [esp + _fjz]

	movlps xmm4, [edi + eax*4]
	movlps xmm7, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm7, [edi + edx*4]
	
	movaps xmm3, xmm4
	shufps xmm3, xmm7, 0b10001000
	shufps xmm4, xmm7, 0b11011101			      
	/* xmm3 has fjx, xmm4 has fjy */
	subps xmm3, xmm0
	subps xmm4, xmm1
	/* unpack them back for storing */
	movaps xmm7, xmm3
	unpcklps xmm7, xmm4
	unpckhps xmm3, xmm4	
	movlps [edi + eax*4], xmm7
	movlps [edi + ecx*4], xmm3
	movhps [edi + ebx*4], xmm7
	movhps [edi + edx*4], xmm3
	/* finally z forces */
	movss  xmm0, [edi + eax*4 + 8]
	movss  xmm1, [edi + ebx*4 + 8]
	movss  xmm3, [edi + ecx*4 + 8]
	movss  xmm4, [edi + edx*4 + 8]
	subss  xmm0, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm1, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm3, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm4, xmm2
	movss  [edi + eax*4 + 8], xmm0
	movss  [edi + ebx*4 + 8], xmm1
	movss  [edi + ecx*4 + 8], xmm3
	movss  [edi + edx*4 + 8], xmm4
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i2120_odd_inner
	jmp   .i2120_unroll_loop
.i2120_odd_inner:	
	add   [esp + _innerk],  4
	jnz   .i2120_odd_loop
	jmp   .i2120_updateouterdata
.i2120_odd_loop:
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	add   [esp + _innerjjnr],  4	

 	xorps xmm4, xmm4
	movss xmm4, [esp + _iqO]
	mov esi, [ebp + _charge] 
	movhps xmm4, [esp + _iqH]     
	movss xmm3, [esi + eax*4]	/* charge in xmm3 */
	shufps xmm3, xmm3, 0
	mulps xmm3, xmm4
	movaps [esp + _qqO], xmm3	/* use oxygen qq for storage */

	xorps xmm6, xmm6
	mov esi, [ebp + _type]
	mov ebx, [esi + eax*4]
	mov esi, [ebp + _nbfp]
	shl ebx, 1	
	add ebx, [esp + _ntia]
	movlps xmm6, [esi + ebx*4]
	movaps xmm7, xmm6
	shufps xmm6, xmm6, 0b11111100
	shufps xmm7, xmm7, 0b11111101
	movaps [esp + _c6], xmm6
	movaps [esp + _c12], xmm7

	mov esi, [ebp + _pos]
	lea   eax, [eax + eax*2]  
	
	/* move j coords to xmm0-xmm2 */
	movss xmm0, [esi + eax*4]
	movss xmm1, [esi + eax*4 + 4]
	movss xmm2, [esi + eax*4 + 8]
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	
	movss xmm3, [esp + _ixO]
	movss xmm4, [esp + _iyO]
	movss xmm5, [esp + _izO]
		
	movlps xmm6, [esp + _ixH1]
	movlps xmm7, [esp + _ixH2]
	unpcklps xmm6, xmm7
	movlhps xmm3, xmm6
	movlps xmm6, [esp + _iyH1]
	movlps xmm7, [esp + _iyH2]
	unpcklps xmm6, xmm7
	movlhps xmm4, xmm6
	movlps xmm6, [esp + _izH1]
	movlps xmm7, [esp + _izH2]
	unpcklps xmm6, xmm7
	movlhps xmm5, xmm6

	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	
	movaps [esp + _dxO], xmm3
	movaps [esp + _dyO], xmm4
	movaps [esp + _dzO], xmm5

	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5

	addps  xmm4, xmm3
	addps  xmm4, xmm5
	/* rsq in xmm4 */

	movaps xmm0, xmm4
	mulps xmm0, [esp + _krf]
	movaps [esp + _krsqO], xmm0
	
	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */
	movaps xmm1, xmm4
	mulss  xmm1, xmm4
	mulss  xmm1, xmm4	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulss  xmm2, xmm2	/* xmm2=rinvtwelve */
	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subss  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulss  xmm1, [esp + _six]
	mulss  xmm2, [esp + _twelve]
	subss  xmm2, xmm1

	movaps xmm1, xmm0	/* xmm1=rinv */
	movaps xmm3, [esp + _krsqO]
	addps  xmm0, xmm3	/* xmm0=rinv+ krsq */
	mulps  xmm3, [esp + _two]
	subps  xmm0, [esp + _crf] /* xmm0=rinv+ krsq-crf */
	subps  xmm1, xmm3	/* xmm1=rinv-2*krsq */
	mulps  xmm0, [esp + _qqO]	/* xmm0=vcoul */
	mulps  xmm1, [esp + _qqO] 	/* xmm1=coul part of fs */

	addps xmm2, xmm1	/* total fs */
	
	mulps  xmm4, xmm2	/* xmm4=total fscal */
	addps  xmm0, [esp + _vctot]
	movaps [esp + _vctot], xmm0
	
	movaps xmm0, [esp + _dxO]
	movaps xmm1, [esp + _dyO]
	movaps xmm2, [esp + _dzO]

	movaps [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	movss  xmm3, [esp + _fixO]	
	movss  xmm4, [esp + _fiyO]	
	movss  xmm5, [esp + _fizO]	
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esp + _fixO], xmm3	
	movss  [esp + _fiyO], xmm4	
	movss  [esp + _fizO], xmm5	/* updated the O force now do the H's */
	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2
	shufps xmm3, xmm3, 0b11100110	/* shift right */
	shufps xmm4, xmm4, 0b11100110
	shufps xmm5, xmm5, 0b11100110
	addss  xmm3, [esp + _fixH1]
	addss  xmm4, [esp + _fiyH1]
	addss  xmm5, [esp + _fizH1]
	movss  [esp + _fixH1], xmm3	
	movss  [esp + _fiyH1], xmm4	
	movss  [esp + _fizH1], xmm5	/* updated the H1 force */

	mov edi, [ebp + _faction]
	shufps xmm3, xmm3, 0b11100111	/* shift right */
	shufps xmm4, xmm4, 0b11100111
	shufps xmm5, xmm5, 0b11100111
	addss  xmm3, [esp + _fixH2]
	addss  xmm4, [esp + _fiyH2]
	addss  xmm5, [esp + _fizH2]
	movss  [esp + _fixH2], xmm3	
	movss  [esp + _fiyH2], xmm4	
	movss  [esp + _fizH2], xmm5	/* updated the H2 force */

	/* the fj's - start by accumulating the tx/ty/tz force in xmm0, xmm1 */
	xorps  xmm5, xmm5
	movaps xmm3, xmm0
	movlps xmm6, [edi + eax*4]
	movss  xmm7, [edi + eax*4 + 8]
	unpcklps xmm3, xmm1
	movlhps  xmm3, xmm5	
	unpckhps xmm0, xmm1		
	addps    xmm0, xmm3
	movhlps  xmm3, xmm0	
	addps    xmm0, xmm3	/* x,y sum in xmm0 */

	movhlps  xmm1, xmm2
	addss    xmm2, xmm1
	shufps   xmm1, xmm1, 1 
	addss    xmm2, xmm1    /* z sum in xmm2 */
	subps    xmm6, xmm0
	subss    xmm7, xmm2
	
	movlps [edi + eax*4],     xmm6
	movss  [edi + eax*4 + 8], xmm7

	dec dword ptr [esp + _innerk]
	jz    .i2120_updateouterdata
	jmp   .i2120_odd_loop
.i2120_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate  Oi forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixO]
	movaps xmm1, [esp + _fiyO]
	movaps xmm2, [esp + _fizO]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	movaps xmm6, xmm0
	movss xmm7, xmm2
	movlhps xmm6, xmm1
	shufps  xmm6, xmm6, 0b1000	

	/* accumulate H1i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH1]
	movaps xmm1, [esp + _fiyH1]
	movaps xmm2, [esp + _fizH1]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 12]
	movss  xmm4, [edi + ecx*4 + 16]
	movss  xmm5, [edi + ecx*4 + 20]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 12], xmm3
	movss  [edi + ecx*4 + 16], xmm4
	movss  [edi + ecx*4 + 20], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* accumulate H2i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH2]
	movaps xmm1, [esp + _fiyH2]
	movaps xmm2, [esp + _fizH2]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 24]
	movss  xmm4, [edi + ecx*4 + 28]
	movss  xmm5, [edi + ecx*4 + 32]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 24], xmm3
	movss  [edi + ecx*4 + 28], xmm4
	movss  [edi + ecx*4 + 32], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* increment fshift force */ 
	movlps  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 8]
	addps  xmm3, xmm6
	addss  xmm4, xmm7
	movlps  [esi + edx*4],    xmm3
	movss  [esi + edx*4 + 8], xmm4

	mov   edx, [ebp + _gid]  
	mov   edx, [edx]
	add   [ebp + _gid],  4	

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		
        
	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i2120_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i2120_outer
.i2120_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 792
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret


	
.globl inl2130_sse
	.type inl2130_sse,@function
inl2130_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_argkrf,	60
.equ		_argcrf,	64
.equ		_type,		68
.equ		_ntype,		72
.equ		_nbfp,		76	
.equ		_Vnb,		80
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ixO,		0
.equ		_iyO,		16
.equ		_izO,		32
.equ		_ixH1,		48
.equ		_iyH1,		64
.equ		_izH1,		80
.equ		_ixH2,		96
.equ		_iyH2,		112
.equ		_izH2,		128
.equ		_jxO,		144
.equ		_jyO,		160
.equ		_jzO,		176
.equ		_jxH1,		192
.equ		_jyH1,		208
.equ		_jzH1,		224
.equ		_jxH2,		240
.equ		_jyH2,		256
.equ		_jzH2,		272
.equ		_dxOO,		288
.equ		_dyOO,		304
.equ		_dzOO,		320	
.equ		_dxOH1,		336
.equ		_dyOH1,		352
.equ		_dzOH1,		368	
.equ		_dxOH2,		384
.equ		_dyOH2,		400
.equ		_dzOH2,		416	
.equ		_dxH1O,		432
.equ		_dyH1O,		448
.equ		_dzH1O,		464	
.equ		_dxH1H1,	480
.equ		_dyH1H1,	496
.equ		_dzH1H1,	512	
.equ		_dxH1H2,	528
.equ		_dyH1H2,	544
.equ		_dzH1H2,	560	
.equ		_dxH2O,		576
.equ		_dyH2O,		592
.equ		_dzH2O,		608	
.equ		_dxH2H1,	624
.equ		_dyH2H1,	640
.equ		_dzH2H1,	656	
.equ		_dxH2H2,	672
.equ		_dyH2H2,	688
.equ		_dzH2H2,	704
.equ		_qqOO,		720
.equ		_qqOH,		736
.equ		_qqHH,		752
.equ		_c6,		768
.equ		_c12,		784
.equ		_six,		800
.equ		_twelve,	816		 
.equ		_vctot,		832
.equ		_vnbtot,	848
.equ		_fixO,		864
.equ		_fiyO,		880
.equ		_fizO,		896
.equ		_fixH1,		912
.equ		_fiyH1,		928
.equ		_fizH1,		944
.equ		_fixH2,		960
.equ		_fiyH2,		976
.equ		_fizH2,		992
.equ		_fjxO,		1008
.equ		_fjyO,		1024
.equ		_fjzO,		1040
.equ		_fjxH1,		1056
.equ		_fjyH1,		1072
.equ		_fjzH1,		1088
.equ		_fjxH2,		1104
.equ		_fjyH2,		1120
.equ		_fjzH2,		1136
.equ		_half,		1152
.equ		_three,		1168
.equ		_rsqOO,		1184
.equ		_rsqOH1,	1200
.equ		_rsqOH2,	1216
.equ		_rsqH1O,	1232
.equ		_rsqH1H1,	1248
.equ		_rsqH1H2,	1264
.equ		_rsqH2O,	1280
.equ		_rsqH2H1,	1296
.equ		_rsqH2H2,	1312
.equ		_rinvOO,	1328
.equ		_rinvOH1,	1344
.equ		_rinvOH2,	1360
.equ		_rinvH1O,	1376
.equ		_rinvH1H1,	1392
.equ		_rinvH1H2,	1408
.equ		_rinvH2O,	1424
.equ		_rinvH2H1,	1440
.equ		_rinvH2H2,	1456
.equ		_two,		1472
.equ		_krf,		1488	
.equ		_crf,		1504
.equ		_is3,		1520
.equ		_ii3,		1524
.equ		_innerjjnr,	1528
.equ		_innerk,	1532
.equ		_salign,	1536							
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 1540		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_three]
	movups xmm2, [sse_six]
	movups xmm3, [sse_twelve]
	movups xmm4, [sse_two]
	movss xmm5, [ebp + _argkrf]
	movss xmm6, [ebp + _argcrf]
	
	movaps [esp + _half],  xmm0
	movaps [esp + _three], xmm1
	movaps [esp + _six],  xmm2
	movaps [esp + _twelve], xmm3
	movaps [esp + _two], xmm4
	shufps xmm5, xmm5, 0
	shufps xmm6, xmm6, 0
	movaps [esp + _krf], xmm5
	movaps [esp + _crf], xmm6
	
	/* assume we have at least one i particle - start directly */
	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	movss xmm4, xmm3	
	movss xmm5, [edx + ebx*4 + 4]	
	movss xmm6, [ebp + _facel]
	mulss  xmm3, xmm3
	mulss  xmm4, xmm5
	mulss  xmm5, xmm5
	mulss  xmm3, xmm6
	mulss  xmm4, xmm6
	mulss  xmm5, xmm6
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _qqOO], xmm3
	movaps [esp + _qqOH], xmm4
	movaps [esp + _qqHH], xmm5
		
	xorps xmm0, xmm0
	mov   edx, [ebp + _type]
	mov   ecx, [edx + ebx*4]
	shl   ecx, 1
	mov   edx, ecx
	imul  ecx, [ebp + _ntype]      /* ecx = ntia = 2*ntype*type[ii0] */
	add   edx, ecx
	mov   eax, [ebp + _nbfp]
	movlps xmm0, [eax + edx*4] 
	movaps xmm1, xmm0
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0b01010101
	movaps [esp + _c6], xmm0
	movaps [esp + _c12], xmm1

.i2130_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx	
	
	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2
	addss xmm3, [eax + ebx*4]
	addss xmm4, [eax + ebx*4 + 4]
	addss xmm5, [eax + ebx*4 + 8]		
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixO], xmm3
	movaps [esp + _iyO], xmm4
	movaps [esp + _izO], xmm5

	movss xmm3, xmm0
	movss xmm4, xmm1
	movss xmm5, xmm2
	addss xmm0, [eax + ebx*4 + 12]
	addss xmm1, [eax + ebx*4 + 16]
	addss xmm2, [eax + ebx*4 + 20]		
	addss xmm3, [eax + ebx*4 + 24]
	addss xmm4, [eax + ebx*4 + 28]
	addss xmm5, [eax + ebx*4 + 32]		

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixH1], xmm0
	movaps [esp + _iyH1], xmm1
	movaps [esp + _izH1], xmm2
	movaps [esp + _ixH2], xmm3
	movaps [esp + _iyH2], xmm4
	movaps [esp + _izH2], xmm5

	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _vnbtot], xmm4
	movaps [esp + _fixO], xmm4
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm4
	movaps [esp + _fixH1], xmm4
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm4
	movaps [esp + _fixH2], xmm4
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i2130_unroll_loop
	jmp   .i2130_single_check
.i2130_unroll_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */

	mov   eax, [edx]	
	mov   ebx, [edx + 4] 
	mov   ecx, [edx + 8]
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	
	
	/* move j coordinates to local temp variables */
	movlps xmm2, [esi + eax*4]
	movlps xmm3, [esi + eax*4 + 12]
	movlps xmm4, [esi + eax*4 + 24]

	movlps xmm5, [esi + ebx*4]
	movlps xmm6, [esi + ebx*4 + 12]
	movlps xmm7, [esi + ebx*4 + 24]

	movhps xmm2, [esi + ecx*4]
	movhps xmm3, [esi + ecx*4 + 12]
	movhps xmm4, [esi + ecx*4 + 24]

	movhps xmm5, [esi + edx*4]
	movhps xmm6, [esi + edx*4 + 12]
	movhps xmm7, [esi + edx*4 + 24]

	/* current state: */	
	/* xmm2= jxOa  jyOa  jxOc  jyOc */
	/* xmm3= jxH1a jyH1a jxH1c jyH1c */
	/* xmm4= jxH2a jyH2a jxH2c jyH2c */
	/* xmm5= jxOb  jyOb  jxOd  jyOd */
	/* xmm6= jxH1b jyH1b jxH1d jyH1d */
	/* xmm7= jxH2b jyH2b jxH2d jyH2d */
	
	movaps xmm0, xmm2
	movaps xmm1, xmm3
	unpcklps xmm0, xmm5	/* xmm0= jxOa  jxOb  jyOa  jyOb */
	unpcklps xmm1, xmm6	/* xmm1= jxH1a jxH1b jyH1a jyH1b */
	unpckhps xmm2, xmm5	/* xmm2= jxOc  jxOd  jyOc  jyOd */
	unpckhps xmm3, xmm6	/* xmm3= jxH1c jxH1d jyH1c jyH1d */
	movaps xmm5, xmm4
	movaps   xmm6, xmm0
	unpcklps xmm4, xmm7	/* xmm4= jxH2a jxH2b jyH2a jyH2b */		
	unpckhps xmm5, xmm7	/* xmm5= jxH2c jxH2d jyH2c jyH2d */
	movaps   xmm7, xmm1
	movlhps  xmm0, xmm2	/* xmm0= jxOa  jxOb  jxOc  jxOd */
	movaps [esp + _jxO], xmm0
	movhlps  xmm2, xmm6	/* xmm2= jyOa  jyOb  jyOc  jyOd */
	movaps [esp + _jyO], xmm2
	movlhps  xmm1, xmm3
	movaps [esp + _jxH1], xmm1
	movhlps  xmm3, xmm7
	movaps   xmm6, xmm4
	movaps [esp + _jyH1], xmm3
	movlhps  xmm4, xmm5
	movaps [esp + _jxH2], xmm4
	movhlps  xmm5, xmm6
	movaps [esp + _jyH2], xmm5

	movss  xmm0, [esi + eax*4 + 8]
	movss  xmm1, [esi + eax*4 + 20]
	movss  xmm2, [esi + eax*4 + 32]

	movss  xmm3, [esi + ecx*4 + 8]
	movss  xmm4, [esi + ecx*4 + 20]
	movss  xmm5, [esi + ecx*4 + 32]

	movhps xmm0, [esi + ebx*4 + 4]
	movhps xmm1, [esi + ebx*4 + 16]
	movhps xmm2, [esi + ebx*4 + 28]
	
	movhps xmm3, [esi + edx*4 + 4]
	movhps xmm4, [esi + edx*4 + 16]
	movhps xmm5, [esi + edx*4 + 28]
	
	shufps xmm0, xmm3, 0b11001100
	shufps xmm1, xmm4, 0b11001100
	shufps xmm2, xmm5, 0b11001100
	movaps [esp + _jzO],  xmm0
	movaps [esp + _jzH1],  xmm1
	movaps [esp + _jzH2],  xmm2

	movaps xmm0, [esp + _ixO]
	movaps xmm1, [esp + _iyO]
	movaps xmm2, [esp + _izO]
	movaps xmm3, [esp + _ixO]
	movaps xmm4, [esp + _iyO]
	movaps xmm5, [esp + _izO]
	subps  xmm0, [esp + _jxO]
	subps  xmm1, [esp + _jyO]
	subps  xmm2, [esp + _jzO]
	subps  xmm3, [esp + _jxH1]
	subps  xmm4, [esp + _jyH1]
	subps  xmm5, [esp + _jzH1]
	movaps [esp + _dxOO], xmm0
	movaps [esp + _dyOO], xmm1
	movaps [esp + _dzOO], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxOH1], xmm3
	movaps [esp + _dyOH1], xmm4
	movaps [esp + _dzOH1], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqOO], xmm0
	movaps [esp + _rsqOH1], xmm3

	movaps xmm0, [esp + _ixO]
	movaps xmm1, [esp + _iyO]
	movaps xmm2, [esp + _izO]
	movaps xmm3, [esp + _ixH1]
	movaps xmm4, [esp + _iyH1]
	movaps xmm5, [esp + _izH1]
	subps  xmm0, [esp + _jxH2]
	subps  xmm1, [esp + _jyH2]
	subps  xmm2, [esp + _jzH2]
	subps  xmm3, [esp + _jxO]
	subps  xmm4, [esp + _jyO]
	subps  xmm5, [esp + _jzO]
	movaps [esp + _dxOH2], xmm0
	movaps [esp + _dyOH2], xmm1
	movaps [esp + _dzOH2], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH1O], xmm3
	movaps [esp + _dyH1O], xmm4
	movaps [esp + _dzH1O], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqOH2], xmm0
	movaps [esp + _rsqH1O], xmm3

	movaps xmm0, [esp + _ixH1]
	movaps xmm1, [esp + _iyH1]
	movaps xmm2, [esp + _izH1]
	movaps xmm3, [esp + _ixH1]
	movaps xmm4, [esp + _iyH1]
	movaps xmm5, [esp + _izH1]
	subps  xmm0, [esp + _jxH1]
	subps  xmm1, [esp + _jyH1]
	subps  xmm2, [esp + _jzH1]
	subps  xmm3, [esp + _jxH2]
	subps  xmm4, [esp + _jyH2]
	subps  xmm5, [esp + _jzH2]
	movaps [esp + _dxH1H1], xmm0
	movaps [esp + _dyH1H1], xmm1
	movaps [esp + _dzH1H1], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH1H2], xmm3
	movaps [esp + _dyH1H2], xmm4
	movaps [esp + _dzH1H2], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqH1H1], xmm0
	movaps [esp + _rsqH1H2], xmm3

	movaps xmm0, [esp + _ixH2]
	movaps xmm1, [esp + _iyH2]
	movaps xmm2, [esp + _izH2]
	movaps xmm3, [esp + _ixH2]
	movaps xmm4, [esp + _iyH2]
	movaps xmm5, [esp + _izH2]
	subps  xmm0, [esp + _jxO]
	subps  xmm1, [esp + _jyO]
	subps  xmm2, [esp + _jzO]
	subps  xmm3, [esp + _jxH1]
	subps  xmm4, [esp + _jyH1]
	subps  xmm5, [esp + _jzH1]
	movaps [esp + _dxH2O], xmm0
	movaps [esp + _dyH2O], xmm1
	movaps [esp + _dzH2O], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH2H1], xmm3
	movaps [esp + _dyH2H1], xmm4
	movaps [esp + _dzH2H1], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm4, xmm3
	addps  xmm4, xmm5
	movaps [esp + _rsqH2O], xmm0
	movaps [esp + _rsqH2H1], xmm4

	movaps xmm0, [esp + _ixH2]
	movaps xmm1, [esp + _iyH2]
	movaps xmm2, [esp + _izH2]
	subps  xmm0, [esp + _jxH2]
	subps  xmm1, [esp + _jyH2]
	subps  xmm2, [esp + _jzH2]
	movaps [esp + _dxH2H2], xmm0
	movaps [esp + _dyH2H2], xmm1
	movaps [esp + _dzH2H2], xmm2
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2
	movaps [esp + _rsqH2H2], xmm0
		
	/* start doing invsqrt use rsq values in xmm0, xmm4 */
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] /* rinvH2H2 */
	mulps   xmm7, [esp + _half] /* rinvH2H1 */
	movaps  [esp + _rinvH2H2], xmm3
	movaps  [esp + _rinvH2H1], xmm7
	
	rsqrtps xmm1, [esp + _rsqOO]
	rsqrtps xmm5, [esp + _rsqOH1]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqOO]
	mulps   xmm5, [esp + _rsqOH1]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvOO], xmm3
	movaps  [esp + _rinvOH1], xmm7
	
	rsqrtps xmm1, [esp + _rsqOH2]
	rsqrtps xmm5, [esp + _rsqH1O]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqOH2]
	mulps   xmm5, [esp + _rsqH1O]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvOH2], xmm3
	movaps  [esp + _rinvH1O], xmm7
	
	rsqrtps xmm1, [esp + _rsqH1H1]
	rsqrtps xmm5, [esp + _rsqH1H2]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqH1H1]
	mulps   xmm5, [esp + _rsqH1H2]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvH1H1], xmm3
	movaps  [esp + _rinvH1H2], xmm7
	
	rsqrtps xmm1, [esp + _rsqH2O]
	movaps  xmm2, xmm1
	mulps   xmm1, xmm1
	movaps  xmm3, [esp + _three]
	mulps   xmm1, [esp + _rsqH2O]
	subps   xmm3, xmm1
	mulps   xmm3, xmm2
	mulps   xmm3, [esp + _half] 
	movaps  [esp + _rinvH2O], xmm3

	/* start with OO interaction */
	movaps xmm0, [esp + _rinvOO]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]
	mulps  xmm0, xmm0
	movaps xmm1, xmm0
	mulps  xmm1, xmm0
	mulps  xmm1, xmm0	/* xmm1=rinvsix */
	mulps  xmm5, [esp + _rsqOO] /* xmm5=krsq */
	movaps xmm6, xmm5
	addps  xmm6, xmm7	/* xmm6=rinv+ krsq */
	subps  xmm6, [esp + _crf]
	
	mulps  xmm6, [esp + _qqOO] /* xmm6=voul=qq*(rinv+ krsq-crf) */
	mulps xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqOO] /* xmm7 = coul part of fscal */
	
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */
	mulps  xmm1, [esp + _c6]	
	mulps  xmm2, [esp + _c12]	
	movaps xmm3, xmm2
	subps  xmm3, xmm1	/* xmm3=vnb12-vnb6 */
	addps  xmm3, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	movaps [esp + _vnbtot], xmm3
	subps  xmm2, xmm1
	addps  xmm2, xmm7
	addps  xmm6, [esp + _vctot] /* local vctot summation variable */
	mulps  xmm0, xmm2
	
	movaps xmm1, xmm0
	movaps xmm2, xmm0

	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOO]
	mulps xmm1, [esp + _dyOO]
	mulps xmm2, [esp + _dzOO]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* O-H1 interaction */
	movaps xmm0, [esp + _rinvOH1]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]
	movaps xmm1, xmm0
	mulps  xmm5, [esp + _rsqOH1] /* xmm5=krsq */
	movaps xmm4, xmm5
	addps  xmm4, xmm7	/* xmm4=rinv+ krsq */
	mulps  xmm0, xmm0
	subps  xmm4, [esp + _crf]
	mulps  xmm4, [esp + _qqOH] /* xmm4=voul=qq*(rinv+ krsq) */
	mulps  xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqOH] /* xmm7 = coul part of fscal */
	addps  xmm6, xmm4	/* add to local vctot */
	mulps xmm0, xmm7	/* fsOH1  */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	
	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOH1]
	mulps xmm1, [esp + _dyOH1]
	mulps xmm2, [esp + _dzOH1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* O-H2 interaction */ 
	movaps xmm0, [esp + _rinvOH2]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]	
	movaps xmm1, xmm0
	mulps  xmm5, [esp + _rsqOH2] /* xmm5=krsq */
	movaps xmm4, xmm5
	addps  xmm4, xmm7	/* xmm4=r inv+ krsq */
	mulps xmm0, xmm0
	subps  xmm4, [esp + _crf]
	mulps  xmm4, [esp + _qqOH] /* xmm4=voul=qq*(rinv+ krsq) */
	mulps  xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqOH] /* xmm7 = coul part of fscal */
	addps  xmm6, xmm4	/* add to local vctot */
	mulps xmm0, xmm7	/* fsOH2 */
	movaps xmm1, xmm0
	movaps xmm2, xmm0

	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOH2]
	mulps xmm1, [esp + _dyOH2]
	mulps xmm2, [esp + _dzOH2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* H1-O interaction */
	movaps xmm0, [esp + _rinvH1O]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]	
	movaps xmm1, xmm0
	mulps  xmm5, [esp + _rsqH1O] /* xmm5=krsq */
	movaps xmm4, xmm5
	addps  xmm4, xmm7	/* xmm4=rinv+ krsq */
	mulps xmm0, xmm0
	subps  xmm4, [esp + _crf]
	mulps  xmm4, [esp + _qqOH] /* xmm4=voul=qq*(rinv+ krsq) */
	mulps  xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqOH] /* xmm7 = coul part of fscal */
	addps  xmm6, xmm4	/* add to local vctot */
	mulps xmm0, xmm7	/* fsOH2 */
	movaps xmm1, xmm0
	movaps xmm2, xmm0

	movaps xmm3, [esp + _fjxO]
	movaps xmm4, [esp + _fjyO]
	movaps xmm5, [esp + _fjzO]
	mulps xmm0, [esp + _dxH1O]
	mulps xmm1, [esp + _dyH1O]
	mulps xmm2, [esp + _dzH1O]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H1-H1 interaction */
	movaps xmm0, [esp + _rinvH1H1]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]	
	movaps xmm1, xmm0
	mulps  xmm5, [esp + _rsqH1H1] /* xmm5=krsq */
	movaps xmm4, xmm5
	addps  xmm4, xmm7	/* xmm4=r inv+ krsq */
	subps  xmm4, [esp + _crf]
	mulps xmm0, xmm0
	mulps  xmm4, [esp + _qqHH] /* xmm4=voul=qq*(rinv+ krsq) */
	mulps  xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqHH] /* xmm7 = coul part of fscal */
	addps  xmm6, xmm4	/* add to local vctot */
	mulps xmm0, xmm7	/* fsOH2 */
	movaps xmm1, xmm0
	movaps xmm2, xmm0

	movaps xmm3, [esp + _fjxH1]
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	mulps xmm0, [esp + _dxH1H1]
	mulps xmm1, [esp + _dyH1H1]
	mulps xmm2, [esp + _dzH1H1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H1-H2 interaction */
	movaps xmm0, [esp + _rinvH1H2]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]	
	movaps xmm1, xmm0
	mulps  xmm5, [esp + _rsqH1H2] /* xmm5=krsq */
	movaps xmm4, xmm5
	addps  xmm4, xmm7	/* xmm4=r inv+ krsq */
	mulps xmm0, xmm0
	subps  xmm4, [esp + _crf]
	mulps  xmm4, [esp + _qqHH] /* xmm4=voul=qq*(rinv+ krsq) */
	mulps  xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqHH] /* xmm7 = coul part of fscal */
	addps  xmm6, xmm4	/* add to local vctot */
	mulps xmm0, xmm7	/* fsOH2 */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	
	movaps xmm3, [esp + _fjxH2]
	movaps xmm4, [esp + _fjyH2]
	movaps xmm5, [esp + _fjzH2]
	mulps xmm0, [esp + _dxH1H2]
	mulps xmm1, [esp + _dyH1H2]
	mulps xmm2, [esp + _dzH1H2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H2-O interaction */
	movaps xmm0, [esp + _rinvH2O]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]	
	movaps xmm1, xmm0
	mulps  xmm5, [esp + _rsqH2O] /* xmm5=krsq */
	movaps xmm4, xmm5
	addps  xmm4, xmm7	/* xmm4=r inv+ krsq */
	subps  xmm4, [esp + _crf]
	mulps xmm0, xmm0
	mulps  xmm4, [esp + _qqOH] /* xmm4=voul=qq*(rinv+ krsq) */
	mulps  xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqOH] /* xmm7 = coul part of fscal */
	addps  xmm6, xmm4	/* add to local vctot */
	mulps xmm0, xmm7	/* fsOH2 */
	movaps xmm1, xmm0
	movaps xmm2, xmm0

	movaps xmm3, [esp + _fjxO]
	movaps xmm4, [esp + _fjyO]
	movaps xmm5, [esp + _fjzO]
	mulps xmm0, [esp + _dxH2O]
	mulps xmm1, [esp + _dyH2O]
	mulps xmm2, [esp + _dzH2O]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	/* H2-H1 interaction */
	movaps xmm0, [esp + _rinvH2H1]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]	
	movaps xmm1, xmm0
	mulps  xmm5, [esp + _rsqH2H1] /* xmm5=krsq */
	movaps xmm4, xmm5
	addps  xmm4, xmm7	/* xmm4=r inv+ krsq */
	subps  xmm4, [esp + _crf]
	mulps xmm0, xmm0
	mulps  xmm4, [esp + _qqHH] /* xmm4=voul=qq*(rinv+ krsq) */
	mulps  xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqHH] /* xmm7 = coul part of fscal */
	addps  xmm6, xmm4	/* add to local vctot */
	mulps xmm0, xmm7	/* fsOH2 */
	movaps xmm1, xmm0
	movaps xmm2, xmm0

	movaps xmm3, [esp + _fjxH1]
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	mulps xmm0, [esp + _dxH2H1]
	mulps xmm1, [esp + _dyH2H1]
	mulps xmm2, [esp + _dzH2H1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	/* H2-H2 interaction */
	movaps xmm0, [esp + _rinvH2H2]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]	
	movaps xmm1, xmm0
	mulps  xmm5, [esp + _rsqH2H2] /* xmm5=krsq */
	movaps xmm4, xmm5
	addps  xmm4, xmm7	/* xmm4=r inv+ krsq */
	subps  xmm4, [esp + _crf]
	mulps xmm0, xmm0
	mulps  xmm4, [esp + _qqHH] /* xmm4=voul=qq*(rinv+ krsq) */
	mulps  xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqHH] /* xmm7 = coul part of fscal */
	addps  xmm6, xmm4	/* add to local vctot */
	mulps xmm0, xmm7	/* fsOH2 */
	movaps xmm1, xmm0
	movaps xmm2, xmm0

	movaps xmm1, xmm0
	movaps [esp + _vctot], xmm6
	movaps xmm2, xmm0
	
	movaps xmm3, [esp + _fjxH2]
	movaps xmm4, [esp + _fjyH2]
	movaps xmm5, [esp + _fjzH2]
	mulps xmm0, [esp + _dxH2H2]
	mulps xmm1, [esp + _dyH2H2]
	mulps xmm2, [esp + _dzH2H2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	mov edi, [ebp + _faction]
		
	/* Did all interactions - now update j forces */
	/* 4 j waters with three atoms each - first do a & b j particles */
	movaps xmm0, [esp + _fjxO] /* xmm0= fjxOa  fjxOb  fjxOc  fjxOd */
	movaps xmm1, [esp + _fjyO] /* xmm1= fjyOa  fjyOb  fjyOc  fjyOd */ 
	unpcklps xmm0, xmm1    	   /* xmm0= fjxOa  fjyOa  fjxOb  fjyOb */
	movaps xmm1, [esp + _fjzO]
	movaps xmm2, [esp + _fjxH1]
	movhlps  xmm3, xmm0	   /* xmm3= fjxOb  fjyOb */ 
	unpcklps xmm1, xmm2	   /* xmm1= fjzOa  fjxH1a fjzOb  fjxH1b */
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	unpcklps xmm4, xmm5	   /* xmm4= fjyH1a fjzH1a fjyH1b fjzH1b */
	movaps xmm5, [esp + _fjxH2]
	movaps xmm6, [esp + _fjyH2]
	movhlps  xmm7, xmm4	   /* xmm7= fjyH1b fjzH1b */
	unpcklps xmm5, xmm6	   /* xmm5= fjxH2a fjyH2a fjxH2b fjyH2b */
	movlhps  xmm0, xmm1    	   /* xmm0= fjxOa  fjyOa  fjzOa  fjxH1a */
	shufps   xmm3, xmm1, 0b11100100
                                   /* xmm3= fjxOb  fjyOb  fjzOb  fjxH1b */
	movlhps  xmm4, xmm5   	   /* xmm4= fjyH1a fjzH1a fjxH2a fjyH2a */
	shufps   xmm7, xmm5, 0b11100100
                                   /* xmm7= fjyH1b fjzH1b fjxH2b fjyH2b */
	movups   xmm1, [edi + eax*4]
	movups   xmm2, [edi + eax*4 + 16]
	movups   xmm5, [edi + ebx*4]
	movups   xmm6, [edi + ebx*4 + 16]
	addps    xmm1, xmm0
	addps    xmm2, xmm4
	addps    xmm5, xmm3
	addps    xmm6, xmm7
	movss    xmm0, [edi + eax*4 + 32]
	movss    xmm3, [edi + ebx*4 + 32]
	
	movaps   xmm4, [esp + _fjzH2]
	movaps   xmm7, xmm4
	shufps   xmm7, xmm7, 1
	
	movups   [edi + eax*4],     xmm1
	movups   [edi + eax*4 + 16],xmm2
	movups   [edi + ebx*4],     xmm5
	movups   [edi + ebx*4 + 16],xmm6	
	addss    xmm0, xmm4
	addss    xmm3, xmm7
	movss    [edi + eax*4 + 32], xmm0
	movss    [edi + ebx*4 + 32], xmm3	

	/* then do the second pair (c & d) */
	movaps xmm0, [esp + _fjxO] /* xmm0= fjxOa  fjxOb  fjxOc  fjxOd */
	movaps xmm1, [esp + _fjyO] /* xmm1= fjyOa  fjyOb  fjyOc  fjyOd */ 
	unpckhps xmm0, xmm1	   /* xmm0= fjxOc  fjyOc  fjxOd  fjyOd */
	movaps xmm1, [esp + _fjzO]
	movaps xmm2, [esp + _fjxH1]
	movhlps  xmm3, xmm0	   /* xmm3= fjxOd  fjyOd */ 
	unpckhps xmm1, xmm2	   /* xmm1= fjzOc  fjxH1c fjzOd  fjxH1d */
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	unpckhps xmm4, xmm5	   /* xmm4= fjyH1c fjzH1c fjyH1d fjzH1d	*/
	movaps xmm5, [esp + _fjxH2]
	movaps xmm6, [esp + _fjyH2]
	movhlps  xmm7, xmm4	   /* xmm7= fjyH1d fjzH1d */	 
	unpckhps xmm5, xmm6	   /* xmm5= fjxH2c fjyH2c fjxH2d fjyH2d */
	movlhps  xmm0, xmm1	   /* xmm0= fjxOc  fjyOc  fjzOc  fjxH1c */
	shufps   xmm3, xmm1, 0b11100100
                                   /* xmm3= fjxOd  fjyOd  fjzOd  fjxH1d */
	movlhps  xmm4, xmm5	   /* xmm4= fjyH1c fjzH1c fjxH2c fjyH2c  */
	shufps   xmm7, xmm5, 0b11100100
                                   /* xmm7= fjyH1d fjzH1d fjxH2d fjyH2d */
	movups   xmm1, [edi + ecx*4]
	movups   xmm2, [edi + ecx*4 + 16]
	movups   xmm5, [edi + edx*4]
	movups   xmm6, [edi + edx*4 + 16]
	addps    xmm1, xmm0
	addps    xmm2, xmm4
	addps    xmm5, xmm3
	addps    xmm6, xmm7
	movss    xmm0, [edi + ecx*4 + 32]
	movss    xmm3, [edi + edx*4 + 32]
	
	movaps   xmm4, [esp + _fjzH2]
	movaps   xmm7, xmm4
	shufps   xmm4, xmm4, 0b10
	shufps   xmm7, xmm7, 0b11
	movups   [edi + ecx*4],     xmm1
	movups   [edi + ecx*4 + 16],xmm2
	movups   [edi + edx*4],     xmm5
	movups   [edi + edx*4 + 16],xmm6	
	addss    xmm0, xmm4
	addss    xmm3, xmm7
	movss    [edi + ecx*4 + 32], xmm0
	movss    [edi + edx*4 + 32], xmm3	
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i2130_single_check
	jmp   .i2130_unroll_loop
.i2130_single_check:
	add   [esp + _innerk],  4
	jnz   .i2130_single_loop
	jmp   .i2130_updateouterdata
.i2130_single_loop:
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	add   [esp + _innerjjnr],  4	

	mov esi, [ebp + _pos]
	lea   eax, [eax + eax*2]  

	/* fetch j coordinates */
	xorps xmm3, xmm3
	xorps xmm4, xmm4
	xorps xmm5, xmm5
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + eax*4 + 4]
	movss xmm5, [esi + eax*4 + 8]

	movlps xmm6, [esi + eax*4 + 12]
	movhps xmm6, [esi + eax*4 + 24]	/* xmm6=jxH1 jyH1 jxH2 jyH2 */
	/* fetch both z coords in one go, to positions 0 and 3 in xmm7 */
	movups xmm7, [esi + eax*4 + 20] /* xmm7=jzH1 jxH2 jyH2 jzH2 */
	shufps xmm6, xmm6, 0b11011000    /* xmm6=jxH1 jxH2 jyH1 jyH2 */
	movlhps xmm3, xmm6      	/* xmm3= jxO   0  jxH1 jxH2 */
	movaps  xmm0, [esp + _ixO]     
	movaps  xmm1, [esp + _iyO]
	movaps  xmm2, [esp + _izO]	
	shufps  xmm4, xmm6, 0b11100100 /* xmm4= jyO   0   jyH1 jyH2 */
	shufps xmm5, xmm7, 0b11000100  /* xmm5= jzO   0   jzH1 jzH2 */
	/* store all j coordinates in jO */ 
	movaps [esp + _jxO], xmm3
	movaps [esp + _jyO], xmm4
	movaps [esp + _jzO], xmm5
	subps  xmm0, xmm3
	subps  xmm1, xmm4
	subps  xmm2, xmm5
	movaps [esp + _dxOO], xmm0
	movaps [esp + _dyOO], xmm1
	movaps [esp + _dzOO], xmm2
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2	/* have rsq in xmm0 */

	movaps xmm6, xmm0
	
	/* do invsqrt */
	rsqrtps xmm1, xmm0
	mulps   xmm6, [esp + _krf] /* xmm6=krsq */
	movaps  xmm2, xmm1
	movaps  xmm7, xmm6
	mulps   xmm1, xmm1
	movaps  xmm3, [esp + _three]
	mulps   xmm1, xmm0
	subps   xmm3, xmm1
	mulps   xmm3, xmm2							
	mulps   xmm3, [esp + _half] /* rinv iO - j water */

	addps   xmm6, xmm3	/* xmm6=rinv+ krsq */
	mulps   xmm7, [esp + _two]
	subps  xmm6, [esp + _crf]	/* xmm6=rinv+ krsq-crf */
	
	xorps   xmm1, xmm1
	movaps  xmm0, xmm3
	subps   xmm3, xmm7	/* xmm3=rinv-2*krsq */
	xorps   xmm4, xmm4
	mulps   xmm0, xmm0	/* xmm0=rinvsq */
	/* fetch charges to xmm4 (temporary) */
	movss   xmm4, [esp + _qqOO]
	movss   xmm1, xmm0
	movhps  xmm4, [esp + _qqOH]
	mulss   xmm1, xmm0

	mulps xmm6, xmm4	/* vcoul */ 
	mulps xmm3, xmm4	/* coul part of fs */ 
	
	mulss   xmm1, xmm0	/* xmm1(0)=rinvsix */
	movaps  xmm2, xmm1	/* zero everything else in xmm2 */
	mulss   xmm2, xmm2	/* xmm2=rinvtwelve */

	mulss   xmm1, [esp + _c6]
	mulss   xmm2, [esp + _c12]
	movaps  xmm4, xmm2
	subss   xmm4, xmm1	/* vnbtot=vnb12-vnb6 */
	addps   xmm4, [esp + _vnbtot]
	mulss   xmm1, [esp + _six]
	mulss   xmm2, [esp + _twelve]	
	movaps  [esp + _vnbtot], xmm4
	subss   xmm2, xmm1	/* fsD+ fsR */
	addps   xmm2, xmm3	/* fsC+ fsD+ fsR */

	addps   xmm6, [esp + _vctot]
	mulps   xmm0, xmm2	/* total fscal */
	movaps  [esp + _vctot], xmm6	

	movaps  xmm1, xmm0
	movaps  xmm2, xmm0
	mulps   xmm0, [esp + _dxOO]
	mulps   xmm1, [esp + _dyOO]
	mulps   xmm2, [esp + _dzOO]
	
	/* initial update for j forces */
	xorps   xmm3, xmm3
	xorps   xmm4, xmm4
	xorps   xmm5, xmm5
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixO]
	addps   xmm1, [esp + _fiyO]
	addps   xmm2, [esp + _fizO]
	movaps  [esp + _fixO], xmm0
	movaps  [esp + _fiyO], xmm1
	movaps  [esp + _fizO], xmm2

	
	/* done with i O Now do i H1 & H2 simultaneously first get i particle coords: */
	movaps  xmm0, [esp + _ixH1]
	movaps  xmm1, [esp + _iyH1]
	movaps  xmm2, [esp + _izH1]	
	movaps  xmm3, [esp + _ixH2] 
	movaps  xmm4, [esp + _iyH2] 
	movaps  xmm5, [esp + _izH2] 
	subps   xmm0, [esp + _jxO]
	subps   xmm1, [esp + _jyO]
	subps   xmm2, [esp + _jzO]
	subps   xmm3, [esp + _jxO]
	subps   xmm4, [esp + _jyO]
	subps   xmm5, [esp + _jzO]
	movaps [esp + _dxH1O], xmm0
	movaps [esp + _dyH1O], xmm1
	movaps [esp + _dzH1O], xmm2
	movaps [esp + _dxH2O], xmm3
	movaps [esp + _dyH2O], xmm4
	movaps [esp + _dzH2O], xmm5
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	mulps xmm3, xmm3
	mulps xmm4, xmm4
	mulps xmm5, xmm5
	addps xmm0, xmm1
	addps xmm4, xmm3
	addps xmm0, xmm2	/* have rsqH1 in xmm0 */
	addps xmm4, xmm5	/* have rsqH2 in xmm4 */
	
	/* do invsqrt */
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] /* rinv H1 - j water */
	mulps   xmm7, [esp + _half] /* rinv H2 - j water */ 

	mulps xmm0, [esp + _krf] /* krsq */
	mulps xmm4, [esp + _krf] /* krsq */ 


	/* assemble charges in xmm6 */
	xorps   xmm6, xmm6
	movss   xmm6, [esp + _qqOH]
	movhps  xmm6, [esp + _qqHH]
	movaps  xmm1, xmm0
	movaps  xmm5, xmm4
	addps   xmm0, xmm3	/* krsq+ rinv */
	addps   xmm4, xmm7	/* krsq+ rinv */
	subps xmm0, [esp + _crf]
	subps xmm4, [esp + _crf]
	mulps   xmm1, [esp + _two]
	mulps   xmm5, [esp + _two]
	mulps   xmm0, xmm6	/* vcoul */
	mulps   xmm4, xmm6	/* vcoul */
	addps   xmm4, xmm0		
	addps   xmm4, [esp + _vctot]
	movaps  [esp + _vctot], xmm4
	movaps  xmm0, xmm3
	movaps  xmm4, xmm7
	mulps   xmm3, xmm3
	mulps   xmm7, xmm7
	subps   xmm0, xmm1
	subps   xmm4, xmm5
	mulps   xmm0, xmm6
	mulps   xmm4, xmm6
	mulps   xmm0, xmm3	/* fscal */
	mulps   xmm7, xmm4	/* fscal */
	
	movaps  xmm1, xmm0
	movaps  xmm2, xmm0
	mulps   xmm0, [esp + _dxH1O]
	mulps   xmm1, [esp + _dyH1O]
	mulps   xmm2, [esp + _dzH1O]
	/* update forces H1 - j water */
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixH1]
	addps   xmm1, [esp + _fiyH1]
	addps   xmm2, [esp + _fizH1]
	movaps  [esp + _fixH1], xmm0
	movaps  [esp + _fiyH1], xmm1
	movaps  [esp + _fizH1], xmm2
	/* do forces H2 - j water */
	movaps xmm0, xmm7
	movaps xmm1, xmm7
	movaps xmm2, xmm7
	mulps   xmm0, [esp + _dxH2O]
	mulps   xmm1, [esp + _dyH2O]
	mulps   xmm2, [esp + _dzH2O]
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	mov     esi, [ebp + _faction]
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixH2]
	addps   xmm1, [esp + _fiyH2]
	addps   xmm2, [esp + _fizH2]
	movaps  [esp + _fixH2], xmm0
	movaps  [esp + _fiyH2], xmm1
	movaps  [esp + _fizH2], xmm2

	/* update j water forces from local variables */
	movlps  xmm0, [esi + eax*4]
	movlps  xmm1, [esi + eax*4 + 12]
	movhps  xmm1, [esi + eax*4 + 24]
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	movaps  xmm6, xmm5
	movaps  xmm7, xmm5
	shufps  xmm6, xmm6, 0b10
	shufps  xmm7, xmm7, 0b11
	addss   xmm5, [esi + eax*4 + 8]
	addss   xmm6, [esi + eax*4 + 20]
	addss   xmm7, [esi + eax*4 + 32]
	movss   [esi + eax*4 + 8], xmm5
	movss   [esi + eax*4 + 20], xmm6
	movss   [esi + eax*4 + 32], xmm7
	movaps   xmm5, xmm3
	unpcklps xmm3, xmm4
	unpckhps xmm5, xmm4
	addps    xmm0, xmm3
	addps    xmm1, xmm5
	movlps  [esi + eax*4], xmm0 
	movlps  [esi + eax*4 + 12], xmm1 
	movhps  [esi + eax*4 + 24], xmm1 
	
	dec dword ptr [esp + _innerk]
	jz    .i2130_updateouterdata
	jmp   .i2130_single_loop
.i2130_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate  Oi forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixO]
	movaps xmm1, [esp + _fiyO] 
	movaps xmm2, [esp + _fizO]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	movaps xmm6, xmm0
	movss xmm7, xmm2
	movlhps xmm6, xmm1
	shufps  xmm6, xmm6, 0b1000	
 
	/* accumulate H1i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH1]
	movaps xmm1, [esp + _fiyH1]
	movaps xmm2, [esp + _fizH1]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 12]
	movss  xmm4, [edi + ecx*4 + 16]
	movss  xmm5, [edi + ecx*4 + 20]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 12], xmm3
	movss  [edi + ecx*4 + 16], xmm4
	movss  [edi + ecx*4 + 20], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* accumulate H2i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH2]
	movaps xmm1, [esp + _fiyH2]
	movaps xmm2, [esp + _fizH2]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 24]
	movss  xmm4, [edi + ecx*4 + 28]
	movss  xmm5, [edi + ecx*4 + 32]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 24], xmm3
	movss  [edi + ecx*4 + 28], xmm4
	movss  [edi + ecx*4 + 32], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* increment fshift force */ 
	movlps  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 8]
	addps  xmm3, xmm6
	addss  xmm4, xmm7
	movlps  [esi + edx*4],    xmm3
	movss  [esi + edx*4 + 8], xmm4

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i2130_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i2130_outer
.i2130_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 1540
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret


	

.globl inl2020_sse
	.type inl2020_sse,@function
inl2020_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_argkrf,	60	
.equ		_argcrf,	64	
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ixO,		0
.equ		_iyO,		16
.equ		_izO,		32
.equ		_ixH1,		48
.equ		_iyH1,		64
.equ		_izH1,		80
.equ		_ixH2,		96
.equ		_iyH2,		112
.equ		_izH2,		128
.equ		_iqO,		144 
.equ		_iqH,		160 
.equ		_dxO,		176
.equ		_dyO,		192
.equ		_dzO,		208	
.equ		_dxH1,		224
.equ		_dyH1,		240
.equ		_dzH1,		256	
.equ		_dxH2,		272
.equ		_dyH2,		288
.equ		_dzH2,		304	
.equ		_qqO,		320
.equ		_qqH,		336
.equ		_vctot,		352
.equ		_fixO,		384
.equ		_fiyO,		400
.equ		_fizO,		416
.equ		_fixH1,		432
.equ		_fiyH1,		448
.equ		_fizH1,		464
.equ		_fixH2,		480
.equ		_fiyH2,		496
.equ		_fizH2,		512
.equ		_fjx,		528
.equ		_fjy,		544
.equ		_fjz,		560
.equ		_half,		576
.equ		_three,		592
.equ		_two,		608
.equ		_krf,		624
.equ		_crf,		640
.equ		_krsqO,		656
.equ		_krsqH1,	672
.equ		_krsqH2,	688	 		
.equ		_is3,		704
.equ		_ii3,		708
.equ		_innerjjnr,	712
.equ		_innerk,	716
.equ		_salign,	720								
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 724		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_three]
	movups xmm4, [sse_two]
	movss xmm5, [ebp + _argkrf]
	movss xmm6, [ebp + _argcrf]

	movaps [esp + _half],  xmm0
	movaps [esp + _three], xmm1
	movaps [esp + _two], xmm4
	shufps xmm5, xmm5, 0
	shufps xmm6, xmm6, 0
	movaps [esp + _krf], xmm5
	movaps [esp + _crf], xmm6
	
	/* assume we have at least one i particle - start directly */
	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	movss xmm4, [edx + ebx*4 + 4]	
	movss xmm5, [ebp + _facel]
	mulss  xmm3, xmm5
	mulss  xmm4, xmm5

	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	movaps [esp + _iqO], xmm3
	movaps [esp + _iqH], xmm4
			
.i2020_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2

	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx

	addss xmm3, [eax + ebx*4]
	addss xmm4, [eax + ebx*4 + 4]
	addss xmm5, [eax + ebx*4 + 8]		
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixO], xmm3
	movaps [esp + _iyO], xmm4
	movaps [esp + _izO], xmm5

	movss xmm3, xmm0
	movss xmm4, xmm1
	movss xmm5, xmm2
	addss xmm0, [eax + ebx*4 + 12]
	addss xmm1, [eax + ebx*4 + 16]
	addss xmm2, [eax + ebx*4 + 20]		
	addss xmm3, [eax + ebx*4 + 24]
	addss xmm4, [eax + ebx*4 + 28]
	addss xmm5, [eax + ebx*4 + 32]		

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixH1], xmm0
	movaps [esp + _iyH1], xmm1
	movaps [esp + _izH1], xmm2
	movaps [esp + _ixH2], xmm3
	movaps [esp + _iyH2], xmm4
	movaps [esp + _izH2], xmm5
	
	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _fixO], xmm4
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm4
	movaps [esp + _fixH1], xmm4
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm4
	movaps [esp + _fixH2], xmm4
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i2020_unroll_loop
	jmp   .i2020_odd_inner
.i2020_unroll_loop:
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */

	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	movaps xmm4, xmm3	     /* and in xmm4 */
	mulps  xmm3, [esp + _iqO]
	mulps  xmm4, [esp + _iqH]

	movaps  [esp + _qqO], xmm3
	movaps  [esp + _qqH], xmm4

	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	
	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ixO-izO to xmm4-xmm6 */
	movaps xmm4, [esp + _ixO]
	movaps xmm5, [esp + _iyO]
	movaps xmm6, [esp + _izO]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dxO], xmm4
	movaps [esp + _dyO], xmm5
	movaps [esp + _dzO], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	movaps xmm7, xmm4
	/* rsqO in xmm7 */

	/* move ixH1-izH1 to xmm4-xmm6 */
	movaps xmm4, [esp + _ixH1]
	movaps xmm5, [esp + _iyH1]
	movaps xmm6, [esp + _izH1]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dxH1], xmm4
	movaps [esp + _dyH1], xmm5
	movaps [esp + _dzH1], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm6, xmm5
	addps xmm6, xmm4
	/* rsqH1 in xmm6 */

	/* move ixH2-izH2 to xmm3-xmm5 */ 
	movaps xmm3, [esp + _ixH2]
	movaps xmm4, [esp + _iyH2]
	movaps xmm5, [esp + _izH2]

	/* calc dr */
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2

	/* store dr */
	movaps [esp + _dxH2], xmm3
	movaps [esp + _dyH2], xmm4
	movaps [esp + _dzH2], xmm5
	/* square it */
	mulps xmm3,xmm3
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	addps xmm5, xmm4
	addps xmm5, xmm3
	/* rsqH2 in xmm5, rsqH1 in xmm6, rsqO in xmm7 */

	movaps xmm0, xmm5
	movaps xmm1, xmm6
	movaps xmm2, xmm7

	mulps  xmm0, [esp + _krf]	
	mulps  xmm1, [esp + _krf]	
	mulps  xmm2, [esp + _krf]	

	movaps [esp + _krsqH2], xmm0
	movaps [esp + _krsqH1], xmm1
	movaps [esp + _krsqO], xmm2
	
	/* start with rsqO - seed in xmm2 */	
	rsqrtps xmm2, xmm7
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm7	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  xmm7, xmm4	/* rinvO in xmm7 */
	/* rsqH1 - seed in xmm2 */
	rsqrtps xmm2, xmm6
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm6	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  xmm6, xmm4	/* rinvH1 in xmm6 */
	/* rsqH2 - seed in xmm2 */
	rsqrtps xmm2, xmm5
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm5	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  xmm5, xmm4	/* rinvH2 in xmm5 */

	/* do O interactions */
	movaps  xmm4, xmm7	
	mulps   xmm4, xmm4	/* xmm7=rinv, xmm4=rinvsq */

	movaps xmm0, xmm7
	movaps xmm1, [esp + _krsqO]
	addps  xmm0, xmm1
	subps  xmm0, [esp + _crf] /* xmm0=rinv+ krsq-crf */
	mulps  xmm1, [esp + _two]
	subps  xmm7, xmm1
	mulps  xmm0, [esp + _qqO]
	mulps  xmm7, [esp + _qqO]

	mulps  xmm4, xmm7	/* total fsO in xmm4 */

	addps  xmm0, [esp + _vctot]
	movaps [esp + _vctot], xmm0

	movaps xmm0, [esp + _dxO]
	movaps xmm1, [esp + _dyO]
	movaps xmm2, [esp + _dzO]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

	/* update O forces */
	movaps xmm3, [esp + _fixO]
	movaps xmm4, [esp + _fiyO]
	movaps xmm7, [esp + _fizO]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixO], xmm3
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm7
	/* update j forces with water O */
	movaps [esp + _fjx], xmm0
	movaps [esp + _fjy], xmm1
	movaps [esp + _fjz], xmm2

	/* H1 interactions */
	movaps  xmm4, xmm6	
	mulps   xmm4, xmm4	/* xmm6=rinv, xmm4=rinvsq */
	movaps  xmm7, xmm6
	movaps  xmm0, [esp + _krsqH1]
	addps   xmm6, xmm0	/* xmm6=rinv+ krsq */
	subps   xmm6, [esp + _crf] /* xmm6=rinv+ krsq-crf */
	mulps   xmm0, [esp + _two]
	subps   xmm7, xmm0	/* xmm7=rinv-2*krsq */
	mulps   xmm6, [esp + _qqH] /* vcoul */
	mulps   xmm7, [esp + _qqH]
	mulps  xmm4, xmm7		/* total fsH1 in xmm4 */
	
	addps  xmm6, [esp + _vctot]

	movaps xmm0, [esp + _dxH1]
	movaps xmm1, [esp + _dyH1]
	movaps xmm2, [esp + _dzH1]
	movaps [esp + _vctot], xmm6
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

	/* update H1 forces */
	movaps xmm3, [esp + _fixH1]
	movaps xmm4, [esp + _fiyH1]
	movaps xmm7, [esp + _fizH1]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixH1], xmm3
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm7
	/* update j forces with water H1 */
	addps  xmm0, [esp + _fjx]
	addps  xmm1, [esp + _fjy]
	addps  xmm2, [esp + _fjz]
	movaps [esp + _fjx], xmm0
	movaps [esp + _fjy], xmm1
	movaps [esp + _fjz], xmm2

	/* H2 interactions */
	movaps  xmm4, xmm5	
	mulps   xmm4, xmm4	/* xmm5=rinv, xmm4=rinvsq */
	movaps  xmm7, xmm5
	movaps  xmm0, [esp + _krsqH2]
	addps   xmm5, xmm0	/* xmm6=rinv+ krsq */
	subps   xmm5, [esp + _crf] /* xmm5=rinv+ krsq-crf */
	mulps   xmm0, [esp + _two]
	subps   xmm7, xmm0	/* xmm7=rinv-2*krsq */
	mulps   xmm5, [esp + _qqH] /* vcoul */
	mulps   xmm7, [esp + _qqH]
	mulps  xmm4, xmm7		/* total fsH2 in xmm4 */
	
	addps  xmm5, [esp + _vctot]

	movaps xmm0, [esp + _dxH2]
	movaps xmm1, [esp + _dyH2]
	movaps xmm2, [esp + _dzH2]
	movaps [esp + _vctot], xmm5
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

	/* update H2 forces */
	movaps xmm3, [esp + _fixH2]
	movaps xmm4, [esp + _fiyH2]
	movaps xmm7, [esp + _fizH2]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixH2], xmm3
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm7

	mov edi, [ebp + _faction]
	/* update j forces */
	addps xmm0, [esp + _fjx]
	addps xmm1, [esp + _fjy]
	addps xmm2, [esp + _fjz]

	movlps xmm4, [edi + eax*4]
	movlps xmm7, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm7, [edi + edx*4]
	
	movaps xmm3, xmm4
	shufps xmm3, xmm7, 0b10001000
	shufps xmm4, xmm7, 0b11011101			      
	/* xmm3 has fjx, xmm4 has fjy */
	subps xmm3, xmm0
	subps xmm4, xmm1
	/* unpack them back for storing */
	movaps xmm7, xmm3
	unpcklps xmm7, xmm4
	unpckhps xmm3, xmm4	
	movlps [edi + eax*4], xmm7
	movlps [edi + ecx*4], xmm3
	movhps [edi + ebx*4], xmm7
	movhps [edi + edx*4], xmm3
	/* finally z forces */
	movss  xmm0, [edi + eax*4 + 8]
	movss  xmm1, [edi + ebx*4 + 8]
	movss  xmm3, [edi + ecx*4 + 8]
	movss  xmm4, [edi + edx*4 + 8]
	subss  xmm0, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm1, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm3, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm4, xmm2
	movss  [edi + eax*4 + 8], xmm0
	movss  [edi + ebx*4 + 8], xmm1
	movss  [edi + ecx*4 + 8], xmm3
	movss  [edi + edx*4 + 8], xmm4
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i2020_odd_inner
	jmp   .i2020_unroll_loop
.i2020_odd_inner:	
	add   [esp + _innerk],  4
	jnz   .i2020_odd_loop
	jmp   .i2020_updateouterdata
.i2020_odd_loop:
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	add   [esp + _innerjjnr],  4	

 	xorps xmm4, xmm4
	movss xmm4, [esp + _iqO]
	mov esi, [ebp + _charge] 
	movhps xmm4, [esp + _iqH]     
	movss xmm3, [esi + eax*4]	/* charge in xmm3 */
	shufps xmm3, xmm3, 0
	mulps xmm3, xmm4
	movaps [esp + _qqO], xmm3	/* use oxygen qq for storage */

	mov esi, [ebp + _pos]
	lea   eax, [eax + eax*2]  
	
	/* move j coords to xmm0-xmm2 */
	movss xmm0, [esi + eax*4]
	movss xmm1, [esi + eax*4 + 4]
	movss xmm2, [esi + eax*4 + 8]
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	
	movss xmm3, [esp + _ixO]
	movss xmm4, [esp + _iyO]
	movss xmm5, [esp + _izO]
		
	movlps xmm6, [esp + _ixH1]
	movlps xmm7, [esp + _ixH2]
	unpcklps xmm6, xmm7
	movlhps xmm3, xmm6
	movlps xmm6, [esp + _iyH1]
	movlps xmm7, [esp + _iyH2]
	unpcklps xmm6, xmm7
	movlhps xmm4, xmm6
	movlps xmm6, [esp + _izH1]
	movlps xmm7, [esp + _izH2]
	unpcklps xmm6, xmm7
	movlhps xmm5, xmm6

	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	
	movaps [esp + _dxO], xmm3
	movaps [esp + _dyO], xmm4
	movaps [esp + _dzO], xmm5

	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5

	addps  xmm4, xmm3
	addps  xmm4, xmm5
	/* rsq in xmm4 */

	movaps xmm0, xmm4
	mulps xmm0, [esp + _krf]
	movaps [esp + _krsqO], xmm0
	
	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	movaps xmm4, xmm0
	mulps  xmm4, xmm4	/* xmm4=rinvsq */

	movaps xmm1, xmm0	/* xmm1=rinv */
	movaps xmm3, [esp + _krsqO]
	addps  xmm0, xmm3	/* xmm0=rinv+ krsq */
	subps  xmm0, [esp + _crf] /* xmm0=rinv+ krsq-crf */
	mulps  xmm3, [esp + _two]
	subps  xmm1, xmm3	/* xmm1=rinv-2*krsq */
	mulps  xmm0, [esp + _qqO]	/* xmm0=vcoul */
	mulps  xmm1, [esp + _qqO] 	/* xmm1=coul part of fs */

	
	mulps  xmm4, xmm1	/* xmm4=total fscal */
	addps  xmm0, [esp + _vctot]
	movaps [esp + _vctot], xmm0
	
	movaps xmm0, [esp + _dxO]
	movaps xmm1, [esp + _dyO]
	movaps xmm2, [esp + _dzO]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	movss  xmm3, [esp + _fixO]	
	movss  xmm4, [esp + _fiyO]	
	movss  xmm5, [esp + _fizO]	
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esp + _fixO], xmm3	
	movss  [esp + _fiyO], xmm4	
	movss  [esp + _fizO], xmm5	/* updated the O force now do the H's */
	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2
	shufps xmm3, xmm3, 0b11100110	/* shift right */
	shufps xmm4, xmm4, 0b11100110
	shufps xmm5, xmm5, 0b11100110
	addss  xmm3, [esp + _fixH1]
	addss  xmm4, [esp + _fiyH1]
	addss  xmm5, [esp + _fizH1]
	movss  [esp + _fixH1], xmm3	
	movss  [esp + _fiyH1], xmm4	
	movss  [esp + _fizH1], xmm5	/* updated the H1 force */

	mov edi, [ebp + _faction]
	shufps xmm3, xmm3, 0b11100111	/* shift right */
	shufps xmm4, xmm4, 0b11100111
	shufps xmm5, xmm5, 0b11100111
	addss  xmm3, [esp + _fixH2]
	addss  xmm4, [esp + _fiyH2]
	addss  xmm5, [esp + _fizH2]
	movss  [esp + _fixH2], xmm3	
	movss  [esp + _fiyH2], xmm4	
	movss  [esp + _fizH2], xmm5	/* updated the H2 force */

	/* the fj's - start by accumulating the tx/ty/tz force in xmm0, xmm1 */
	xorps  xmm5, xmm5
	movaps xmm3, xmm0
	movlps xmm6, [edi + eax*4]
	movss  xmm7, [edi + eax*4 + 8]
	unpcklps xmm3, xmm1
	movlhps  xmm3, xmm5	
	unpckhps xmm0, xmm1		
	addps    xmm0, xmm3
	movhlps  xmm3, xmm0	
	addps    xmm0, xmm3	/* x,y sum in xmm0 */

	movhlps  xmm1, xmm2
	addss    xmm2, xmm1
	shufps   xmm1, xmm1, 1 
	addss    xmm2, xmm1    /* z sum in xmm2 */
	subps    xmm6, xmm0
	subss    xmm7, xmm2
	
	movlps [edi + eax*4],     xmm6
	movss  [edi + eax*4 + 8], xmm7

	dec dword ptr [esp + _innerk]
	jz    .i2020_updateouterdata
	jmp   .i2020_odd_loop
.i2020_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate  Oi forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixO]
	movaps xmm1, [esp + _fiyO]
	movaps xmm2, [esp + _fizO]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	movaps xmm6, xmm0
	movss xmm7, xmm2
	movlhps xmm6, xmm1
	shufps  xmm6, xmm6, 0b1000	

	/* accumulate H1i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH1]
	movaps xmm1, [esp + _fiyH1]
	movaps xmm2, [esp + _fizH1]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 12]
	movss  xmm4, [edi + ecx*4 + 16]
	movss  xmm5, [edi + ecx*4 + 20]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 12], xmm3
	movss  [edi + ecx*4 + 16], xmm4
	movss  [edi + ecx*4 + 20], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* accumulate H2i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH2]
	movaps xmm1, [esp + _fiyH2]
	movaps xmm2, [esp + _fizH2]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 24]
	movss  xmm4, [edi + ecx*4 + 28]
	movss  xmm5, [edi + ecx*4 + 32]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 24], xmm3
	movss  [edi + ecx*4 + 28], xmm4
	movss  [edi + ecx*4 + 32], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* increment fshift force */ 
	movlps  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 8]
	addps  xmm3, xmm6
	addss  xmm4, xmm7
	movlps  [esi + edx*4],    xmm3
	movss  [esi + edx*4 + 8], xmm4

	mov   edx, [ebp + _gid]  
	mov   edx, [edx]
	add   [ebp + _gid],  4	

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		
        
	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i2020_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i2020_outer
.i2020_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 724
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret


	
.globl inl2030_sse
	.type inl2030_sse,@function
inl2030_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_argkrf,	60
.equ		_argcrf,	64
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ixO,		0
.equ		_iyO,		16
.equ		_izO,		32
.equ		_ixH1,		48
.equ		_iyH1,		64
.equ		_izH1,		80
.equ		_ixH2,		96
.equ		_iyH2,		112
.equ		_izH2,		128
.equ		_jxO,		144
.equ		_jyO,		160
.equ		_jzO,		176
.equ		_jxH1,		192
.equ		_jyH1,		208
.equ		_jzH1,		224
.equ		_jxH2,		240
.equ		_jyH2,		256
.equ		_jzH2,		272
.equ		_dxOO,		288
.equ		_dyOO,		304
.equ		_dzOO,		320	
.equ		_dxOH1,		336
.equ		_dyOH1,		352
.equ		_dzOH1,		368	
.equ		_dxOH2,		384
.equ		_dyOH2,		400
.equ		_dzOH2,		416	
.equ		_dxH1O,		432
.equ		_dyH1O,		448
.equ		_dzH1O,		464	
.equ		_dxH1H1,	480
.equ		_dyH1H1,	496
.equ		_dzH1H1,	512	
.equ		_dxH1H2,	528
.equ		_dyH1H2,	544
.equ		_dzH1H2,	560	
.equ		_dxH2O,		576
.equ		_dyH2O,		592
.equ		_dzH2O,		608	
.equ		_dxH2H1,	624
.equ		_dyH2H1,	640
.equ		_dzH2H1,	656	
.equ		_dxH2H2,	672
.equ		_dyH2H2,	688
.equ		_dzH2H2,	704
.equ		_qqOO,		720
.equ		_qqOH,		736
.equ		_qqHH,		752
.equ		_vctot,		768
.equ		_fixO,		784
.equ		_fiyO,		800
.equ		_fizO,		816
.equ		_fixH1,		832
.equ		_fiyH1,		848
.equ		_fizH1,		864
.equ		_fixH2,		880
.equ		_fiyH2,		896
.equ		_fizH2,		912
.equ		_fjxO,		928
.equ		_fjyO,		944
.equ		_fjzO,		960
.equ		_fjxH1,		976
.equ		_fjyH1,		992
.equ		_fjzH1,		1008
.equ		_fjxH2,		1024
.equ		_fjyH2,		1040
.equ		_fjzH2,		1056
.equ		_half,		1072
.equ		_three,		1088
.equ		_rsqOO,		1104
.equ		_rsqOH1,	1120
.equ		_rsqOH2,	1136
.equ		_rsqH1O,	1152
.equ		_rsqH1H1,	1168
.equ		_rsqH1H2,	1184
.equ		_rsqH2O,	1200
.equ		_rsqH2H1,	1216
.equ		_rsqH2H2,	1232
.equ		_rinvOO,	1248
.equ		_rinvOH1,	1264
.equ		_rinvOH2,	1280
.equ		_rinvH1O,	1296
.equ		_rinvH1H1,	1312
.equ		_rinvH1H2,	1328
.equ		_rinvH2O,	1344
.equ		_rinvH2H1,	1360
.equ		_rinvH2H2,	1376
.equ		_two,		1392
.equ		_krf,		1408	
.equ		_crf,		1424
.equ		_is3,		1440
.equ		_ii3,		1444
.equ		_innerjjnr,	1448
.equ		_innerk,	1452
.equ		_salign,	1456							
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 1460		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_three]
	movups xmm4, [sse_two]
	movss xmm5, [ebp + _argkrf]
	movss xmm6, [ebp + _argcrf]
	
	movaps [esp + _half],  xmm0
	movaps [esp + _three], xmm1
	movaps [esp + _two], xmm4
	shufps xmm5, xmm5, 0
	shufps xmm6, xmm6, 0
	movaps [esp + _krf], xmm5
	movaps [esp + _crf], xmm6
	
	/* assume we have at least one i particle - start directly */
	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	movss xmm4, xmm3	
	movss xmm5, [edx + ebx*4 + 4]	
	movss xmm6, [ebp + _facel]
	mulss  xmm3, xmm3
	mulss  xmm4, xmm5
	mulss  xmm5, xmm5
	mulss  xmm3, xmm6
	mulss  xmm4, xmm6
	mulss  xmm5, xmm6
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _qqOO], xmm3
	movaps [esp + _qqOH], xmm4
	movaps [esp + _qqHH], xmm5
	
.i2030_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx	
	
	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2
	addss xmm3, [eax + ebx*4]
	addss xmm4, [eax + ebx*4 + 4]
	addss xmm5, [eax + ebx*4 + 8]		
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixO], xmm3
	movaps [esp + _iyO], xmm4
	movaps [esp + _izO], xmm5

	movss xmm3, xmm0
	movss xmm4, xmm1
	movss xmm5, xmm2
	addss xmm0, [eax + ebx*4 + 12]
	addss xmm1, [eax + ebx*4 + 16]
	addss xmm2, [eax + ebx*4 + 20]		
	addss xmm3, [eax + ebx*4 + 24]
	addss xmm4, [eax + ebx*4 + 28]
	addss xmm5, [eax + ebx*4 + 32]		

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixH1], xmm0
	movaps [esp + _iyH1], xmm1
	movaps [esp + _izH1], xmm2
	movaps [esp + _ixH2], xmm3
	movaps [esp + _iyH2], xmm4
	movaps [esp + _izH2], xmm5

	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _fixO], xmm4
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm4
	movaps [esp + _fixH1], xmm4
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm4
	movaps [esp + _fixH2], xmm4
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i2030_unroll_loop
	jmp   .i2030_single_check
.i2030_unroll_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */

	mov   eax, [edx]	
	mov   ebx, [edx + 4] 
	mov   ecx, [edx + 8]
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	
	
	/* move j coordinates to local temp variables */
	movlps xmm2, [esi + eax*4]
	movlps xmm3, [esi + eax*4 + 12]
	movlps xmm4, [esi + eax*4 + 24]

	movlps xmm5, [esi + ebx*4]
	movlps xmm6, [esi + ebx*4 + 12]
	movlps xmm7, [esi + ebx*4 + 24]

	movhps xmm2, [esi + ecx*4]
	movhps xmm3, [esi + ecx*4 + 12]
	movhps xmm4, [esi + ecx*4 + 24]

	movhps xmm5, [esi + edx*4]
	movhps xmm6, [esi + edx*4 + 12]
	movhps xmm7, [esi + edx*4 + 24]

	/* current state: */	
	/* xmm2= jxOa  jyOa  jxOc  jyOc */
	/* xmm3= jxH1a jyH1a jxH1c jyH1c */
	/* xmm4= jxH2a jyH2a jxH2c jyH2c */
	/* xmm5= jxOb  jyOb  jxOd  jyOd */
	/* xmm6= jxH1b jyH1b jxH1d jyH1d */
	/* xmm7= jxH2b jyH2b jxH2d jyH2d */
	
	movaps xmm0, xmm2
	movaps xmm1, xmm3
	unpcklps xmm0, xmm5	/* xmm0= jxOa  jxOb  jyOa  jyOb */
	unpcklps xmm1, xmm6	/* xmm1= jxH1a jxH1b jyH1a jyH1b */
	unpckhps xmm2, xmm5	/* xmm2= jxOc  jxOd  jyOc  jyOd */
	unpckhps xmm3, xmm6	/* xmm3= jxH1c jxH1d jyH1c jyH1d */
	movaps xmm5, xmm4
	movaps   xmm6, xmm0
	unpcklps xmm4, xmm7	/* xmm4= jxH2a jxH2b jyH2a jyH2b */		
	unpckhps xmm5, xmm7	/* xmm5= jxH2c jxH2d jyH2c jyH2d */
	movaps   xmm7, xmm1
	movlhps  xmm0, xmm2	/* xmm0= jxOa  jxOb  jxOc  jxOd */
	movaps [esp + _jxO], xmm0
	movhlps  xmm2, xmm6	/* xmm2= jyOa  jyOb  jyOc  jyOd */
	movaps [esp + _jyO], xmm2
	movlhps  xmm1, xmm3
	movaps [esp + _jxH1], xmm1
	movhlps  xmm3, xmm7
	movaps   xmm6, xmm4
	movaps [esp + _jyH1], xmm3
	movlhps  xmm4, xmm5
	movaps [esp + _jxH2], xmm4
	movhlps  xmm5, xmm6
	movaps [esp + _jyH2], xmm5

	movss  xmm0, [esi + eax*4 + 8]
	movss  xmm1, [esi + eax*4 + 20]
	movss  xmm2, [esi + eax*4 + 32]

	movss  xmm3, [esi + ecx*4 + 8]
	movss  xmm4, [esi + ecx*4 + 20]
	movss  xmm5, [esi + ecx*4 + 32]

	movhps xmm0, [esi + ebx*4 + 4]
	movhps xmm1, [esi + ebx*4 + 16]
	movhps xmm2, [esi + ebx*4 + 28]
	
	movhps xmm3, [esi + edx*4 + 4]
	movhps xmm4, [esi + edx*4 + 16]
	movhps xmm5, [esi + edx*4 + 28]
	
	shufps xmm0, xmm3, 0b11001100
	shufps xmm1, xmm4, 0b11001100
	shufps xmm2, xmm5, 0b11001100
	movaps [esp + _jzO],  xmm0
	movaps [esp + _jzH1],  xmm1
	movaps [esp + _jzH2],  xmm2

	movaps xmm0, [esp + _ixO]
	movaps xmm1, [esp + _iyO]
	movaps xmm2, [esp + _izO]
	movaps xmm3, [esp + _ixO]
	movaps xmm4, [esp + _iyO]
	movaps xmm5, [esp + _izO]
	subps  xmm0, [esp + _jxO]
	subps  xmm1, [esp + _jyO]
	subps  xmm2, [esp + _jzO]
	subps  xmm3, [esp + _jxH1]
	subps  xmm4, [esp + _jyH1]
	subps  xmm5, [esp + _jzH1]
	movaps [esp + _dxOO], xmm0
	movaps [esp + _dyOO], xmm1
	movaps [esp + _dzOO], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxOH1], xmm3
	movaps [esp + _dyOH1], xmm4
	movaps [esp + _dzOH1], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqOO], xmm0
	movaps [esp + _rsqOH1], xmm3

	movaps xmm0, [esp + _ixO]
	movaps xmm1, [esp + _iyO]
	movaps xmm2, [esp + _izO]
	movaps xmm3, [esp + _ixH1]
	movaps xmm4, [esp + _iyH1]
	movaps xmm5, [esp + _izH1]
	subps  xmm0, [esp + _jxH2]
	subps  xmm1, [esp + _jyH2]
	subps  xmm2, [esp + _jzH2]
	subps  xmm3, [esp + _jxO]
	subps  xmm4, [esp + _jyO]
	subps  xmm5, [esp + _jzO]
	movaps [esp + _dxOH2], xmm0
	movaps [esp + _dyOH2], xmm1
	movaps [esp + _dzOH2], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH1O], xmm3
	movaps [esp + _dyH1O], xmm4
	movaps [esp + _dzH1O], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqOH2], xmm0
	movaps [esp + _rsqH1O], xmm3

	movaps xmm0, [esp + _ixH1]
	movaps xmm1, [esp + _iyH1]
	movaps xmm2, [esp + _izH1]
	movaps xmm3, [esp + _ixH1]
	movaps xmm4, [esp + _iyH1]
	movaps xmm5, [esp + _izH1]
	subps  xmm0, [esp + _jxH1]
	subps  xmm1, [esp + _jyH1]
	subps  xmm2, [esp + _jzH1]
	subps  xmm3, [esp + _jxH2]
	subps  xmm4, [esp + _jyH2]
	subps  xmm5, [esp + _jzH2]
	movaps [esp + _dxH1H1], xmm0
	movaps [esp + _dyH1H1], xmm1
	movaps [esp + _dzH1H1], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH1H2], xmm3
	movaps [esp + _dyH1H2], xmm4
	movaps [esp + _dzH1H2], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqH1H1], xmm0
	movaps [esp + _rsqH1H2], xmm3

	movaps xmm0, [esp + _ixH2]
	movaps xmm1, [esp + _iyH2]
	movaps xmm2, [esp + _izH2]
	movaps xmm3, [esp + _ixH2]
	movaps xmm4, [esp + _iyH2]
	movaps xmm5, [esp + _izH2]
	subps  xmm0, [esp + _jxO]
	subps  xmm1, [esp + _jyO]
	subps  xmm2, [esp + _jzO]
	subps  xmm3, [esp + _jxH1]
	subps  xmm4, [esp + _jyH1]
	subps  xmm5, [esp + _jzH1]
	movaps [esp + _dxH2O], xmm0
	movaps [esp + _dyH2O], xmm1
	movaps [esp + _dzH2O], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH2H1], xmm3
	movaps [esp + _dyH2H1], xmm4
	movaps [esp + _dzH2H1], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm4, xmm3
	addps  xmm4, xmm5
	movaps [esp + _rsqH2O], xmm0
	movaps [esp + _rsqH2H1], xmm4

	movaps xmm0, [esp + _ixH2]
	movaps xmm1, [esp + _iyH2]
	movaps xmm2, [esp + _izH2]
	subps  xmm0, [esp + _jxH2]
	subps  xmm1, [esp + _jyH2]
	subps  xmm2, [esp + _jzH2]
	movaps [esp + _dxH2H2], xmm0
	movaps [esp + _dyH2H2], xmm1
	movaps [esp + _dzH2H2], xmm2
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2
	movaps [esp + _rsqH2H2], xmm0
		
	/* start doing invsqrt use rsq values in xmm0, xmm4 */
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] /* rinvH2H2 */
	mulps   xmm7, [esp + _half] /* rinvH2H1 */
	movaps  [esp + _rinvH2H2], xmm3
	movaps  [esp + _rinvH2H1], xmm7
	
	rsqrtps xmm1, [esp + _rsqOO]
	rsqrtps xmm5, [esp + _rsqOH1]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqOO]
	mulps   xmm5, [esp + _rsqOH1]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvOO], xmm3
	movaps  [esp + _rinvOH1], xmm7
	
	rsqrtps xmm1, [esp + _rsqOH2]
	rsqrtps xmm5, [esp + _rsqH1O]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqOH2]
	mulps   xmm5, [esp + _rsqH1O]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvOH2], xmm3
	movaps  [esp + _rinvH1O], xmm7
	
	rsqrtps xmm1, [esp + _rsqH1H1]
	rsqrtps xmm5, [esp + _rsqH1H2]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqH1H1]
	mulps   xmm5, [esp + _rsqH1H2]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvH1H1], xmm3
	movaps  [esp + _rinvH1H2], xmm7
	
	rsqrtps xmm1, [esp + _rsqH2O]
	movaps  xmm2, xmm1
	mulps   xmm1, xmm1
	movaps  xmm3, [esp + _three]
	mulps   xmm1, [esp + _rsqH2O]
	subps   xmm3, xmm1
	mulps   xmm3, xmm2
	mulps   xmm3, [esp + _half] 
	movaps  [esp + _rinvH2O], xmm3

	/* start with OO interaction */
	movaps xmm0, [esp + _rinvOO]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]
	mulps  xmm0, xmm0	/* xmm0=rinvsq */

	mulps  xmm5, [esp + _rsqOO] /* xmm5=krsq */
	movaps xmm6, xmm5
	addps  xmm6, xmm7	/* xmm6=rinv+ krsq */
	subps  xmm6, [esp + _crf]
	mulps  xmm6, [esp + _qqOO] /* xmm6=voul=qq*(rinv+ krsq-crf) */
	mulps xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqOO] /* xmm7 = coul part of fscal */
	
	addps  xmm6, [esp + _vctot] /* local vctot summation variable */
	mulps  xmm0, xmm7
	
	movaps xmm1, xmm0
	movaps xmm2, xmm0

	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOO]
	mulps xmm1, [esp + _dyOO]
	mulps xmm2, [esp + _dzOO]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* O-H1 interaction */
	movaps xmm0, [esp + _rinvOH1]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]
	movaps xmm1, xmm0
	mulps  xmm5, [esp + _rsqOH1] /* xmm5=krsq */
	movaps xmm4, xmm5
	addps  xmm4, xmm7	/* xmm4=r inv+ krsq */
	subps  xmm4, [esp + _crf]
	mulps  xmm0, xmm0
	mulps  xmm4, [esp + _qqOH] /* xmm4=voul=qq*(rinv+ krsq-crf) */
	mulps  xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqOH] /* xmm7 = coul part of fscal */
	addps  xmm6, xmm4	/* add to local vctot */
	mulps xmm0, xmm7	/* fsOH1  */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	
	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOH1]
	mulps xmm1, [esp + _dyOH1]
	mulps xmm2, [esp + _dzOH1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* O-H2 interaction */ 
	movaps xmm0, [esp + _rinvOH2]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]	
	movaps xmm1, xmm0
	mulps  xmm5, [esp + _rsqOH2] /* xmm5=krsq */
	movaps xmm4, xmm5
	addps  xmm4, xmm7	/* xmm4=r inv+ krsq */
	subps  xmm4, [esp + _crf]
	mulps xmm0, xmm0
	mulps  xmm4, [esp + _qqOH] /* xmm4=voul=qq*(rinv+ krsq-crf) */
	mulps  xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqOH] /* xmm7 = coul part of fscal */
	addps  xmm6, xmm4	/* add to local vctot */
	mulps xmm0, xmm7	/* fsOH2 */
	movaps xmm1, xmm0
	movaps xmm2, xmm0

	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOH2]
	mulps xmm1, [esp + _dyOH2]
	mulps xmm2, [esp + _dzOH2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* H1-O interaction */
	movaps xmm0, [esp + _rinvH1O]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]	
	movaps xmm1, xmm0
	mulps  xmm5, [esp + _rsqH1O] /* xmm5=krsq */
	movaps xmm4, xmm5
	addps  xmm4, xmm7	/* xmm4=r inv+ krsq */
	subps  xmm4, [esp + _crf]
	mulps xmm0, xmm0
	mulps  xmm4, [esp + _qqOH] /* xmm4=voul=qq*(rinv+ krsq-crf) */
	mulps  xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqOH] /* xmm7 = coul part of fscal */
	addps  xmm6, xmm4	/* add to local vctot */
	mulps xmm0, xmm7	/* fsOH2 */
	movaps xmm1, xmm0
	movaps xmm2, xmm0

	movaps xmm3, [esp + _fjxO]
	movaps xmm4, [esp + _fjyO]
	movaps xmm5, [esp + _fjzO]
	mulps xmm0, [esp + _dxH1O]
	mulps xmm1, [esp + _dyH1O]
	mulps xmm2, [esp + _dzH1O]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H1-H1 interaction */
	movaps xmm0, [esp + _rinvH1H1]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]	
	movaps xmm1, xmm0
	mulps  xmm5, [esp + _rsqH1H1] /* xmm5=krsq */
	movaps xmm4, xmm5
	addps  xmm4, xmm7	/* xmm4=r inv+ krsq */
	subps  xmm4, [esp + _crf]
	mulps xmm0, xmm0
	mulps  xmm4, [esp + _qqHH] /* xmm4=voul=qq*(rinv+ krsq-crf) */
	mulps  xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqHH] /* xmm7 = coul part of fscal */
	addps  xmm6, xmm4	/* add to local vctot */
	mulps xmm0, xmm7	/* fsOH2 */
	movaps xmm1, xmm0
	movaps xmm2, xmm0

	movaps xmm3, [esp + _fjxH1]
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	mulps xmm0, [esp + _dxH1H1]
	mulps xmm1, [esp + _dyH1H1]
	mulps xmm2, [esp + _dzH1H1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H1-H2 interaction */
	movaps xmm0, [esp + _rinvH1H2]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]	
	movaps xmm1, xmm0
	mulps  xmm5, [esp + _rsqH1H2] /* xmm5=krsq */
	movaps xmm4, xmm5
	addps  xmm4, xmm7	/* xmm4=r inv+ krsq */
	subps  xmm4, [esp + _crf]
	mulps xmm0, xmm0
	mulps  xmm4, [esp + _qqHH] /* xmm4=voul=qq*(rinv+ krsq-crf) */
	mulps  xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqHH] /* xmm7 = coul part of fscal */
	addps  xmm6, xmm4	/* add to local vctot */
	mulps xmm0, xmm7	/* fsOH2 */
	movaps xmm1, xmm0
	movaps xmm2, xmm0
	
	movaps xmm3, [esp + _fjxH2]
	movaps xmm4, [esp + _fjyH2]
	movaps xmm5, [esp + _fjzH2]
	mulps xmm0, [esp + _dxH1H2]
	mulps xmm1, [esp + _dyH1H2]
	mulps xmm2, [esp + _dzH1H2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H2-O interaction */
	movaps xmm0, [esp + _rinvH2O]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]	
	movaps xmm1, xmm0
	mulps  xmm5, [esp + _rsqH2O] /* xmm5=krsq */
	movaps xmm4, xmm5
	addps  xmm4, xmm7	/* xmm4=r inv+ krsq */
	subps  xmm4, [esp + _crf]
	mulps xmm0, xmm0
	mulps  xmm4, [esp + _qqOH] /* xmm4=voul=qq*(rinv+ krsq-crf) */
	mulps  xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqOH] /* xmm7 = coul part of fscal */
	addps  xmm6, xmm4	/* add to local vctot */
	mulps xmm0, xmm7	/* fsOH2 */
	movaps xmm1, xmm0
	movaps xmm2, xmm0

	movaps xmm3, [esp + _fjxO]
	movaps xmm4, [esp + _fjyO]
	movaps xmm5, [esp + _fjzO]
	mulps xmm0, [esp + _dxH2O]
	mulps xmm1, [esp + _dyH2O]
	mulps xmm2, [esp + _dzH2O]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	/* H2-H1 interaction */
	movaps xmm0, [esp + _rinvH2H1]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]	
	movaps xmm1, xmm0
	mulps  xmm5, [esp + _rsqH2H1] /* xmm5=krsq */
	movaps xmm4, xmm5
	addps  xmm4, xmm7	/* xmm4=r inv+ krsq */
	subps  xmm4, [esp + _crf]
	mulps xmm0, xmm0
	mulps  xmm4, [esp + _qqHH] /* xmm4=voul=qq*(rinv+ krsq-crf) */
	mulps  xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqHH] /* xmm7 = coul part of fscal */
	addps  xmm6, xmm4	/* add to local vctot */
	mulps xmm0, xmm7	/* fsOH2 */
	movaps xmm1, xmm0
	movaps xmm2, xmm0

	movaps xmm3, [esp + _fjxH1]
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	mulps xmm0, [esp + _dxH2H1]
	mulps xmm1, [esp + _dyH2H1]
	mulps xmm2, [esp + _dzH2H1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	/* H2-H2 interaction */
	movaps xmm0, [esp + _rinvH2H2]
	movaps xmm7, xmm0	/* xmm7=rinv */
	movaps xmm5, [esp + _krf]	
	movaps xmm1, xmm0
	mulps  xmm5, [esp + _rsqH2H2] /* xmm5=krsq */
	movaps xmm4, xmm5
	addps  xmm4, xmm7	/* xmm4=r inv+ krsq */
	subps  xmm4, [esp + _crf]
	mulps xmm0, xmm0
	mulps  xmm4, [esp + _qqHH] /* xmm4=voul=qq*(rinv+ krsq-crf) */
	mulps  xmm5, [esp + _two]
	subps  xmm7, xmm5	/* xmm7=rinv-2*krsq */
	mulps  xmm7, [esp + _qqHH] /* xmm7 = coul part of fscal */
	addps  xmm6, xmm4	/* add to local vctot */
	mulps xmm0, xmm7	/* fsOH2 */
	movaps xmm1, xmm0
	movaps xmm2, xmm0

	movaps xmm1, xmm0
	movaps [esp + _vctot], xmm6
	movaps xmm2, xmm0
	
	movaps xmm3, [esp + _fjxH2]
	movaps xmm4, [esp + _fjyH2]
	movaps xmm5, [esp + _fjzH2]
	mulps xmm0, [esp + _dxH2H2]
	mulps xmm1, [esp + _dyH2H2]
	mulps xmm2, [esp + _dzH2H2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	mov edi, [ebp + _faction]
		
	/* Did all interactions - now update j forces */
	/* 4 j waters with three atoms each - first do a & b j particles */
	movaps xmm0, [esp + _fjxO] /* xmm0= fjxOa  fjxOb  fjxOc  fjxOd */
	movaps xmm1, [esp + _fjyO] /* xmm1= fjyOa  fjyOb  fjyOc  fjyOd */ 
	unpcklps xmm0, xmm1    	   /* xmm0= fjxOa  fjyOa  fjxOb  fjyOb */
	movaps xmm1, [esp + _fjzO]
	movaps xmm2, [esp + _fjxH1]
	movhlps  xmm3, xmm0	   /* xmm3= fjxOb  fjyOb */ 
	unpcklps xmm1, xmm2	   /* xmm1= fjzOa  fjxH1a fjzOb  fjxH1b */
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	unpcklps xmm4, xmm5	   /* xmm4= fjyH1a fjzH1a fjyH1b fjzH1b */
	movaps xmm5, [esp + _fjxH2]
	movaps xmm6, [esp + _fjyH2]
	movhlps  xmm7, xmm4	   /* xmm7= fjyH1b fjzH1b */
	unpcklps xmm5, xmm6	   /* xmm5= fjxH2a fjyH2a fjxH2b fjyH2b */
	movlhps  xmm0, xmm1    	   /* xmm0= fjxOa  fjyOa  fjzOa  fjxH1a */
	shufps   xmm3, xmm1, 0b11100100
                                   /* xmm3= fjxOb  fjyOb  fjzOb  fjxH1b */
	movlhps  xmm4, xmm5   	   /* xmm4= fjyH1a fjzH1a fjxH2a fjyH2a */
	shufps   xmm7, xmm5, 0b11100100
                                   /* xmm7= fjyH1b fjzH1b fjxH2b fjyH2b */
	movups   xmm1, [edi + eax*4]
	movups   xmm2, [edi + eax*4 + 16]
	movups   xmm5, [edi + ebx*4]
	movups   xmm6, [edi + ebx*4 + 16]
	addps    xmm1, xmm0
	addps    xmm2, xmm4
	addps    xmm5, xmm3
	addps    xmm6, xmm7
	movss    xmm0, [edi + eax*4 + 32]
	movss    xmm3, [edi + ebx*4 + 32]
	
	movaps   xmm4, [esp + _fjzH2]
	movaps   xmm7, xmm4
	shufps   xmm7, xmm7, 1
	
	movups   [edi + eax*4],     xmm1
	movups   [edi + eax*4 + 16],xmm2
	movups   [edi + ebx*4],     xmm5
	movups   [edi + ebx*4 + 16],xmm6	
	addss    xmm0, xmm4
	addss    xmm3, xmm7
	movss    [edi + eax*4 + 32], xmm0
	movss    [edi + ebx*4 + 32], xmm3	

	/* then do the second pair (c & d) */
	movaps xmm0, [esp + _fjxO] /* xmm0= fjxOa  fjxOb  fjxOc  fjxOd */
	movaps xmm1, [esp + _fjyO] /* xmm1= fjyOa  fjyOb  fjyOc  fjyOd */ 
	unpckhps xmm0, xmm1	   /* xmm0= fjxOc  fjyOc  fjxOd  fjyOd */
	movaps xmm1, [esp + _fjzO]
	movaps xmm2, [esp + _fjxH1]
	movhlps  xmm3, xmm0	   /* xmm3= fjxOd  fjyOd */ 
	unpckhps xmm1, xmm2	   /* xmm1= fjzOc  fjxH1c fjzOd  fjxH1d */
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	unpckhps xmm4, xmm5	   /* xmm4= fjyH1c fjzH1c fjyH1d fjzH1d	*/
	movaps xmm5, [esp + _fjxH2]
	movaps xmm6, [esp + _fjyH2]
	movhlps  xmm7, xmm4	   /* xmm7= fjyH1d fjzH1d */	 
	unpckhps xmm5, xmm6	   /* xmm5= fjxH2c fjyH2c fjxH2d fjyH2d */
	movlhps  xmm0, xmm1	   /* xmm0= fjxOc  fjyOc  fjzOc  fjxH1c */
	shufps   xmm3, xmm1, 0b11100100
                                   /* xmm3= fjxOd  fjyOd  fjzOd  fjxH1d */
	movlhps  xmm4, xmm5	   /* xmm4= fjyH1c fjzH1c fjxH2c fjyH2c  */
	shufps   xmm7, xmm5, 0b11100100
                                   /* xmm7= fjyH1d fjzH1d fjxH2d fjyH2d */
	movups   xmm1, [edi + ecx*4]
	movups   xmm2, [edi + ecx*4 + 16]
	movups   xmm5, [edi + edx*4]
	movups   xmm6, [edi + edx*4 + 16]
	addps    xmm1, xmm0
	addps    xmm2, xmm4
	addps    xmm5, xmm3
	addps    xmm6, xmm7
	movss    xmm0, [edi + ecx*4 + 32]
	movss    xmm3, [edi + edx*4 + 32]
	
	movaps   xmm4, [esp + _fjzH2]
	movaps   xmm7, xmm4
	shufps   xmm4, xmm4, 0b10
	shufps   xmm7, xmm7, 0b11
	movups   [edi + ecx*4],     xmm1
	movups   [edi + ecx*4 + 16],xmm2
	movups   [edi + edx*4],     xmm5
	movups   [edi + edx*4 + 16],xmm6	
	addss    xmm0, xmm4
	addss    xmm3, xmm7
	movss    [edi + ecx*4 + 32], xmm0
	movss    [edi + edx*4 + 32], xmm3	
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i2030_single_check
	jmp   .i2030_unroll_loop
.i2030_single_check:
	add   [esp + _innerk],  4
	jnz   .i2030_single_loop
	jmp   .i2030_updateouterdata
.i2030_single_loop:
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	add   [esp + _innerjjnr],  4	

	mov esi, [ebp + _pos]
	lea   eax, [eax + eax*2]  

	/* fetch j coordinates */
	xorps xmm3, xmm3
	xorps xmm4, xmm4
	xorps xmm5, xmm5
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + eax*4 + 4]
	movss xmm5, [esi + eax*4 + 8]

	movlps xmm6, [esi + eax*4 + 12]
	movhps xmm6, [esi + eax*4 + 24]	/* xmm6=jxH1 jyH1 jxH2 jyH2 */
	/* fetch both z coords in one go, to positions 0 and 3 in xmm7 */
	movups xmm7, [esi + eax*4 + 20] /* xmm7=jzH1 jxH2 jyH2 jzH2 */
	shufps xmm6, xmm6, 0b11011000    /* xmm6=jxH1 jxH2 jyH1 jyH2 */
	movlhps xmm3, xmm6      	/* xmm3= jxO   0  jxH1 jxH2 */
	movaps  xmm0, [esp + _ixO]     
	movaps  xmm1, [esp + _iyO]
	movaps  xmm2, [esp + _izO]	
	shufps  xmm4, xmm6, 0b11100100 /* xmm4= jyO   0   jyH1 jyH2 */
	shufps xmm5, xmm7, 0b11000100  /* xmm5= jzO   0   jzH1 jzH2 */
	/* store all j coordinates in jO */ 
	movaps [esp + _jxO], xmm3
	movaps [esp + _jyO], xmm4
	movaps [esp + _jzO], xmm5
	subps  xmm0, xmm3
	subps  xmm1, xmm4
	subps  xmm2, xmm5
	movaps [esp + _dxOO], xmm0
	movaps [esp + _dyOO], xmm1
	movaps [esp + _dzOO], xmm2
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2	/* have rsq in xmm0 */

	movaps xmm6, xmm0
	
	/* do invsqrt */
	rsqrtps xmm1, xmm0
	mulps   xmm6, [esp + _krf] /* xmm6=krsq */
	movaps  xmm2, xmm1
	movaps  xmm7, xmm6         /* xmm7=krsq */
	mulps   xmm1, xmm1
	movaps  xmm3, [esp + _three]
	mulps   xmm1, xmm0
	subps   xmm3, xmm1
	mulps   xmm3, xmm2							
	mulps   xmm3, [esp + _half] /* rinv iO - j water */


	
	addps   xmm6, xmm3	/* xmm6=rinv+ krsq */
	mulps   xmm7, [esp + _two]
	subps   xmm6, [esp + _crf] /* xmm6=rinv+ krsq-crf */
	
	xorps   xmm1, xmm1
	movaps  xmm0, xmm3
	subps   xmm3, xmm7	/* xmm3=rinv-2*krsq */
	xorps   xmm4, xmm4
	mulps   xmm0, xmm0	/* xmm0=rinvsq */
	/* fetch charges to xmm4 (temporary) */
	movss   xmm4, [esp + _qqOO]
	movhps  xmm4, [esp + _qqOH]

	mulps xmm6, xmm4	/* vcoul */ 
	mulps xmm3, xmm4	/* coul part of fs */ 


	addps   xmm6, [esp + _vctot]
	mulps   xmm0, xmm3	/* total fscal */
	movaps  [esp + _vctot], xmm6	

	movaps  xmm1, xmm0
	movaps  xmm2, xmm0
	mulps   xmm0, [esp + _dxOO]
	mulps   xmm1, [esp + _dyOO]
	mulps   xmm2, [esp + _dzOO]
	
	/* initial update for j forces */
	xorps   xmm3, xmm3
	xorps   xmm4, xmm4
	xorps   xmm5, xmm5
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixO]
	addps   xmm1, [esp + _fiyO]
	addps   xmm2, [esp + _fizO]
	movaps  [esp + _fixO], xmm0
	movaps  [esp + _fiyO], xmm1
	movaps  [esp + _fizO], xmm2

	
	/* done with i O Now do i H1 & H2 simultaneously first get i particle coords: */
	movaps  xmm0, [esp + _ixH1]
	movaps  xmm1, [esp + _iyH1]
	movaps  xmm2, [esp + _izH1]	
	movaps  xmm3, [esp + _ixH2] 
	movaps  xmm4, [esp + _iyH2] 
	movaps  xmm5, [esp + _izH2] 
	subps   xmm0, [esp + _jxO]
	subps   xmm1, [esp + _jyO]
	subps   xmm2, [esp + _jzO]
	subps   xmm3, [esp + _jxO]
	subps   xmm4, [esp + _jyO]
	subps   xmm5, [esp + _jzO]
	movaps [esp + _dxH1O], xmm0
	movaps [esp + _dyH1O], xmm1
	movaps [esp + _dzH1O], xmm2
	movaps [esp + _dxH2O], xmm3
	movaps [esp + _dyH2O], xmm4
	movaps [esp + _dzH2O], xmm5
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	mulps xmm3, xmm3
	mulps xmm4, xmm4
	mulps xmm5, xmm5
	addps xmm0, xmm1
	addps xmm4, xmm3
	addps xmm0, xmm2	/* have rsqH1 in xmm0 */
	addps xmm4, xmm5	/* have rsqH2 in xmm4 */
	
	/* do invsqrt */
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] /* rinv H1 - j water */
	mulps   xmm7, [esp + _half] /* rinv H2 - j water */ 

	mulps xmm0, [esp + _krf] /* krsq */
	mulps xmm4, [esp + _krf] /* krsq */ 

	/* assemble charges in xmm6 */
	xorps   xmm6, xmm6
	movss   xmm6, [esp + _qqOH]
	movhps  xmm6, [esp + _qqHH]
	movaps  xmm1, xmm0
	movaps  xmm5, xmm4
	addps   xmm0, xmm3	/* krsq+ rinv */
	addps   xmm4, xmm7	/* krsq+ rinv */
	subps   xmm0, [esp + _crf]
	subps   xmm4, [esp + _crf]
	mulps   xmm1, [esp + _two]
	mulps   xmm5, [esp + _two]
	mulps   xmm0, xmm6	/* vcoul */
	mulps   xmm4, xmm6	/* vcoul */
	addps   xmm4, xmm0		
	addps   xmm4, [esp + _vctot]
	movaps  [esp + _vctot], xmm4
	movaps  xmm0, xmm3
	movaps  xmm4, xmm7
	mulps   xmm3, xmm3
	mulps   xmm7, xmm7
	subps   xmm0, xmm1
	subps   xmm4, xmm5
	mulps   xmm0, xmm6
	mulps   xmm4, xmm6
	mulps   xmm0, xmm3	/* fscal */
	mulps   xmm7, xmm4	/* fscal */
	
	movaps  xmm1, xmm0
	movaps  xmm2, xmm0
	mulps   xmm0, [esp + _dxH1O]
	mulps   xmm1, [esp + _dyH1O]
	mulps   xmm2, [esp + _dzH1O]
	/* update forces H1 - j water */
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixH1]
	addps   xmm1, [esp + _fiyH1]
	addps   xmm2, [esp + _fizH1]
	movaps  [esp + _fixH1], xmm0
	movaps  [esp + _fiyH1], xmm1
	movaps  [esp + _fizH1], xmm2
	/* do forces H2 - j water */
	movaps xmm0, xmm7
	movaps xmm1, xmm7
	movaps xmm2, xmm7
	mulps   xmm0, [esp + _dxH2O]
	mulps   xmm1, [esp + _dyH2O]
	mulps   xmm2, [esp + _dzH2O]
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	mov     esi, [ebp + _faction]
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixH2]
	addps   xmm1, [esp + _fiyH2]
	addps   xmm2, [esp + _fizH2]
	movaps  [esp + _fixH2], xmm0
	movaps  [esp + _fiyH2], xmm1
	movaps  [esp + _fizH2], xmm2

	/* update j water forces from local variables */
	movlps  xmm0, [esi + eax*4]
	movlps  xmm1, [esi + eax*4 + 12]
	movhps  xmm1, [esi + eax*4 + 24]
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	movaps  xmm6, xmm5
	movaps  xmm7, xmm5
	shufps  xmm6, xmm6, 0b10
	shufps  xmm7, xmm7, 0b11
	addss   xmm5, [esi + eax*4 + 8]
	addss   xmm6, [esi + eax*4 + 20]
	addss   xmm7, [esi + eax*4 + 32]
	movss   [esi + eax*4 + 8], xmm5
	movss   [esi + eax*4 + 20], xmm6
	movss   [esi + eax*4 + 32], xmm7
	movaps   xmm5, xmm3
	unpcklps xmm3, xmm4
	unpckhps xmm5, xmm4
	addps    xmm0, xmm3
	addps    xmm1, xmm5
	movlps  [esi + eax*4], xmm0 
	movlps  [esi + eax*4 + 12], xmm1 
	movhps  [esi + eax*4 + 24], xmm1 
	
	dec dword ptr [esp + _innerk]
	jz    .i2030_updateouterdata
	jmp   .i2030_single_loop
.i2030_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate  Oi forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixO]
	movaps xmm1, [esp + _fiyO] 
	movaps xmm2, [esp + _fizO]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	movaps xmm6, xmm0
	movss xmm7, xmm2
	movlhps xmm6, xmm1
	shufps  xmm6, xmm6, 0b1000	
 
	/* accumulate H1i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH1]
	movaps xmm1, [esp + _fiyH1]
	movaps xmm2, [esp + _fizH1]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 12]
	movss  xmm4, [edi + ecx*4 + 16]
	movss  xmm5, [edi + ecx*4 + 20]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 12], xmm3
	movss  [edi + ecx*4 + 16], xmm4
	movss  [edi + ecx*4 + 20], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* accumulate H2i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH2]
	movaps xmm1, [esp + _fiyH2]
	movaps xmm2, [esp + _fizH2]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 24]
	movss  xmm4, [edi + ecx*4 + 28]
	movss  xmm5, [edi + ecx*4 + 32]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 24], xmm3
	movss  [edi + ecx*4 + 28], xmm4
	movss  [edi + ecx*4 + 32], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* increment fshift force */ 
	movlps  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 8]
	addps  xmm3, xmm6
	addss  xmm4, xmm7
	movlps  [esi + edx*4],    xmm3
	movss  [esi + edx*4 + 8], xmm4

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 	
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i2030_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i2030_outer
.i2030_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 1460
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret

	
		

.globl inl3000_sse
	.type inl3000_sse,@function
inl3000_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_tabscale,	60
.equ		_VFtab,		64
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ix,		0
.equ		_iy,		16
.equ		_iz,		32
.equ		_iq,		48
.equ		_dx,		64
.equ		_dy,		80
.equ		_dz,		96
.equ		_two,		112
.equ		_tsc,		128
.equ		_qq,		144	
.equ		_fs,		160
.equ		_vctot,		176
.equ		_fix,		192
.equ		_fiy,		208
.equ		_fiz,		224
.equ		_half,		240
.equ		_three,		256
.equ		_is3,		272
.equ		_ii3,		276
.equ		_innerjjnr,	280
.equ		_innerk,	284
.equ		_salign,	288								
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 292		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_two]
	movups xmm2, [sse_three]
	movss xmm3, [ebp + _tabscale]
	movaps [esp + _half],  xmm0
	movaps [esp + _two], xmm1
	movaps [esp + _three],  xmm2
	shufps xmm3, xmm3, 0
	movaps [esp + _tsc], xmm3

	/* assume we have at least one i particle - start directly */	
.i3000_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	mulss xmm3, [ebp + _facel]
	shufps xmm3, xmm3, 0

	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]

	movaps [esp + _iq], xmm3
	
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   [esp + _ii3], ebx
	
	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i3000_unroll_loop
	jmp   .i3000_finish_inner
.i3000_unroll_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	movaps xmm2, [esp + _iq]
	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	mulps  xmm3, xmm2

	movaps [esp + _qq], xmm3	
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	movhlps xmm5, xmm4
	cvttps2pi mm6, xmm4
	cvttps2pi mm7, xmm5	/* mm6/mm7 contain lu indices */
	cvtpi2ps xmm6, mm6
	cvtpi2ps xmm5, mm7
	movlhps xmm6, xmm5
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */
	pslld mm6, 2
	pslld mm7, 2

	movd mm0, eax	
	movd mm1, ebx
	movd mm2, ecx
	movd mm3, edx

	mov  esi, [ebp + _VFtab]
	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7
		
	movlps xmm5, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm5, [esi + ebx*4]
	movhps xmm7, [esi + edx*4] /* got half coulomb table */

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101

	movlps xmm7, [esi + eax*4 + 8]
	movlps xmm3, [esi + ecx*4 + 8]
	movhps xmm7, [esi + ebx*4 + 8]
	movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* coulomb table ready, in xmm4-xmm7 */ 	
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addps  xmm5, [esp + _vctot]
	movaps [esp + _vctot], xmm5 

	xorps  xmm4, xmm4

	mulps xmm3, [esp + _tsc]
	mulps xmm3, xmm0
	subps  xmm4, xmm3

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movd eax, mm0	
	movd ebx, mm1
	movd ecx, mm2
	movd edx, mm3

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i3000_finish_inner
	jmp   .i3000_unroll_loop
.i3000_finish_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i3000_dopair
	jmp   .i3000_checksingle
.i3000_dopair:	
	mov esi, [ebp + _charge]

        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8	
	xorps xmm7, xmm7
	movss xmm3, [esi + eax*4]		
	movss xmm6, [esi + ebx*4]
	shufps xmm3, xmm6, 0 
	shufps xmm3, xmm3, 0b00001000 /* xmm3(0,1) has the charges */

	mulps  xmm3, [esp + _iq]
	movlhps xmm3, xmm7
	movaps [esp + _qq], xmm3

	mov edi, [ebp + _pos]	
	
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ecx, mm6
	psrlq mm6, 32
	movd edx, mm6

	movlps xmm5, [esi + ecx*4]
	movhps xmm5, [esi + edx*4] /* got half coulomb table */
	movaps xmm4, xmm5
	shufps xmm4, xmm4, 0b10001000
	shufps xmm5, xmm7, 0b11011101
	
	movlps xmm7, [esi + ecx*4 + 8]
	movhps xmm7, [esi + edx*4 + 8]
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 0b10001000
	shufps xmm7, xmm7, 0b11011101
	/* table ready in xmm4-xmm7 */

	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addps  xmm5, [esp + _vctot]
	movaps [esp + _vctot], xmm5 

	xorps  xmm4, xmm4

	mulps xmm3, [esp + _tsc]
	mulps xmm3, xmm0
	subps  xmm4, xmm3

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i3000_checksingle:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    .i3000_dosingle
	jmp    .i3000_updateouterdata
.i3000_dosingle:
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	xorps  xmm6, xmm6
	movss xmm6, [esi + eax*4]	/* xmm6(0) has the charge */	
	mulps  xmm6, [esp + _iq]
	movaps [esp + _qq], xmm6
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	 
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */

	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ebx, mm6
	
	movlps xmm4, [esi + ebx*4]
	movlps xmm6, [esi + ebx*4 + 8]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */

	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addss  xmm5, [esp + _vctot]
	movss [esp + _vctot], xmm5 

	xorps xmm4, xmm4

	mulps xmm3, [esp + _tsc]
	mulps xmm3, xmm0
	subps  xmm4, xmm3
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
.i3000_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i3000_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i3000_outer
.i3000_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 292
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret



.globl inl3010_sse
	.type inl3010_sse,@function
inl3010_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56
.equ		_tabscale,	60
.equ		_VFtab,		64
.equ		_nsatoms,	68	
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ix,		0
.equ		_iy,		16
.equ		_iz,		32
.equ		_iq,		48
.equ		_dx,		64
.equ		_dy,		80
.equ		_dz,		96
.equ		_two,		112
.equ		_tsc,		128
.equ		_qq,		144	
.equ		_fscal,		160
.equ		_vctot,		176
.equ		_fix,		192
.equ		_fiy,		208
.equ		_fiz,		224
.equ		_half,		240
.equ		_three,		256
.equ		_is3,		272
.equ		_ii3,		276
.equ		_shX,		280
.equ		_shY,		284
.equ		_shZ,		288
.equ		_ntia,		292	
.equ		_innerjjnr0,	296
.equ		_innerk0,	300
.equ		_innerjjnr,	304
.equ		_innerk,	308
.equ		_salign,	312
.equ		_nscoul,	316
.equ		_solnr,		320			
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 324		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_two]
	movups xmm2, [sse_three]
	movss xmm3, [ebp + _tabscale]
	movaps [esp + _half],  xmm0
	movaps [esp + _two], xmm1
	movaps [esp + _three],  xmm2
	shufps xmm3, xmm3, 0
	movaps [esp + _tsc], xmm3

	add   [ebp + _nsatoms],  8

	/* assume we have at least one i particle - start directly */	
.i3010_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 
	movss [esp + _shX], xmm0
	movss [esp + _shY], xmm1
	movss [esp + _shZ], xmm2

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   eax, [ebp + _nsatoms]
	mov   ecx, [eax]
	add   [ebp + _nsatoms],  12
	mov   [esp + _nscoul], ecx	

	/* clear vctot */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	mov   [esp + _solnr], ebx

	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr0], eax     /* pointer to jjnr[nj0] */
	mov   [esp + _innerk0], edx        /* number of innerloop atoms */

	mov   ecx, [esp + _nscoul]
	cmp   ecx,  0
	jnz  .i3010_mno_coul
	jmp   .i3010_last_mno
.i3010_mno_coul:
	mov   ebx,  [esp + _solnr]
	inc   dword ptr [esp + _solnr]

	movss xmm0, [esp + _shX]
	movss xmm1, [esp + _shY]
	movss xmm2, [esp + _shZ]

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	mulss xmm3, [ebp + _facel]
	shufps xmm3, xmm3, 0
	
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]

	movaps [esp + _iq], xmm3
	
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   [esp + _ii3], ebx
	
	/* clear i forces */
	xorps xmm4, xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4

	mov   ecx, [esp + _innerjjnr0]
	mov   [esp + _innerjjnr], ecx
	mov   edx, [esp + _innerk0]
        sub   edx,  4
        mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i3010_unroll_coul_loop
	jmp   .i3010_finish_coul_inner

.i3010_unroll_coul_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	movaps xmm2, [esp + _iq]
	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	mulps  xmm3, xmm2

	movaps [esp + _qq], xmm3	
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	movhlps xmm5, xmm4
	cvttps2pi mm6, xmm4
	cvttps2pi mm7, xmm5	/* mm6/mm7 contain lu indices */
	cvtpi2ps xmm6, mm6
	cvtpi2ps xmm5, mm7
	movlhps xmm6, xmm5
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */
	pslld mm6, 2
	pslld mm7, 2

	movd mm0, eax	
	movd mm1, ebx
	movd mm2, ecx
	movd mm3, edx

	mov  esi, [ebp + _VFtab]
	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7
		
	movlps xmm5, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm5, [esi + ebx*4]
	movhps xmm7, [esi + edx*4] /* got half coulomb table */

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101

	movlps xmm7, [esi + eax*4 + 8]
	movlps xmm3, [esi + ecx*4 + 8]
	movhps xmm7, [esi + ebx*4 + 8]
	movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* coulomb table ready, in xmm4-xmm7 */ 	
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addps  xmm5, [esp + _vctot]
	movaps [esp + _vctot], xmm5 

	xorps  xmm4, xmm4

	mulps xmm3, [esp + _tsc]
	mulps xmm3, xmm0
	subps  xmm4, xmm3

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movd eax, mm0	
	movd ebx, mm1
	movd ecx, mm2
	movd edx, mm3

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i3010_finish_coul_inner
	jmp   .i3010_unroll_coul_loop
.i3010_finish_coul_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i3010_dopair_coul
	jmp   .i3010_checksingle_coul
.i3010_dopair_coul:	
	mov esi, [ebp + _charge]

        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8	
	xorps xmm7, xmm7
	movss xmm3, [esi + eax*4]		
	movss xmm6, [esi + ebx*4]
	shufps xmm3, xmm6, 0 
	shufps xmm3, xmm3, 0b00001000 /* xmm3(0,1) has the charges */

	mulps  xmm3, [esp + _iq]
	movlhps xmm3, xmm7
	movaps [esp + _qq], xmm3

	mov edi, [ebp + _pos]	
	
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ecx, mm6
	psrlq mm6, 32
	movd edx, mm6

	movlps xmm5, [esi + ecx*4]
	movhps xmm5, [esi + edx*4] /* got half coulomb table */
	movaps xmm4, xmm5
	shufps xmm4, xmm4, 0b10001000
	shufps xmm5, xmm7, 0b11011101
	
	movlps xmm7, [esi + ecx*4 + 8]
	movhps xmm7, [esi + edx*4 + 8]
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 0b10001000
	shufps xmm7, xmm7, 0b11011101
	/* table ready in xmm4-xmm7 */

	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addps  xmm5, [esp + _vctot]
	movaps [esp + _vctot], xmm5 

	xorps  xmm4, xmm4

	mulps xmm3, [esp + _tsc]
	mulps xmm3, xmm0
	subps  xmm4, xmm3

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i3010_checksingle_coul:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    .i3010_dosingle_coul
	jmp    .i3010_updateouterdata_coul
.i3010_dosingle_coul:
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	xorps  xmm6, xmm6
	movss xmm6, [esi + eax*4]	/* xmm6(0) has the charge */	
	mulps  xmm6, [esp + _iq]
	movaps [esp + _qq], xmm6
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	 
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */

	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ebx, mm6
	
	movlps xmm4, [esi + ebx*4]
	movlps xmm6, [esi + ebx*4 + 8]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */

	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addss  xmm5, [esp + _vctot]
	movss [esp + _vctot], xmm5 

	xorps xmm4, xmm4

	mulps xmm3, [esp + _tsc]
	mulps xmm3, xmm0
	subps  xmm4, xmm3
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
.i3010_updateouterdata_coul:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5

	/* loop back to mno */
	dec  dword ptr [esp + _nscoul]
	jz  .i3010_last_mno
	jmp .i3010_mno_coul
	
.i3010_last_mno:	
	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i3010_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i3010_outer
.i3010_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 324
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret




.globl inl3020_sse
	.type inl3020_sse,@function
inl3020_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_tabscale,	60	
.equ		_VFtab,		64	
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ixO,		0
.equ		_iyO,		16
.equ		_izO,		32
.equ		_ixH1,		48
.equ		_iyH1,		64
.equ		_izH1,		80
.equ		_ixH2,		96
.equ		_iyH2,		112
.equ		_izH2,		128
.equ		_iqO,		144 
.equ		_iqH,		160 
.equ		_dxO,		176
.equ		_dyO,		192
.equ		_dzO,		208	
.equ		_dxH1,		224
.equ		_dyH1,		240
.equ		_dzH1,		256	
.equ		_dxH2,		272
.equ		_dyH2,		288
.equ		_dzH2,		304	
.equ		_qqO,		320
.equ		_qqH,		336
.equ		_rinvO,		352
.equ		_rinvH1,	368
.equ		_rinvH2,	384		
.equ		_rO,		400
.equ		_rH1,		416
.equ		_rH2,		432
.equ		_tsc,		448	
.equ		_two,		464
.equ		_vctot,		480
.equ		_fixO,		496
.equ		_fiyO,		512
.equ		_fizO,		528
.equ		_fixH1,		544
.equ		_fiyH1,		560
.equ		_fizH1,		576
.equ		_fixH2,		592
.equ		_fiyH2,		608
.equ		_fizH2,		624
.equ		_fjx,		640
.equ		_fjy,		656
.equ		_fjz,		672
.equ		_half,		688
.equ		_three,		704
.equ		_is3,		720
.equ		_ii3,		724
.equ		_innerjjnr,	728
.equ		_innerk,	732
.equ		_salign,	736								
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 740		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_two]
	movups xmm2, [sse_three]
	movss xmm3, [ebp + _tabscale]
	
	movaps [esp + _half],  xmm0
	movaps [esp + _two],  xmm1
	movaps [esp + _three],  xmm2
	shufps xmm3, xmm3, 0 
	movaps [esp + _tsc], xmm3
	
	/* assume we have at least one i particle - start directly */
	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	movss xmm4, [edx + ebx*4 + 4]	
	movss xmm5, [ebp + _facel]
	mulss  xmm3, xmm5
	mulss  xmm4, xmm5

	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	movaps [esp + _iqO], xmm3
	movaps [esp + _iqH], xmm4
	
.i3020_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2

	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx

	addss xmm3, [eax + ebx*4]
	addss xmm4, [eax + ebx*4 + 4]
	addss xmm5, [eax + ebx*4 + 8]		
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixO], xmm3
	movaps [esp + _iyO], xmm4
	movaps [esp + _izO], xmm5

	movss xmm3, xmm0
	movss xmm4, xmm1
	movss xmm5, xmm2
	addss xmm0, [eax + ebx*4 + 12]
	addss xmm1, [eax + ebx*4 + 16]
	addss xmm2, [eax + ebx*4 + 20]		
	addss xmm3, [eax + ebx*4 + 24]
	addss xmm4, [eax + ebx*4 + 28]
	addss xmm5, [eax + ebx*4 + 32]		

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixH1], xmm0
	movaps [esp + _iyH1], xmm1
	movaps [esp + _izH1], xmm2
	movaps [esp + _ixH2], xmm3
	movaps [esp + _iyH2], xmm4
	movaps [esp + _izH2], xmm5
	
	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _fixO], xmm4
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm4
	movaps [esp + _fixH1], xmm4
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm4
	movaps [esp + _fixH2], xmm4
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i3020_unroll_loop
	jmp   .i3020_odd_inner
.i3020_unroll_loop:
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */

	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	movaps xmm4, xmm3	     /* and in xmm4 */
	mulps  xmm3, [esp + _iqO]
	mulps  xmm4, [esp + _iqH]

	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	movd  mm2, ecx
	movd  mm3, edx

	movaps  [esp + _qqO], xmm3
	movaps  [esp + _qqH], xmm4	

	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	
	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ixO-izO to xmm4-xmm6 */
	movaps xmm4, [esp + _ixO]
	movaps xmm5, [esp + _iyO]
	movaps xmm6, [esp + _izO]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dxO], xmm4
	movaps [esp + _dyO], xmm5
	movaps [esp + _dzO], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	movaps xmm7, xmm4
	/* rsqO in xmm7 */

	/* move ixH1-izH1 to xmm4-xmm6 */
	movaps xmm4, [esp + _ixH1]
	movaps xmm5, [esp + _iyH1]
	movaps xmm6, [esp + _izH1]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dxH1], xmm4
	movaps [esp + _dyH1], xmm5
	movaps [esp + _dzH1], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm6, xmm5
	addps xmm6, xmm4
	/* rsqH1 in xmm6 */

	/* move ixH2-izH2 to xmm3-xmm5 */ 
	movaps xmm3, [esp + _ixH2]
	movaps xmm4, [esp + _iyH2]
	movaps xmm5, [esp + _izH2]

	/* calc dr */
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2

	/* store dr */
	movaps [esp + _dxH2], xmm3
	movaps [esp + _dyH2], xmm4
	movaps [esp + _dzH2], xmm5
	/* square it */
	mulps xmm3,xmm3
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	addps xmm5, xmm4
	addps xmm5, xmm3
	/* rsqH2 in xmm5, rsqH1 in xmm6, rsqO in xmm7 */

	/* start with rsqO - seed to xmm2 */	
	rsqrtps xmm2, xmm7
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm7	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  [esp + _rinvO], xmm4	/* rinvO in xmm4 */
	mulps   xmm7, xmm4
	movaps  [esp + _rO], xmm7	

	/* rsqH1 - seed in xmm2 */
	rsqrtps xmm2, xmm6
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm6	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  [esp + _rinvH1], xmm4	/* rinvH1 in xmm4 */
	mulps   xmm6, xmm4
	movaps  [esp + _rH1], xmm6

	/* rsqH2 - seed to xmm2 */
	rsqrtps xmm2, xmm5
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm5	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  [esp + _rinvH2], xmm4	/* rinvH2 in xmm4 */
	mulps   xmm5, xmm4
	movaps  [esp + _rH2], xmm5

	/* do O interactions */
	/* rO is still in xmm7 */
	mulps   xmm7, [esp + _tsc]
	movhlps xmm4, xmm7
	cvttps2pi mm6, xmm7
	cvttps2pi mm7, xmm4    /* mm6/mm7 contain lu indices */
	
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm4, mm7
        movlhps xmm3, xmm4
	
        subps xmm7, xmm3

	movaps xmm1, xmm7	/* xmm1=eps */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2
		
        movd mm0, eax   
        movd mm1, ebx
        movd mm2, ecx
        movd mm3, edx

        mov  esi, [ebp + _VFtab]
        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */     
        
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */       
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm0, [esp + _qqO]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm0 /* vcoul=qq*VV */ 
        mulps  xmm0, xmm7 /* fijC=FF*qq */

        /* at this point mm5 contains vcoul and xmm0 fijC */
        /* increment vcoul - then we can get rid of mm5 */
        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5 
	xorps  xmm4, xmm4

	mulps  xmm0, [esp + _tsc]
	mulps  xmm0, [esp + _rinvO]	
	subps  xmm4, xmm0

	movaps xmm0, [esp + _dxO]
	movaps xmm1, [esp + _dyO]
	movaps xmm2, [esp + _dzO]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4	/* tx in xmm0-xmm2 */

	/* update O forces */
	movaps xmm3, [esp + _fixO]
	movaps xmm4, [esp + _fiyO]
	movaps xmm7, [esp + _fizO]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixO], xmm3
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm7
	/* update j forces with water O */
	movaps [esp + _fjx], xmm0
	movaps [esp + _fjy], xmm1
	movaps [esp + _fjz], xmm2

	/* Done with O interactions - now H1! */
	movaps xmm7, [esp + _rH1]
	mulps   xmm7, [esp + _tsc]
	movhlps xmm4, xmm7
	cvttps2pi mm6, xmm7
	cvttps2pi mm7, xmm4    /* mm6/mm7 contain lu indices */
	
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm4, mm7
        movlhps xmm3, xmm4
	
        subps xmm7, xmm3
	movaps xmm1, xmm7	/* xmm1=eps */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2
		
        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */     
        
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */       
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm0, [esp + _qqH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm0 /* vcoul=qq*VV */ 
        mulps  xmm7, xmm0 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and xmm7 fijC */
        /* increment vcoul */
	xorps  xmm4, xmm4
        addps  xmm5, [esp + _vctot]
	mulps  xmm7, [esp + _rinvH1]
        movaps [esp + _vctot], xmm5 
	mulps  xmm7, [esp + _tsc]
	subps xmm4, xmm7

	movaps xmm0, [esp + _dxH1]
	movaps xmm1, [esp + _dyH1]
	movaps xmm2, [esp + _dzH1]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

	/* update H1 forces */
	movaps xmm3, [esp + _fixH1]
	movaps xmm4, [esp + _fiyH1]
	movaps xmm7, [esp + _fizH1]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixH1], xmm3
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm7
	/* update j forces with water H1 */
	addps  xmm0, [esp + _fjx]
	addps  xmm1, [esp + _fjy]
	addps  xmm2, [esp + _fjz]
	movaps [esp + _fjx], xmm0
	movaps [esp + _fjy], xmm1
	movaps [esp + _fjz], xmm2

	/* Done with H1, finally we do H2 interactions */
	movaps xmm7, [esp + _rH2]
	mulps   xmm7, [esp + _tsc]
	movhlps xmm4, xmm7
	cvttps2pi mm6, xmm7
	cvttps2pi mm7, xmm4    /* mm6/mm7 contain lu indices */
	
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm4, mm7
        movlhps xmm3, xmm4
	
        subps xmm7, xmm3
	movaps xmm1, xmm7	/* xmm1=eps */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2
		
        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */     
        
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */       
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm0, [esp + _qqH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm0 /* vcoul=qq*VV */ 
        mulps  xmm7, xmm0 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and xmm0 fijC */
        /* increment vcoul */
	xorps  xmm4, xmm4
        addps  xmm5, [esp + _vctot]
	mulps  xmm7, [esp + _rinvH2]
        movaps [esp + _vctot], xmm5 
	mulps  xmm7, [esp + _tsc]
	subps  xmm4, xmm7

	movaps xmm0, [esp + _dxH2]
	movaps xmm1, [esp + _dyH2]
	movaps xmm2, [esp + _dzH2]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

        movd eax, mm0   
        movd ebx, mm1
        movd ecx, mm2
        movd edx, mm3
	
	/* update H2 forces */
	movaps xmm3, [esp + _fixH2]
	movaps xmm4, [esp + _fiyH2]
	movaps xmm7, [esp + _fizH2]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixH2], xmm3
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm7

	mov edi, [ebp + _faction]
	/* update j forces */
	addps xmm0, [esp + _fjx]
	addps xmm1, [esp + _fjy]
	addps xmm2, [esp + _fjz]

	movlps xmm4, [edi + eax*4]
	movlps xmm7, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm7, [edi + edx*4]
	
	movaps xmm3, xmm4
	shufps xmm3, xmm7, 0b10001000
	shufps xmm4, xmm7, 0b11011101			      
	/* xmm3 has fjx, xmm4 has fjy */
	subps xmm3, xmm0
	subps xmm4, xmm1
	/* unpack them back for storing */
	movaps xmm7, xmm3
	unpcklps xmm7, xmm4
	unpckhps xmm3, xmm4	
	movlps [edi + eax*4], xmm7
	movlps [edi + ecx*4], xmm3
	movhps [edi + ebx*4], xmm7
	movhps [edi + edx*4], xmm3
	/* finally z forces */
	movss  xmm0, [edi + eax*4 + 8]
	movss  xmm1, [edi + ebx*4 + 8]
	movss  xmm3, [edi + ecx*4 + 8]
	movss  xmm4, [edi + edx*4 + 8]
	subss  xmm0, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm1, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm3, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm4, xmm2
	movss  [edi + eax*4 + 8], xmm0
	movss  [edi + ebx*4 + 8], xmm1
	movss  [edi + ecx*4 + 8], xmm3
	movss  [edi + edx*4 + 8], xmm4
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i3020_odd_inner
	jmp   .i3020_unroll_loop
.i3020_odd_inner:	
	add   [esp + _innerk],  4
	jnz   .i3020_odd_loop
	jmp   .i3020_updateouterdata
.i3020_odd_loop:
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	add   [esp + _innerjjnr],  4	

 	xorps xmm4, xmm4
	movss xmm4, [esp + _iqO]
	mov esi, [ebp + _charge] 
	movhps xmm4, [esp + _iqH]     
	movss xmm3, [esi + eax*4]	/* charge in xmm3 */
	shufps xmm3, xmm3, 0
	mulps xmm3, xmm4
	movaps [esp + _qqO], xmm3	/* use oxygen qq for storage */

	mov esi, [ebp + _pos]
	lea   eax, [eax + eax*2]  
	
	/* move j coords to xmm0-xmm2 */
	movss xmm0, [esi + eax*4]
	movss xmm1, [esi + eax*4 + 4]
	movss xmm2, [esi + eax*4 + 8]
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	
	movss xmm3, [esp + _ixO]
	movss xmm4, [esp + _iyO]
	movss xmm5, [esp + _izO]
		
	movlps xmm6, [esp + _ixH1]
	movlps xmm7, [esp + _ixH2]
	unpcklps xmm6, xmm7
	movlhps xmm3, xmm6
	movlps xmm6, [esp + _iyH1]
	movlps xmm7, [esp + _iyH2]
	unpcklps xmm6, xmm7
	movlhps xmm4, xmm6
	movlps xmm6, [esp + _izH1]
	movlps xmm7, [esp + _izH2]
	unpcklps xmm6, xmm7
	movlhps xmm5, xmm6

	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	
	movaps [esp + _dxO], xmm3
	movaps [esp + _dyO], xmm4
	movaps [esp + _dzO], xmm5

	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5

	addps  xmm4, xmm3
	addps  xmm4, xmm5
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	movaps [esp + _rinvO], xmm0
	
	mulps xmm4, [esp + _tsc]
	movhlps xmm7, xmm4
	cvttps2pi mm6, xmm4
	cvttps2pi mm7, xmm7    /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm7, mm7
        movlhps xmm3, xmm7

	subps   xmm4, xmm3	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2
	
        movd mm0, eax   
        movd mm1, ecx
        movd mm2, edx

        mov  esi, [ebp + _VFtab]
        movd eax, mm6
        movd ecx, mm7
        psrlq mm7, 32
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */     
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */       
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm0, [esp + _qqO]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm0 /* vcoul=qq*VV */ 
        mulps  xmm0, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and xmm0 fijC */
        /* increment vcoul - then we can get rid of mm5 */
        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5

	xorps xmm4, xmm4
	mulps  xmm0, [esp + _tsc]
	mulps  xmm0, [esp + _rinvO]	
	subps  xmm4, xmm0
		
        movd eax, mm0   
        movd ecx, mm1
        movd edx, mm2	
		
	movaps xmm0, [esp + _dxO]
	movaps xmm1, [esp + _dyO]
	movaps xmm2, [esp + _dzO]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4 /* xmm0-xmm2 now contains tx-tz (partial force) */
	movss  xmm3, [esp + _fixO]	
	movss  xmm4, [esp + _fiyO]	
	movss  xmm5, [esp + _fizO]	
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esp + _fixO], xmm3	
	movss  [esp + _fiyO], xmm4	
	movss  [esp + _fizO], xmm5	/* updated the O force now do the H's */
	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2
	shufps xmm3, xmm3, 0b11100110	/* shift right */
	shufps xmm4, xmm4, 0b11100110
	shufps xmm5, xmm5, 0b11100110
	addss  xmm3, [esp + _fixH1]
	addss  xmm4, [esp + _fiyH1]
	addss  xmm5, [esp + _fizH1]
	movss  [esp + _fixH1], xmm3	
	movss  [esp + _fiyH1], xmm4	
	movss  [esp + _fizH1], xmm5	/* updated the H1 force */

	mov edi, [ebp + _faction]
	shufps xmm3, xmm3, 0b11100111	/* shift right */
	shufps xmm4, xmm4, 0b11100111
	shufps xmm5, xmm5, 0b11100111
	addss  xmm3, [esp + _fixH2]
	addss  xmm4, [esp + _fiyH2]
	addss  xmm5, [esp + _fizH2]
	movss  [esp + _fixH2], xmm3	
	movss  [esp + _fiyH2], xmm4	
	movss  [esp + _fizH2], xmm5	/* updated the H2 force */

	/* the fj's - start by accumulating the tx/ty/tz force in xmm0, xmm1 */
	xorps  xmm5, xmm5
	movaps xmm3, xmm0
	movlps xmm6, [edi + eax*4]
	movss  xmm7, [edi + eax*4 + 8]
	unpcklps xmm3, xmm1
	movlhps  xmm3, xmm5	
	unpckhps xmm0, xmm1		
	addps    xmm0, xmm3
	movhlps  xmm3, xmm0	
	addps    xmm0, xmm3	/* x,y sum in xmm0 */

	movhlps  xmm1, xmm2
	addss    xmm2, xmm1
	shufps   xmm1, xmm1, 1 
	addss    xmm2, xmm1    /* z sum in xmm2 */
	subps    xmm6, xmm0
	subss    xmm7, xmm2
	
	movlps [edi + eax*4],     xmm6
	movss  [edi + eax*4 + 8], xmm7

	dec dword ptr [esp + _innerk]
	jz    .i3020_updateouterdata
	jmp   .i3020_odd_loop
.i3020_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate  Oi forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixO]
	movaps xmm1, [esp + _fiyO]
	movaps xmm2, [esp + _fizO]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	movaps xmm6, xmm0
	movss xmm7, xmm2
	movlhps xmm6, xmm1
	shufps  xmm6, xmm6, 0b1000	

	/* accumulate H1i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH1]
	movaps xmm1, [esp + _fiyH1]
	movaps xmm2, [esp + _fizH1]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 12]
	movss  xmm4, [edi + ecx*4 + 16]
	movss  xmm5, [edi + ecx*4 + 20]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 12], xmm3
	movss  [edi + ecx*4 + 16], xmm4
	movss  [edi + ecx*4 + 20], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* accumulate H2i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH2]
	movaps xmm1, [esp + _fiyH2]
	movaps xmm2, [esp + _fizH2]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 24]
	movss  xmm4, [edi + ecx*4 + 28]
	movss  xmm5, [edi + ecx*4 + 32]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 24], xmm3
	movss  [edi + ecx*4 + 28], xmm4
	movss  [edi + ecx*4 + 32], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* increment fshift force */ 
	movlps  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 8]
	addps  xmm3, xmm6
	addss  xmm4, xmm7
	movlps  [esi + edx*4],    xmm3
	movss  [esi + edx*4 + 8], xmm4

	mov   edx, [ebp + _gid]  
	mov   edx, [edx]
	add   [ebp + _gid],  4	

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		
        
	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 

	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i3020_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i3020_outer
.i3020_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 740
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret
	

	
.globl inl3030_sse
	.type inl3030_sse,@function
inl3030_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_tabscale,	60	
.equ		_VFtab,		64
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ixO,		0
.equ		_iyO,		16
.equ		_izO,		32
.equ		_ixH1,		48
.equ		_iyH1,		64
.equ		_izH1,		80
.equ		_ixH2,		96
.equ		_iyH2,		112
.equ		_izH2,		128
.equ		_jxO,		144
.equ		_jyO,		160
.equ		_jzO,		176
.equ		_jxH1,		192
.equ		_jyH1,		208
.equ		_jzH1,		224
.equ		_jxH2,		240
.equ		_jyH2,		256
.equ		_jzH2,		272
.equ		_dxOO,		288
.equ		_dyOO,		304
.equ		_dzOO,		320	
.equ		_dxOH1,		336
.equ		_dyOH1,		352
.equ		_dzOH1,		368	
.equ		_dxOH2,		384
.equ		_dyOH2,		400
.equ		_dzOH2,		416	
.equ		_dxH1O,		432
.equ		_dyH1O,		448
.equ		_dzH1O,		464	
.equ		_dxH1H1,	480
.equ		_dyH1H1,	496
.equ		_dzH1H1,	512	
.equ		_dxH1H2,	528
.equ		_dyH1H2,	544
.equ		_dzH1H2,	560	
.equ		_dxH2O,		576
.equ		_dyH2O,		592
.equ		_dzH2O,		608	
.equ		_dxH2H1,	624
.equ		_dyH2H1,	640
.equ		_dzH2H1,	656	
.equ		_dxH2H2,	672
.equ		_dyH2H2,	688
.equ		_dzH2H2,	704
.equ		_qqOO,		720
.equ		_qqOH,		736
.equ		_qqHH,		752
.equ		_two,		768
.equ		_tsc,		784
.equ		_vctot,		800
.equ		_fixO,		816
.equ		_fiyO,		832
.equ		_fizO,		848
.equ		_fixH1,		864
.equ		_fiyH1,		880
.equ		_fizH1,		896
.equ		_fixH2,		912
.equ		_fiyH2,		928
.equ		_fizH2,		944
.equ		_fjxO,		960
.equ		_fjyO,		976
.equ		_fjzO,		992
.equ		_fjxH1,		1008
.equ		_fjyH1,		1024
.equ		_fjzH1,		1040
.equ		_fjxH2,		1056
.equ		_fjyH2,		1072
.equ		_fjzH2,		1088
.equ		_half,		1104
.equ		_three,		1120
.equ		_rsqOO,		1136
.equ		_rsqOH1,	1152
.equ		_rsqOH2,	1168
.equ		_rsqH1O,	1184
.equ		_rsqH1H1,	1200
.equ		_rsqH1H2,	1216
.equ		_rsqH2O,	1232
.equ		_rsqH2H1,	1248
.equ		_rsqH2H2,	1264
.equ		_rinvOO,	1280
.equ		_rinvOH1,	1296
.equ		_rinvOH2,	1312
.equ		_rinvH1O,	1328
.equ		_rinvH1H1,	1344
.equ		_rinvH1H2,	1360
.equ		_rinvH2O,	1376
.equ		_rinvH2H1,	1392
.equ		_rinvH2H2,	1408	
.equ		_is3,		1424
.equ		_ii3,		1428
.equ		_innerjjnr,	1432
.equ		_innerk,	1436
.equ		_salign,	1440							
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 1444		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_two]
	movups xmm2, [sse_three]
	movss xmm3, [ebp + _tabscale]
	movaps [esp + _half],  xmm0
	movaps [esp + _two],  xmm1
	movaps [esp + _three], xmm2
	shufps xmm3, xmm3, 0
	movaps [esp + _tsc],  xmm3

	/* assume we have at least one i particle - start directly */
	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	movss xmm4, xmm3	
	movss xmm5, [edx + ebx*4 + 4]	
	movss xmm6, [ebp + _facel]
	mulss  xmm3, xmm3
	mulss  xmm4, xmm5
	mulss  xmm5, xmm5
	mulss  xmm3, xmm6
	mulss  xmm4, xmm6
	mulss  xmm5, xmm6
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _qqOO], xmm3
	movaps [esp + _qqOH], xmm4
	movaps [esp + _qqHH], xmm5		

.i3030_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx	
	
	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2
	addss xmm3, [eax + ebx*4]
	addss xmm4, [eax + ebx*4 + 4]
	addss xmm5, [eax + ebx*4 + 8]		
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixO], xmm3
	movaps [esp + _iyO], xmm4
	movaps [esp + _izO], xmm5

	movss xmm3, xmm0
	movss xmm4, xmm1
	movss xmm5, xmm2
	addss xmm0, [eax + ebx*4 + 12]
	addss xmm1, [eax + ebx*4 + 16]
	addss xmm2, [eax + ebx*4 + 20]		
	addss xmm3, [eax + ebx*4 + 24]
	addss xmm4, [eax + ebx*4 + 28]
	addss xmm5, [eax + ebx*4 + 32]		

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixH1], xmm0
	movaps [esp + _iyH1], xmm1
	movaps [esp + _izH1], xmm2
	movaps [esp + _ixH2], xmm3
	movaps [esp + _iyH2], xmm4
	movaps [esp + _izH2], xmm5

	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _fixO], xmm4
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm4
	movaps [esp + _fixH1], xmm4
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm4
	movaps [esp + _fixH2], xmm4
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i3030_unroll_loop
	jmp   .i3030_single_check
.i3030_unroll_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */

	mov   eax, [edx]	
	mov   ebx, [edx + 4] 
	mov   ecx, [edx + 8]
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	
	
	/* move j coordinates to local temp variables */
	movlps xmm2, [esi + eax*4]
	movlps xmm3, [esi + eax*4 + 12]
	movlps xmm4, [esi + eax*4 + 24]

	movlps xmm5, [esi + ebx*4]
	movlps xmm6, [esi + ebx*4 + 12]
	movlps xmm7, [esi + ebx*4 + 24]

	movhps xmm2, [esi + ecx*4]
	movhps xmm3, [esi + ecx*4 + 12]
	movhps xmm4, [esi + ecx*4 + 24]

	movhps xmm5, [esi + edx*4]
	movhps xmm6, [esi + edx*4 + 12]
	movhps xmm7, [esi + edx*4 + 24]

	/* current state: */	
	/* xmm2= jxOa  jyOa  jxOc  jyOc */
	/* xmm3= jxH1a jyH1a jxH1c jyH1c */
	/* xmm4= jxH2a jyH2a jxH2c jyH2c */
	/* xmm5= jxOb  jyOb  jxOd  jyOd */
	/* xmm6= jxH1b jyH1b jxH1d jyH1d */
	/* xmm7= jxH2b jyH2b jxH2d jyH2d */
	
	movaps xmm0, xmm2
	movaps xmm1, xmm3
	unpcklps xmm0, xmm5	/* xmm0= jxOa  jxOb  jyOa  jyOb */
	unpcklps xmm1, xmm6	/* xmm1= jxH1a jxH1b jyH1a jyH1b */
	unpckhps xmm2, xmm5	/* xmm2= jxOc  jxOd  jyOc  jyOd */
	unpckhps xmm3, xmm6	/* xmm3= jxH1c jxH1d jyH1c jyH1d */
	movaps xmm5, xmm4
	movaps   xmm6, xmm0
	unpcklps xmm4, xmm7	/* xmm4= jxH2a jxH2b jyH2a jyH2b */		
	unpckhps xmm5, xmm7	/* xmm5= jxH2c jxH2d jyH2c jyH2d */
	movaps   xmm7, xmm1
	movlhps  xmm0, xmm2	/* xmm0= jxOa  jxOb  jxOc  jxOd */
	movaps [esp + _jxO], xmm0
	movhlps  xmm2, xmm6	/* xmm2= jyOa  jyOb  jyOc  jyOd */
	movaps [esp + _jyO], xmm2
	movlhps  xmm1, xmm3
	movaps [esp + _jxH1], xmm1
	movhlps  xmm3, xmm7
	movaps   xmm6, xmm4
	movaps [esp + _jyH1], xmm3
	movlhps  xmm4, xmm5
	movaps [esp + _jxH2], xmm4
	movhlps  xmm5, xmm6
	movaps [esp + _jyH2], xmm5

	movss  xmm0, [esi + eax*4 + 8]
	movss  xmm1, [esi + eax*4 + 20]
	movss  xmm2, [esi + eax*4 + 32]

	movss  xmm3, [esi + ecx*4 + 8]
	movss  xmm4, [esi + ecx*4 + 20]
	movss  xmm5, [esi + ecx*4 + 32]

	movhps xmm0, [esi + ebx*4 + 4]
	movhps xmm1, [esi + ebx*4 + 16]
	movhps xmm2, [esi + ebx*4 + 28]
	
	movhps xmm3, [esi + edx*4 + 4]
	movhps xmm4, [esi + edx*4 + 16]
	movhps xmm5, [esi + edx*4 + 28]
	
	shufps xmm0, xmm3, 0b11001100
	shufps xmm1, xmm4, 0b11001100
	shufps xmm2, xmm5, 0b11001100
	movaps [esp + _jzO],  xmm0
	movaps [esp + _jzH1],  xmm1
	movaps [esp + _jzH2],  xmm2

	movaps xmm0, [esp + _ixO]
	movaps xmm1, [esp + _iyO]
	movaps xmm2, [esp + _izO]
	movaps xmm3, [esp + _ixO]
	movaps xmm4, [esp + _iyO]
	movaps xmm5, [esp + _izO]
	subps  xmm0, [esp + _jxO]
	subps  xmm1, [esp + _jyO]
	subps  xmm2, [esp + _jzO]
	subps  xmm3, [esp + _jxH1]
	subps  xmm4, [esp + _jyH1]
	subps  xmm5, [esp + _jzH1]
	movaps [esp + _dxOO], xmm0
	movaps [esp + _dyOO], xmm1
	movaps [esp + _dzOO], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxOH1], xmm3
	movaps [esp + _dyOH1], xmm4
	movaps [esp + _dzOH1], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqOO], xmm0
	movaps [esp + _rsqOH1], xmm3

	movaps xmm0, [esp + _ixO]
	movaps xmm1, [esp + _iyO]
	movaps xmm2, [esp + _izO]
	movaps xmm3, [esp + _ixH1]
	movaps xmm4, [esp + _iyH1]
	movaps xmm5, [esp + _izH1]
	subps  xmm0, [esp + _jxH2]
	subps  xmm1, [esp + _jyH2]
	subps  xmm2, [esp + _jzH2]
	subps  xmm3, [esp + _jxO]
	subps  xmm4, [esp + _jyO]
	subps  xmm5, [esp + _jzO]
	movaps [esp + _dxOH2], xmm0
	movaps [esp + _dyOH2], xmm1
	movaps [esp + _dzOH2], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH1O], xmm3
	movaps [esp + _dyH1O], xmm4
	movaps [esp + _dzH1O], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqOH2], xmm0
	movaps [esp + _rsqH1O], xmm3

	movaps xmm0, [esp + _ixH1]
	movaps xmm1, [esp + _iyH1]
	movaps xmm2, [esp + _izH1]
	movaps xmm3, [esp + _ixH1]
	movaps xmm4, [esp + _iyH1]
	movaps xmm5, [esp + _izH1]
	subps  xmm0, [esp + _jxH1]
	subps  xmm1, [esp + _jyH1]
	subps  xmm2, [esp + _jzH1]
	subps  xmm3, [esp + _jxH2]
	subps  xmm4, [esp + _jyH2]
	subps  xmm5, [esp + _jzH2]
	movaps [esp + _dxH1H1], xmm0
	movaps [esp + _dyH1H1], xmm1
	movaps [esp + _dzH1H1], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH1H2], xmm3
	movaps [esp + _dyH1H2], xmm4
	movaps [esp + _dzH1H2], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqH1H1], xmm0
	movaps [esp + _rsqH1H2], xmm3

	movaps xmm0, [esp + _ixH2]
	movaps xmm1, [esp + _iyH2]
	movaps xmm2, [esp + _izH2]
	movaps xmm3, [esp + _ixH2]
	movaps xmm4, [esp + _iyH2]
	movaps xmm5, [esp + _izH2]
	subps  xmm0, [esp + _jxO]
	subps  xmm1, [esp + _jyO]
	subps  xmm2, [esp + _jzO]
	subps  xmm3, [esp + _jxH1]
	subps  xmm4, [esp + _jyH1]
	subps  xmm5, [esp + _jzH1]
	movaps [esp + _dxH2O], xmm0
	movaps [esp + _dyH2O], xmm1
	movaps [esp + _dzH2O], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH2H1], xmm3
	movaps [esp + _dyH2H1], xmm4
	movaps [esp + _dzH2H1], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm4, xmm3
	addps  xmm4, xmm5
	movaps [esp + _rsqH2O], xmm0
	movaps [esp + _rsqH2H1], xmm4

	movaps xmm0, [esp + _ixH2]
	movaps xmm1, [esp + _iyH2]
	movaps xmm2, [esp + _izH2]
	subps  xmm0, [esp + _jxH2]
	subps  xmm1, [esp + _jyH2]
	subps  xmm2, [esp + _jzH2]
	movaps [esp + _dxH2H2], xmm0
	movaps [esp + _dyH2H2], xmm1
	movaps [esp + _dzH2H2], xmm2
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2
	movaps [esp + _rsqH2H2], xmm0
		
	/* start doing invsqrt use rsq values in xmm0, xmm4 */
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] /* rinvH2H2 */
	mulps   xmm7, [esp + _half] /* rinvH2H1 */
	movaps  [esp + _rinvH2H2], xmm3
	movaps  [esp + _rinvH2H1], xmm7
		
	rsqrtps xmm1, [esp + _rsqOO]
	rsqrtps xmm5, [esp + _rsqOH1]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqOO]
	mulps   xmm5, [esp + _rsqOH1]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvOO], xmm3
	movaps  [esp + _rinvOH1], xmm7
	
	rsqrtps xmm1, [esp + _rsqOH2]
	rsqrtps xmm5, [esp + _rsqH1O]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqOH2]
	mulps   xmm5, [esp + _rsqH1O]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvOH2], xmm3
	movaps  [esp + _rinvH1O], xmm7
	
	rsqrtps xmm1, [esp + _rsqH1H1]
	rsqrtps xmm5, [esp + _rsqH1H2]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqH1H1]
	mulps   xmm5, [esp + _rsqH1H2]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvH1H1], xmm3
	movaps  [esp + _rinvH1H2], xmm7
	
	rsqrtps xmm1, [esp + _rsqH2O]
	movaps  xmm2, xmm1
	mulps   xmm1, xmm1
	movaps  xmm3, [esp + _three]
	mulps   xmm1, [esp + _rsqH2O]
	subps   xmm3, xmm1
	mulps   xmm3, xmm2
	mulps   xmm3, [esp + _half] 
	movaps  [esp + _rinvH2O], xmm3

	/* start with OO interaction */
	movaps xmm0, [esp + _rinvOO]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqOO] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]
		
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
	pslld   mm6, 2
	pslld   mm7, 2
	
        movd mm0, eax
        movd mm1, ebx
        movd mm2, ecx
        movd mm3, edx

        mov  esi, [ebp + _VFtab]
        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqOO]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */
        /* increment vcoul - then we can get rid of mm5 */
        /* update vctot */
        addps  xmm5, [esp + _vctot]
	xorps  xmm2, xmm2
        movaps [esp + _vctot], xmm5
	mulps  xmm3, [esp + _tsc]
	
	subps  xmm2, xmm3
	mulps  xmm0, xmm2
	
	movaps xmm1, xmm0
	movaps xmm2, xmm0		

	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOO]
	mulps xmm1, [esp + _dyOO]
	mulps xmm2, [esp + _dzOO]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* O-H1 interaction */
	movaps xmm0, [esp + _rinvOH1]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqOH1] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */

	pslld   mm6, 2
	pslld   mm7, 2
	
        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqOH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOH1]
	mulps xmm1, [esp + _dyOH1]
	mulps xmm2, [esp + _dzOH1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* O-H2 interaction */ 
	movaps xmm0, [esp + _rinvOH2]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqOH2] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */

	pslld   mm6, 2
	pslld   mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqOH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOH2]
	mulps xmm1, [esp + _dyOH2]
	mulps xmm2, [esp + _dzOH2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* H1-O interaction */
	movaps xmm0, [esp + _rinvH1O]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH1O] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */

	pslld   mm6, 2
	pslld   mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqOH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [esp + _fjxO]
	movaps xmm4, [esp + _fjyO]
	movaps xmm5, [esp + _fjzO]
	mulps xmm0, [esp + _dxH1O]
	mulps xmm1, [esp + _dyH1O]
	mulps xmm2, [esp + _dzH1O]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H1-H1 interaction */
	movaps xmm0, [esp + _rinvH1H1]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH1H1] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */

	pslld   mm6, 2
	pslld   mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqHH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [esp + _fjxH1]
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	mulps xmm0, [esp + _dxH1H1]
	mulps xmm1, [esp + _dyH1H1]
	mulps xmm2, [esp + _dzH1H1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H1-H2 interaction */
	movaps xmm0, [esp + _rinvH1H2]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH1H2] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */

	pslld   mm6, 2
	pslld   mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqHH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [esp + _fjxH2]
	movaps xmm4, [esp + _fjyH2]
	movaps xmm5, [esp + _fjzH2]
	mulps xmm0, [esp + _dxH1H2]
	mulps xmm1, [esp + _dyH1H2]
	mulps xmm2, [esp + _dzH1H2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H2-O interaction */
	movaps xmm0, [esp + _rinvH2O]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH2O] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */

	pslld   mm6, 2
	pslld   mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqOH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1

	movaps xmm3, [esp + _fjxO]
	movaps xmm4, [esp + _fjyO]
	movaps xmm5, [esp + _fjzO]
	mulps xmm0, [esp + _dxH2O]
	mulps xmm1, [esp + _dyH2O]
	mulps xmm2, [esp + _dzH2O]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	/* H2-H1 interaction */
	movaps xmm0, [esp + _rinvH2H1]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH2H1] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */

	pslld   mm6, 2
	pslld   mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqHH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [esp + _fjxH1]
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	mulps xmm0, [esp + _dxH2H1]
	mulps xmm1, [esp + _dyH2H1]
	mulps xmm2, [esp + _dzH2H1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	/* H2-H2 interaction */
	movaps xmm0, [esp + _rinvH2H2]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH2H2] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */

	pslld   mm6, 2
	pslld   mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqHH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [esp + _fjxH2]
	movaps xmm4, [esp + _fjyH2]
	movaps xmm5, [esp + _fjzH2]
	mulps xmm0, [esp + _dxH2H2]
	mulps xmm1, [esp + _dyH2H2]
	mulps xmm2, [esp + _dzH2H2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	mov edi, [ebp + _faction]

	movd eax, mm0
	movd ebx, mm1
	movd ecx, mm2
	movd edx, mm3
	
	/* Did all interactions - now update j forces */
	/* 4 j waters with three atoms each - first do a & b j particles */
	movaps xmm0, [esp + _fjxO] /* xmm0= fjxOa  fjxOb  fjxOc  fjxOd */
	movaps xmm1, [esp + _fjyO] /* xmm1= fjyOa  fjyOb  fjyOc  fjyOd */ 
	unpcklps xmm0, xmm1    	   /* xmm0= fjxOa  fjyOa  fjxOb  fjyOb */
	movaps xmm1, [esp + _fjzO]
	movaps xmm2, [esp + _fjxH1]
	movhlps  xmm3, xmm0	   /* xmm3= fjxOb  fjyOb */ 
	unpcklps xmm1, xmm2	   /* xmm1= fjzOa  fjxH1a fjzOb  fjxH1b */
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	unpcklps xmm4, xmm5	   /* xmm4= fjyH1a fjzH1a fjyH1b fjzH1b */
	movaps xmm5, [esp + _fjxH2]
	movaps xmm6, [esp + _fjyH2]
	movhlps  xmm7, xmm4	   /* xmm7= fjyH1b fjzH1b */
	unpcklps xmm5, xmm6	   /* xmm5= fjxH2a fjyH2a fjxH2b fjyH2b */
	movlhps  xmm0, xmm1    	   /* xmm0= fjxOa  fjyOa  fjzOa  fjxH1a */
	shufps   xmm3, xmm1, 0b11100100
                                   /* xmm3= fjxOb  fjyOb  fjzOb  fjxH1b */
	movlhps  xmm4, xmm5   	   /* xmm4= fjyH1a fjzH1a fjxH2a fjyH2a */
	shufps   xmm7, xmm5, 0b11100100
                                   /* xmm7= fjyH1b fjzH1b fjxH2b fjyH2b */
	movups   xmm1, [edi + eax*4]
	movups   xmm2, [edi + eax*4 + 16]
	movups   xmm5, [edi + ebx*4]
	movups   xmm6, [edi + ebx*4 + 16]
	addps    xmm1, xmm0
	addps    xmm2, xmm4
	addps    xmm5, xmm3
	addps    xmm6, xmm7
	movss    xmm0, [edi + eax*4 + 32]
	movss    xmm3, [edi + ebx*4 + 32]
	
	movaps   xmm4, [esp + _fjzH2]
	movaps   xmm7, xmm4
	shufps   xmm7, xmm7, 1
	
	movups   [edi + eax*4],     xmm1
	movups   [edi + eax*4 + 16],xmm2
	movups   [edi + ebx*4],     xmm5
	movups   [edi + ebx*4 + 16],xmm6	
	addss    xmm0, xmm4
	addss    xmm3, xmm7
	movss    [edi + eax*4 + 32], xmm0
	movss    [edi + ebx*4 + 32], xmm3	

	/* then do the second pair (c & d) */
	movaps xmm0, [esp + _fjxO] /* xmm0= fjxOa  fjxOb  fjxOc  fjxOd */
	movaps xmm1, [esp + _fjyO] /* xmm1= fjyOa  fjyOb  fjyOc  fjyOd */ 
	unpckhps xmm0, xmm1	   /* xmm0= fjxOc  fjyOc  fjxOd  fjyOd */
	movaps xmm1, [esp + _fjzO]
	movaps xmm2, [esp + _fjxH1]
	movhlps  xmm3, xmm0	   /* xmm3= fjxOd  fjyOd */ 
	unpckhps xmm1, xmm2	   /* xmm1= fjzOc  fjxH1c fjzOd  fjxH1d */
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	unpckhps xmm4, xmm5	   /* xmm4= fjyH1c fjzH1c fjyH1d fjzH1d	*/
	movaps xmm5, [esp + _fjxH2]
	movaps xmm6, [esp + _fjyH2]
	movhlps  xmm7, xmm4	   /* xmm7= fjyH1d fjzH1d */	 
	unpckhps xmm5, xmm6	   /* xmm5= fjxH2c fjyH2c fjxH2d fjyH2d */
	movlhps  xmm0, xmm1	   /* xmm0= fjxOc  fjyOc  fjzOc  fjxH1c */
	shufps   xmm3, xmm1, 0b11100100
                                   /* xmm3= fjxOd  fjyOd  fjzOd  fjxH1d */
	movlhps  xmm4, xmm5	   /* xmm4= fjyH1c fjzH1c fjxH2c fjyH2c  */
	shufps   xmm7, xmm5, 0b11100100
                                   /* xmm7= fjyH1d fjzH1d fjxH2d fjyH2d */
	movups   xmm1, [edi + ecx*4]
	movups   xmm2, [edi + ecx*4 + 16]
	movups   xmm5, [edi + edx*4]
	movups   xmm6, [edi + edx*4 + 16]
	addps    xmm1, xmm0
	addps    xmm2, xmm4
	addps    xmm5, xmm3
	addps    xmm6, xmm7
	movss    xmm0, [edi + ecx*4 + 32]
	movss    xmm3, [edi + edx*4 + 32]
	
	movaps   xmm4, [esp + _fjzH2]
	movaps   xmm7, xmm4
	shufps   xmm4, xmm4, 0b10
	shufps   xmm7, xmm7, 0b11
	movups   [edi + ecx*4],     xmm1
	movups   [edi + ecx*4 + 16],xmm2
	movups   [edi + edx*4],     xmm5
	movups   [edi + edx*4 + 16],xmm6	
	addss    xmm0, xmm4
	addss    xmm3, xmm7
	movss    [edi + ecx*4 + 32], xmm0
	movss    [edi + edx*4 + 32], xmm3	
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i3030_single_check
	jmp   .i3030_unroll_loop
.i3030_single_check:
	add   [esp + _innerk],  4
	jnz   .i3030_single_loop
	jmp   .i3030_updateouterdata
.i3030_single_loop:
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	add   [esp + _innerjjnr],  4	

	mov esi, [ebp + _pos]
	lea   eax, [eax + eax*2]  

	/* fetch j coordinates */
	xorps xmm3, xmm3
	xorps xmm4, xmm4
	xorps xmm5, xmm5
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + eax*4 + 4]
	movss xmm5, [esi + eax*4 + 8]

	movlps xmm6, [esi + eax*4 + 12]
	movhps xmm6, [esi + eax*4 + 24]	/* xmm6=jxH1 jyH1 jxH2 jyH2 */
	/* fetch both z coords in one go, to positions 0 and 3 in xmm7 */
	movups xmm7, [esi + eax*4 + 20] /* xmm7=jzH1 jxH2 jyH2 jzH2 */
	shufps xmm6, xmm6, 0b11011000    /* xmm6=jxH1 jxH2 jyH1 jyH2 */
	movlhps xmm3, xmm6      	/* xmm3= jxO   0  jxH1 jxH2 */
	movaps  xmm0, [esp + _ixO]     
	movaps  xmm1, [esp + _iyO]
	movaps  xmm2, [esp + _izO]	
	shufps  xmm4, xmm6, 0b11100100 /* xmm4= jyO   0   jyH1 jyH2 */
	shufps xmm5, xmm7, 0b11000100  /* xmm5= jzO   0   jzH1 jzH2 */
	/* store all j coordinates in jO */ 
	movaps [esp + _jxO], xmm3
	movaps [esp + _jyO], xmm4
	movaps [esp + _jzO], xmm5
	subps  xmm0, xmm3
	subps  xmm1, xmm4
	subps  xmm2, xmm5
	movaps [esp + _dxOO], xmm0
	movaps [esp + _dyOO], xmm1
	movaps [esp + _dzOO], xmm2
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2	/* have rsq in xmm0 */
	
	/* do invsqrt */
	rsqrtps xmm1, xmm0
	movaps  xmm2, xmm1	
	mulps   xmm1, xmm1
	movaps  xmm3, [esp + _three]
	mulps   xmm1, xmm0
	subps   xmm3, xmm1
	mulps   xmm3, xmm2							
	mulps   xmm3, [esp + _half] /* rinv iO - j water */

	movaps  xmm1, xmm3
	mulps   xmm1, xmm0	/* xmm1=r */
	movaps  xmm0, xmm3	/* xmm0=rinv */
	mulps  xmm1, [esp + _tsc]
	
	movhlps xmm2, xmm1	
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
	pslld   mm6, 2
	pslld   mm7, 2
	
        movd ebx, mm6
        movd ecx, mm7
        psrlq mm7, 32
        movd edx, mm7		/* table indices in ebx,ecx,edx */

	mov esi, [ebp + _VFtab]
	
        movlps xmm5, [esi + ebx*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */
        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + ebx*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */

	xorps  xmm3, xmm3
	/* fetch charges to xmm3 (temporary) */
	movss   xmm3, [esp + _qqOO]
	movhps  xmm3, [esp + _qqOH]
		
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point xmm5 contains vcoul and xmm3 fijC */
	
        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm2, xmm2
	mulps  xmm3, [esp + _tsc]

	subps  xmm2, xmm3
	mulps  xmm0, xmm2
	
	movaps xmm1, xmm0
	movaps xmm2, xmm0			

	mulps   xmm0, [esp + _dxOO]
	mulps   xmm1, [esp + _dyOO]
	mulps   xmm2, [esp + _dzOO]
	/* initial update for j forces */
	xorps   xmm3, xmm3
	xorps   xmm4, xmm4
	xorps   xmm5, xmm5
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixO]
	addps   xmm1, [esp + _fiyO]
	addps   xmm2, [esp + _fizO]
	movaps  [esp + _fixO], xmm0
	movaps  [esp + _fiyO], xmm1
	movaps  [esp + _fizO], xmm2

	
	/* done with i O Now do i H1 & H2 simultaneously first get i particle coords: */
	movaps  xmm0, [esp + _ixH1]
	movaps  xmm1, [esp + _iyH1]
	movaps  xmm2, [esp + _izH1]	
	movaps  xmm3, [esp + _ixH2] 
	movaps  xmm4, [esp + _iyH2] 
	movaps  xmm5, [esp + _izH2] 
	subps   xmm0, [esp + _jxO]
	subps   xmm1, [esp + _jyO]
	subps   xmm2, [esp + _jzO]
	subps   xmm3, [esp + _jxO]
	subps   xmm4, [esp + _jyO]
	subps   xmm5, [esp + _jzO]
	movaps [esp + _dxH1O], xmm0
	movaps [esp + _dyH1O], xmm1
	movaps [esp + _dzH1O], xmm2
	movaps [esp + _dxH2O], xmm3
	movaps [esp + _dyH2O], xmm4
	movaps [esp + _dzH2O], xmm5
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	mulps xmm3, xmm3
	mulps xmm4, xmm4
	mulps xmm5, xmm5
	addps xmm0, xmm1
	addps xmm4, xmm3
	addps xmm0, xmm2	/* have rsqH1 in xmm0 */
	addps xmm4, xmm5	/* have rsqH2 in xmm4 */

	/* start with H1, save H2 data */
	movaps [esp + _rsqH2O], xmm4
	
	/* do invsqrt */
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] /* rinv H1 - j water */
	mulps   xmm7, [esp + _half] /* rinv H2 - j water */ 

	/* start with H1, save H2 data */
	movaps [esp + _rinvH2O], xmm7

	movaps xmm1, xmm3
	mulps  xmm1, xmm0	/* xmm1=r */
	movaps xmm0, xmm3	/* xmm0=rinv */
	mulps  xmm1, [esp + _tsc]
	
	movhlps xmm2, xmm1	
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
	pslld   mm6, 2
	pslld   mm7, 2

        movd ebx, mm6
        movd ecx, mm7
        psrlq mm7, 32
        movd edx, mm7		/* table indices in ebx,ecx,edx */

        movlps xmm5, [esi + ebx*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */
        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + ebx*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */

	xorps  xmm3, xmm3
	/* fetch charges to xmm3 (temporary) */
	movss   xmm3, [esp + _qqOH]
	movhps  xmm3, [esp + _qqHH]
		
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point xmm5 contains vcoul and xmm3 fijC */
        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5	

        xorps  xmm1, xmm1

        mulps xmm3, [esp + _tsc]
        mulps xmm3, xmm0
        subps  xmm1, xmm3
	
	movaps  xmm0, xmm1
	movaps  xmm2, xmm1
	mulps   xmm0, [esp + _dxH1O]
	mulps   xmm1, [esp + _dyH1O]
	mulps   xmm2, [esp + _dzH1O]
	/* update forces H1 - j water */
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixH1]
	addps   xmm1, [esp + _fiyH1]
	addps   xmm2, [esp + _fizH1]
	movaps  [esp + _fixH1], xmm0
	movaps  [esp + _fiyH1], xmm1
	movaps  [esp + _fizH1], xmm2
	/* do table for H2 - j water interaction */
	movaps xmm0, [esp + _rinvH2O]
	movaps xmm1, [esp + _rsqH2O]
	mulps  xmm1, xmm0	/* xmm0=rinv, xmm1=r */
	mulps  xmm1, [esp + _tsc]
	
	movhlps xmm2, xmm1	
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
	pslld   mm6, 2
	pslld   mm7, 2

        movd ebx, mm6
        movd ecx, mm7
        psrlq mm7, 32
        movd edx, mm7		/* table indices in ebx,ecx,edx */

        movlps xmm5, [esi + ebx*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */
        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + ebx*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */

	xorps  xmm3, xmm3
	/* fetch charges to xmm3 (temporary) */
	movss   xmm3, [esp + _qqOH]
	movhps  xmm3, [esp + _qqHH]
		
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point xmm5 contains vcoul and xmm3 fijC */
        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5	

        xorps  xmm1, xmm1

        mulps xmm3, [esp + _tsc]
        mulps xmm3, xmm0
        subps  xmm1, xmm3
	
	movaps  xmm0, xmm1
	movaps  xmm2, xmm1
	
	mulps   xmm0, [esp + _dxH2O]
	mulps   xmm1, [esp + _dyH2O]
	mulps   xmm2, [esp + _dzH2O]
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	mov     esi, [ebp + _faction]
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixH2]
	addps   xmm1, [esp + _fiyH2]
	addps   xmm2, [esp + _fizH2]
	movaps  [esp + _fixH2], xmm0
	movaps  [esp + _fiyH2], xmm1
	movaps  [esp + _fizH2], xmm2

	/* update j water forces from local variables */
	movlps  xmm0, [esi + eax*4]
	movlps  xmm1, [esi + eax*4 + 12]
	movhps  xmm1, [esi + eax*4 + 24]
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	movaps  xmm6, xmm5
	movaps  xmm7, xmm5
	shufps  xmm6, xmm6, 0b10
	shufps  xmm7, xmm7, 0b11
	addss   xmm5, [esi + eax*4 + 8]
	addss   xmm6, [esi + eax*4 + 20]
	addss   xmm7, [esi + eax*4 + 32]
	movss   [esi + eax*4 + 8], xmm5
	movss   [esi + eax*4 + 20], xmm6
	movss   [esi + eax*4 + 32], xmm7
	movaps   xmm5, xmm3
	unpcklps xmm3, xmm4
	unpckhps xmm5, xmm4
	addps    xmm0, xmm3
	addps    xmm1, xmm5
	movlps  [esi + eax*4], xmm0 
	movlps  [esi + eax*4 + 12], xmm1 
	movhps  [esi + eax*4 + 24], xmm1 
	
	dec dword ptr [esp + _innerk]
	jz    .i3030_updateouterdata
	jmp   .i3030_single_loop
.i3030_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate  Oi forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixO]
	movaps xmm1, [esp + _fiyO] 
	movaps xmm2, [esp + _fizO]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	movaps xmm6, xmm0
	movss xmm7, xmm2
	movlhps xmm6, xmm1
	shufps  xmm6, xmm6, 0b1000	

	/* accumulate H1i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH1]
	movaps xmm1, [esp + _fiyH1]
	movaps xmm2, [esp + _fizH1]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 12]
	movss  xmm4, [edi + ecx*4 + 16]
	movss  xmm5, [edi + ecx*4 + 20]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 12], xmm3
	movss  [edi + ecx*4 + 16], xmm4
	movss  [edi + ecx*4 + 20], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* accumulate H2i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH2]
	movaps xmm1, [esp + _fiyH2]
	movaps xmm2, [esp + _fizH2]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 24]
	movss  xmm4, [edi + ecx*4 + 28]
	movss  xmm5, [edi + ecx*4 + 32]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 24], xmm3
	movss  [edi + ecx*4 + 28], xmm4
	movss  [edi + ecx*4 + 32], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* increment fshift force */ 
	movlps  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 8]
	addps  xmm3, xmm6
	addss  xmm4, xmm7
	movlps  [esi + edx*4],    xmm3
	movss  [esi + edx*4 + 8], xmm4

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i3030_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i3030_outer
.i3030_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 1444
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret
	



.globl inl3100_sse
	.type inl3100_sse,@function
inl3100_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_type,		60
.equ		_ntype,		64
.equ		_nbfp,		68	
.equ		_Vnb,		72
.equ		_tabscale,	76
.equ		_VFtab,		80
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ix,		0
.equ		_iy,		16
.equ		_iz,		32
.equ		_iq,		48
.equ		_dx,		64
.equ		_dy,		80
.equ		_dz,		96
.equ		_two,		112
.equ		_six,		128
.equ		_twelve,	144
.equ		_tsc,		160
.equ		_qq,		176	
.equ		_c6,		192
.equ		_c12,		208
.equ		_fscal,		224
.equ		_vctot,		240
.equ		_vnbtot,	256
.equ		_fix,		272
.equ		_fiy,		288
.equ		_fiz,		304
.equ		_half,		320
.equ		_three,		336
.equ		_is3,		352
.equ		_ii3,		356
.equ		_ntia,		360	
.equ		_innerjjnr,	364
.equ		_innerk,	368
.equ		_salign,	372
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 376		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_two]
	movups xmm2, [sse_three]
	movups xmm3, [sse_six]
	movups xmm4, [sse_twelve]
	movss xmm5, [ebp + _tabscale]
	movaps [esp + _half],  xmm0
	movaps [esp + _two], xmm1
	movaps [esp + _three],  xmm2
	movaps [esp + _six],  xmm3
	movaps [esp + _twelve],  xmm4
	shufps xmm5, xmm5, 0
	movaps [esp + _tsc], xmm5

	/* assume we have at least one i particle - start directly */	
.i3100_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	mulss xmm3, [ebp + _facel]
	shufps xmm3, xmm3, 0

        mov   edx, [ebp + _type] 
        mov   edx, [edx + ebx*4]
        imul  edx, [ebp + _ntype]
        shl   edx, 1
        mov   [esp + _ntia], edx
		
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]

	movaps [esp + _iq], xmm3
	
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   [esp + _ii3], ebx
	
	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _vnbtot], xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i3100_unroll_loop
	jmp   .i3100_finish_inner
.i3100_unroll_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	movaps xmm2, [esp + _iq]
	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	mulps  xmm3, xmm2
	movd  mm2, ecx
	movd  mm3, edx

	movaps [esp + _qq], xmm3
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	movhlps xmm5, xmm4
	cvttps2pi mm6, xmm4
	cvttps2pi mm7, xmm5	/* mm6/mm7 contain lu indices */
	cvtpi2ps xmm6, mm6
	cvtpi2ps xmm5, mm7
	movlhps xmm6, xmm5
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */
	pslld mm6, 2
	pslld mm7, 2

	movd mm0, eax	
	movd mm1, ebx
	movd mm2, ecx
	movd mm3, edx

	mov  esi, [ebp + _VFtab]
	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm5, [esi + ebx*4]
	movhps xmm7, [esi + edx*4] /* got half coulomb table */

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101

	movlps xmm7, [esi + eax*4 + 8]
	movlps xmm3, [esi + ecx*4 + 8]
	movhps xmm7, [esi + ebx*4 + 8]
	movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* coulomb table ready, in xmm4-xmm7 */ 	
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* L-J */
	movaps xmm4, xmm0
	mulps  xmm4, xmm0	/* xmm4=rinvsq */

	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addps  xmm5, [esp + _vctot]

	movaps xmm6, xmm4
	mulps  xmm6, xmm4

	movaps [esp + _vctot], xmm5 

	mulps  xmm6, xmm4	/* xmm6=rinvsix */
	movaps xmm4, xmm6
	mulps  xmm4, xmm4	/* xmm4=rinvtwelve */
	mulps  xmm6, [esp + _c6]
	mulps  xmm4, [esp + _c12]
	movaps xmm7, [esp + _vnbtot]
	addps  xmm7, xmm4
	mulps  xmm4, [esp + _twelve]
	subps  xmm7, xmm6
	mulps  xmm3, [esp + _tsc]
	mulps  xmm6, [esp + _six]
	movaps [esp + _vnbtot], xmm7
	subps  xmm4, xmm6
	mulps  xmm4, xmm0
	subps  xmm4, xmm3
	mulps  xmm4, xmm0

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movd eax, mm0	
	movd ebx, mm1
	movd ecx, mm2
	movd edx, mm3

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i3100_finish_inner
	jmp   .i3100_unroll_loop
.i3100_finish_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i3100_dopair
	jmp   .i3100_checksingle
.i3100_dopair:	
	mov esi, [ebp + _charge]
        mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8	
	xorps xmm7, xmm7
	movss xmm3, [esi + eax*4]		
	movss xmm6, [esi + ebx*4]
	shufps xmm3, xmm6, 0 
	shufps xmm3, xmm3, 0b00001000 /* xmm3(0,1) has the charges */

	mulps  xmm3, [esp + _iq]
	movlhps xmm3, xmm7
	movaps [esp + _qq], xmm3

	mov esi, [ebp + _type]
	mov   ecx, eax
	mov   edx, ebx
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add ecx, edi
	add edx, edi
	movlps xmm6, [esi + ecx*4]
	movhps xmm6, [esi + edx*4]
	mov edi, [ebp + _pos]	
	
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b1000 	
	shufps xmm6, xmm6, 0b1101
	movlhps xmm4, xmm7
	movlhps xmm6, xmm7
	
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
			
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ecx, mm6
	psrlq mm6, 32
	movd edx, mm6

	movlps xmm5, [esi + ecx*4]
	movhps xmm5, [esi + edx*4] /* got half coulomb table */
	movaps xmm4, xmm5
	shufps xmm4, xmm4, 0b10001000
	shufps xmm5, xmm7, 0b11011101
	
	movlps xmm7, [esi + ecx*4 + 8]
	movhps xmm7, [esi + edx*4 + 8]
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 0b10001000
	shufps xmm7, xmm7, 0b11011101
	/* table ready in xmm4-xmm7 */

	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* L-J */
	movaps xmm4, xmm0
	mulps  xmm4, xmm0	/* xmm4=rinvsq */

	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addps  xmm5, [esp + _vctot]

	movaps xmm6, xmm4
	mulps  xmm6, xmm4

	movaps [esp + _vctot], xmm5 

	mulps  xmm6, xmm4	/* xmm6=rinvsix */
	movaps xmm4, xmm6
	mulps  xmm4, xmm4	/* xmm4=rinvtwelve */
	mulps  xmm6, [esp + _c6]
	mulps  xmm4, [esp + _c12]
	movaps xmm7, [esp + _vnbtot]
	addps  xmm7, xmm4
	mulps  xmm4, [esp + _twelve]
	subps  xmm7, xmm6
	mulps  xmm3, [esp + _tsc]
	mulps  xmm6, [esp + _six]
	movaps [esp + _vnbtot], xmm7
	subps  xmm4, xmm6
	mulps  xmm4, xmm0
	subps  xmm4, xmm3
	mulps  xmm4, xmm0

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i3100_checksingle:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    .i3100_dosingle
	jmp    .i3100_updateouterdata
.i3100_dosingle:
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	xorps  xmm6, xmm6
	movss xmm6, [esi + eax*4]	/* xmm6(0) has the charge */	
	mulps  xmm6, [esp + _iq]
	movaps [esp + _qq], xmm6

	mov esi, [ebp + _type]
	mov ecx, eax
	mov ecx, [esi + ecx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1
	add ecx, [esp + _ntia]
	movlps xmm6, [esi + ecx*4]
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b11111100	
	shufps xmm6, xmm6, 0b11111101	
			
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	 
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */

	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ebx, mm6
	
	movlps xmm4, [esi + ebx*4]
	movlps xmm6, [esi + ebx*4 + 8]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */

	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* L-J */
	movaps xmm4, xmm0
	mulps  xmm4, xmm0	/* xmm4=rinvsq */

	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addss  xmm5, [esp + _vctot]

	movaps xmm6, xmm4
	mulps  xmm6, xmm4

	movss [esp + _vctot], xmm5 

	mulps  xmm6, xmm4	/* xmm6=rinvsix */
	movaps xmm4, xmm6
	mulps  xmm4, xmm4	/* xmm4=rinvtwelve */
	mulps  xmm6, [esp + _c6]
	mulps  xmm4, [esp + _c12]
	movss xmm7, [esp + _vnbtot]
	addps  xmm7, xmm4
	mulps  xmm4, [esp + _twelve]
	subps  xmm7, xmm6
	mulps  xmm3, [esp + _tsc]
	mulps  xmm6, [esp + _six]
	movss [esp + _vnbtot], xmm7
	subps  xmm4, xmm6
	mulps  xmm4, xmm0
	subps  xmm4, xmm3
	mulps  xmm4, xmm0

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
.i3100_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i3100_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i3100_outer
.i3100_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 376
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret




.globl inl3110_sse
	.type inl3110_sse,@function
inl3110_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_type,		60
.equ		_ntype,		64
.equ		_nbfp,		68	
.equ		_Vnb,		72
.equ		_tabscale,	76
.equ		_VFtab,		80
.equ		_nsatoms,	84			
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ix,		0
.equ		_iy,		16
.equ		_iz,		32
.equ		_iq,		48
.equ		_dx,		64
.equ		_dy,		80
.equ		_dz,		96
.equ		_two,		112
.equ		_tsc,		128
.equ		_qq,		144	
.equ		_c6,		160
.equ		_c12,		176
.equ		_six,		192
.equ		_twelve,	208
.equ		_fscal,		224
.equ		_vctot,		240
.equ		_vnbtot,	256
.equ		_fix,		272
.equ		_fiy,		288
.equ		_fiz,		304
.equ		_half,		320
.equ		_three,		336
.equ		_is3,		352
.equ		_ii3,		356
.equ		_shX,		360
.equ		_shY,		364
.equ		_shZ,		368
.equ		_ntia,		372	
.equ		_innerjjnr0,	376
.equ		_innerk0,	380	
.equ		_innerjjnr,	384
.equ		_innerk,	388
.equ		_salign,	392
.equ		_nsvdwc,	396
.equ		_nscoul,	400
.equ		_nsvdw,		404
.equ		_solnr,		408		
	push ebp
	mov ebp,esp	
	push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 412		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_two]
	movups xmm2, [sse_three]
	movups xmm3, [sse_six]
	movups xmm4, [sse_twelve]
	movss xmm5, [ebp + _tabscale]
	movaps [esp + _half],  xmm0
	movaps [esp + _two], xmm1
	movaps [esp + _three], xmm2
	movaps [esp + _six],  xmm3
	movaps [esp + _twelve], xmm4
	shufps xmm5, xmm5, 0
	movaps [esp + _tsc], xmm5

	/* assume we have at least one i particle - start directly */	
.i3110_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movlps xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 8] 
	movlps [esp + _shX], xmm0
	movss [esp + _shZ], xmm1

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   eax, [ebp + _nsatoms]
	add   [ebp + _nsatoms],  12
	mov   ecx, [eax]	
	mov   edx, [eax + 4]
	mov   eax, [eax + 8]	
	sub   ecx, eax
	sub   eax, edx
	
	mov   [esp + _nsvdwc], edx
	mov   [esp + _nscoul], eax
	mov   [esp + _nsvdw], ecx
		
	/* clear potential */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _vnbtot], xmm4
	mov   [esp + _solnr],  ebx

	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr0], eax     /* pointer to jjnr[nj0] */
	mov   [esp + _innerk0], edx        /* number of innerloop atoms */

	mov   ecx, [esp + _nsvdwc]
	cmp   ecx,  0
	jnz   .i3110_mno_vdwc
	jmp   .i3110_testcoul
.i3110_mno_vdwc:
	mov   ebx,  [esp + _solnr]
	inc   dword ptr [esp + _solnr]

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	mulss xmm3, [ebp + _facel]
	shufps xmm3, xmm3, 0

        mov   edx, [ebp + _type] 
        mov   edx, [edx + ebx*4]
        imul  edx, [ebp + _ntype]
        shl   edx, 1
        mov   [esp + _ntia], edx
		
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 

	movss xmm0, [esp + _shX]
	movss xmm1, [esp + _shY]
	movss xmm2, [esp + _shZ]
	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]

	movaps [esp + _iq], xmm3
	
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   [esp + _ii3], ebx
	
	/* clear i forces */
	xorps xmm4, xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4
	
	mov   ecx, [esp + _innerjjnr0]
	mov   [esp + _innerjjnr], ecx
	mov   edx, [esp + _innerk0]
        sub   edx,  4
        mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i3110_unroll_vdwc_loop
	jmp   .i3110_finish_vdwc_inner
.i3110_unroll_vdwc_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	movaps xmm2, [esp + _iq]
	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	mulps  xmm3, xmm2
	movd  mm2, ecx
	movd  mm3, edx

	movaps [esp + _qq], xmm3
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	movhlps xmm5, xmm4
	cvttps2pi mm6, xmm4
	cvttps2pi mm7, xmm5	/* mm6/mm7 contain lu indices */
	cvtpi2ps xmm6, mm6
	cvtpi2ps xmm5, mm7
	movlhps xmm6, xmm5
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */
	pslld mm6, 2
	pslld mm7, 2

	movd mm0, eax	
	movd mm1, ebx
	movd mm2, ecx
	movd mm3, edx

	mov  esi, [ebp + _VFtab]
	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm5, [esi + ebx*4]
	movhps xmm7, [esi + edx*4] /* got half coulomb table */

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101

	movlps xmm7, [esi + eax*4 + 8]
	movlps xmm3, [esi + ecx*4 + 8]
	movhps xmm7, [esi + ebx*4 + 8]
	movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* coulomb table ready, in xmm4-xmm7 */ 	
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* L-J */
	movaps xmm4, xmm0
	mulps  xmm4, xmm0	/* xmm4=rinvsq */

	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addps  xmm5, [esp + _vctot]

	movaps xmm6, xmm4
	mulps  xmm6, xmm4

	movaps [esp + _vctot], xmm5 

	mulps  xmm6, xmm4	/* xmm6=rinvsix */
	movaps xmm4, xmm6
	mulps  xmm4, xmm4	/* xmm4=rinvtwelve */
	mulps  xmm6, [esp + _c6]
	mulps  xmm4, [esp + _c12]
	movaps xmm7, [esp + _vnbtot]
	addps  xmm7, xmm4
	mulps  xmm4, [esp + _twelve]
	subps  xmm7, xmm6
	mulps  xmm3, [esp + _tsc]
	mulps  xmm6, [esp + _six]
	movaps [esp + _vnbtot], xmm7
	subps  xmm4, xmm6
	mulps  xmm4, xmm0
	subps  xmm4, xmm3
	mulps  xmm4, xmm0

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movd eax, mm0	
	movd ebx, mm1
	movd ecx, mm2
	movd edx, mm3

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i3110_finish_vdwc_inner
	jmp   .i3110_unroll_vdwc_loop
.i3110_finish_vdwc_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i3110_dopair_vdwc
	jmp   .i3110_checksingle_vdwc
.i3110_dopair_vdwc:	
	mov esi, [ebp + _charge]

        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8	
	xorps xmm7, xmm7
	movss xmm3, [esi + eax*4]		
	movss xmm6, [esi + ebx*4]
	shufps xmm3, xmm6, 0 
	shufps xmm3, xmm3, 0b00001000 /* xmm3(0,1) has the charges */

	mulps  xmm3, [esp + _iq]
	movlhps xmm3, xmm7
	movaps [esp + _qq], xmm3

	mov esi, [ebp + _type]
	mov   ecx, eax
	mov   edx, ebx
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add ecx, edi
	add edx, edi
	movlps xmm6, [esi + ecx*4]
	movhps xmm6, [esi + edx*4]
	mov edi, [ebp + _pos]	
	
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b1000 	
	shufps xmm6, xmm6, 0b1101
	movlhps xmm4, xmm7
	movlhps xmm6, xmm7
	
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
			
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	/* move ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ecx, mm6
	psrlq mm6, 32
	movd edx, mm6

	movlps xmm5, [esi + ecx*4]
	movhps xmm5, [esi + edx*4] /* got half coulomb table */
	movaps xmm4, xmm5
	shufps xmm4, xmm4, 0b10001000
	shufps xmm5, xmm7, 0b11011101
	
	movlps xmm7, [esi + ecx*4 + 8]
	movhps xmm7, [esi + edx*4 + 8]
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 0b10001000
	shufps xmm7, xmm7, 0b11011101
	/* table ready in xmm4-xmm7 */

	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* L-J */
	movaps xmm4, xmm0
	mulps  xmm4, xmm0	/* xmm4=rinvsq */

	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addps  xmm5, [esp + _vctot]

	movaps xmm6, xmm4
	mulps  xmm6, xmm4

	movaps [esp + _vctot], xmm5 

	mulps  xmm6, xmm4	/* xmm6=rinvsix */
	movaps xmm4, xmm6
	mulps  xmm4, xmm4	/* xmm4=rinvtwelve */
	mulps  xmm6, [esp + _c6]
	mulps  xmm4, [esp + _c12]
	movaps xmm7, [esp + _vnbtot]
	addps  xmm7, xmm4
	mulps  xmm4, [esp + _twelve]
	subps  xmm7, xmm6
	mulps  xmm3, [esp + _tsc]
	mulps  xmm6, [esp + _six]
	movaps [esp + _vnbtot], xmm7
	subps  xmm4, xmm6
	mulps  xmm4, xmm0
	subps  xmm4, xmm3
	mulps  xmm4, xmm0

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	mov    edi, [ebp + _faction]
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i3110_checksingle_vdwc:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    .i3110_dosingle_vdwc
	jmp    .i3110_updateouterdata_vdwc
.i3110_dosingle_vdwc:
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	xorps  xmm6, xmm6
	movss xmm6, [esi + eax*4]	/* xmm6(0) has the charge */	
	mulps  xmm6, [esp + _iq]
	movaps [esp + _qq], xmm6

	mov esi, [ebp + _type]
	mov ecx, eax
	mov ecx, [esi + ecx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1
	add ecx, [esp + _ntia]
	movlps xmm6, [esi + ecx*4]
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b11111100	
	shufps xmm6, xmm6, 0b11111101	
			
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	 
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */

	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ebx, mm6
						
	movlps xmm4, [esi + ebx*4]
	movlps xmm6, [esi + ebx*4 + 8]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */

	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* L-J */
	movaps xmm4, xmm0
	mulps  xmm4, xmm0	/* xmm4=rinvsq */

	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addss  xmm5, [esp + _vctot]

	movaps xmm6, xmm4
	mulps  xmm6, xmm4

	movss [esp + _vctot], xmm5 

	mulps  xmm6, xmm4	/* xmm6=rinvsix */
	movaps xmm4, xmm6
	mulps  xmm4, xmm4	/* xmm4=rinvtwelve */
	mulps  xmm6, [esp + _c6]
	mulps  xmm4, [esp + _c12]
	movss xmm7, [esp + _vnbtot]
	addps  xmm7, xmm4
	mulps  xmm4, [esp + _twelve]
	subps  xmm7, xmm6
	mulps  xmm3, [esp + _tsc]
	mulps  xmm6, [esp + _six]
	movss [esp + _vnbtot], xmm7
	subps  xmm4, xmm6
	mulps  xmm4, xmm0
	subps  xmm4, xmm3
	mulps  xmm4, xmm0

	mov edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
.i3110_updateouterdata_vdwc:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5


	/* loop back to mno */
	dec  dword ptr [esp + _nsvdwc]
	jz  .i3110_testcoul
	jmp .i3110_mno_vdwc
.i3110_testcoul:
	mov  ecx, [esp + _nscoul]
	cmp  ecx,  0
	jnz  .i3110_mno_coul
	jmp  .i3110_testvdw
.i3110_mno_coul:
	mov   ebx,  [esp + _solnr]
	inc   dword ptr [esp + _solnr]

	movss xmm0, [esp + _shX]
	movss xmm1, [esp + _shY]
	movss xmm2, [esp + _shZ]

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	mulss xmm3, [ebp + _facel]
	shufps xmm3, xmm3, 0
	
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]

	movaps [esp + _iq], xmm3
	
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	
	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   [esp + _ii3], ebx
	
	/* clear i forces */
	xorps xmm4, xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4

	mov   ecx, [esp + _innerjjnr0]
	mov   [esp + _innerjjnr], ecx
	mov   edx, [esp + _innerk0]
        sub   edx,  4
        mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i3110_unroll_coul_loop
	jmp   .i3110_finish_coul_inner

.i3110_unroll_coul_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	movaps xmm2, [esp + _iq]
	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	mulps  xmm3, xmm2

	movaps [esp + _qq], xmm3	
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	movhlps xmm5, xmm4
	cvttps2pi mm6, xmm4
	cvttps2pi mm7, xmm5	/* mm6/mm7 contain lu indices */
	cvtpi2ps xmm6, mm6
	cvtpi2ps xmm5, mm7
	movlhps xmm6, xmm5
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */
	pslld mm6, 2
	pslld mm7, 2

	movd mm0, eax	
	movd mm1, ebx
	movd mm2, ecx
	movd mm3, edx

	mov  esi, [ebp + _VFtab]
	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	movlps xmm5, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm5, [esi + ebx*4]
	movhps xmm7, [esi + edx*4] /* got half coulomb table */

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101

	movlps xmm7, [esi + eax*4 + 8]
	movlps xmm3, [esi + ecx*4 + 8]
	movhps xmm7, [esi + ebx*4 + 8]
	movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* coulomb table ready, in xmm4-xmm7 */ 	
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addps  xmm5, [esp + _vctot]
	movaps [esp + _vctot], xmm5 

	xorps  xmm4, xmm4

	mulps xmm3, [esp + _tsc]
	mulps xmm3, xmm0
	subps  xmm4, xmm3

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movd eax, mm0	
	movd ebx, mm1
	movd ecx, mm2
	movd edx, mm3

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i3110_finish_coul_inner
	jmp   .i3110_unroll_coul_loop
.i3110_finish_coul_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i3110_dopair_coul
	jmp   .i3110_checksingle_coul
.i3110_dopair_coul:	
	mov esi, [ebp + _charge]

        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8	
	xorps xmm7, xmm7
	movss xmm3, [esi + eax*4]		
	movss xmm6, [esi + ebx*4]
	shufps xmm3, xmm6, 0 
	shufps xmm3, xmm3, 0b00001000 /* xmm3(0,1) has the charges */

	mulps  xmm3, [esp + _iq]
	movlhps xmm3, xmm7
	movaps [esp + _qq], xmm3

	mov edi, [ebp + _pos]	
	
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ecx, mm6
	psrlq mm6, 32
	movd edx, mm6

	movlps xmm5, [esi + ecx*4]
	movhps xmm5, [esi + edx*4] /* got half coulomb table */
	movaps xmm4, xmm5
	shufps xmm4, xmm4, 0b10001000
	shufps xmm5, xmm7, 0b11011101
	
	movlps xmm7, [esi + ecx*4 + 8]
	movhps xmm7, [esi + edx*4 + 8]
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 0b10001000
	shufps xmm7, xmm7, 0b11011101
	/* table ready in xmm4-xmm7 */

	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addps  xmm5, [esp + _vctot]
	movaps [esp + _vctot], xmm5 

	xorps  xmm4, xmm4

	mulps xmm3, [esp + _tsc]
	mulps xmm3, xmm0
	subps  xmm4, xmm3

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i3110_checksingle_coul:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    .i3110_dosingle_coul
	jmp    .i3110_updateouterdata_coul
.i3110_dosingle_coul:
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	xorps  xmm6, xmm6
	movss xmm6, [esi + eax*4]	/* xmm6(0) has the charge */	
	mulps  xmm6, [esp + _iq]
	movaps [esp + _qq], xmm6
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	 
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */

	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ebx, mm6
	
	movlps xmm4, [esi + ebx*4]
	movlps xmm6, [esi + ebx*4 + 8]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */

	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addss  xmm5, [esp + _vctot]
	movss [esp + _vctot], xmm5 

	xorps xmm4, xmm4

	mulps xmm3, [esp + _tsc]
	mulps xmm3, xmm0
	subps  xmm4, xmm3
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
.i3110_updateouterdata_coul:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5

	/* loop back to mno */
	dec  dword ptr [esp + _nscoul]
	jz  .i3110_testvdw
	jmp .i3110_mno_coul
.i3110_testvdw:
	mov  ecx, [esp + _nsvdw]
	cmp  ecx,  0
	jnz  .i3110_mno_vdw
	jmp  .i3110_last_mno
.i3110_mno_vdw:
	mov   ebx,  [esp + _solnr]
	inc   dword ptr [esp + _solnr]

        mov   edx, [ebp + _type] 
        mov   edx, [edx + ebx*4]
        imul  edx, [ebp + _ntype]
        shl   edx, 1
        mov   [esp + _ntia], edx
		
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx

	movss xmm0, [esp + _shX]
	movss xmm1, [esp + _shY]
	movss xmm2, [esp + _shZ]

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]
	
	xorps xmm4, xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   ecx, [esp + _innerjjnr0]
	mov   [esp + _innerjjnr], ecx
	mov   edx, [esp + _innerk0]
        sub   edx,  4
        mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i3110_unroll_vdw_loop
	jmp   .i3110_finish_vdw_inner
.i3110_unroll_vdw_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	movd  mm2, ecx
	movd  mm3, edx
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rcpps xmm5, xmm4
	/* 1/x lookup seed in xmm5 */
	movaps xmm0, [esp + _two]
	mulps xmm4, xmm5
	subps xmm0, xmm4
	mulps xmm0, xmm5	/* xmm0=rinvsq */
	movaps xmm4, xmm0
	
	movaps xmm1, xmm0
	mulps  xmm1, xmm0
	mulps  xmm1, xmm0	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */

	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	mulps  xmm4, xmm2	/* xmm4=total fscal */
	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vnbtot], xmm5

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i3110_finish_vdw_inner
	jmp   .i3110_unroll_vdw_loop
.i3110_finish_vdw_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i3110_dopair_vdw
	jmp   .i3110_checksingle_vdw
.i3110_dopair_vdw:	
        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8	
	xorps xmm7, xmm7

	mov esi, [ebp + _type]
	mov   ecx, eax
	mov   edx, ebx
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add ecx, edi
	add edx, edi
	movlps xmm6, [esi + ecx*4]
	movhps xmm6, [esi + edx*4]
	mov edi, [ebp + _pos]	
	
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b1000 	
	shufps xmm6, xmm6, 0b1101
	movlhps xmm4, xmm7
	movlhps xmm6, xmm7
	
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
			
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rcpps xmm5, xmm4
	/* 1/x lookup seed in xmm5 */
	movaps xmm0, [esp + _two]
	mulps xmm4, xmm5
	subps xmm0, xmm4
	mulps xmm0, xmm5	/* xmm0=rinvsq */
	movaps xmm4, xmm0
	
	movaps xmm1, xmm0
	mulps  xmm1, xmm0
	mulps  xmm1, xmm0	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */

	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addps  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	mulps  xmm4, xmm2	/* xmm4=total fscal */

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movaps [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i3110_checksingle_vdw:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    .i3110_dosingle_vdw
	jmp    .i3110_updateouterdata_vdw
.i3110_dosingle_vdw:
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	xorps  xmm6, xmm6

	mov esi, [ebp + _type]
	mov ecx, eax
	mov ecx, [esi + ecx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1
	add ecx, [esp + _ntia]
	movlps xmm6, [esi + ecx*4]
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b11111100	
	shufps xmm6, xmm6, 0b11111101	
			
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	 
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rcpps xmm5, xmm4
	/* 1/x lookup seed in xmm5 */
	movaps xmm0, [esp + _two]
	mulps xmm4, xmm5
	subps xmm0, xmm4
	mulps xmm0, xmm5	/* xmm0=rinvsq */
	movaps xmm4, xmm0
	
	movaps xmm1, xmm0
	mulps  xmm1, xmm0
	mulps  xmm1, xmm0	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */

	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm5, xmm2
	subps  xmm5, xmm1	/* vnb=vnb12-vnb6 */
	addss  xmm5, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	subps  xmm2, xmm1
	mulps  xmm4, xmm2	/* xmm4=total fscal */
	
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movss [esp + _vnbtot], xmm5

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	mov edi, [ebp + _faction]

	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5
.i3110_updateouterdata_vdw:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5
	
	/* loop back to mno */
	dec dword ptr [esp + _nsvdw]
	jz  .i3110_last_mno
	jmp .i3110_mno_vdw
.i3110_last_mno:	
	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i3110_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i3110_outer
.i3110_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 412
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret




.globl inl3120_sse
	.type inl3120_sse,@function
inl3120_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_type,		60
.equ		_ntype,		64
.equ		_nbfp,		68	
.equ		_Vnb,		72	
.equ		_tabscale,	76	
.equ		_VFtab,		80	
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ixO,		0
.equ		_iyO,		16
.equ		_izO,		32
.equ		_ixH1,		48
.equ		_iyH1,		64
.equ		_izH1,		80
.equ		_ixH2,		96
.equ		_iyH2,		112
.equ		_izH2,		128
.equ		_iqO,		144 
.equ		_iqH,		160 
.equ		_dxO,		176
.equ		_dyO,		192
.equ		_dzO,		208	
.equ		_dxH1,		224
.equ		_dyH1,		240
.equ		_dzH1,		256	
.equ		_dxH2,		272
.equ		_dyH2,		288
.equ		_dzH2,		304	
.equ		_qqO,		320
.equ		_qqH,		336
.equ		_rinvO,		352
.equ		_rinvH1,	368
.equ		_rinvH2,	384		
.equ		_rO,		400
.equ		_rH1,		416
.equ		_rH2,		432
.equ		_tsc,		448	
.equ		_two,		464
.equ		_c6,		480
.equ		_c12,		496
.equ		_six,		512
.equ		_twelve,	528
.equ		_vctot,		544
.equ		_vnbtot,	560
.equ		_fixO,		576
.equ		_fiyO,		592
.equ		_fizO,		608
.equ		_fixH1,		624
.equ		_fiyH1,		640
.equ		_fizH1,		656
.equ		_fixH2,		672
.equ		_fiyH2,		688
.equ		_fizH2,		704
.equ		_fjx,		720
.equ		_fjy,		736
.equ		_fjz,		752
.equ		_half,		768
.equ		_three,		784
.equ		_is3,		800
.equ		_ii3,		804
.equ		_ntia,		808	
.equ		_innerjjnr,	812
.equ		_innerk,	816
.equ		_salign,	820								
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 824		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_two]
	movups xmm2, [sse_three]
	movups xmm3, [sse_six]
	movups xmm4, [sse_twelve]
	movss xmm5, [ebp + _tabscale]
	
	movaps [esp + _half],  xmm0
	movaps [esp + _two],  xmm1
	movaps [esp + _three],  xmm2
	movaps [esp + _six],  xmm3
	movaps [esp + _twelve],  xmm4
	shufps xmm5, xmm5, 0
	movaps [esp + _tsc], xmm5
	
	/* assume we have at least one i particle - start directly */
	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	movss xmm4, [edx + ebx*4 + 4]	
	movss xmm5, [ebp + _facel]
	mulss  xmm3, xmm5
	mulss  xmm4, xmm5

	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	movaps [esp + _iqO], xmm3
	movaps [esp + _iqH], xmm4
	
	mov   edx, [ebp + _type]
	mov   ecx, [edx + ebx*4]
	shl   ecx, 1
	imul  ecx, [ebp + _ntype]      /* ecx = ntia = 2*ntype*type[ii0] */
	mov   [esp + _ntia], ecx		
.i3120_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2

	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx

	addss xmm3, [eax + ebx*4]
	addss xmm4, [eax + ebx*4 + 4]
	addss xmm5, [eax + ebx*4 + 8]		
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixO], xmm3
	movaps [esp + _iyO], xmm4
	movaps [esp + _izO], xmm5

	movss xmm3, xmm0
	movss xmm4, xmm1
	movss xmm5, xmm2
	addss xmm0, [eax + ebx*4 + 12]
	addss xmm1, [eax + ebx*4 + 16]
	addss xmm2, [eax + ebx*4 + 20]		
	addss xmm3, [eax + ebx*4 + 24]
	addss xmm4, [eax + ebx*4 + 28]
	addss xmm5, [eax + ebx*4 + 32]		

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixH1], xmm0
	movaps [esp + _iyH1], xmm1
	movaps [esp + _izH1], xmm2
	movaps [esp + _ixH2], xmm3
	movaps [esp + _iyH2], xmm4
	movaps [esp + _izH2], xmm5
	
	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _vnbtot], xmm4
	movaps [esp + _fixO], xmm4
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm4
	movaps [esp + _fixH1], xmm4
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm4
	movaps [esp + _fixH2], xmm4
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i3120_unroll_loop
	jmp   .i3120_odd_inner
.i3120_unroll_loop:
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */

	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	movaps xmm4, xmm3	     /* and in xmm4 */
	mulps  xmm3, [esp + _iqO]
	mulps  xmm4, [esp + _iqH]

	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	movd  mm2, ecx
	movd  mm3, edx

	movaps  [esp + _qqO], xmm3
	movaps  [esp + _qqH], xmm4
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6

	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	
	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ixO-izO to xmm4-xmm6 */
	movaps xmm4, [esp + _ixO]
	movaps xmm5, [esp + _iyO]
	movaps xmm6, [esp + _izO]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dxO], xmm4
	movaps [esp + _dyO], xmm5
	movaps [esp + _dzO], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	movaps xmm7, xmm4
	/* rsqO in xmm7 */

	/* move ixH1-izH1 to xmm4-xmm6 */
	movaps xmm4, [esp + _ixH1]
	movaps xmm5, [esp + _iyH1]
	movaps xmm6, [esp + _izH1]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dxH1], xmm4
	movaps [esp + _dyH1], xmm5
	movaps [esp + _dzH1], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm6, xmm5
	addps xmm6, xmm4
	/* rsqH1 in xmm6 */

	/* move ixH2-izH2 to xmm3-xmm5 */ 
	movaps xmm3, [esp + _ixH2]
	movaps xmm4, [esp + _iyH2]
	movaps xmm5, [esp + _izH2]

	/* calc dr */
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2

	/* store dr */
	movaps [esp + _dxH2], xmm3
	movaps [esp + _dyH2], xmm4
	movaps [esp + _dzH2], xmm5
	/* square it */
	mulps xmm3,xmm3
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	addps xmm5, xmm4
	addps xmm5, xmm3
	/* rsqH2 in xmm5, rsqH1 in xmm6, rsqO in xmm7 */

	/* start with rsqO - seed to xmm2 */	
	rsqrtps xmm2, xmm7
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm7	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  [esp + _rinvO], xmm4	/* rinvO in xmm4 */
	mulps   xmm7, xmm4
	movaps  [esp + _rO], xmm7	

	/* rsqH1 - seed in xmm2 */
	rsqrtps xmm2, xmm6
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm6	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  [esp + _rinvH1], xmm4	/* rinvH1 in xmm4 */
	mulps   xmm6, xmm4
	movaps  [esp + _rH1], xmm6

	/* rsqH2 - seed to xmm2 */
	rsqrtps xmm2, xmm5
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm5	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  [esp + _rinvH2], xmm4	/* rinvH2 in xmm4 */
	mulps   xmm5, xmm4
	movaps  [esp + _rH2], xmm5

	/* do O interactions */
	/* rO is still in xmm7 */
	mulps   xmm7, [esp + _tsc]
	movhlps xmm4, xmm7
	cvttps2pi mm6, xmm7
	cvttps2pi mm7, xmm4    /* mm6/mm7 contain lu indices */
	
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm4, mm7
        movlhps xmm3, xmm4
	
        subps xmm7, xmm3

	movaps xmm1, xmm7	/* xmm1=eps */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2
		
        movd mm0, eax   
        movd mm1, ebx
        movd mm2, ecx
        movd mm3, edx

        mov  esi, [ebp + _VFtab]
        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */     
        
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */       
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm0, [esp + _qqO]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm0 /* vcoul=qq*VV */ 
        mulps  xmm0, xmm7 /* fijC=FF*qq */

	/* do nontable L-J */
	movaps xmm2, [esp + _rinvO]
	mulps  xmm2, xmm2

        /* at this point mm5 contains vcoul and xmm0 fijC */
        /* increment vcoul - then we can get rid of mm5 */
        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5 

	movaps xmm1, xmm2
	mulps  xmm1, xmm1
	mulps  xmm1, xmm2	/* xmm1=rinvsix */
	movaps xmm4, xmm1
	mulps  xmm4, xmm4	/* xmm4=rinvtwelve */
	mulps  xmm1, [esp + _c6]
	mulps  xmm4, [esp + _c12]
	movaps xmm3, xmm4
	subps  xmm3, xmm1	/* xmm3=vnb12-vnb6 */
	mulps  xmm1, [esp + _six]
	mulps  xmm4, [esp + _twelve]
	subps  xmm4, xmm1
	addps  xmm3, [esp + _vnbtot]
	mulps  xmm4, [esp + _rinvO]
	mulps  xmm0, [esp + _tsc]
	subps  xmm4, xmm0
	movaps [esp + _vnbtot], xmm3
	mulps  xmm4, [esp + _rinvO]	

	movaps xmm0, [esp + _dxO]
	movaps xmm1, [esp + _dyO]
	movaps xmm2, [esp + _dzO]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4	/* tx in xmm0-xmm2 */

	/* update O forces */
	movaps xmm3, [esp + _fixO]
	movaps xmm4, [esp + _fiyO]
	movaps xmm7, [esp + _fizO]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixO], xmm3
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm7
	/* update j forces with water O */
	movaps [esp + _fjx], xmm0
	movaps [esp + _fjy], xmm1
	movaps [esp + _fjz], xmm2

	/* Done with O interactions - now H1! */
	movaps xmm7, [esp + _rH1]
	mulps   xmm7, [esp + _tsc]
	movhlps xmm4, xmm7
	cvttps2pi mm6, xmm7
	cvttps2pi mm7, xmm4    /* mm6/mm7 contain lu indices */
	
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm4, mm7
        movlhps xmm3, xmm4
	
        subps xmm7, xmm3
	movaps xmm1, xmm7	/* xmm1=eps */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2
		
        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */     
        
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */       
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm0, [esp + _qqH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm0 /* vcoul=qq*VV */ 
        mulps  xmm7, xmm0 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and xmm7 fijC */
        /* increment vcoul */
	xorps  xmm4, xmm4
        addps  xmm5, [esp + _vctot]
	mulps  xmm7, [esp + _rinvH1]
        movaps [esp + _vctot], xmm5 
	mulps  xmm7, [esp + _tsc]
	subps xmm4, xmm7

	movaps xmm0, [esp + _dxH1]
	movaps xmm1, [esp + _dyH1]
	movaps xmm2, [esp + _dzH1]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

	/* update H1 forces */
	movaps xmm3, [esp + _fixH1]
	movaps xmm4, [esp + _fiyH1]
	movaps xmm7, [esp + _fizH1]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixH1], xmm3
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm7
	/* update j forces with water H1 */
	addps  xmm0, [esp + _fjx]
	addps  xmm1, [esp + _fjy]
	addps  xmm2, [esp + _fjz]
	movaps [esp + _fjx], xmm0
	movaps [esp + _fjy], xmm1
	movaps [esp + _fjz], xmm2

	/* Done with H1, finally we do H2 interactions */
	movaps xmm7, [esp + _rH2]
	mulps   xmm7, [esp + _tsc]
	movhlps xmm4, xmm7
	cvttps2pi mm6, xmm7
	cvttps2pi mm7, xmm4    /* mm6/mm7 contain lu indices */
	
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm4, mm7
        movlhps xmm3, xmm4
	
        subps xmm7, xmm3
	movaps xmm1, xmm7	/* xmm1=eps */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2
		
        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */     
        
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */       
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm0, [esp + _qqH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm0 /* vcoul=qq*VV */ 
        mulps  xmm7, xmm0 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and xmm0 fijC */
        /* increment vcoul */
	xorps  xmm4, xmm4
        addps  xmm5, [esp + _vctot]
	mulps  xmm7, [esp + _rinvH2]
        movaps [esp + _vctot], xmm5 
	mulps  xmm7, [esp + _tsc]
	subps  xmm4, xmm7

	movaps xmm0, [esp + _dxH2]
	movaps xmm1, [esp + _dyH2]
	movaps xmm2, [esp + _dzH2]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

        movd eax, mm0   
        movd ebx, mm1
        movd ecx, mm2
        movd edx, mm3
	
	/* update H2 forces */
	movaps xmm3, [esp + _fixH2]
	movaps xmm4, [esp + _fiyH2]
	movaps xmm7, [esp + _fizH2]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixH2], xmm3
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm7

	mov edi, [ebp + _faction]
	/* update j forces */
	addps xmm0, [esp + _fjx]
	addps xmm1, [esp + _fjy]
	addps xmm2, [esp + _fjz]

	movlps xmm4, [edi + eax*4]
	movlps xmm7, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm7, [edi + edx*4]
	
	movaps xmm3, xmm4
	shufps xmm3, xmm7, 0b10001000
	shufps xmm4, xmm7, 0b11011101			      
	/* xmm3 has fjx, xmm4 has fjy */
	subps xmm3, xmm0
	subps xmm4, xmm1
	/* unpack them back for storing */
	movaps xmm7, xmm3
	unpcklps xmm7, xmm4
	unpckhps xmm3, xmm4	
	movlps [edi + eax*4], xmm7
	movlps [edi + ecx*4], xmm3
	movhps [edi + ebx*4], xmm7
	movhps [edi + edx*4], xmm3
	/* finally z forces */
	movss  xmm0, [edi + eax*4 + 8]
	movss  xmm1, [edi + ebx*4 + 8]
	movss  xmm3, [edi + ecx*4 + 8]
	movss  xmm4, [edi + edx*4 + 8]
	subss  xmm0, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm1, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm3, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm4, xmm2
	movss  [edi + eax*4 + 8], xmm0
	movss  [edi + ebx*4 + 8], xmm1
	movss  [edi + ecx*4 + 8], xmm3
	movss  [edi + edx*4 + 8], xmm4
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i3120_odd_inner
	jmp   .i3120_unroll_loop
.i3120_odd_inner:	
	add   [esp + _innerk],  4
	jnz   .i3120_odd_loop
	jmp   .i3120_updateouterdata
.i3120_odd_loop:
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	add   [esp + _innerjjnr],  4	

 	xorps xmm4, xmm4
	movss xmm4, [esp + _iqO]
	mov esi, [ebp + _charge] 
	movhps xmm4, [esp + _iqH]     
	movss xmm3, [esi + eax*4]	/* charge in xmm3 */
	shufps xmm3, xmm3, 0
	mulps xmm3, xmm4
	movaps [esp + _qqO], xmm3	/* use oxygen qq for storage */

	xorps xmm6, xmm6
	mov esi, [ebp + _type]
	mov ebx, [esi + eax*4]
	mov esi, [ebp + _nbfp]
	shl ebx, 1	
	add ebx, [esp + _ntia]
	movlps xmm6, [esi + ebx*4]
	movaps xmm7, xmm6
	shufps xmm6, xmm6, 0b11111100
	shufps xmm7, xmm7, 0b11111101
	movaps [esp + _c6], xmm6
	movaps [esp + _c12], xmm7

	mov esi, [ebp + _pos]
	lea   eax, [eax + eax*2]  
	
	/* move j coords to xmm0-xmm2 */
	movss xmm0, [esi + eax*4]
	movss xmm1, [esi + eax*4 + 4]
	movss xmm2, [esi + eax*4 + 8]
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0	
	movss xmm3, [esp + _ixO]
	movss xmm4, [esp + _iyO]
	movss xmm5, [esp + _izO]
		
	movlps xmm6, [esp + _ixH1]
	movlps xmm7, [esp + _ixH2]
	unpcklps xmm6, xmm7
	movlhps xmm3, xmm6
	movlps xmm6, [esp + _iyH1]
	movlps xmm7, [esp + _iyH2]
	unpcklps xmm6, xmm7
	movlhps xmm4, xmm6
	movlps xmm6, [esp + _izH1]
	movlps xmm7, [esp + _izH2]
	unpcklps xmm6, xmm7
	movlhps xmm5, xmm6

	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	
	movaps [esp + _dxO], xmm3
	movaps [esp + _dyO], xmm4
	movaps [esp + _dzO], xmm5

	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5

	addps  xmm4, xmm3
	addps  xmm4, xmm5
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	movaps [esp + _rinvO], xmm0
	
	mulps xmm4, [esp + _tsc]
	movhlps xmm7, xmm4
	cvttps2pi mm6, xmm4
	cvttps2pi mm7, xmm7    /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm7, mm7
        movlhps xmm3, xmm7

	subps   xmm4, xmm3	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2
	
        movd mm0, eax   
        movd mm1, ecx
        movd mm2, edx

        mov  esi, [ebp + _VFtab]
        movd eax, mm6
        movd ecx, mm7
        psrlq mm7, 32
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */     
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */       
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm0, [esp + _qqO]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm0 /* vcoul=qq*VV */ 
        mulps  xmm0, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and xmm0 fijC */
        /* increment vcoul - then we can get rid of mm5 */
        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5

	/* do nontable L-J */
	movaps xmm2, [esp + _rinvO]
	mulps  xmm2, xmm2
	movaps xmm1, xmm2
	mulps  xmm1, xmm1
	mulps  xmm1, xmm2	/* xmm1=rinvsix */
	movaps xmm4, xmm1
	mulps  xmm4, xmm4	/* xmm4=rinvtwelve */
	mulps  xmm1, [esp + _c6]
	mulps  xmm4, [esp + _c12]
	movaps xmm3, xmm4
	subps  xmm3, xmm1	/* xmm3=vnb12-vnb6 */
	mulps  xmm1, [esp + _six]
	mulps  xmm4, [esp + _twelve]
	subps  xmm4, xmm1
	addps  xmm3, [esp + _vnbtot]
	mulps  xmm4, [esp + _rinvO]
	mulps  xmm0, [esp + _tsc]
	subps  xmm4, xmm0
	movaps [esp + _vnbtot], xmm3
	mulps  xmm4, [esp + _rinvO]	
		
        movd eax, mm0   
        movd ecx, mm1
        movd edx, mm2	
		
	movaps xmm0, [esp + _dxO]
	movaps xmm1, [esp + _dyO]
	movaps xmm2, [esp + _dzO]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4 /* xmm0-xmm2 now contains tx-tz (partial force) */
	movss  xmm3, [esp + _fixO]	
	movss  xmm4, [esp + _fiyO]	
	movss  xmm5, [esp + _fizO]	
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esp + _fixO], xmm3	
	movss  [esp + _fiyO], xmm4	
	movss  [esp + _fizO], xmm5	/* updated the O force now do the H's */
	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2
	shufps xmm3, xmm3, 0b11100110	/* shift right */
	shufps xmm4, xmm4, 0b11100110
	shufps xmm5, xmm5, 0b11100110
	addss  xmm3, [esp + _fixH1]
	addss  xmm4, [esp + _fiyH1]
	addss  xmm5, [esp + _fizH1]
	movss  [esp + _fixH1], xmm3	
	movss  [esp + _fiyH1], xmm4	
	movss  [esp + _fizH1], xmm5	/* updated the H1 force */

	mov edi, [ebp + _faction]
	shufps xmm3, xmm3, 0b11100111	/* shift right */
	shufps xmm4, xmm4, 0b11100111
	shufps xmm5, xmm5, 0b11100111
	addss  xmm3, [esp + _fixH2]
	addss  xmm4, [esp + _fiyH2]
	addss  xmm5, [esp + _fizH2]
	movss  [esp + _fixH2], xmm3	
	movss  [esp + _fiyH2], xmm4	
	movss  [esp + _fizH2], xmm5	/* updated the H2 force */

	/* the fj's - start by accumulating the tx/ty/tz force in xmm0, xmm1 */
	xorps  xmm5, xmm5
	movaps xmm3, xmm0
	movlps xmm6, [edi + eax*4]
	movss  xmm7, [edi + eax*4 + 8]
	unpcklps xmm3, xmm1
	movlhps  xmm3, xmm5	
	unpckhps xmm0, xmm1		
	addps    xmm0, xmm3
	movhlps  xmm3, xmm0	
	addps    xmm0, xmm3	/* x,y sum in xmm0 */

	movhlps  xmm1, xmm2
	addss    xmm2, xmm1
	shufps   xmm1, xmm1, 1 
	addss    xmm2, xmm1    /* z sum in xmm2 */
	subps    xmm6, xmm0
	subss    xmm7, xmm2
	
	movlps [edi + eax*4],     xmm6
	movss  [edi + eax*4 + 8], xmm7

	dec dword ptr [esp + _innerk]
	jz    .i3120_updateouterdata
	jmp   .i3120_odd_loop
.i3120_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate  Oi forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixO]
	movaps xmm1, [esp + _fiyO]
	movaps xmm2, [esp + _fizO]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	movaps xmm6, xmm0
	movss xmm7, xmm2
	movlhps xmm6, xmm1
	shufps  xmm6, xmm6, 0b1000	

	/* accumulate H1i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH1]
	movaps xmm1, [esp + _fiyH1]
	movaps xmm2, [esp + _fizH1]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 12]
	movss  xmm4, [edi + ecx*4 + 16]
	movss  xmm5, [edi + ecx*4 + 20]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 12], xmm3
	movss  [edi + ecx*4 + 16], xmm4
	movss  [edi + ecx*4 + 20], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* accumulate H2i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH2]
	movaps xmm1, [esp + _fiyH2]
	movaps xmm2, [esp + _fizH2]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 24]
	movss  xmm4, [edi + ecx*4 + 28]
	movss  xmm5, [edi + ecx*4 + 32]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 24], xmm3
	movss  [edi + ecx*4 + 28], xmm4
	movss  [edi + ecx*4 + 32], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* increment fshift force */ 
	movlps  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 8]
	addps  xmm3, xmm6
	addss  xmm4, xmm7
	movlps  [esi + edx*4],    xmm3
	movss  [esi + edx*4 + 8], xmm4

	mov   edx, [ebp + _gid]  
	mov   edx, [edx]
	add   [ebp + _gid],  4	

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		
        
	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i3120_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i3120_outer
.i3120_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 824
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret
	

	
.globl inl3130_sse
	.type inl3130_sse,@function
inl3130_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_type,		60
.equ		_ntype,		64
.equ		_nbfp,		68	
.equ		_Vnb,		72
.equ		_tabscale,	76	
.equ		_VFtab,		80
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ixO,		0
.equ		_iyO,		16
.equ		_izO,		32
.equ		_ixH1,		48
.equ		_iyH1,		64
.equ		_izH1,		80
.equ		_ixH2,		96
.equ		_iyH2,		112
.equ		_izH2,		128
.equ		_jxO,		144
.equ		_jyO,		160
.equ		_jzO,		176
.equ		_jxH1,		192
.equ		_jyH1,		208
.equ		_jzH1,		224 
.equ		_jxH2,		240
.equ		_jyH2,		256
.equ		_jzH2,		272
.equ		_dxOO,		288
.equ		_dyOO,		304
.equ		_dzOO,		320	
.equ		_dxOH1,		336
.equ		_dyOH1,		352
.equ		_dzOH1,		368	
.equ		_dxOH2,		384
.equ		_dyOH2,		400
.equ		_dzOH2,		416	
.equ		_dxH1O,		432
.equ		_dyH1O,		448
.equ		_dzH1O,		464	
.equ		_dxH1H1,	480
.equ		_dyH1H1,	496
.equ		_dzH1H1,	512	
.equ		_dxH1H2,	528
.equ		_dyH1H2,	544
.equ		_dzH1H2,	560	
.equ		_dxH2O,		576
.equ		_dyH2O,		592
.equ		_dzH2O,		608	
.equ		_dxH2H1,	624
.equ		_dyH2H1,	640
.equ		_dzH2H1,	656	
.equ		_dxH2H2,	672
.equ		_dyH2H2,	688
.equ		_dzH2H2,	704
.equ		_qqOO,		720
.equ		_qqOH,		736
.equ		_qqHH,		752
.equ		_two,		768
.equ		_tsc,		784
.equ		_c6,		800
.equ		_c12,		816		 
.equ		_six,		832
.equ		_twelve,	848		 
.equ		_vctot,		864
.equ		_vnbtot,	880
.equ		_fixO,		896
.equ		_fiyO,		912
.equ		_fizO,		928
.equ		_fixH1,		944
.equ		_fiyH1,		960
.equ		_fizH1,		976
.equ		_fixH2,		992
.equ		_fiyH2,		1008
.equ		_fizH2,		1024
.equ		_fjxO,		1040
.equ		_fjyO,		1056
.equ		_fjzO,		1072
.equ		_fjxH1,		1088
.equ		_fjyH1,		1104
.equ		_fjzH1,		1120
.equ		_fjxH2,		1136
.equ		_fjyH2,		1152
.equ		_fjzH2,		1168
.equ		_half,		1184
.equ		_three,		1200
.equ		_rsqOO,		1216
.equ		_rsqOH1,	1232
.equ		_rsqOH2,	1248
.equ		_rsqH1O,	1264
.equ		_rsqH1H1,	1280
.equ		_rsqH1H2,	1296
.equ		_rsqH2O,	1312
.equ		_rsqH2H1,	1328
.equ		_rsqH2H2,	1344
.equ		_rinvOO,	1360
.equ		_rinvOH1,	1376
.equ		_rinvOH2,	1392
.equ		_rinvH1O,	1408
.equ		_rinvH1H1,	1424
.equ		_rinvH1H2,	1440
.equ		_rinvH2O,	1456
.equ		_rinvH2H1,	1472
.equ		_rinvH2H2,	1488
.equ		_fstmp,		1504	
.equ		_is3,		1520
.equ		_ii3,		1524
.equ		_innerjjnr,	1528
.equ		_innerk,	1532
.equ		_salign,	1536							
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 1540		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_two]
	movups xmm2, [sse_three]
	movups xmm3, [sse_six]
	movups xmm4, [sse_twelve]
	movss xmm5, [ebp + _tabscale]
	movaps [esp + _half],  xmm0
	movaps [esp + _two],  xmm1
	movaps [esp + _three], xmm2
	movaps [esp + _six], xmm3
	movaps [esp + _twelve], xmm4
	shufps xmm5, xmm5, 0
	movaps [esp + _tsc],  xmm5

	/* assume we have at least one i particle - start directly */
	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	movss xmm4, xmm3	
	movss xmm5, [edx + ebx*4 + 4]	
	movss xmm6, [ebp + _facel]
	mulss  xmm3, xmm3
	mulss  xmm4, xmm5
	mulss  xmm5, xmm5
	mulss  xmm3, xmm6
	mulss  xmm4, xmm6
	mulss  xmm5, xmm6
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _qqOO], xmm3
	movaps [esp + _qqOH], xmm4
	movaps [esp + _qqHH], xmm5
		
	xorps xmm0, xmm0
	mov   edx, [ebp + _type]
	mov   ecx, [edx + ebx*4]
	shl   ecx, 1
	mov   edx, ecx
	imul  ecx, [ebp + _ntype]      /* ecx = ntia = 2*ntype*type[ii0] */
	add   edx, ecx
	mov   eax, [ebp + _nbfp]
	movlps xmm0, [eax + edx*4] 
	movaps xmm1, xmm0
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0b01010101
	movaps [esp + _c6], xmm0
	movaps [esp + _c12], xmm1

.i3130_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx	
	
	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2
	addss xmm3, [eax + ebx*4]
	addss xmm4, [eax + ebx*4 + 4]
	addss xmm5, [eax + ebx*4 + 8]		
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixO], xmm3
	movaps [esp + _iyO], xmm4
	movaps [esp + _izO], xmm5

	movss xmm3, xmm0
	movss xmm4, xmm1
	movss xmm5, xmm2
	addss xmm0, [eax + ebx*4 + 12]
	addss xmm1, [eax + ebx*4 + 16]
	addss xmm2, [eax + ebx*4 + 20]		
	addss xmm3, [eax + ebx*4 + 24]
	addss xmm4, [eax + ebx*4 + 28]
	addss xmm5, [eax + ebx*4 + 32]		

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixH1], xmm0
	movaps [esp + _iyH1], xmm1
	movaps [esp + _izH1], xmm2
	movaps [esp + _ixH2], xmm3
	movaps [esp + _iyH2], xmm4
	movaps [esp + _izH2], xmm5

	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _vnbtot], xmm4
	movaps [esp + _fixO], xmm4
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm4
	movaps [esp + _fixH1], xmm4
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm4
	movaps [esp + _fixH2], xmm4
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i3130_unroll_loop
	jmp   .i3130_single_check
.i3130_unroll_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */

	mov   eax, [edx]	
	mov   ebx, [edx + 4] 
	mov   ecx, [edx + 8]
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	
	
	/* move j coordinates to local temp variables */
	movlps xmm2, [esi + eax*4]
	movlps xmm3, [esi + eax*4 + 12]
	movlps xmm4, [esi + eax*4 + 24]

	movlps xmm5, [esi + ebx*4]
	movlps xmm6, [esi + ebx*4 + 12]
	movlps xmm7, [esi + ebx*4 + 24]

	movhps xmm2, [esi + ecx*4]
	movhps xmm3, [esi + ecx*4 + 12]
	movhps xmm4, [esi + ecx*4 + 24]

	movhps xmm5, [esi + edx*4]
	movhps xmm6, [esi + edx*4 + 12]
	movhps xmm7, [esi + edx*4 + 24]

	/* current state: */	
	/* xmm2= jxOa  jyOa  jxOc  jyOc */
	/* xmm3= jxH1a jyH1a jxH1c jyH1c */
	/* xmm4= jxH2a jyH2a jxH2c jyH2c */
	/* xmm5= jxOb  jyOb  jxOd  jyOd */
	/* xmm6= jxH1b jyH1b jxH1d jyH1d */
	/* xmm7= jxH2b jyH2b jxH2d jyH2d */
	
	movaps xmm0, xmm2
	movaps xmm1, xmm3
	unpcklps xmm0, xmm5	/* xmm0= jxOa  jxOb  jyOa  jyOb */
	unpcklps xmm1, xmm6	/* xmm1= jxH1a jxH1b jyH1a jyH1b */
	unpckhps xmm2, xmm5	/* xmm2= jxOc  jxOd  jyOc  jyOd */
	unpckhps xmm3, xmm6	/* xmm3= jxH1c jxH1d jyH1c jyH1d */
	movaps xmm5, xmm4
	movaps   xmm6, xmm0
	unpcklps xmm4, xmm7	/* xmm4= jxH2a jxH2b jyH2a jyH2b */		
	unpckhps xmm5, xmm7	/* xmm5= jxH2c jxH2d jyH2c jyH2d */
	movaps   xmm7, xmm1
	movlhps  xmm0, xmm2	/* xmm0= jxOa  jxOb  jxOc  jxOd */
	movaps [esp + _jxO], xmm0
	movhlps  xmm2, xmm6	/* xmm2= jyOa  jyOb  jyOc  jyOd */
	movaps [esp + _jyO], xmm2
	movlhps  xmm1, xmm3
	movaps [esp + _jxH1], xmm1
	movhlps  xmm3, xmm7
	movaps   xmm6, xmm4
	movaps [esp + _jyH1], xmm3
	movlhps  xmm4, xmm5
	movaps [esp + _jxH2], xmm4
	movhlps  xmm5, xmm6
	movaps [esp + _jyH2], xmm5

	movss  xmm0, [esi + eax*4 + 8]
	movss  xmm1, [esi + eax*4 + 20]
	movss  xmm2, [esi + eax*4 + 32]

	movss  xmm3, [esi + ecx*4 + 8]
	movss  xmm4, [esi + ecx*4 + 20]
	movss  xmm5, [esi + ecx*4 + 32]

	movhps xmm0, [esi + ebx*4 + 4]
	movhps xmm1, [esi + ebx*4 + 16]
	movhps xmm2, [esi + ebx*4 + 28]
	
	movhps xmm3, [esi + edx*4 + 4]
	movhps xmm4, [esi + edx*4 + 16]
	movhps xmm5, [esi + edx*4 + 28]
	
	shufps xmm0, xmm3, 0b11001100
	shufps xmm1, xmm4, 0b11001100
	shufps xmm2, xmm5, 0b11001100
	movaps [esp + _jzO],  xmm0
	movaps [esp + _jzH1],  xmm1
	movaps [esp + _jzH2],  xmm2

	movaps xmm0, [esp + _ixO]
	movaps xmm1, [esp + _iyO]
	movaps xmm2, [esp + _izO]
	movaps xmm3, [esp + _ixO]
	movaps xmm4, [esp + _iyO]
	movaps xmm5, [esp + _izO]
	subps  xmm0, [esp + _jxO]
	subps  xmm1, [esp + _jyO]
	subps  xmm2, [esp + _jzO]
	subps  xmm3, [esp + _jxH1]
	subps  xmm4, [esp + _jyH1]
	subps  xmm5, [esp + _jzH1]
	movaps [esp + _dxOO], xmm0
	movaps [esp + _dyOO], xmm1
	movaps [esp + _dzOO], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxOH1], xmm3
	movaps [esp + _dyOH1], xmm4
	movaps [esp + _dzOH1], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqOO], xmm0
	movaps [esp + _rsqOH1], xmm3

	movaps xmm0, [esp + _ixO]
	movaps xmm1, [esp + _iyO]
	movaps xmm2, [esp + _izO]
	movaps xmm3, [esp + _ixH1]
	movaps xmm4, [esp + _iyH1]
	movaps xmm5, [esp + _izH1]
	subps  xmm0, [esp + _jxH2]
	subps  xmm1, [esp + _jyH2]
	subps  xmm2, [esp + _jzH2]
	subps  xmm3, [esp + _jxO]
	subps  xmm4, [esp + _jyO]
	subps  xmm5, [esp + _jzO]
	movaps [esp + _dxOH2], xmm0
	movaps [esp + _dyOH2], xmm1
	movaps [esp + _dzOH2], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH1O], xmm3
	movaps [esp + _dyH1O], xmm4
	movaps [esp + _dzH1O], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqOH2], xmm0
	movaps [esp + _rsqH1O], xmm3

	movaps xmm0, [esp + _ixH1]
	movaps xmm1, [esp + _iyH1]
	movaps xmm2, [esp + _izH1]
	movaps xmm3, [esp + _ixH1]
	movaps xmm4, [esp + _iyH1]
	movaps xmm5, [esp + _izH1]
	subps  xmm0, [esp + _jxH1]
	subps  xmm1, [esp + _jyH1]
	subps  xmm2, [esp + _jzH1]
	subps  xmm3, [esp + _jxH2]
	subps  xmm4, [esp + _jyH2]
	subps  xmm5, [esp + _jzH2]
	movaps [esp + _dxH1H1], xmm0
	movaps [esp + _dyH1H1], xmm1
	movaps [esp + _dzH1H1], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH1H2], xmm3
	movaps [esp + _dyH1H2], xmm4
	movaps [esp + _dzH1H2], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqH1H1], xmm0
	movaps [esp + _rsqH1H2], xmm3

	movaps xmm0, [esp + _ixH2]
	movaps xmm1, [esp + _iyH2]
	movaps xmm2, [esp + _izH2]
	movaps xmm3, [esp + _ixH2]
	movaps xmm4, [esp + _iyH2]
	movaps xmm5, [esp + _izH2]
	subps  xmm0, [esp + _jxO]
	subps  xmm1, [esp + _jyO]
	subps  xmm2, [esp + _jzO]
	subps  xmm3, [esp + _jxH1]
	subps  xmm4, [esp + _jyH1]
	subps  xmm5, [esp + _jzH1]
	movaps [esp + _dxH2O], xmm0
	movaps [esp + _dyH2O], xmm1
	movaps [esp + _dzH2O], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH2H1], xmm3
	movaps [esp + _dyH2H1], xmm4
	movaps [esp + _dzH2H1], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm4, xmm3
	addps  xmm4, xmm5
	movaps [esp + _rsqH2O], xmm0
	movaps [esp + _rsqH2H1], xmm4

	movaps xmm0, [esp + _ixH2]
	movaps xmm1, [esp + _iyH2]
	movaps xmm2, [esp + _izH2]
	subps  xmm0, [esp + _jxH2]
	subps  xmm1, [esp + _jyH2]
	subps  xmm2, [esp + _jzH2]
	movaps [esp + _dxH2H2], xmm0
	movaps [esp + _dyH2H2], xmm1
	movaps [esp + _dzH2H2], xmm2
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2
	movaps [esp + _rsqH2H2], xmm0
		
	/* start doing invsqrt use rsq values in xmm0, xmm4 */
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] /* rinvH2H2 */
	mulps   xmm7, [esp + _half] /* rinvH2H1 */
	movaps  [esp + _rinvH2H2], xmm3
	movaps  [esp + _rinvH2H1], xmm7
		
	rsqrtps xmm1, [esp + _rsqOO]
	rsqrtps xmm5, [esp + _rsqOH1]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqOO]
	mulps   xmm5, [esp + _rsqOH1]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvOO], xmm3
	movaps  [esp + _rinvOH1], xmm7
	
	rsqrtps xmm1, [esp + _rsqOH2]
	rsqrtps xmm5, [esp + _rsqH1O]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqOH2]
	mulps   xmm5, [esp + _rsqH1O]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvOH2], xmm3
	movaps  [esp + _rinvH1O], xmm7
	
	rsqrtps xmm1, [esp + _rsqH1H1]
	rsqrtps xmm5, [esp + _rsqH1H2]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqH1H1]
	mulps   xmm5, [esp + _rsqH1H2]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvH1H1], xmm3
	movaps  [esp + _rinvH1H2], xmm7
	
	rsqrtps xmm1, [esp + _rsqH2O]
	movaps  xmm2, xmm1
	mulps   xmm1, xmm1
	movaps  xmm3, [esp + _three]
	mulps   xmm1, [esp + _rsqH2O]
	subps   xmm3, xmm1
	mulps   xmm3, xmm2
	mulps   xmm3, [esp + _half] 
	movaps  [esp + _rinvH2O], xmm3

	/* start with OO interaction */
	movaps xmm0, [esp + _rinvOO]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqOO] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]
		
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
	pslld   mm6, 2
	pslld   mm7, 2
	
        movd mm0, eax
        movd mm1, ebx
        movd mm2, ecx
        movd mm3, edx

        mov  esi, [ebp + _VFtab]
        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqOO]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */
        /* increment vcoul - then we can get rid of mm5 */
        /* update vctot */
        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	mulps  xmm3, [esp + _tsc]
	
	/* start doing lj */
	movaps xmm2, xmm0
	mulps  xmm2, xmm2
	movaps xmm1, xmm2
	mulps  xmm1, xmm2
	mulps  xmm1, xmm2	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=rinvtwelve */
	mulps  xmm1, [esp + _c6]
	mulps  xmm2, [esp + _c12]
	movaps xmm4, xmm2
	subps  xmm4, xmm1
	addps  xmm4, [esp + _vnbtot]
	mulps  xmm1, [esp + _six]
	mulps  xmm2, [esp + _twelve]
	movaps [esp + _vnbtot], xmm4
	subps  xmm2, xmm1
	mulps  xmm2, xmm0

	subps  xmm2, xmm3
	mulps  xmm0, xmm2
	
	movaps xmm1, xmm0
	movaps xmm2, xmm0		

	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOO]
	mulps xmm1, [esp + _dyOO]
	mulps xmm2, [esp + _dzOO]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* O-H1 interaction */
	movaps xmm0, [esp + _rinvOH1]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqOH1] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */

	pslld   mm6, 2
	pslld   mm7, 2
	
        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqOH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOH1]
	mulps xmm1, [esp + _dyOH1]
	mulps xmm2, [esp + _dzOH1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* O-H2 interaction */ 
	movaps xmm0, [esp + _rinvOH2]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqOH2] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */

	pslld   mm6, 2
	pslld   mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqOH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOH2]
	mulps xmm1, [esp + _dyOH2]
	mulps xmm2, [esp + _dzOH2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* H1-O interaction */
	movaps xmm0, [esp + _rinvH1O]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH1O] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */

	pslld   mm6, 2
	pslld   mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqOH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [esp + _fjxO]
	movaps xmm4, [esp + _fjyO]
	movaps xmm5, [esp + _fjzO]
	mulps xmm0, [esp + _dxH1O]
	mulps xmm1, [esp + _dyH1O]
	mulps xmm2, [esp + _dzH1O]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H1-H1 interaction */
	movaps xmm0, [esp + _rinvH1H1]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH1H1] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */

	pslld   mm6, 2
	pslld   mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqHH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [esp + _fjxH1]
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	mulps xmm0, [esp + _dxH1H1]
	mulps xmm1, [esp + _dyH1H1]
	mulps xmm2, [esp + _dzH1H1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H1-H2 interaction */
	movaps xmm0, [esp + _rinvH1H2]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH1H2] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */

	pslld   mm6, 2
	pslld   mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqHH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [esp + _fjxH2]
	movaps xmm4, [esp + _fjyH2]
	movaps xmm5, [esp + _fjzH2]
	mulps xmm0, [esp + _dxH1H2]
	mulps xmm1, [esp + _dyH1H2]
	mulps xmm2, [esp + _dzH1H2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H2-O interaction */
	movaps xmm0, [esp + _rinvH2O]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH2O] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */

	pslld   mm6, 2
	pslld   mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqOH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1

	movaps xmm3, [esp + _fjxO]
	movaps xmm4, [esp + _fjyO]
	movaps xmm5, [esp + _fjzO]
	mulps xmm0, [esp + _dxH2O]
	mulps xmm1, [esp + _dyH2O]
	mulps xmm2, [esp + _dzH2O]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	/* H2-H1 interaction */
	movaps xmm0, [esp + _rinvH2H1]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH2H1] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */

	pslld   mm6, 2
	pslld   mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqHH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [esp + _fjxH1]
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	mulps xmm0, [esp + _dxH2H1]
	mulps xmm1, [esp + _dyH2H1]
	mulps xmm2, [esp + _dzH2H1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	/* H2-H2 interaction */
	movaps xmm0, [esp + _rinvH2H2]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH2H2] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */

	pslld   mm6, 2
	pslld   mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqHH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [esp + _fjxH2]
	movaps xmm4, [esp + _fjyH2]
	movaps xmm5, [esp + _fjzH2]
	mulps xmm0, [esp + _dxH2H2]
	mulps xmm1, [esp + _dyH2H2]
	mulps xmm2, [esp + _dzH2H2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	mov edi, [ebp + _faction]

	movd eax, mm0
	movd ebx, mm1
	movd ecx, mm2
	movd edx, mm3
	
	/* Did all interactions - now update j forces */
	/* 4 j waters with three atoms each - first do a & b j particles */
	movaps xmm0, [esp + _fjxO] /* xmm0= fjxOa  fjxOb  fjxOc  fjxOd */
	movaps xmm1, [esp + _fjyO] /* xmm1= fjyOa  fjyOb  fjyOc  fjyOd */ 
	unpcklps xmm0, xmm1    	   /* xmm0= fjxOa  fjyOa  fjxOb  fjyOb */
	movaps xmm1, [esp + _fjzO]
	movaps xmm2, [esp + _fjxH1]
	movhlps  xmm3, xmm0	   /* xmm3= fjxOb  fjyOb */ 
	unpcklps xmm1, xmm2	   /* xmm1= fjzOa  fjxH1a fjzOb  fjxH1b */
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	unpcklps xmm4, xmm5	   /* xmm4= fjyH1a fjzH1a fjyH1b fjzH1b */
	movaps xmm5, [esp + _fjxH2]
	movaps xmm6, [esp + _fjyH2]
	movhlps  xmm7, xmm4	   /* xmm7= fjyH1b fjzH1b */
	unpcklps xmm5, xmm6	   /* xmm5= fjxH2a fjyH2a fjxH2b fjyH2b */
	movlhps  xmm0, xmm1    	   /* xmm0= fjxOa  fjyOa  fjzOa  fjxH1a */
	shufps   xmm3, xmm1, 0b11100100
                                   /* xmm3= fjxOb  fjyOb  fjzOb  fjxH1b */
	movlhps  xmm4, xmm5   	   /* xmm4= fjyH1a fjzH1a fjxH2a fjyH2a */
	shufps   xmm7, xmm5, 0b11100100
                                   /* xmm7= fjyH1b fjzH1b fjxH2b fjyH2b */
	movups   xmm1, [edi + eax*4]
	movups   xmm2, [edi + eax*4 + 16]
	movups   xmm5, [edi + ebx*4]
	movups   xmm6, [edi + ebx*4 + 16]
	addps    xmm1, xmm0
	addps    xmm2, xmm4
	addps    xmm5, xmm3
	addps    xmm6, xmm7
	movss    xmm0, [edi + eax*4 + 32]
	movss    xmm3, [edi + ebx*4 + 32]
	
	movaps   xmm4, [esp + _fjzH2]
	movaps   xmm7, xmm4
	shufps   xmm7, xmm7, 1
	
	movups   [edi + eax*4],     xmm1
	movups   [edi + eax*4 + 16],xmm2
	movups   [edi + ebx*4],     xmm5
	movups   [edi + ebx*4 + 16],xmm6	
	addss    xmm0, xmm4
	addss    xmm3, xmm7
	movss    [edi + eax*4 + 32], xmm0
	movss    [edi + ebx*4 + 32], xmm3	

	/* then do the second pair (c & d) */
	movaps xmm0, [esp + _fjxO] /* xmm0= fjxOa  fjxOb  fjxOc  fjxOd */
	movaps xmm1, [esp + _fjyO] /* xmm1= fjyOa  fjyOb  fjyOc  fjyOd */ 
	unpckhps xmm0, xmm1	   /* xmm0= fjxOc  fjyOc  fjxOd  fjyOd */
	movaps xmm1, [esp + _fjzO]
	movaps xmm2, [esp + _fjxH1]
	movhlps  xmm3, xmm0	   /* xmm3= fjxOd  fjyOd */ 
	unpckhps xmm1, xmm2	   /* xmm1= fjzOc  fjxH1c fjzOd  fjxH1d */
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	unpckhps xmm4, xmm5	   /* xmm4= fjyH1c fjzH1c fjyH1d fjzH1d	*/
	movaps xmm5, [esp + _fjxH2]
	movaps xmm6, [esp + _fjyH2]
	movhlps  xmm7, xmm4	   /* xmm7= fjyH1d fjzH1d */	 
	unpckhps xmm5, xmm6	   /* xmm5= fjxH2c fjyH2c fjxH2d fjyH2d */
	movlhps  xmm0, xmm1	   /* xmm0= fjxOc  fjyOc  fjzOc  fjxH1c */
	shufps   xmm3, xmm1, 0b11100100
                                   /* xmm3= fjxOd  fjyOd  fjzOd  fjxH1d */
	movlhps  xmm4, xmm5	   /* xmm4= fjyH1c fjzH1c fjxH2c fjyH2c  */
	shufps   xmm7, xmm5, 0b11100100
                                   /* xmm7= fjyH1d fjzH1d fjxH2d fjyH2d */
	movups   xmm1, [edi + ecx*4]
	movups   xmm2, [edi + ecx*4 + 16]
	movups   xmm5, [edi + edx*4]
	movups   xmm6, [edi + edx*4 + 16]
	addps    xmm1, xmm0
	addps    xmm2, xmm4
	addps    xmm5, xmm3
	addps    xmm6, xmm7
	movss    xmm0, [edi + ecx*4 + 32]
	movss    xmm3, [edi + edx*4 + 32]
	
	movaps   xmm4, [esp + _fjzH2]
	movaps   xmm7, xmm4
	shufps   xmm4, xmm4, 0b10
	shufps   xmm7, xmm7, 0b11
	movups   [edi + ecx*4],     xmm1
	movups   [edi + ecx*4 + 16],xmm2
	movups   [edi + edx*4],     xmm5
	movups   [edi + edx*4 + 16],xmm6	
	addss    xmm0, xmm4
	addss    xmm3, xmm7
	movss    [edi + ecx*4 + 32], xmm0
	movss    [edi + edx*4 + 32], xmm3	
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i3130_single_check
	jmp   .i3130_unroll_loop
.i3130_single_check:
	add   [esp + _innerk],  4
	jnz   .i3130_single_loop
	jmp   .i3130_updateouterdata
.i3130_single_loop:
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	add   [esp + _innerjjnr],  4	

	mov esi, [ebp + _pos]
	lea   eax, [eax + eax*2]  

	/* fetch j coordinates */
	xorps xmm3, xmm3
	xorps xmm4, xmm4
	xorps xmm5, xmm5
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + eax*4 + 4]
	movss xmm5, [esi + eax*4 + 8]

	movlps xmm6, [esi + eax*4 + 12]
	movhps xmm6, [esi + eax*4 + 24]	/* xmm6=jxH1 jyH1 jxH2 jyH2 */
	/* fetch both z coords in one go, to positions 0 and 3 in xmm7 */
	movups xmm7, [esi + eax*4 + 20] /* xmm7=jzH1 jxH2 jyH2 jzH2 */
	shufps xmm6, xmm6, 0b11011000    /* xmm6=jxH1 jxH2 jyH1 jyH2 */
	movlhps xmm3, xmm6      	/* xmm3= jxO   0  jxH1 jxH2 */
	movaps  xmm0, [esp + _ixO]     
	movaps  xmm1, [esp + _iyO]
	movaps  xmm2, [esp + _izO]	
	shufps  xmm4, xmm6, 0b11100100 /* xmm4= jyO   0   jyH1 jyH2 */
	shufps xmm5, xmm7, 0b11000100  /* xmm5= jzO   0   jzH1 jzH2 */
	/* store all j coordinates in jO */ 
	movaps [esp + _jxO], xmm3
	movaps [esp + _jyO], xmm4
	movaps [esp + _jzO], xmm5
	subps  xmm0, xmm3
	subps  xmm1, xmm4
	subps  xmm2, xmm5
	movaps [esp + _dxOO], xmm0
	movaps [esp + _dyOO], xmm1
	movaps [esp + _dzOO], xmm2
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2	/* have rsq in xmm0 */
	
	/* do invsqrt */
	rsqrtps xmm1, xmm0
	movaps  xmm2, xmm1	
	mulps   xmm1, xmm1
	movaps  xmm3, [esp + _three]
	mulps   xmm1, xmm0
	subps   xmm3, xmm1
	mulps   xmm3, xmm2							
	mulps   xmm3, [esp + _half] /* rinv iO - j water */

	movaps  xmm1, xmm3
	mulps   xmm1, xmm0	/* xmm1=r */
	movaps  xmm0, xmm3	/* xmm0=rinv */
	mulps  xmm1, [esp + _tsc]
	
	movhlps xmm2, xmm1	
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
	pslld   mm6, 2
	pslld   mm7, 2
	
        movd ebx, mm6
        movd ecx, mm7
        psrlq mm7, 32
        movd edx, mm7		/* table indices in ebx,ecx,edx */

	mov esi, [ebp + _VFtab]
	
        movlps xmm5, [esi + ebx*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */
        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + ebx*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */

	xorps  xmm3, xmm3
	/* fetch charges to xmm3 (temporary) */
	movss   xmm3, [esp + _qqOO]
	movhps  xmm3, [esp + _qqOH]
		
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point xmm5 contains vcoul and xmm3 fijC */
	
        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5

	mulps  xmm3, [esp + _tsc]
	
	/* start doing lj */
	xorps  xmm2, xmm2
	movss  xmm2, xmm0
	mulss  xmm2, xmm2
	movaps xmm1, xmm2
	mulss  xmm1, xmm2
	mulss  xmm1, xmm2	/* xmm1=rinvsix */
	movaps xmm2, xmm1
	mulss  xmm2, xmm2	/* xmm2=rinvtwelve */
	mulss  xmm1, [esp + _c6]
	mulss  xmm2, [esp + _c12]
	movaps xmm4, xmm2
	subss  xmm4, xmm1
	addps  xmm4, [esp + _vnbtot]
	mulss  xmm1, [esp + _six]
	mulss  xmm2, [esp + _twelve]
	movaps [esp + _vnbtot], xmm4
	subss  xmm2, xmm1
	mulss  xmm2, xmm0

	subps  xmm2, xmm3
	mulps  xmm0, xmm2
	
	movaps xmm1, xmm0
	movaps xmm2, xmm0			

	mulps   xmm0, [esp + _dxOO]
	mulps   xmm1, [esp + _dyOO]
	mulps   xmm2, [esp + _dzOO]
	/* initial update for j forces */
	xorps   xmm3, xmm3
	xorps   xmm4, xmm4
	xorps   xmm5, xmm5
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixO]
	addps   xmm1, [esp + _fiyO]
	addps   xmm2, [esp + _fizO]
	movaps  [esp + _fixO], xmm0
	movaps  [esp + _fiyO], xmm1
	movaps  [esp + _fizO], xmm2

	
	/* done with i O Now do i H1 & H2 simultaneously first get i particle coords: */
	movaps  xmm0, [esp + _ixH1]
	movaps  xmm1, [esp + _iyH1]
	movaps  xmm2, [esp + _izH1]	
	movaps  xmm3, [esp + _ixH2] 
	movaps  xmm4, [esp + _iyH2] 
	movaps  xmm5, [esp + _izH2] 
	subps   xmm0, [esp + _jxO]
	subps   xmm1, [esp + _jyO]
	subps   xmm2, [esp + _jzO]
	subps   xmm3, [esp + _jxO]
	subps   xmm4, [esp + _jyO]
	subps   xmm5, [esp + _jzO]
	movaps [esp + _dxH1O], xmm0
	movaps [esp + _dyH1O], xmm1
	movaps [esp + _dzH1O], xmm2
	movaps [esp + _dxH2O], xmm3
	movaps [esp + _dyH2O], xmm4
	movaps [esp + _dzH2O], xmm5
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	mulps xmm3, xmm3
	mulps xmm4, xmm4
	mulps xmm5, xmm5
	addps xmm0, xmm1
	addps xmm4, xmm3
	addps xmm0, xmm2	/* have rsqH1 in xmm0 */
	addps xmm4, xmm5	/* have rsqH2 in xmm4 */

	/* start with H1, save H2 data */
	movaps [esp + _rsqH2O], xmm4
	
	/* do invsqrt */
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] /* rinv H1 - j water */
	mulps   xmm7, [esp + _half] /* rinv H2 - j water */ 

	/* start with H1, save H2 data */
	movaps [esp + _rinvH2O], xmm7

	movaps xmm1, xmm3
	mulps  xmm1, xmm0	/* xmm1=r */
	movaps xmm0, xmm3	/* xmm0=rinv */
	mulps  xmm1, [esp + _tsc]
	
	movhlps xmm2, xmm1	
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
	pslld   mm6, 2
	pslld   mm7, 2

        movd ebx, mm6
        movd ecx, mm7
        psrlq mm7, 32
        movd edx, mm7		/* table indices in ebx,ecx,edx */

        movlps xmm5, [esi + ebx*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */
        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + ebx*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */

	xorps  xmm3, xmm3
	/* fetch charges to xmm3 (temporary) */
	movss   xmm3, [esp + _qqOH]
	movhps  xmm3, [esp + _qqHH]
		
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point xmm5 contains vcoul and xmm3 fijC */
        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5	

        xorps  xmm1, xmm1

        mulps xmm3, [esp + _tsc]
        mulps xmm3, xmm0
        subps  xmm1, xmm3
	
	movaps  xmm0, xmm1
	movaps  xmm2, xmm1
	mulps   xmm0, [esp + _dxH1O]
	mulps   xmm1, [esp + _dyH1O]
	mulps   xmm2, [esp + _dzH1O]
	/* update forces H1 - j water */
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixH1]
	addps   xmm1, [esp + _fiyH1]
	addps   xmm2, [esp + _fizH1]
	movaps  [esp + _fixH1], xmm0
	movaps  [esp + _fiyH1], xmm1
	movaps  [esp + _fizH1], xmm2
	/* do table for H2 - j water interaction */
	movaps xmm0, [esp + _rinvH2O]
	movaps xmm1, [esp + _rsqH2O]
	mulps  xmm1, xmm0	/* xmm0=rinv, xmm1=r */
	mulps  xmm1, [esp + _tsc]
	
	movhlps xmm2, xmm1	
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
	pslld   mm6, 2
	pslld   mm7, 2

        movd ebx, mm6
        movd ecx, mm7
        psrlq mm7, 32
        movd edx, mm7		/* table indices in ebx,ecx,edx */

        movlps xmm5, [esi + ebx*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */
        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + ebx*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */

	xorps  xmm3, xmm3
	/* fetch charges to xmm3 (temporary) */
	movss   xmm3, [esp + _qqOH]
	movhps  xmm3, [esp + _qqHH]
		
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point xmm5 contains vcoul and xmm3 fijC */
        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5	

        xorps  xmm1, xmm1

        mulps xmm3, [esp + _tsc]
        mulps xmm3, xmm0
        subps  xmm1, xmm3
	
	movaps  xmm0, xmm1
	movaps  xmm2, xmm1
	
	mulps   xmm0, [esp + _dxH2O]
	mulps   xmm1, [esp + _dyH2O]
	mulps   xmm2, [esp + _dzH2O]
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	mov     esi, [ebp + _faction]
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixH2]
	addps   xmm1, [esp + _fiyH2]
	addps   xmm2, [esp + _fizH2]
	movaps  [esp + _fixH2], xmm0
	movaps  [esp + _fiyH2], xmm1
	movaps  [esp + _fizH2], xmm2

	/* update j water forces from local variables */
	movlps  xmm0, [esi + eax*4]
	movlps  xmm1, [esi + eax*4 + 12]
	movhps  xmm1, [esi + eax*4 + 24]
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	movaps  xmm6, xmm5
	movaps  xmm7, xmm5
	shufps  xmm6, xmm6, 0b10
	shufps  xmm7, xmm7, 0b11
	addss   xmm5, [esi + eax*4 + 8]
	addss   xmm6, [esi + eax*4 + 20]
	addss   xmm7, [esi + eax*4 + 32]
	movss   [esi + eax*4 + 8], xmm5
	movss   [esi + eax*4 + 20], xmm6
	movss   [esi + eax*4 + 32], xmm7
	movaps   xmm5, xmm3
	unpcklps xmm3, xmm4
	unpckhps xmm5, xmm4
	addps    xmm0, xmm3
	addps    xmm1, xmm5
	movlps  [esi + eax*4], xmm0 
	movlps  [esi + eax*4 + 12], xmm1 
	movhps  [esi + eax*4 + 24], xmm1 
	
	dec dword ptr [esp + _innerk]
	jz    .i3130_updateouterdata
	jmp   .i3130_single_loop
.i3130_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate  Oi forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixO]
	movaps xmm1, [esp + _fiyO] 
	movaps xmm2, [esp + _fizO]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	movaps xmm6, xmm0
	movss xmm7, xmm2
	movlhps xmm6, xmm1
	shufps  xmm6, xmm6, 0b1000	

	/* accumulate H1i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH1]
	movaps xmm1, [esp + _fiyH1]
	movaps xmm2, [esp + _fizH1]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 12]
	movss  xmm4, [edi + ecx*4 + 16]
	movss  xmm5, [edi + ecx*4 + 20]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 12], xmm3
	movss  [edi + ecx*4 + 16], xmm4
	movss  [edi + ecx*4 + 20], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* accumulate H2i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH2]
	movaps xmm1, [esp + _fiyH2]
	movaps xmm2, [esp + _fizH2]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 24]
	movss  xmm4, [edi + ecx*4 + 28]
	movss  xmm5, [edi + ecx*4 + 32]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 24], xmm3
	movss  [edi + ecx*4 + 28], xmm4
	movss  [edi + ecx*4 + 32], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* increment fshift force */ 
	movlps  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 8]
	addps  xmm3, xmm6
	addss  xmm4, xmm7
	movlps  [esi + edx*4],    xmm3
	movss  [esi + edx*4 + 8], xmm4

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i3130_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i3130_outer
.i3130_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 1540
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret

	


.globl inl3300_sse
	.type inl3300_sse,@function
inl3300_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_type,		60
.equ		_ntype,		64
.equ		_nbfp,		68	
.equ		_Vnb,		72
.equ		_tabscale,	76
.equ		_VFtab,		80
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ix,		0
.equ		_iy,		16
.equ		_iz,		32
.equ		_iq,		48
.equ		_dx,		64
.equ		_dy,		80
.equ		_dz,		96
.equ		_two,		112
.equ		_tsc,		128
.equ		_qq,		144	
.equ		_c6,		160
.equ		_c12,		176
.equ		_fscal,		192
.equ		_vctot,		208
.equ		_vnbtot,	224
.equ		_fix,		240
.equ		_fiy,		256
.equ		_fiz,		272
.equ		_half,		288
.equ		_three,		304
.equ		_is3,		320
.equ		_ii3,		324
.equ		_ntia,		328	
.equ		_innerjjnr,	332
.equ		_innerk,	336
.equ		_salign,	340								
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 344		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_two]
	movups xmm2, [sse_three]
	movss xmm3, [ebp + _tabscale]
	movaps [esp + _half],  xmm0
	movaps [esp + _two], xmm1
	movaps [esp + _three],  xmm2
	shufps xmm3, xmm3, 0
	movaps [esp + _tsc], xmm3

	/* assume we have at least one i particle - start directly */	
.i3300_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	mulss xmm3, [ebp + _facel]
	shufps xmm3, xmm3, 0

        mov   edx, [ebp + _type] 
        mov   edx, [edx + ebx*4]
        imul  edx, [ebp + _ntype]
        shl   edx, 1
        mov   [esp + _ntia], edx
		
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]

	movaps [esp + _iq], xmm3
	
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   [esp + _ii3], ebx
	
	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _vnbtot], xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i3300_unroll_loop
	jmp   .i3300_finish_inner
.i3300_unroll_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	movaps xmm2, [esp + _iq]
	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	mulps  xmm3, xmm2
	movd  mm2, ecx
	movd  mm3, edx

	movaps [esp + _qq], xmm3
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	movhlps xmm5, xmm4
	cvttps2pi mm6, xmm4
	cvttps2pi mm7, xmm5	/* mm6/mm7 contain lu indices */
	cvtpi2ps xmm6, mm6
	cvtpi2ps xmm5, mm7
	movlhps xmm6, xmm5
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */
	pslld mm6, 2
	pslld mm7, 2

	movd mm0, eax	
	movd mm1, ebx
	movd mm2, ecx
	movd mm3, edx

	mov  esi, [ebp + _VFtab]
	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	lea   ecx, [ecx + ecx*2]
	lea   edx, [edx + edx*2]
		
	movlps xmm5, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm5, [esi + ebx*4]
	movhps xmm7, [esi + edx*4] /* got half coulomb table */

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101

	movlps xmm7, [esi + eax*4 + 8]
	movlps xmm3, [esi + ecx*4 + 8]
	movhps xmm7, [esi + ebx*4 + 8]
	movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* coulomb table ready, in xmm4-xmm7 */ 	
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addps  xmm5, [esp + _vctot]
	movaps [esp + _vctot], xmm5 

	/* put scalar force on stack temporarily */
	movaps [esp + _fscal], xmm3

	/* dispersion */
	movlps xmm5, [esi + eax*4 + 16]
	movlps xmm7, [esi + ecx*4 + 16]
	movhps xmm5, [esi + ebx*4 + 16]
	movhps xmm7, [esi + edx*4 + 16] /* got half dispersion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101
	
	movlps xmm7, [esi + eax*4 + 24]
	movlps xmm3, [esi + ecx*4 + 24]
	movhps xmm7, [esi + ebx*4 + 24]
	movhps xmm3, [esi + edx*4 + 24] /* other half of dispersion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* dispersion table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */
	addps  xmm7, [esp + _fscal] /* add to fscal */

	/* put scalar force on stack Update vnbtot directly */
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movaps [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm5, [esi + eax*4 + 32]
	movlps xmm7, [esi + ecx*4 + 32]
	movhps xmm5, [esi + ebx*4 + 32]
	movhps xmm7, [esi + edx*4 + 32] /* got half repulsion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101

	movlps xmm7, [esi + eax*4 + 40]
	movlps xmm3, [esi + ecx*4 + 40]
	movhps xmm7, [esi + ebx*4 + 40]
	movhps xmm3, [esi + edx*4 + 40] /* other half of repulsion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
 	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 /* fijR */
	mulps  xmm5, xmm4 /* vnb12 */
	addps  xmm7, [esp + _fscal] 
	
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movd eax, mm0	
	movd ebx, mm1
	movd ecx, mm2
	movd edx, mm3

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i3300_finish_inner
	jmp   .i3300_unroll_loop
.i3300_finish_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i3300_dopair
	jmp   .i3300_checksingle
.i3300_dopair:	
	mov esi, [ebp + _charge]

        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8	
	xorps xmm7, xmm7
	movss xmm3, [esi + eax*4]		
	movss xmm6, [esi + ebx*4]
	shufps xmm3, xmm6, 0 
	shufps xmm3, xmm3, 0b00001000 /* xmm3(0,1) has the charges */

	mulps  xmm3, [esp + _iq]
	movlhps xmm3, xmm7
	movaps [esp + _qq], xmm3

	mov esi, [ebp + _type]
	mov   ecx, eax
	mov   edx, ebx
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add ecx, edi
	add edx, edi
	movlps xmm6, [esi + ecx*4]
	movhps xmm6, [esi + edx*4]
	mov edi, [ebp + _pos]	
	
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b1000 	
	shufps xmm6, xmm6, 0b1101
	movlhps xmm4, xmm7
	movlhps xmm6, xmm7
	
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
			
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ecx, mm6
	psrlq mm6, 32
	movd edx, mm6
	lea   ecx, [ecx + ecx*2]
	lea   edx, [edx + edx*2]

	movlps xmm5, [esi + ecx*4]
	movhps xmm5, [esi + edx*4] /* got half coulomb table */
	movaps xmm4, xmm5
	shufps xmm4, xmm4, 0b10001000
	shufps xmm5, xmm7, 0b11011101
	
	movlps xmm7, [esi + ecx*4 + 8]
	movhps xmm7, [esi + edx*4 + 8]
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 0b10001000
	shufps xmm7, xmm7, 0b11011101
	/* table ready in xmm4-xmm7 */

	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addps  xmm5, [esp + _vctot]
	movaps [esp + _vctot], xmm5 

	/* put scalar force on stack temporarily */
	movaps [esp + _fscal], xmm3

	/* dispersion */
	movlps xmm5, [esi + ecx*4 + 16]
	movhps xmm5, [esi + edx*4 + 16]/* got half dispersion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm4, 0b10001000
	shufps xmm5, xmm5, 0b11011101
	
	movlps xmm7, [esi + ecx*4 + 24]
	movhps xmm7, [esi + edx*4 + 24] /* other half of dispersion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 0b10001000
	shufps xmm7, xmm7, 0b11011101
	/* dispersion table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */
	addps  xmm7, [esp + _fscal] /* add to fscal */

	/* put scalar force on stack Update vnbtot directly */
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movaps [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm5, [esi + ecx*4 + 32]
	movhps xmm5, [esi + edx*4 + 32] /* got half repulsion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101

	movlps xmm7, [esi + ecx*4 + 40]
	movhps xmm7, [esi + edx*4 + 40] /* other half of repulsion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
 	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 /* fijR */
	mulps  xmm5, xmm4 /* vnb12 */
	addps  xmm7, [esp + _fscal] 
	
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i3300_checksingle:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    .i3300_dosingle
	jmp    .i3300_updateouterdata
.i3300_dosingle:
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	xorps  xmm6, xmm6
	movss xmm6, [esi + eax*4]	/* xmm6(0) has the charge */	
	mulps  xmm6, [esp + _iq]
	movaps [esp + _qq], xmm6

	mov esi, [ebp + _type]
	mov ecx, eax
	mov ecx, [esi + ecx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1
	add ecx, [esp + _ntia]
	movlps xmm6, [esi + ecx*4]
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b11111100	
	shufps xmm6, xmm6, 0b11111101	
			
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	 
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */

	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ebx, mm6
	
	lea  ebx, [ebx + ebx*2]
						
	movlps xmm4, [esi + ebx*4]
	movlps xmm6, [esi + ebx*4 + 8]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */

	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addss  xmm5, [esp + _vctot]
	movss [esp + _vctot], xmm5 

	/* put scalar force on stack temporarily */
	movaps [esp + _fscal], xmm3

	/* dispersion */
	movlps xmm4, [esi + ebx*4 + 16]
	movlps xmm6, [esi + ebx*4 + 24]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */
	addps  xmm7, [esp + _fscal] /* add to fscal */

	/* put scalar force on stack Update vnbtot directly */
	addss  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movss [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm4, [esi + ebx*4 + 32]
	movlps xmm6, [esi + ebx*4 + 40]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
 	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 /* fijR */
	mulps  xmm5, xmm4 /* vnb12 */
	addps  xmm7, [esp + _fscal] 
	
	addss  xmm5, [esp + _vnbtot]
	movss [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
.i3300_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i3300_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i3300_outer
.i3300_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 344
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret





.globl inl3310_sse
	.type inl3310_sse,@function
inl3310_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_type,		60
.equ		_ntype,		64
.equ		_nbfp,		68	
.equ		_Vnb,		72
.equ		_tabscale,	76
.equ		_VFtab,		80
.equ		_nsatoms,	84			
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ix,		0
.equ		_iy,		16
.equ		_iz,		32
.equ		_iq,		48
.equ		_dx,		64
.equ		_dy,		80
.equ		_dz,		96
.equ		_two,		112
.equ		_tsc,		128
.equ		_qq,		144	
.equ		_c6,		160
.equ		_c12,		176
.equ		_fscal,		192
.equ		_vctot,		208
.equ		_vnbtot,	224
.equ		_fix,		240
.equ		_fiy,		256
.equ		_fiz,		272
.equ		_half,		288
.equ		_three,		304
.equ		_is3,		320
.equ		_ii3,		324
.equ		_shX,		328
.equ		_shY,		332
.equ		_shZ,		336
.equ		_ntia,		340	
.equ		_innerjjnr0,	344
.equ		_innerk0,	348	
.equ		_innerjjnr,	352
.equ		_innerk,	356
.equ		_salign,	360
.equ		_nsvdwc,	364
.equ		_nscoul,	368
.equ		_nsvdw,		372
.equ		_solnr,		376		
	push ebp
	mov ebp,esp	
	push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 380		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_two]
	movups xmm2, [sse_three]
	movss xmm3, [ebp + _tabscale]
	movaps [esp + _half],  xmm0
	movaps [esp + _two], xmm1
	movaps [esp + _three], xmm2
	shufps xmm3, xmm3, 0
	movaps [esp + _tsc], xmm3

	/* assume we have at least one i particle - start directly */	
.i3310_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movlps xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 8] 
	movlps [esp + _shX], xmm0
	movss [esp + _shZ], xmm1

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   eax, [ebp + _nsatoms]
	add   [ebp + _nsatoms],  12
	mov   ecx, [eax]	
	mov   edx, [eax + 4]
	mov   eax, [eax + 8]	
	sub   ecx, eax
	sub   eax, edx
	
	mov   [esp + _nsvdwc], edx
	mov   [esp + _nscoul], eax
	mov   [esp + _nsvdw], ecx
		
	/* clear potential */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _vnbtot], xmm4
	mov   [esp + _solnr],  ebx

	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr0], eax     /* pointer to jjnr[nj0] */
	mov   [esp + _innerk0], edx        /* number of innerloop atoms */

	mov   ecx, [esp + _nsvdwc]
	cmp   ecx,  0
	jnz   .i3310_mno_vdwc
	jmp   .i3310_testcoul
.i3310_mno_vdwc:
	mov   ebx,  [esp + _solnr]
	inc   dword ptr [esp + _solnr]

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	mulss xmm3, [ebp + _facel]
	shufps xmm3, xmm3, 0

        mov   edx, [ebp + _type] 
        mov   edx, [edx + ebx*4]
        imul  edx, [ebp + _ntype]
        shl   edx, 1
        mov   [esp + _ntia], edx
		
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 

	movss xmm0, [esp + _shX]
	movss xmm1, [esp + _shY]
	movss xmm2, [esp + _shZ]
	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]
	/* clear i forces */
	movaps [esp + _iq], xmm3
	
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   [esp + _ii3], ebx
	
	/* clear i forces */
	xorps xmm4, xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4
	
	mov   ecx, [esp + _innerjjnr0]
	mov   [esp + _innerjjnr], ecx
	mov   edx, [esp + _innerk0]
        sub   edx,  4
        mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i3310_unroll_vdwc_loop
	jmp   .i3310_finish_vdwc_inner
.i3310_unroll_vdwc_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	movaps xmm2, [esp + _iq]
	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	mulps  xmm3, xmm2
	movd  mm2, ecx
	movd  mm3, edx

	movaps [esp + _qq], xmm3
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	movhlps xmm5, xmm4
	cvttps2pi mm6, xmm4
	cvttps2pi mm7, xmm5	/* mm6/mm7 contain lu indices */
	cvtpi2ps xmm6, mm6
	cvtpi2ps xmm5, mm7
	movlhps xmm6, xmm5
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */
	pslld mm6, 2
	pslld mm7, 2

	movd mm0, eax	
	movd mm1, ebx
	movd mm2, ecx
	movd mm3, edx

	mov  esi, [ebp + _VFtab]
	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	lea   ecx, [ecx + ecx*2]
	lea   edx, [edx + edx*2]
		
	movlps xmm5, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm5, [esi + ebx*4]
	movhps xmm7, [esi + edx*4] /* got half coulomb table */

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101

	movlps xmm7, [esi + eax*4 + 8]
	movlps xmm3, [esi + ecx*4 + 8]
	movhps xmm7, [esi + ebx*4 + 8]
	movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* coulomb table ready, in xmm4-xmm7 */ 	
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addps  xmm5, [esp + _vctot]
	movaps [esp + _vctot], xmm5 

	/* put scalar force on stack temporarily */
	movaps [esp + _fscal], xmm3

	/* dispersion */
	movlps xmm5, [esi + eax*4 + 16]
	movlps xmm7, [esi + ecx*4 + 16]
	movhps xmm5, [esi + ebx*4 + 16]
	movhps xmm7, [esi + edx*4 + 16] /* got half dispersion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101
	
	movlps xmm7, [esi + eax*4 + 24]
	movlps xmm3, [esi + ecx*4 + 24]
	movhps xmm7, [esi + ebx*4 + 24]
	movhps xmm3, [esi + edx*4 + 24] /* other half of dispersion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* dispersion table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */
	addps  xmm7, [esp + _fscal] /* add to fscal */

	/* put scalar force on stack Update vnbtot directly */
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movaps [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm5, [esi + eax*4 + 32]
	movlps xmm7, [esi + ecx*4 + 32]
	movhps xmm5, [esi + ebx*4 + 32]
	movhps xmm7, [esi + edx*4 + 32] /* got half repulsion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101

	movlps xmm7, [esi + eax*4 + 40]
	movlps xmm3, [esi + ecx*4 + 40]
	movhps xmm7, [esi + ebx*4 + 40]
	movhps xmm3, [esi + edx*4 + 40] /* other half of repulsion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
 	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 /* fijR */
	mulps  xmm5, xmm4 /* vnb12 */
	addps  xmm7, [esp + _fscal] 
	
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movd eax, mm0	
	movd ebx, mm1
	movd ecx, mm2
	movd edx, mm3

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i3310_finish_vdwc_inner
	jmp   .i3310_unroll_vdwc_loop
.i3310_finish_vdwc_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i3310_dopair_vdwc
	jmp   .i3310_checksingle_vdwc
.i3310_dopair_vdwc:	
	mov esi, [ebp + _charge]

        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8	
	xorps xmm7, xmm7
	movss xmm3, [esi + eax*4]		
	movss xmm6, [esi + ebx*4]
	shufps xmm3, xmm6, 0 
	shufps xmm3, xmm3, 0b00001000 /* xmm3(0,1) has the charges */

	mulps  xmm3, [esp + _iq]
	movlhps xmm3, xmm7
	movaps [esp + _qq], xmm3

	mov esi, [ebp + _type]
	mov   ecx, eax
	mov   edx, ebx
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add ecx, edi
	add edx, edi
	movlps xmm6, [esi + ecx*4]
	movhps xmm6, [esi + edx*4]
	mov edi, [ebp + _pos]	
	
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b1000 	
	shufps xmm6, xmm6, 0b1101
	movlhps xmm4, xmm7
	movlhps xmm6, xmm7
	
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
			
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ecx, mm6
	psrlq mm6, 32
	movd edx, mm6
	lea   ecx, [ecx + ecx*2]
	lea   edx, [edx + edx*2]

	movlps xmm5, [esi + ecx*4]
	movhps xmm5, [esi + edx*4] /* got half coulomb table */
	movaps xmm4, xmm5
	shufps xmm4, xmm4, 0b10001000
	shufps xmm5, xmm5, 0b11011101
	
	movlps xmm7, [esi + ecx*4 + 8]
	movhps xmm7, [esi + edx*4 + 8]
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 0b10001000
	shufps xmm7, xmm7, 0b11011101
	/* table ready in xmm4-xmm7 */

	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addps  xmm5, [esp + _vctot]
	movaps [esp + _vctot], xmm5 

	/* put scalar force on stack temporarily */
	movaps [esp + _fscal], xmm3

	/* dispersion */
	movlps xmm5, [esi + ecx*4 + 16]
	movhps xmm5, [esi + edx*4 + 16]/* got half dispersion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm4, 0b10001000
	shufps xmm5, xmm5, 0b11011101
	
	movlps xmm7, [esi + ecx*4 + 24]
	movhps xmm7, [esi + edx*4 + 24] /* other half of dispersion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 0b10001000
	shufps xmm7, xmm7, 0b11011101
	/* dispersion table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */
	addps  xmm7, [esp + _fscal] /* add to fscal */

	/* put scalar force on stack Update vnbtot directly */
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movaps [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm5, [esi + ecx*4 + 32]
	movhps xmm5, [esi + edx*4 + 32] /* got half repulsion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm4, 0b10001000
	shufps xmm5, xmm5, 0b11011101

	movlps xmm7, [esi + ecx*4 + 40]
	movhps xmm7, [esi + edx*4 + 40] /* other half of repulsion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 0b10001000
	shufps xmm7, xmm7, 0b11011101
	/* table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
 	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 /* fijR */
	mulps  xmm5, xmm4 /* vnb12 */
	addps  xmm7, [esp + _fscal] 
	
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i3310_checksingle_vdwc:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    .i3310_dosingle_vdwc
	jmp    .i3310_updateouterdata_vdwc
.i3310_dosingle_vdwc:
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	xorps  xmm6, xmm6
	movss xmm6, [esi + eax*4]	/* xmm6(0) has the charge */	
	mulps  xmm6, [esp + _iq]
	movaps [esp + _qq], xmm6

	mov esi, [ebp + _type]
	mov ecx, eax
	mov ecx, [esi + ecx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1
	add ecx, [esp + _ntia]
	movlps xmm6, [esi + ecx*4]
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b11111100	
	shufps xmm6, xmm6, 0b11111101	
			
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	 
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */

	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ebx, mm6
	
	lea  ebx, [ebx + ebx*2]
						
	movlps xmm4, [esi + ebx*4]
	movlps xmm6, [esi + ebx*4 + 8]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */

	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addss  xmm5, [esp + _vctot]
	movss [esp + _vctot], xmm5 

	/* put scalar force on stack temporarily */
	movaps [esp + _fscal], xmm3

	/* dispersion */
	movlps xmm4, [esi + ebx*4 + 16]
	movlps xmm6, [esi + ebx*4 + 24]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */
	addps  xmm7, [esp + _fscal] /* add to fscal */

	/* put scalar force on stack Update vnbtot directly */
	addss  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movss [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm4, [esi + ebx*4 + 32]
	movlps xmm6, [esi + ebx*4 + 40]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
 	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 /* fijR */
	mulps  xmm5, xmm4 /* vnb12 */
	addps  xmm7, [esp + _fscal] 
	
	addss  xmm5, [esp + _vnbtot]
	movss [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
.i3310_updateouterdata_vdwc:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5


	/* loop back to mno */
	dec  dword ptr [esp + _nsvdwc]
	jz  .i3310_testcoul
	jmp .i3310_mno_vdwc
.i3310_testcoul:
	mov  ecx, [esp + _nscoul]
	cmp  ecx,  0
	jnz  .i3310_mno_coul
	jmp  .i3310_testvdw
.i3310_mno_coul:
	mov   ebx,  [esp + _solnr]
	inc   dword ptr [esp + _solnr]

	movss xmm0, [esp + _shX]
	movss xmm1, [esp + _shY]
	movss xmm2, [esp + _shZ]

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	mulss xmm3, [ebp + _facel]
	shufps xmm3, xmm3, 0
	
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]

	movaps [esp + _iq], xmm3
	
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   [esp + _ii3], ebx
	
	/* clear i forces */
	xorps xmm4, xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4

	mov   ecx, [esp + _innerjjnr0]
	mov   [esp + _innerjjnr], ecx
	mov   edx, [esp + _innerk0]
        sub   edx,  4
        mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i3310_unroll_coul_loop
	jmp   .i3310_finish_coul_inner

.i3310_unroll_coul_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	movaps xmm2, [esp + _iq]
	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	mulps  xmm3, xmm2

	movaps [esp + _qq], xmm3	
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	movhlps xmm5, xmm4
	cvttps2pi mm6, xmm4
	cvttps2pi mm7, xmm5	/* mm6/mm7 contain lu indices */
	cvtpi2ps xmm6, mm6
	cvtpi2ps xmm5, mm7
	movlhps xmm6, xmm5
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */
	pslld mm6, 2
	pslld mm7, 2

	movd mm0, eax	
	movd mm1, ebx
	movd mm2, ecx
	movd mm3, edx

	mov  esi, [ebp + _VFtab]
	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	lea   ecx, [ecx + ecx*2]
	lea   edx, [edx + edx*2]
		
	movlps xmm5, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm5, [esi + ebx*4]
	movhps xmm7, [esi + edx*4] /* got half coulomb table */

	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101

	movlps xmm7, [esi + eax*4 + 8]
	movlps xmm3, [esi + ecx*4 + 8]
	movhps xmm7, [esi + ebx*4 + 8]
	movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* coulomb table ready, in xmm4-xmm7 */ 	
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addps  xmm5, [esp + _vctot]
	movaps [esp + _vctot], xmm5 

	xorps  xmm4, xmm4

	mulps xmm3, [esp + _tsc]
	mulps xmm3, xmm0
	subps  xmm4, xmm3

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movd eax, mm0	
	movd ebx, mm1
	movd ecx, mm2
	movd edx, mm3

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i3310_finish_coul_inner
	jmp   .i3310_unroll_coul_loop
.i3310_finish_coul_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i3310_dopair_coul
	jmp   .i3310_checksingle_coul
.i3310_dopair_coul:	
	mov esi, [ebp + _charge]

        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8	
	xorps xmm7, xmm7
	movss xmm3, [esi + eax*4]		
	movss xmm6, [esi + ebx*4]
	shufps xmm3, xmm6, 0 
	shufps xmm3, xmm3, 0b00001000 /* xmm3(0,1) has the charges */

	mulps  xmm3, [esp + _iq]
	movlhps xmm3, xmm7
	movaps [esp + _qq], xmm3

	mov edi, [ebp + _pos]	
	
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ecx, mm6
	psrlq mm6, 32
	movd edx, mm6

	lea   ecx, [ecx + ecx*2]
	lea   edx, [edx + edx*2]

	movlps xmm5, [esi + ecx*4]
	movhps xmm5, [esi + edx*4] /* got half coulomb table */
	movaps xmm4, xmm5
	shufps xmm4, xmm4, 0b10001000
	shufps xmm5, xmm7, 0b11011101
	
	movlps xmm7, [esi + ecx*4 + 8]
	movhps xmm7, [esi + edx*4 + 8]
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 0b10001000
	shufps xmm7, xmm7, 0b11011101
	/* table ready in xmm4-xmm7 */

	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addps  xmm5, [esp + _vctot]
	movaps [esp + _vctot], xmm5 

	xorps  xmm4, xmm4

	mulps xmm3, [esp + _tsc]
	mulps xmm3, xmm0
	subps  xmm4, xmm3

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i3310_checksingle_coul:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    .i3310_dosingle_coul
	jmp    .i3310_updateouterdata_coul
.i3310_dosingle_coul:
	mov esi, [ebp + _charge]
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	xorps  xmm6, xmm6
	movss xmm6, [esi + eax*4]	/* xmm6(0) has the charge */	
	mulps  xmm6, [esp + _iq]
	movaps [esp + _qq], xmm6
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	 
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */

	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ebx, mm6
	
	lea   ebx, [ebx + ebx*2]

	movlps xmm4, [esi + ebx*4]
	movlps xmm6, [esi + ebx*4 + 8]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */

	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	movaps xmm3, [esp + _qq]
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
	mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
	mulps  xmm3, xmm7 /* fijC=FF*qq */
	/* at this point mm5 contains vcoul and mm3 fijC */
	/* increment vcoul - then we can get rid of mm5 */
	/* update vctot */
	addss  xmm5, [esp + _vctot]
	movss [esp + _vctot], xmm5 

	xorps xmm4, xmm4

	mulps xmm3, [esp + _tsc]
	mulps xmm3, xmm0
	subps  xmm4, xmm3
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
.i3310_updateouterdata_coul:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5

	/* loop back to mno */
	dec  dword ptr [esp + _nscoul]
	jz  .i3310_testvdw
	jmp .i3310_mno_coul
.i3310_testvdw:
	mov  ecx, [esp + _nsvdw]
	cmp  ecx,  0
	jnz  .i3310_mno_vdw
	jmp  .i3310_last_mno
.i3310_mno_vdw:
	mov   ebx,  [esp + _solnr]
	inc   dword ptr [esp + _solnr]

        mov   edx, [ebp + _type] 
        mov   edx, [edx + ebx*4]
        imul  edx, [ebp + _ntype]
        shl   edx, 1
        mov   [esp + _ntia], edx
		
	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx

	movss xmm0, [esp + _shX]
	movss xmm1, [esp + _shY]
	movss xmm2, [esp + _shZ]

	addss xmm0, [eax + ebx*4]
	addss xmm1, [eax + ebx*4 + 4]
	addss xmm2, [eax + ebx*4 + 8]
	
	xorps xmm4, xmm4
	movaps [esp + _fix], xmm4
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm4

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0

	movaps [esp + _ix], xmm0
	movaps [esp + _iy], xmm1
	movaps [esp + _iz], xmm2

	mov   ecx, [esp + _innerjjnr0]
	mov   [esp + _innerjjnr], ecx
	mov   edx, [esp + _innerk0]
        sub   edx,  4
        mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i3310_unroll_vdw_loop
	jmp   .i3310_finish_vdw_inner
.i3310_unroll_vdw_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	movd  mm2, ecx
	movd  mm3, edx
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6
	
	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	

	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	

	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ix-iz to xmm4-xmm6 */
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	movhlps xmm5, xmm4
	cvttps2pi mm6, xmm4
	cvttps2pi mm7, xmm5	/* mm6/mm7 contain lu indices */
	cvtpi2ps xmm6, mm6
	cvtpi2ps xmm5, mm7
	movlhps xmm6, xmm5
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */
	pslld mm6, 2
	pslld mm7, 2

	movd mm0, eax	
	movd mm1, ebx
	movd mm2, ecx
	movd mm3, edx

	mov  esi, [ebp + _VFtab]
	movd eax, mm6
	psrlq mm6, 32
	movd ecx, mm7
	psrlq mm7, 32
	movd ebx, mm6
	movd edx, mm7

	lea   eax, [eax + eax*2] 
	lea   ebx, [ebx + ebx*2] 
	lea   ecx, [ecx + ecx*2] 
	lea   edx, [edx + edx*2] 

	/* dispersion */
	movlps xmm5, [esi + eax*4 + 0]
	movlps xmm7, [esi + ecx*4 + 0]
	movhps xmm5, [esi + ebx*4 + 0]
	movhps xmm7, [esi + edx*4 + 0] /* got half dispersion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101
	
	movlps xmm7, [esi + eax*4 + 8]
	movlps xmm3, [esi + ecx*4 + 8]
	movhps xmm7, [esi + ebx*4 + 8]
	movhps xmm3, [esi + edx*4 + 8] /* other half of dispersion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* dispersion table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */

	/* put scalar force on stack Update vnbtot directly */
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movaps [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm5, [esi + eax*4 + 16]
	movlps xmm7, [esi + ecx*4 + 16]
	movhps xmm5, [esi + ebx*4 + 16]
	movhps xmm7, [esi + edx*4 + 16] /* got half repulsion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101

	movlps xmm7, [esi + eax*4 + 24]
	movlps xmm3, [esi + ecx*4 + 24]
	movhps xmm7, [esi + ebx*4 + 24]
	movhps xmm3, [esi + edx*4 + 24] /* other half of repulsion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
 	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 /* fijR */
	mulps  xmm5, xmm4 /* vnb12 */
	addps  xmm7, [esp + _fscal] 
	
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	movd eax, mm0	
	movd ebx, mm1
	movd ecx, mm2
	movd edx, mm3

	mov    edi, [ebp + _faction]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* the fj's - start by accumulating x & y forces from memory */
	movlps xmm4, [edi + eax*4]
	movlps xmm6, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm6, [edi + edx*4]

	movaps xmm3, xmm4
	shufps xmm3, xmm6, 0b10001000
	shufps xmm4, xmm6, 0b11011101			      

	/* now xmm3-xmm5 contains fjx, fjy, fjz */
	subps  xmm3, xmm0
	subps  xmm4, xmm1
	
	/* unpack them back so we can store them - first x & y in xmm3/xmm4 */

	movaps xmm6, xmm3
	unpcklps xmm6, xmm4
	unpckhps xmm3, xmm4	
	/* xmm6(l)=x & y for j1, (h) for j2 */
	/* xmm3(l)=x & y for j3, (h) for j4 */
	movlps [edi + eax*4], xmm6
	movlps [edi + ecx*4], xmm3
	
	movhps [edi + ebx*4], xmm6
	movhps [edi + edx*4], xmm3

	/* and the z forces */
	movss  xmm4, [edi + eax*4 + 8]
	movss  xmm5, [edi + ebx*4 + 8]
	movss  xmm6, [edi + ecx*4 + 8]
	movss  xmm7, [edi + edx*4 + 8]
	subss  xmm4, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm5, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm6, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm7, xmm2
	movss  [edi + eax*4 + 8], xmm4
	movss  [edi + ebx*4 + 8], xmm5
	movss  [edi + ecx*4 + 8], xmm6
	movss  [edi + edx*4 + 8], xmm7
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i3310_finish_vdw_inner
	jmp   .i3310_unroll_vdw_loop
.i3310_finish_vdw_inner:
	/* check if at least two particles remain */
	add   [esp + _innerk],  4
	mov   edx, [esp + _innerk]
	and   edx, 2
	jnz   .i3310_dopair_vdw
	jmp   .i3310_checksingle_vdw
.i3310_dopair_vdw:	
        mov   ecx, [esp + _innerjjnr]
	
	mov   eax, [ecx]	
	mov   ebx, [ecx + 4]              
	add   [esp + _innerjjnr],  8	
	xorps xmm7, xmm7

	mov esi, [ebp + _type]
	mov   ecx, eax
	mov   edx, ebx
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add ecx, edi
	add edx, edi
	movlps xmm6, [esi + ecx*4]
	movhps xmm6, [esi + edx*4]
	mov edi, [ebp + _pos]	
	
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b1000 	
	shufps xmm6, xmm6, 0b1101
	movlhps xmm4, xmm7
	movlhps xmm6, xmm7
	
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
			
	lea   eax, [eax + eax*2]
	lea   ebx, [ebx + ebx*2]
	/* move coordinates to xmm0-xmm2 */
	movlps xmm1, [edi + eax*4]
	movss xmm2, [edi + eax*4 + 8]	
	movhps xmm1, [edi + ebx*4]
	movss xmm0, [edi + ebx*4 + 8]	

	movlhps xmm3, xmm7
	
	shufps xmm2, xmm0, 0
	
	movaps xmm0, xmm1

	shufps xmm2, xmm2, 0b10001000
	
	shufps xmm0, xmm0, 0b10001000
	shufps xmm1, xmm1, 0b11011101
			
	mov    edi, [ebp + _faction]
	/* move ix-iz to xmm4-xmm6 */
	xorps   xmm7, xmm7
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ecx, mm6
	psrlq mm6, 32
	movd edx, mm6

	lea   ecx, [ecx + ecx*2] 
	lea   edx, [edx + edx*2] 

	/* dispersion */
	movlps xmm5, [esi + ecx*4 + 0]
	movhps xmm5, [esi + edx*4 + 0]/* got half dispersion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm4, 0b10001000
	shufps xmm5, xmm5, 0b11011101
	
	movlps xmm7, [esi + ecx*4 + 8]
	movhps xmm7, [esi + edx*4 + 8] /* other half of dispersion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 0b10001000
	shufps xmm7, xmm7, 0b11011101
	/* dispersion table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */

	/* put scalar force on stack Update vnbtot directly */
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movaps [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm5, [esi + ecx*4 + 16]
	movhps xmm5, [esi + edx*4 + 16] /* got half repulsion table */
	movaps xmm4, xmm5
	shufps xmm4, xmm7, 0b10001000
	shufps xmm5, xmm7, 0b11011101

	movlps xmm7, [esi + ecx*4 + 24]
	movhps xmm7, [esi + edx*4 + 24] /* other half of repulsion table */
	movaps xmm6, xmm7
	shufps xmm6, xmm3, 0b10001000
	shufps xmm7, xmm3, 0b11011101
	/* table ready, in xmm4-xmm7 */	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
 	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 /* fijR */
	mulps  xmm5, xmm4 /* vnb12 */
	addps  xmm7, [esp + _fscal] 
	
	addps  xmm5, [esp + _vnbtot]
	movaps [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update the fj's */
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	

	shufps  xmm0, xmm0, 0b11100001
	shufps  xmm1, xmm1, 0b11100001
	shufps  xmm2, xmm2, 0b11100001

	movss   xmm3, [edi + ebx*4]
	movss   xmm4, [edi + ebx*4 + 4]
	movss   xmm5, [edi + ebx*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + ebx*4], xmm3
	movss   [edi + ebx*4 + 4], xmm4
	movss   [edi + ebx*4 + 8], xmm5	

.i3310_checksingle_vdw:				
	mov   edx, [esp + _innerk]
	and   edx, 1
	jnz    .i3310_dosingle_vdw
	jmp    .i3310_updateouterdata_vdw
.i3310_dosingle_vdw:
	mov edi, [ebp + _pos]
	mov   ecx, [esp + _innerjjnr]
	mov   eax, [ecx]	
	xorps  xmm6, xmm6

	mov esi, [ebp + _type]
	mov ecx, eax
	mov ecx, [esi + ecx*4]	
	mov esi, [ebp + _nbfp]
	shl ecx, 1
	add ecx, [esp + _ntia]
	movlps xmm6, [esi + ecx*4]
	movaps xmm4, xmm6
	shufps xmm4, xmm4, 0b11111100	
	shufps xmm6, xmm6, 0b11111101	
			
	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6	
		
	lea   eax, [eax + eax*2]
	
	/* move coordinates to xmm0-xmm2 */
	movss xmm0, [edi + eax*4]	
	movss xmm1, [edi + eax*4 + 4]	
	movss xmm2, [edi + eax*4 + 8]	 
	
	movaps xmm4, [esp + _ix]
	movaps xmm5, [esp + _iy]
	movaps xmm6, [esp + _iz]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dx], xmm4
	movaps [esp + _dy], xmm5
	movaps [esp + _dz], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */

	mulps xmm4, xmm0	/* xmm4=r */
	mulps xmm4, [esp + _tsc]

	cvttps2pi mm6, xmm4     /* mm6 contain lu indices */
	cvtpi2ps xmm6, mm6
	subps xmm4, xmm6	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1	
	mulps  xmm2, xmm2	/* xmm2=eps2 */

	pslld mm6, 2

	mov  esi, [ebp + _VFtab]
	movd ebx, mm6

	lea   ebx, [ebx + ebx*2] 	

	/* dispersion */
	movlps xmm4, [esi + ebx*4 + 0]
	movlps xmm6, [esi + ebx*4 + 8]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */

	movaps xmm4, [esp + _c6]
	mulps  xmm7, xmm4	 /* fijD */
	mulps  xmm5, xmm4	 /* vnb6 */

	/* put scalar force on stack Update vnbtot directly */
	addss  xmm5, [esp + _vnbtot]
	movaps [esp + _fscal], xmm7
	movss [esp + _vnbtot], xmm5

	/* repulsion */
	movlps xmm4, [esi + ebx*4 + 16]
	movlps xmm6, [esi + ebx*4 + 24]
	movaps xmm5, xmm4
	movaps xmm7, xmm6
	shufps xmm5, xmm5, 1
	shufps xmm7, xmm7, 1
	/* table ready in xmm4-xmm7 */
	
	mulps  xmm6, xmm1	/* xmm6=Geps */
	mulps  xmm7, xmm2	/* xmm7=Heps2 */
	addps  xmm5, xmm6
	addps  xmm5, xmm7	/* xmm5=Fp */	
	mulps  xmm7, [esp + _two]	/* two*Heps2 */
	addps  xmm7, xmm6
	addps  xmm7, xmm5 /* xmm7=FF */
	mulps  xmm5, xmm1 /* xmm5=eps*Fp */
	addps  xmm5, xmm4 /* xmm5=VV */
 	
	movaps xmm4, [esp + _c12]
	mulps  xmm7, xmm4 /* fijR */
	mulps  xmm5, xmm4 /* vnb12 */
	addps  xmm7, [esp + _fscal] 
	
	addss  xmm5, [esp + _vnbtot]
	movss [esp + _vnbtot], xmm5
	xorps  xmm4, xmm4

	mulps xmm7, [esp + _tsc]
	mulps xmm7, xmm0
	subps  xmm4, xmm7
	mov    edi, [ebp + _faction]

	movaps xmm0, [esp + _dx]
	movaps xmm1, [esp + _dy]
	movaps xmm2, [esp + _dz]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4
	/* xmm0-xmm2 contains tx-tz (partial force) */
	/* now update f_i */
	movaps xmm3, [esp + _fix]
	movaps xmm4, [esp + _fiy]
	movaps xmm5, [esp + _fiz]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movaps [esp + _fix], xmm3
	movaps [esp + _fiy], xmm4
	movaps [esp + _fiz], xmm5
	/* update fj */
	
	movss   xmm3, [edi + eax*4]
	movss   xmm4, [edi + eax*4 + 4]
	movss   xmm5, [edi + eax*4 + 8]
	subss   xmm3, xmm0
	subss   xmm4, xmm1
	subss   xmm5, xmm2	
	movss   [edi + eax*4], xmm3
	movss   [edi + eax*4 + 4], xmm4
	movss   [edi + eax*4 + 8], xmm5	
.i3310_updateouterdata_vdw:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fix]
	movaps xmm1, [esp + _fiy]
	movaps xmm2, [esp + _fiz]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* increment fshift force */ 
	movss  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 4]
	movss  xmm5, [esi + edx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esi + edx*4],     xmm3
	movss  [esi + edx*4 + 4], xmm4
	movss  [esi + edx*4 + 8], xmm5
	
	/* loop back to mno */
	dec dword ptr [esp + _nsvdw]
	jz  .i3310_last_mno
	jmp .i3310_mno_vdw
.i3310_last_mno:	
	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i3310_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i3310_outer
.i3310_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 380
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret



.globl inl3320_sse
	.type inl3320_sse,@function
inl3320_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56			
.equ		_type,		60
.equ		_ntype,		64
.equ		_nbfp,		68	
.equ		_Vnb,		72	
.equ		_tabscale,	76	
.equ		_VFtab,		80	
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ixO,		0
.equ		_iyO,		16
.equ		_izO,		32
.equ		_ixH1,		48
.equ		_iyH1,		64
.equ		_izH1,		80
.equ		_ixH2,		96
.equ		_iyH2,		112
.equ		_izH2,		128
.equ		_iqO,		144 
.equ		_iqH,		160 
.equ		_dxO,		176
.equ		_dyO,		192
.equ		_dzO,		208	
.equ		_dxH1,		224
.equ		_dyH1,		240
.equ		_dzH1,		256	
.equ		_dxH2,		272
.equ		_dyH2,		288
.equ		_dzH2,		304	
.equ		_qqO,		320
.equ		_qqH,		336
.equ		_rinvO,		352
.equ		_rinvH1,	368
.equ		_rinvH2,	384		
.equ		_rO,		400
.equ		_rH1,		416
.equ		_rH2,		432
.equ		_tsc,		448	
.equ		_two,		464
.equ		_c6,		480
.equ		_c12,		496
.equ		_vctot,		512
.equ		_vnbtot,	528
.equ		_fixO,		544
.equ		_fiyO,		560
.equ		_fizO,		576
.equ		_fixH1,		592
.equ		_fiyH1,		608
.equ		_fizH1,		624
.equ		_fixH2,		640
.equ		_fiyH2,		656
.equ		_fizH2,		672
.equ		_fjx,		688
.equ		_fjy,		704
.equ		_fjz,		720
.equ		_half,		736
.equ		_three,		752
.equ		_is3,		768
.equ		_ii3,		772
.equ		_ntia,		776	
.equ		_innerjjnr,	780
.equ		_innerk,	784
.equ		_salign,	788								
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 792		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_two]
	movups xmm2, [sse_three]
	movss xmm3, [ebp + _tabscale]
	
	movaps [esp + _half],  xmm0
	movaps [esp + _two],  xmm1
	movaps [esp + _three],  xmm2
	shufps xmm3, xmm3, 0
	movaps [esp + _tsc], xmm3
	
	/* assume we have at least one i particle - start directly */
	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	movss xmm4, [edx + ebx*4 + 4]	
	movss xmm5, [ebp + _facel]
	mulss  xmm3, xmm5
	mulss  xmm4, xmm5

	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	movaps [esp + _iqO], xmm3
	movaps [esp + _iqH], xmm4
	
	mov   edx, [ebp + _type]
	mov   ecx, [edx + ebx*4]
	shl   ecx, 1
	imul  ecx, [ebp + _ntype]      /* ecx = ntia = 2*ntype*type[ii0] */
	mov   [esp + _ntia], ecx		
.i3320_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2

	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx

	addss xmm3, [eax + ebx*4]
	addss xmm4, [eax + ebx*4 + 4]
	addss xmm5, [eax + ebx*4 + 8]		
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixO], xmm3
	movaps [esp + _iyO], xmm4
	movaps [esp + _izO], xmm5

	movss xmm3, xmm0
	movss xmm4, xmm1
	movss xmm5, xmm2
	addss xmm0, [eax + ebx*4 + 12]
	addss xmm1, [eax + ebx*4 + 16]
	addss xmm2, [eax + ebx*4 + 20]		
	addss xmm3, [eax + ebx*4 + 24]
	addss xmm4, [eax + ebx*4 + 28]
	addss xmm5, [eax + ebx*4 + 32]		

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixH1], xmm0
	movaps [esp + _iyH1], xmm1
	movaps [esp + _izH1], xmm2
	movaps [esp + _ixH2], xmm3
	movaps [esp + _iyH2], xmm4
	movaps [esp + _izH2], xmm5
	
	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _vnbtot], xmm4
	movaps [esp + _fixO], xmm4
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm4
	movaps [esp + _fixH1], xmm4
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm4
	movaps [esp + _fixH2], xmm4
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i3320_unroll_loop
	jmp   .i3320_odd_inner
.i3320_unroll_loop:
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	mov   ebx, [edx + 4]              
	mov   ecx, [edx + 8]            
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */

	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _charge]        /* base of charge[] */
	
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + ecx*4]
	movss xmm6, [esi + ebx*4]
	movss xmm7, [esi + edx*4]

	shufps xmm3, xmm6, 0 
	shufps xmm4, xmm7, 0 
	shufps xmm3, xmm4, 0b10001000 /* all charges in xmm3 */ 
	movaps xmm4, xmm3	     /* and in xmm4 */
	mulps  xmm3, [esp + _iqO]
	mulps  xmm4, [esp + _iqH]

	movd  mm0, eax		/* use mmx registers as temp storage */
	movd  mm1, ebx
	movd  mm2, ecx
	movd  mm3, edx

	movaps  [esp + _qqO], xmm3
	movaps  [esp + _qqH], xmm4
	
	mov esi, [ebp + _type]
	mov eax, [esi + eax*4]
	mov ebx, [esi + ebx*4]
	mov ecx, [esi + ecx*4]
	mov edx, [esi + edx*4]
	mov esi, [ebp + _nbfp]
	shl eax, 1	
	shl ebx, 1	
	shl ecx, 1	
	shl edx, 1	
	mov edi, [esp + _ntia]
	add eax, edi
	add ebx, edi
	add ecx, edi
	add edx, edi

	movlps xmm6, [esi + eax*4]
	movlps xmm7, [esi + ecx*4]
	movhps xmm6, [esi + ebx*4]
	movhps xmm7, [esi + edx*4]

	movaps xmm4, xmm6
	shufps xmm4, xmm7, 0b10001000
	shufps xmm6, xmm7, 0b11011101
	
	movd  eax, mm0		
	movd  ebx, mm1
	movd  ecx, mm2
	movd  edx, mm3

	movaps [esp + _c6], xmm4
	movaps [esp + _c12], xmm6

	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	

	/* move four coordinates to xmm0-xmm2 */	
	movlps xmm4, [esi + eax*4]
	movlps xmm5, [esi + ecx*4]
	movss xmm2, [esi + eax*4 + 8]
	movss xmm6, [esi + ecx*4 + 8]

	movhps xmm4, [esi + ebx*4]
	movhps xmm5, [esi + edx*4]

	movss xmm0, [esi + ebx*4 + 8]
	movss xmm1, [esi + edx*4 + 8]

	shufps xmm2, xmm0, 0
	shufps xmm6, xmm1, 0
	
	movaps xmm0, xmm4
	movaps xmm1, xmm4

	shufps xmm2, xmm6, 0b10001000
	
	shufps xmm0, xmm5, 0b10001000
	shufps xmm1, xmm5, 0b11011101		

	/* move ixO-izO to xmm4-xmm6 */
	movaps xmm4, [esp + _ixO]
	movaps xmm5, [esp + _iyO]
	movaps xmm6, [esp + _izO]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dxO], xmm4
	movaps [esp + _dyO], xmm5
	movaps [esp + _dzO], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm4, xmm5
	addps xmm4, xmm6
	movaps xmm7, xmm4
	/* rsqO in xmm7 */

	/* move ixH1-izH1 to xmm4-xmm6 */
	movaps xmm4, [esp + _ixH1]
	movaps xmm5, [esp + _iyH1]
	movaps xmm6, [esp + _izH1]

	/* calc dr */
	subps xmm4, xmm0
	subps xmm5, xmm1
	subps xmm6, xmm2

	/* store dr */
	movaps [esp + _dxH1], xmm4
	movaps [esp + _dyH1], xmm5
	movaps [esp + _dzH1], xmm6
	/* square it */
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	mulps xmm6,xmm6
	addps xmm6, xmm5
	addps xmm6, xmm4
	/* rsqH1 in xmm6 */

	/* move ixH2-izH2 to xmm3-xmm5 */ 
	movaps xmm3, [esp + _ixH2]
	movaps xmm4, [esp + _iyH2]
	movaps xmm5, [esp + _izH2]

	/* calc dr */
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2

	/* store dr */
	movaps [esp + _dxH2], xmm3
	movaps [esp + _dyH2], xmm4
	movaps [esp + _dzH2], xmm5
	/* square it */
	mulps xmm3,xmm3
	mulps xmm4,xmm4
	mulps xmm5,xmm5
	addps xmm5, xmm4
	addps xmm5, xmm3
	/* rsqH2 in xmm5, rsqH1 in xmm6, rsqO in xmm7 */

	/* start with rsqO - seed to xmm2 */	
	rsqrtps xmm2, xmm7
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm7	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  [esp + _rinvO], xmm4	/* rinvO in xmm4 */
	mulps   xmm7, xmm4
	movaps  [esp + _rO], xmm7	

	/* rsqH1 - seed in xmm2 */
	rsqrtps xmm2, xmm6
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm6	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  [esp + _rinvH1], xmm4	/* rinvH1 in xmm4 */
	mulps   xmm6, xmm4
	movaps  [esp + _rH1], xmm6

	/* rsqH2 - seed to xmm2 */
	rsqrtps xmm2, xmm5
	movaps  xmm3, xmm2
	mulps   xmm2, xmm2
	movaps  xmm4, [esp + _three]
	mulps   xmm2, xmm5	/* rsq*lu*lu */
	subps   xmm4, xmm2	/* 30-rsq*lu*lu */
	mulps   xmm4, xmm3	/* lu*(3-rsq*lu*lu) */
	mulps   xmm4, [esp + _half]
	movaps  [esp + _rinvH2], xmm4	/* rinvH2 in xmm4 */
	mulps   xmm5, xmm4
	movaps  [esp + _rH2], xmm5

	/* do O interactions */
	/* rO is still in xmm7 */
	mulps   xmm7, [esp + _tsc]
	movhlps xmm4, xmm7
	cvttps2pi mm6, xmm7
	cvttps2pi mm7, xmm4    /* mm6/mm7 contain lu indices */
	
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm4, mm7
        movlhps xmm3, xmm4
	
        subps xmm7, xmm3

	movaps xmm1, xmm7	/* xmm1=eps */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2
		
        movd mm0, eax   
        movd mm1, ebx
        movd mm2, ecx
        movd mm3, edx

        mov  esi, [ebp + _VFtab]
        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        lea   eax, [eax + eax*2]
        lea   ebx, [ebx + ebx*2]
        lea   ecx, [ecx + ecx*2]
        lea   edx, [edx + edx*2]

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */     
        
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */       
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm0, [esp + _qqO]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm0 /* vcoul=qq*VV */ 
        mulps  xmm0, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and xmm0 fijC */
        /* increment vcoul - then we can get rid of mm5 */
        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5 

        /* dispersion */
        movlps xmm5, [esi + eax*4 + 16]
        movlps xmm7, [esi + ecx*4 + 16]
        movhps xmm5, [esi + ebx*4 + 16]
        movhps xmm7, [esi + edx*4 + 16] /* got half dispersion table */
        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101
        
        movlps xmm7, [esi + eax*4 + 24]
        movlps xmm3, [esi + ecx*4 + 24]
        movhps xmm7, [esi + ebx*4 + 24]
        movhps xmm3, [esi + edx*4 + 24] /* other half of dispersion table */
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* dispersion table ready, in xmm4-xmm7 */ 
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */       
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */

        movaps xmm4, [esp + _c6]
        mulps  xmm7, xmm4        /* fijD */
        mulps  xmm5, xmm4        /* vnb6 */
        addps  xmm0, xmm7 /* add to fscal */

        /* Update vnbtot directly */
        addps  xmm5, [esp + _vnbtot]
        movaps [esp + _vnbtot], xmm5

        /* repulsion */
        movlps xmm5, [esi + eax*4 + 32]
        movlps xmm7, [esi + ecx*4 + 32]
        movhps xmm5, [esi + ebx*4 + 32]
        movhps xmm7, [esi + edx*4 + 32] /* got half repulsion table */
        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 40]
        movlps xmm3, [esi + ecx*4 + 40]
        movhps xmm7, [esi + ebx*4 + 40]
        movhps xmm3, [esi + edx*4 + 40] /* other half of repulsion table */
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* repulsion table ready, in xmm4-xmm7 */	
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */       
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */

        movaps xmm4, [esp + _c12]
        mulps  xmm7, xmm4        /* fijD */
        mulps  xmm5, xmm4        /* vnb12 */
        addps  xmm7, xmm0 /* add to fscal */
        addps  xmm5, [esp + _vnbtot] /* total nonbonded potential in xmm5 */
	xorps xmm4, xmm4
	
	mulps  xmm7, [esp + _rinvO] /* total fscal now in xmm7 */

	mulps  xmm7, [esp + _tsc]
        movaps [esp + _vnbtot], xmm5
	subps  xmm4, xmm7

	movaps xmm0, [esp + _dxO]
	movaps xmm1, [esp + _dyO]
	movaps xmm2, [esp + _dzO]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4	/* tx in xmm0-xmm2 */

	/* update O forces */
	movaps xmm3, [esp + _fixO]
	movaps xmm4, [esp + _fiyO]
	movaps xmm7, [esp + _fizO]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixO], xmm3
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm7
	/* update j forces with water O */
	movaps [esp + _fjx], xmm0
	movaps [esp + _fjy], xmm1
	movaps [esp + _fjz], xmm2

	/* Done with O interactions - now H1! */
	movaps xmm7, [esp + _rH1]
	mulps   xmm7, [esp + _tsc]
	movhlps xmm4, xmm7
	cvttps2pi mm6, xmm7
	cvttps2pi mm7, xmm4    /* mm6/mm7 contain lu indices */
	
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm4, mm7
        movlhps xmm3, xmm4
	
        subps xmm7, xmm3
	movaps xmm1, xmm7	/* xmm1=eps */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2
		
        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        lea   eax, [eax + eax*2]
        lea   ebx, [ebx + ebx*2]
        lea   ecx, [ecx + ecx*2]
        lea   edx, [edx + edx*2]

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */     
        
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */       
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm0, [esp + _qqH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm0 /* vcoul=qq*VV */ 
        mulps  xmm7, xmm0 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and xmm7 fijC */
        /* increment vcoul */
	xorps  xmm4, xmm4
        addps  xmm5, [esp + _vctot]
	mulps  xmm7, [esp + _rinvH1]
        movaps [esp + _vctot], xmm5 
	mulps  xmm7, [esp + _tsc]
	subps xmm4, xmm7

	movaps xmm0, [esp + _dxH1]
	movaps xmm1, [esp + _dyH1]
	movaps xmm2, [esp + _dzH1]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

	/* update H1 forces */
	movaps xmm3, [esp + _fixH1]
	movaps xmm4, [esp + _fiyH1]
	movaps xmm7, [esp + _fizH1]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixH1], xmm3
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm7
	/* update j forces with water H1 */
	addps  xmm0, [esp + _fjx]
	addps  xmm1, [esp + _fjy]
	addps  xmm2, [esp + _fjz]
	movaps [esp + _fjx], xmm0
	movaps [esp + _fjy], xmm1
	movaps [esp + _fjz], xmm2

	/* Done with H1, finally we do H2 interactions */
	movaps xmm7, [esp + _rH2]
	mulps   xmm7, [esp + _tsc]
	movhlps xmm4, xmm7
	cvttps2pi mm6, xmm7
	cvttps2pi mm7, xmm4    /* mm6/mm7 contain lu indices */
	
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm4, mm7
        movlhps xmm3, xmm4
	
        subps xmm7, xmm3
	movaps xmm1, xmm7	/* xmm1=eps */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2
		
        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        lea   eax, [eax + eax*2]
        lea   ebx, [ebx + ebx*2]
        lea   ecx, [ecx + ecx*2]
        lea   edx, [edx + edx*2]

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */     
        
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */       
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm0, [esp + _qqH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm0 /* vcoul=qq*VV */ 
        mulps  xmm7, xmm0 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and xmm0 fijC */
        /* increment vcoul */
	xorps  xmm4, xmm4
        addps  xmm5, [esp + _vctot]
	mulps  xmm7, [esp + _rinvH2]
        movaps [esp + _vctot], xmm5 
	mulps  xmm7, [esp + _tsc]
	subps  xmm4, xmm7

	movaps xmm0, [esp + _dxH2]
	movaps xmm1, [esp + _dyH2]
	movaps xmm2, [esp + _dzH2]
	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4

        movd eax, mm0   
        movd ebx, mm1
        movd ecx, mm2
        movd edx, mm3
	
	/* update H2 forces */
	movaps xmm3, [esp + _fixH2]
	movaps xmm4, [esp + _fiyH2]
	movaps xmm7, [esp + _fizH2]
	addps  xmm3, xmm0
	addps  xmm4, xmm1
	addps  xmm7, xmm2
	movaps [esp + _fixH2], xmm3
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm7

	mov edi, [ebp + _faction]
	/* update j forces */
	addps xmm0, [esp + _fjx]
	addps xmm1, [esp + _fjy]
	addps xmm2, [esp + _fjz]

	movlps xmm4, [edi + eax*4]
	movlps xmm7, [edi + ecx*4]
	movhps xmm4, [edi + ebx*4]
	movhps xmm7, [edi + edx*4]
	
	movaps xmm3, xmm4
	shufps xmm3, xmm7, 0b10001000
	shufps xmm4, xmm7, 0b11011101			      
	/* xmm3 has fjx, xmm4 has fjy */
	subps xmm3, xmm0
	subps xmm4, xmm1
	/* unpack them back for storing */
	movaps xmm7, xmm3
	unpcklps xmm7, xmm4
	unpckhps xmm3, xmm4	
	movlps [edi + eax*4], xmm7
	movlps [edi + ecx*4], xmm3
	movhps [edi + ebx*4], xmm7
	movhps [edi + edx*4], xmm3
	/* finally z forces */
	movss  xmm0, [edi + eax*4 + 8]
	movss  xmm1, [edi + ebx*4 + 8]
	movss  xmm3, [edi + ecx*4 + 8]
	movss  xmm4, [edi + edx*4 + 8]
	subss  xmm0, xmm2
	shufps xmm2, xmm2, 0b11100101
	subss  xmm1, xmm2
	shufps xmm2, xmm2, 0b11101010
	subss  xmm3, xmm2
	shufps xmm2, xmm2, 0b11111111
	subss  xmm4, xmm2
	movss  [edi + eax*4 + 8], xmm0
	movss  [edi + ebx*4 + 8], xmm1
	movss  [edi + ecx*4 + 8], xmm3
	movss  [edi + edx*4 + 8], xmm4
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i3320_odd_inner
	jmp   .i3320_unroll_loop
.i3320_odd_inner:	
	add   [esp + _innerk],  4
	jnz   .i3320_odd_loop
	jmp   .i3320_updateouterdata
.i3320_odd_loop:
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	add   [esp + _innerjjnr],  4	

 	xorps xmm4, xmm4
	movss xmm4, [esp + _iqO]
	mov esi, [ebp + _charge] 
	movhps xmm4, [esp + _iqH]     
	movss xmm3, [esi + eax*4]	/* charge in xmm3 */
	shufps xmm3, xmm3, 0
	mulps xmm3, xmm4
	movaps [esp + _qqO], xmm3	/* use oxygen qq for storage */

	xorps xmm6, xmm6
	mov esi, [ebp + _type]
	mov ebx, [esi + eax*4]
	mov esi, [ebp + _nbfp]
	shl ebx, 1	
	add ebx, [esp + _ntia]
	movlps xmm6, [esi + ebx*4]
	movaps xmm7, xmm6
	shufps xmm6, xmm6, 0b11111100
	shufps xmm7, xmm7, 0b11111101
	movaps [esp + _c6], xmm6
	movaps [esp + _c12], xmm7

	mov esi, [ebp + _pos]
	lea   eax, [eax + eax*2]  
	
	/* move j coords to xmm0-xmm2 */
	movss xmm0, [esi + eax*4]
	movss xmm1, [esi + eax*4 + 4]
	movss xmm2, [esi + eax*4 + 8]
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	
	movss xmm3, [esp + _ixO]
	movss xmm4, [esp + _iyO]
	movss xmm5, [esp + _izO]
		
	movlps xmm6, [esp + _ixH1]
	movlps xmm7, [esp + _ixH2]
	unpcklps xmm6, xmm7
	movlhps xmm3, xmm6
	movlps xmm6, [esp + _iyH1]
	movlps xmm7, [esp + _iyH2]
	unpcklps xmm6, xmm7
	movlhps xmm4, xmm6
	movlps xmm6, [esp + _izH1]
	movlps xmm7, [esp + _izH2]
	unpcklps xmm6, xmm7
	movlhps xmm5, xmm6

	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	
	movaps [esp + _dxO], xmm3
	movaps [esp + _dyO], xmm4
	movaps [esp + _dzO], xmm5

	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5

	addps  xmm4, xmm3
	addps  xmm4, xmm5
	/* rsq in xmm4 */

	rsqrtps xmm5, xmm4
	/* lookup seed in xmm5 */
	movaps xmm2, xmm5
	mulps xmm5, xmm5
	movaps xmm1, [esp + _three]
	mulps xmm5, xmm4	/* rsq*lu*lu */			
	movaps xmm0, [esp + _half]
	subps xmm1, xmm5	/* 30-rsq*lu*lu */
	mulps xmm1, xmm2	
	mulps xmm0, xmm1	/* xmm0=rinv */
	mulps xmm4, xmm0	/* xmm4=r */
	movaps [esp + _rinvO], xmm0
	
	mulps xmm4, [esp + _tsc]
	movhlps xmm7, xmm4
	cvttps2pi mm6, xmm4
	cvttps2pi mm7, xmm7    /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm7, mm7
        movlhps xmm3, xmm7

	subps   xmm4, xmm3	
	movaps xmm1, xmm4	/* xmm1=eps */
	movaps xmm2, xmm1
	mulps  xmm2, xmm2	/* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2
	
        movd mm0, eax   
        movd mm1, ecx
        movd mm2, edx

        mov  esi, [ebp + _VFtab]
        movd eax, mm6
        movd ecx, mm7
        psrlq mm7, 32
        movd edx, mm7

        lea   eax, [eax + eax*2]
        lea   ecx, [ecx + ecx*2]
        lea   edx, [edx + edx*2]
	
        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */     
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */       
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm0, [esp + _qqO]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm0 /* vcoul=qq*VV */ 
        mulps  xmm0, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and xmm0 fijC */
        /* increment vcoul - then we can get rid of mm5 */
        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	
        /* dispersion */
        movlps xmm5, [esi + eax*4 + 16]	/* half table */
        movaps xmm4, xmm5
        shufps xmm4, xmm4, 0b11111100
        shufps xmm5, xmm5, 0b11111101
        
        movlps xmm7, [esi + eax*4 + 24] /* other half of dispersion table */
        movaps xmm6, xmm7
        shufps xmm6, xmm6, 0b11111100
        shufps xmm7, xmm7, 0b11111101
        /* dispersion table ready, in xmm4-xmm7 */ 
        mulss  xmm6, xmm1       /* xmm6=Geps */
        mulss  xmm7, xmm2       /* xmm7=Heps2 */
        addss  xmm5, xmm6	/* Update vnbtot directly */
        addss  xmm5, xmm7       /* xmm5=Fp */       
        mulss  xmm7, [esp + _two]       /* two*Heps2 */
        addss  xmm7, xmm6
        addss  xmm7, xmm5 /* xmm7=FF */
        mulss  xmm5, xmm1 /* xmm5=eps*Fp */
        addss  xmm5, xmm4 /* xmm5=VV */

        movaps xmm4, [esp + _c6]
        mulps  xmm7, xmm4        /* fijD */
        mulps  xmm5, xmm4        /* vnb6 */
        addps  xmm0, xmm7 /* add to fscal */

        /* Update vnbtot directly */
        addps  xmm5, [esp + _vnbtot]
        movaps [esp + _vnbtot], xmm5

        /* repulsion */
        movlps xmm5, [esi + eax*4 + 32] /* got half repulsion table */
        movaps xmm4, xmm5
        shufps xmm4, xmm4, 0b10001000
        shufps xmm5, xmm5, 0b11011101

        movlps xmm7, [esi + eax*4 + 40] /* other half of repulsion table */
        movaps xmm6, xmm7
        shufps xmm6, xmm6, 0b10001000
        shufps xmm7, xmm7, 0b11011101
        /* repulsion table ready, in xmm4-xmm7 */	
        mulss  xmm6, xmm1       /* xmm6=Geps */
        mulss  xmm7, xmm2       /* xmm7=Heps2 */
        addss  xmm5, xmm6
        addss  xmm5, xmm7       /* xmm5=Fp */       
        mulss  xmm7, [esp + _two]       /* two*Heps2 */
        addss  xmm7, xmm6
        addss  xmm7, xmm5 /* xmm7=FF */
        mulss  xmm5, xmm1 /* xmm5=eps*Fp */
        addss  xmm5, xmm4 /* xmm5=VV */

        movaps xmm4, [esp + _c12]
        mulps  xmm7, xmm4        /* fijD */
        mulps  xmm5, xmm4        /* vnb12 */
        addps  xmm7, xmm0 /* add to fscal */
        addps  xmm5, [esp + _vnbtot] /* total nonbonded potential in xmm5 */

	xorps  xmm4, xmm4
        movd eax, mm0   
        movd ecx, mm1
        movd edx, mm2	
		
	mulps  xmm7, [esp + _rinvO] /* total fscal now in xmm7 */
        movaps [esp + _vnbtot], xmm5
	mulps  xmm7, [esp + _tsc]
	subps xmm4, xmm7

	movaps xmm0, [esp + _dxO]
	movaps xmm1, [esp + _dyO]
	movaps xmm2, [esp + _dzO]

	mulps  xmm0, xmm4
	mulps  xmm1, xmm4
	mulps  xmm2, xmm4 /* xmm0-xmm2 now contains tx-tz (partial force) */
	movss  xmm3, [esp + _fixO]	
	movss  xmm4, [esp + _fiyO]	
	movss  xmm5, [esp + _fizO]	
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [esp + _fixO], xmm3	
	movss  [esp + _fiyO], xmm4	
	movss  [esp + _fizO], xmm5	/* updated the O force now do the H's */
	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2
	shufps xmm3, xmm3, 0b11100110	/* shift right */
	shufps xmm4, xmm4, 0b11100110
	shufps xmm5, xmm5, 0b11100110
	addss  xmm3, [esp + _fixH1]
	addss  xmm4, [esp + _fiyH1]
	addss  xmm5, [esp + _fizH1]
	movss  [esp + _fixH1], xmm3	
	movss  [esp + _fiyH1], xmm4	
	movss  [esp + _fizH1], xmm5	/* updated the H1 force */

	mov edi, [ebp + _faction]
	shufps xmm3, xmm3, 0b11100111	/* shift right */
	shufps xmm4, xmm4, 0b11100111
	shufps xmm5, xmm5, 0b11100111
	addss  xmm3, [esp + _fixH2]
	addss  xmm4, [esp + _fiyH2]
	addss  xmm5, [esp + _fizH2]
	movss  [esp + _fixH2], xmm3	
	movss  [esp + _fiyH2], xmm4	
	movss  [esp + _fizH2], xmm5	/* updated the H2 force */

	/* the fj's - start by accumulating the tx/ty/tz force in xmm0, xmm1 */
	xorps  xmm5, xmm5
	movaps xmm3, xmm0
	movlps xmm6, [edi + eax*4]
	movss  xmm7, [edi + eax*4 + 8]
	unpcklps xmm3, xmm1
	movlhps  xmm3, xmm5	
	unpckhps xmm0, xmm1		
	addps    xmm0, xmm3
	movhlps  xmm3, xmm0	
	addps    xmm0, xmm3	/* x,y sum in xmm0 */

	movhlps  xmm1, xmm2
	addss    xmm2, xmm1
	shufps   xmm1, xmm1, 1 
	addss    xmm2, xmm1    /* z sum in xmm2 */
	subps    xmm6, xmm0
	subss    xmm7, xmm2
	
	movlps [edi + eax*4],     xmm6
	movss  [edi + eax*4 + 8], xmm7

	dec dword ptr [esp + _innerk]
	jz    .i3320_updateouterdata
	jmp   .i3320_odd_loop
.i3320_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate  Oi forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixO]
	movaps xmm1, [esp + _fiyO]
	movaps xmm2, [esp + _fizO]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	movaps xmm6, xmm0
	movss xmm7, xmm2
	movlhps xmm6, xmm1
	shufps  xmm6, xmm6, 0b1000	

	/* accumulate H1i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH1]
	movaps xmm1, [esp + _fiyH1]
	movaps xmm2, [esp + _fizH1]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 12]
	movss  xmm4, [edi + ecx*4 + 16]
	movss  xmm5, [edi + ecx*4 + 20]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 12], xmm3
	movss  [edi + ecx*4 + 16], xmm4
	movss  [edi + ecx*4 + 20], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* accumulate H2i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH2]
	movaps xmm1, [esp + _fiyH2]
	movaps xmm2, [esp + _fizH2]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 24]
	movss  xmm4, [edi + ecx*4 + 28]
	movss  xmm5, [edi + ecx*4 + 32]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 24], xmm3
	movss  [edi + ecx*4 + 28], xmm4
	movss  [edi + ecx*4 + 32], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* increment fshift force */ 
	movlps  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 8]
	addps  xmm3, xmm6
	addss  xmm4, xmm7
	movlps  [esi + edx*4],    xmm3
	movss  [esi + edx*4 + 8], xmm4

	mov   edx, [ebp + _gid]  
	mov   edx, [edx]
	add   [ebp + _gid],  4	

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		
        
	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i3320_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i3320_outer
.i3320_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 792
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret
	

	
.globl inl3330_sse
	.type inl3330_sse,@function
inl3330_sse:	
.equ		_nri,		8
.equ		_iinr,		12
.equ		_jindex,	16
.equ		_jjnr,		20
.equ		_shift,		24
.equ		_shiftvec,	28
.equ		_fshift,	32
.equ		_gid,		36
.equ		_pos,		40		
.equ		_faction,	44
.equ		_charge,	48
.equ		_facel,		52
.equ		_Vc,		56
.equ		_type,		60
.equ		_ntype,		64
.equ		_nbfp,		68	
.equ		_Vnb,		72
.equ		_tabscale,	76
.equ		_VFtab,		80
	/* stack offsets for local variables */ 
	/* bottom of stack is cache-aligned for sse use */
.equ		_ixO,		0
.equ		_iyO,		16
.equ		_izO,		32
.equ		_ixH1,		48
.equ		_iyH1,		64
.equ		_izH1,		80
.equ		_ixH2,		96
.equ		_iyH2,		112
.equ		_izH2,		128
.equ		_jxO,		144
.equ		_jyO,		160
.equ		_jzO,		176
.equ		_jxH1,		192
.equ		_jyH1,		208
.equ		_jzH1,		224
.equ		_jxH2,		240
.equ		_jyH2,		256
.equ		_jzH2,		272
.equ		_dxOO,		288
.equ		_dyOO,		304
.equ		_dzOO,		320	
.equ		_dxOH1,		336
.equ		_dyOH1,		352
.equ		_dzOH1,		368	
.equ		_dxOH2,		384
.equ		_dyOH2,		400
.equ		_dzOH2,		416	
.equ		_dxH1O,		432
.equ		_dyH1O,		448
.equ		_dzH1O,		464	
.equ		_dxH1H1,	480
.equ		_dyH1H1,	496
.equ		_dzH1H1,	512	
.equ		_dxH1H2,	528
.equ		_dyH1H2,	544
.equ		_dzH1H2,	560	
.equ		_dxH2O,		576
.equ		_dyH2O,		592
.equ		_dzH2O,		608	
.equ		_dxH2H1,	624
.equ		_dyH2H1,	640
.equ		_dzH2H1,	656	
.equ		_dxH2H2,	672
.equ		_dyH2H2,	688
.equ		_dzH2H2,	704
.equ		_qqOO,		720
.equ		_qqOH,		736
.equ		_qqHH,		752
.equ		_two,		768
.equ		_tsc,		784
.equ		_c6,		800
.equ		_c12,		816		 
.equ		_vctot,		832
.equ		_vnbtot,	848
.equ		_fixO,		864
.equ		_fiyO,		880
.equ		_fizO,		896
.equ		_fixH1,		912
.equ		_fiyH1,		928
.equ		_fizH1,		944
.equ		_fixH2,		960
.equ		_fiyH2,		976
.equ		_fizH2,		992
.equ		_fjxO,		1008
.equ		_fjyO,		1024
.equ		_fjzO,		1040
.equ		_fjxH1,		1056
.equ		_fjyH1,		1072
.equ		_fjzH1,		1088
.equ		_fjxH2,		1104
.equ		_fjyH2,		1120
.equ		_fjzH2,		1136
.equ		_half,		1152
.equ		_three,		1168
.equ		_rsqOO,		1184
.equ		_rsqOH1,	1200
.equ		_rsqOH2,	1216
.equ		_rsqH1O,	1232
.equ		_rsqH1H1,	1248
.equ		_rsqH1H2,	1264
.equ		_rsqH2O,	1280
.equ		_rsqH2H1,	1296
.equ		_rsqH2H2,	1312
.equ		_rinvOO,	1328
.equ		_rinvOH1,	1344
.equ		_rinvOH2,	1360
.equ		_rinvH1O,	1376
.equ		_rinvH1H1,	1392
.equ		_rinvH1H2,	1408
.equ		_rinvH2O,	1424
.equ		_rinvH2H1,	1440
.equ		_rinvH2H2,	1456
.equ		_fstmp,		1472	
.equ		_is3,		1488
.equ		_ii3,		1492
.equ		_innerjjnr,	1496
.equ		_innerk,	1500
.equ		_salign,	1504							
	push ebp
	mov ebp,esp	
        push eax
        push ebx
        push ecx
        push edx
	push esi
	push edi
	sub esp, 1508		/* local stack space */
	mov  eax, esp
	and  eax, 0xf
	sub esp, eax
	mov [esp + _salign], eax

	emms

	movups xmm0, [sse_half]
	movups xmm1, [sse_two]
	movups xmm2, [sse_three]
	movss xmm3, [ebp + _tabscale]
	movaps [esp + _half],  xmm0
	movaps [esp + _two],  xmm1
	movaps [esp + _three], xmm2
	shufps xmm3, xmm3, 0
	movaps [esp + _tsc],  xmm3

	/* assume we have at least one i particle - start directly */
	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	mov   ebx, [ecx]	        /* ebx =ii */

	mov   edx, [ebp + _charge]
	movss xmm3, [edx + ebx*4]	
	movss xmm4, xmm3	
	movss xmm5, [edx + ebx*4 + 4]	
	movss xmm6, [ebp + _facel]
	mulss  xmm3, xmm3
	mulss  xmm4, xmm5
	mulss  xmm5, xmm5
	mulss  xmm3, xmm6
	mulss  xmm4, xmm6
	mulss  xmm5, xmm6
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _qqOO], xmm3
	movaps [esp + _qqOH], xmm4
	movaps [esp + _qqHH], xmm5
		
	xorps xmm0, xmm0
	mov   edx, [ebp + _type]
	mov   ecx, [edx + ebx*4]
	shl   ecx, 1
	mov   edx, ecx
	imul  ecx, [ebp + _ntype]      /* ecx = ntia = 2*ntype*type[ii0] */
	add   edx, ecx
	mov   eax, [ebp + _nbfp]
	movlps xmm0, [eax + edx*4] 
	movaps xmm1, xmm0
	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0b01010101
	movaps [esp + _c6], xmm0
	movaps [esp + _c12], xmm1

.i3330_outer:
	mov   eax, [ebp + _shift]      /* eax = pointer into shift[] */
	mov   ebx, [eax]		/* ebx=shift[n] */
	add   [ebp + _shift],  4  /* advance pointer one step */
	
	lea   ebx, [ebx + ebx*2]        /* ebx=3*is */
	mov   [esp + _is3],ebx    	/* store is3 */

	mov   eax, [ebp + _shiftvec]   /* eax = base of shiftvec[] */

	movss xmm0, [eax + ebx*4]
	movss xmm1, [eax + ebx*4 + 4]
	movss xmm2, [eax + ebx*4 + 8] 

	mov   ecx, [ebp + _iinr]       /* ecx = pointer into iinr[] */	
	add   [ebp + _iinr],  4   /* advance pointer */
	mov   ebx, [ecx]	        /* ebx =ii */

	lea   ebx, [ebx + ebx*2]	/* ebx = 3*ii=ii3 */
	mov   eax, [ebp + _pos]        /* eax = base of pos[] */ 
	mov   [esp + _ii3], ebx	
	
	movaps xmm3, xmm0
	movaps xmm4, xmm1
	movaps xmm5, xmm2
	addss xmm3, [eax + ebx*4]
	addss xmm4, [eax + ebx*4 + 4]
	addss xmm5, [eax + ebx*4 + 8]		
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixO], xmm3
	movaps [esp + _iyO], xmm4
	movaps [esp + _izO], xmm5

	movss xmm3, xmm0
	movss xmm4, xmm1
	movss xmm5, xmm2
	addss xmm0, [eax + ebx*4 + 12]
	addss xmm1, [eax + ebx*4 + 16]
	addss xmm2, [eax + ebx*4 + 20]		
	addss xmm3, [eax + ebx*4 + 24]
	addss xmm4, [eax + ebx*4 + 28]
	addss xmm5, [eax + ebx*4 + 32]		

	shufps xmm0, xmm0, 0
	shufps xmm1, xmm1, 0
	shufps xmm2, xmm2, 0
	shufps xmm3, xmm3, 0
	shufps xmm4, xmm4, 0
	shufps xmm5, xmm5, 0
	movaps [esp + _ixH1], xmm0
	movaps [esp + _iyH1], xmm1
	movaps [esp + _izH1], xmm2
	movaps [esp + _ixH2], xmm3
	movaps [esp + _iyH2], xmm4
	movaps [esp + _izH2], xmm5

	/* clear vctot and i forces */
	xorps xmm4, xmm4
	movaps [esp + _vctot], xmm4
	movaps [esp + _vnbtot], xmm4
	movaps [esp + _fixO], xmm4
	movaps [esp + _fiyO], xmm4
	movaps [esp + _fizO], xmm4
	movaps [esp + _fixH1], xmm4
	movaps [esp + _fiyH1], xmm4
	movaps [esp + _fizH1], xmm4
	movaps [esp + _fixH2], xmm4
	movaps [esp + _fiyH2], xmm4
	movaps [esp + _fizH2], xmm4
	
	mov   eax, [ebp + _jindex]
	mov   ecx, [eax]	         /* jindex[n] */
	mov   edx, [eax + 4]	         /* jindex[n+1] */
	add   [ebp + _jindex],  4
	sub   edx, ecx                   /* number of innerloop atoms */

	mov   esi, [ebp + _pos]
	mov   edi, [ebp + _faction]	
	mov   eax, [ebp + _jjnr]
	shl   ecx, 2
	add   eax, ecx
	mov   [esp + _innerjjnr], eax     /* pointer to jjnr[nj0] */
	sub   edx,  4
	mov   [esp + _innerk], edx        /* number of innerloop atoms */
	jge   .i3330_unroll_loop
	jmp   .i3330_single_check
.i3330_unroll_loop:	
	/* quad-unroll innerloop here */
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */

	mov   eax, [edx]	
	mov   ebx, [edx + 4] 
	mov   ecx, [edx + 8]
	mov   edx, [edx + 12]             /* eax-edx=jnr1-4 */
	
	add   [esp + _innerjjnr],  16 /* advance pointer (unrolled 4) */

	mov esi, [ebp + _pos]       /* base of pos[] */

	lea   eax, [eax + eax*2]         /* replace jnr with j3 */
	lea   ebx, [ebx + ebx*2]	
	lea   ecx, [ecx + ecx*2]         /* replace jnr with j3 */
	lea   edx, [edx + edx*2]	
	
	/* move j coordinates to local temp variables */
	movlps xmm2, [esi + eax*4]
	movlps xmm3, [esi + eax*4 + 12]
	movlps xmm4, [esi + eax*4 + 24]

	movlps xmm5, [esi + ebx*4]
	movlps xmm6, [esi + ebx*4 + 12]
	movlps xmm7, [esi + ebx*4 + 24]

	movhps xmm2, [esi + ecx*4]
	movhps xmm3, [esi + ecx*4 + 12]
	movhps xmm4, [esi + ecx*4 + 24]

	movhps xmm5, [esi + edx*4]
	movhps xmm6, [esi + edx*4 + 12]
	movhps xmm7, [esi + edx*4 + 24]

	/* current state: */	
	/* xmm2= jxOa  jyOa  jxOc  jyOc */
	/* xmm3= jxH1a jyH1a jxH1c jyH1c */
	/* xmm4= jxH2a jyH2a jxH2c jyH2c */
	/* xmm5= jxOb  jyOb  jxOd  jyOd */
	/* xmm6= jxH1b jyH1b jxH1d jyH1d */
	/* xmm7= jxH2b jyH2b jxH2d jyH2d */
	
	movaps xmm0, xmm2
	movaps xmm1, xmm3
	unpcklps xmm0, xmm5	/* xmm0= jxOa  jxOb  jyOa  jyOb */
	unpcklps xmm1, xmm6	/* xmm1= jxH1a jxH1b jyH1a jyH1b */
	unpckhps xmm2, xmm5	/* xmm2= jxOc  jxOd  jyOc  jyOd */
	unpckhps xmm3, xmm6	/* xmm3= jxH1c jxH1d jyH1c jyH1d  */
	movaps xmm5, xmm4
	movaps   xmm6, xmm0
	unpcklps xmm4, xmm7	/* xmm4= jxH2a jxH2b jyH2a jyH2b */		
	unpckhps xmm5, xmm7	/* xmm5= jxH2c jxH2d jyH2c jyH2d */
	movaps   xmm7, xmm1
	movlhps  xmm0, xmm2	/* xmm0= jxOa  jxOb  jxOc  jxOd  */
	movaps [esp + _jxO], xmm0
	movhlps  xmm2, xmm6	/* xmm2= jyOa  jyOb  jyOc  jyOd */
	movaps [esp + _jyO], xmm2
	movlhps  xmm1, xmm3
	movaps [esp + _jxH1], xmm1
	movhlps  xmm3, xmm7
	movaps   xmm6, xmm4
	movaps [esp + _jyH1], xmm3
	movlhps  xmm4, xmm5
	movaps [esp + _jxH2], xmm4
	movhlps  xmm5, xmm6
	movaps [esp + _jyH2], xmm5

	movss  xmm0, [esi + eax*4 + 8]
	movss  xmm1, [esi + eax*4 + 20]
	movss  xmm2, [esi + eax*4 + 32]

	movss  xmm3, [esi + ecx*4 + 8]
	movss  xmm4, [esi + ecx*4 + 20]
	movss  xmm5, [esi + ecx*4 + 32]

	movhps xmm0, [esi + ebx*4 + 4]
	movhps xmm1, [esi + ebx*4 + 16]
	movhps xmm2, [esi + ebx*4 + 28]
	
	movhps xmm3, [esi + edx*4 + 4]
	movhps xmm4, [esi + edx*4 + 16]
	movhps xmm5, [esi + edx*4 + 28]
	
	shufps xmm0, xmm3, 0b11001100
	shufps xmm1, xmm4, 0b11001100
	shufps xmm2, xmm5, 0b11001100
	movaps [esp + _jzO],  xmm0
	movaps [esp + _jzH1],  xmm1
	movaps [esp + _jzH2],  xmm2

	movaps xmm0, [esp + _ixO]
	movaps xmm1, [esp + _iyO]
	movaps xmm2, [esp + _izO]
	movaps xmm3, [esp + _ixO]
	movaps xmm4, [esp + _iyO]
	movaps xmm5, [esp + _izO]
	subps  xmm0, [esp + _jxO]
	subps  xmm1, [esp + _jyO]
	subps  xmm2, [esp + _jzO]
	subps  xmm3, [esp + _jxH1]
	subps  xmm4, [esp + _jyH1]
	subps  xmm5, [esp + _jzH1]
	movaps [esp + _dxOO], xmm0
	movaps [esp + _dyOO], xmm1
	movaps [esp + _dzOO], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxOH1], xmm3
	movaps [esp + _dyOH1], xmm4
	movaps [esp + _dzOH1], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqOO], xmm0
	movaps [esp + _rsqOH1], xmm3

	movaps xmm0, [esp + _ixO]
	movaps xmm1, [esp + _iyO]
	movaps xmm2, [esp + _izO]
	movaps xmm3, [esp + _ixH1]
	movaps xmm4, [esp + _iyH1]
	movaps xmm5, [esp + _izH1]
	subps  xmm0, [esp + _jxH2]
	subps  xmm1, [esp + _jyH2]
	subps  xmm2, [esp + _jzH2]
	subps  xmm3, [esp + _jxO]
	subps  xmm4, [esp + _jyO]
	subps  xmm5, [esp + _jzO]
	movaps [esp + _dxOH2], xmm0
	movaps [esp + _dyOH2], xmm1
	movaps [esp + _dzOH2], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH1O], xmm3
	movaps [esp + _dyH1O], xmm4
	movaps [esp + _dzH1O], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqOH2], xmm0
	movaps [esp + _rsqH1O], xmm3

	movaps xmm0, [esp + _ixH1]
	movaps xmm1, [esp + _iyH1]
	movaps xmm2, [esp + _izH1]
	movaps xmm3, [esp + _ixH1]
	movaps xmm4, [esp + _iyH1]
	movaps xmm5, [esp + _izH1]
	subps  xmm0, [esp + _jxH1]
	subps  xmm1, [esp + _jyH1]
	subps  xmm2, [esp + _jzH1]
	subps  xmm3, [esp + _jxH2]
	subps  xmm4, [esp + _jyH2]
	subps  xmm5, [esp + _jzH2]
	movaps [esp + _dxH1H1], xmm0
	movaps [esp + _dyH1H1], xmm1
	movaps [esp + _dzH1H1], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH1H2], xmm3
	movaps [esp + _dyH1H2], xmm4
	movaps [esp + _dzH1H2], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm3, xmm4
	addps  xmm3, xmm5
	movaps [esp + _rsqH1H1], xmm0
	movaps [esp + _rsqH1H2], xmm3

	movaps xmm0, [esp + _ixH2]
	movaps xmm1, [esp + _iyH2]
	movaps xmm2, [esp + _izH2]
	movaps xmm3, [esp + _ixH2]
	movaps xmm4, [esp + _iyH2]
	movaps xmm5, [esp + _izH2]
	subps  xmm0, [esp + _jxO]
	subps  xmm1, [esp + _jyO]
	subps  xmm2, [esp + _jzO]
	subps  xmm3, [esp + _jxH1]
	subps  xmm4, [esp + _jyH1]
	subps  xmm5, [esp + _jzH1]
	movaps [esp + _dxH2O], xmm0
	movaps [esp + _dyH2O], xmm1
	movaps [esp + _dzH2O], xmm2
	mulps  xmm0, xmm0
	mulps  xmm1, xmm1
	mulps  xmm2, xmm2
	movaps [esp + _dxH2H1], xmm3
	movaps [esp + _dyH2H1], xmm4
	movaps [esp + _dzH2H1], xmm5
	mulps  xmm3, xmm3
	mulps  xmm4, xmm4
	mulps  xmm5, xmm5
	addps  xmm0, xmm1
	addps  xmm0, xmm2
	addps  xmm4, xmm3
	addps  xmm4, xmm5
	movaps [esp + _rsqH2O], xmm0
	movaps [esp + _rsqH2H1], xmm4

	movaps xmm0, [esp + _ixH2]
	movaps xmm1, [esp + _iyH2]
	movaps xmm2, [esp + _izH2]
	subps  xmm0, [esp + _jxH2]
	subps  xmm1, [esp + _jyH2]
	subps  xmm2, [esp + _jzH2]
	movaps [esp + _dxH2H2], xmm0
	movaps [esp + _dyH2H2], xmm1
	movaps [esp + _dzH2H2], xmm2
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2
	movaps [esp + _rsqH2H2], xmm0
		
	/* start doing invsqrt use rsq values in xmm0, xmm4 */
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] /* rinvH2H2 */
	mulps   xmm7, [esp + _half] /* rinvH2H1 */
	movaps  [esp + _rinvH2H2], xmm3
	movaps  [esp + _rinvH2H1], xmm7
		
	rsqrtps xmm1, [esp + _rsqOO]
	rsqrtps xmm5, [esp + _rsqOH1]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqOO]
	mulps   xmm5, [esp + _rsqOH1]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvOO], xmm3
	movaps  [esp + _rinvOH1], xmm7
	
	rsqrtps xmm1, [esp + _rsqOH2]
	rsqrtps xmm5, [esp + _rsqH1O]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqOH2]
	mulps   xmm5, [esp + _rsqH1O]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvOH2], xmm3
	movaps  [esp + _rinvH1O], xmm7
	
	rsqrtps xmm1, [esp + _rsqH1H1]
	rsqrtps xmm5, [esp + _rsqH1H2]
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, [esp + _rsqH1H1]
	mulps   xmm5, [esp + _rsqH1H2]
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] 
	mulps   xmm7, [esp + _half]
	movaps  [esp + _rinvH1H1], xmm3
	movaps  [esp + _rinvH1H2], xmm7
	
	rsqrtps xmm1, [esp + _rsqH2O]
	movaps  xmm2, xmm1
	mulps   xmm1, xmm1
	movaps  xmm3, [esp + _three]
	mulps   xmm1, [esp + _rsqH2O]
	subps   xmm3, xmm1
	mulps   xmm3, xmm2
	mulps   xmm3, [esp + _half] 
	movaps  [esp + _rinvH2O], xmm3

	/* start with OO interaction */
	movaps xmm0, [esp + _rinvOO]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqOO] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]
		
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2
	
        movd mm0, eax
        movd mm1, ebx
        movd mm2, ecx
        movd mm3, edx

        mov  esi, [ebp + _VFtab]
        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        lea   eax, [eax + eax*2]
        lea   ebx, [ebx + ebx*2]
        lea   ecx, [ecx + ecx*2]
        lea   edx, [edx + edx*2]

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqOO]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */
        /* increment vcoul - then we can get rid of mm5 */
        /* update vctot */
        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5 

        /* put scalar force on stack temporarily */
        movaps [esp + _fstmp], xmm3

        /* dispersion */
        movlps xmm5, [esi + eax*4 + 16]
        movlps xmm7, [esi + ecx*4 + 16]
        movhps xmm5, [esi + ebx*4 + 16]
        movhps xmm7, [esi + edx*4 + 16] /* got half dispersion table */
        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 24]
        movlps xmm3, [esi + ecx*4 + 24]
        movhps xmm7, [esi + ebx*4 + 24]
        movhps xmm3, [esi + edx*4 + 24] /* other half of dispersion table */
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* dispersion table ready, in xmm4-xmm7 */
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */

        movaps xmm4, [esp + _c6]
        mulps  xmm7, xmm4        /* fijD */
        mulps  xmm5, xmm4        /* vnb6 */
        addps  xmm7, [esp + _fstmp] /* add to fscal */

        /* put scalar force on stack Update vnbtot directly */
        addps  xmm5, [esp + _vnbtot]
        movaps [esp + _fstmp], xmm7
        movaps [esp + _vnbtot], xmm5

        /* repulsion */
        movlps xmm5, [esi + eax*4 + 32]
        movlps xmm7, [esi + ecx*4 + 32]
        movhps xmm5, [esi + ebx*4 + 32]
        movhps xmm7, [esi + edx*4 + 32] /* got half repulsion table */
        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 40]
        movlps xmm3, [esi + ecx*4 + 40]
        movhps xmm7, [esi + ebx*4 + 40]
        movhps xmm3, [esi + edx*4 + 40] /* other half of repulsion table */
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* table ready, in xmm4-xmm7 */
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
 
        movaps xmm4, [esp + _c12]
        mulps  xmm7, xmm4 /* fijR */
        mulps  xmm5, xmm4 /* vnb12 */
        addps  xmm7, [esp + _fstmp] 

        addps  xmm5, [esp + _vnbtot]
        movaps [esp + _vnbtot], xmm5
        xorps  xmm1, xmm1

        mulps xmm7, [esp + _tsc]
        mulps xmm7, xmm0
        subps  xmm1, xmm7

	movaps xmm0, xmm1
	movaps xmm2, xmm1		

	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOO]
	mulps xmm1, [esp + _dyOO]
	mulps xmm2, [esp + _dzOO]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* O-H1 interaction */
	movaps xmm0, [esp + _rinvOH1]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqOH1] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        lea   eax, [eax + eax*2]
        lea   ebx, [ebx + ebx*2]
        lea   ecx, [ecx + ecx*2]
        lea   edx, [edx + edx*2]

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqOH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOH1]
	mulps xmm1, [esp + _dyOH1]
	mulps xmm2, [esp + _dzOH1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* O-H2 interaction */ 
	movaps xmm0, [esp + _rinvOH2]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqOH2] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        lea   eax, [eax + eax*2]
        lea   ebx, [ebx + ebx*2]
        lea   ecx, [ecx + ecx*2]
        lea   edx, [edx + edx*2]

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqOH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	xorps xmm3, xmm3
	movaps xmm4, xmm3
	movaps xmm5, xmm3
	mulps xmm0, [esp + _dxOH2]
	mulps xmm1, [esp + _dyOH2]
	mulps xmm2, [esp + _dzOH2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixO]
	addps xmm1, [esp + _fiyO]
	addps xmm2, [esp + _fizO]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixO], xmm0
	movaps [esp + _fiyO], xmm1
	movaps [esp + _fizO], xmm2

	/* H1-O interaction */
	movaps xmm0, [esp + _rinvH1O]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH1O] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        lea   eax, [eax + eax*2]
        lea   ebx, [ebx + ebx*2]
        lea   ecx, [ecx + ecx*2]
        lea   edx, [edx + edx*2]

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqOH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [esp + _fjxO]
	movaps xmm4, [esp + _fjyO]
	movaps xmm5, [esp + _fjzO]
	mulps xmm0, [esp + _dxH1O]
	mulps xmm1, [esp + _dyH1O]
	mulps xmm2, [esp + _dzH1O]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H1-H1 interaction */
	movaps xmm0, [esp + _rinvH1H1]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH1H1] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        lea   eax, [eax + eax*2]
        lea   ebx, [ebx + ebx*2]
        lea   ecx, [ecx + ecx*2]
        lea   edx, [edx + edx*2]

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqHH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [esp + _fjxH1]
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	mulps xmm0, [esp + _dxH1H1]
	mulps xmm1, [esp + _dyH1H1]
	mulps xmm2, [esp + _dzH1H1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H1-H2 interaction */
	movaps xmm0, [esp + _rinvH1H2]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH1H2] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        lea   eax, [eax + eax*2]
        lea   ebx, [ebx + ebx*2]
        lea   ecx, [ecx + ecx*2]
        lea   edx, [edx + edx*2]

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqHH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [esp + _fjxH2]
	movaps xmm4, [esp + _fjyH2]
	movaps xmm5, [esp + _fjzH2]
	mulps xmm0, [esp + _dxH1H2]
	mulps xmm1, [esp + _dyH1H2]
	mulps xmm2, [esp + _dzH1H2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH1]
	addps xmm1, [esp + _fiyH1]
	addps xmm2, [esp + _fizH1]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixH1], xmm0
	movaps [esp + _fiyH1], xmm1
	movaps [esp + _fizH1], xmm2

	/* H2-O interaction */
	movaps xmm0, [esp + _rinvH2O]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH2O] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        lea   eax, [eax + eax*2]
        lea   ebx, [ebx + ebx*2]
        lea   ecx, [ecx + ecx*2]
        lea   edx, [edx + edx*2]

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqOH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1

	movaps xmm3, [esp + _fjxO]
	movaps xmm4, [esp + _fjyO]
	movaps xmm5, [esp + _fjzO]
	mulps xmm0, [esp + _dxH2O]
	mulps xmm1, [esp + _dyH2O]
	mulps xmm2, [esp + _dzH2O]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxO], xmm3
	movaps [esp + _fjyO], xmm4
	movaps [esp + _fjzO], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	/* H2-H1 interaction */
	movaps xmm0, [esp + _rinvH2H1]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH2H1] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        lea   eax, [eax + eax*2]
        lea   ebx, [ebx + ebx*2]
        lea   ecx, [ecx + ecx*2]
        lea   edx, [edx + edx*2]

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqHH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [esp + _fjxH1]
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	mulps xmm0, [esp + _dxH2H1]
	mulps xmm1, [esp + _dyH2H1]
	mulps xmm2, [esp + _dzH2H1]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxH1], xmm3
	movaps [esp + _fjyH1], xmm4
	movaps [esp + _fjzH1], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	/* H2-H2 interaction */
	movaps xmm0, [esp + _rinvH2H2]
	movaps xmm1, xmm0
	mulps  xmm1, [esp + _rsqH2H2] /* xmm1=r */
	mulps  xmm1, [esp + _tsc]	
	movhlps xmm2, xmm1
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2

        movd eax, mm6
        psrlq mm6, 32
        movd ecx, mm7
        psrlq mm7, 32
        movd ebx, mm6
        movd edx, mm7

        lea   eax, [eax + eax*2]
        lea   ebx, [ebx + ebx*2]
        lea   ecx, [ecx + ecx*2]
        lea   edx, [edx + edx*2]

        movlps xmm5, [esi + eax*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm5, [esi + ebx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */

        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + eax*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm7, [esi + ebx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 

        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */
        movaps xmm3, [esp + _qqHH]
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point mm5 contains vcoul and mm3 fijC */

        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
	xorps  xmm1, xmm1
	mulps  xmm3,  [esp + _tsc]
	mulps  xmm3, xmm0
	subps  xmm1, xmm3

	movaps xmm0, xmm1
	movaps xmm2, xmm1
	
	movaps xmm3, [esp + _fjxH2]
	movaps xmm4, [esp + _fjyH2]
	movaps xmm5, [esp + _fjzH2]
	mulps xmm0, [esp + _dxH2H2]
	mulps xmm1, [esp + _dyH2H2]
	mulps xmm2, [esp + _dzH2H2]
	subps xmm3, xmm0
	subps xmm4, xmm1
	subps xmm5, xmm2
	addps xmm0, [esp + _fixH2]
	addps xmm1, [esp + _fiyH2]
	addps xmm2, [esp + _fizH2]
	movaps [esp + _fjxH2], xmm3
	movaps [esp + _fjyH2], xmm4
	movaps [esp + _fjzH2], xmm5
	movaps [esp + _fixH2], xmm0
	movaps [esp + _fiyH2], xmm1
	movaps [esp + _fizH2], xmm2

	mov edi, [ebp + _faction]

	movd eax, mm0
	movd ebx, mm1
	movd ecx, mm2
	movd edx, mm3
	
	/* Did all interactions - now update j forces */
	/* 4 j waters with three atoms each - first do a & b j particles */
	movaps xmm0, [esp + _fjxO] /* xmm0= fjxOa  fjxOb  fjxOc  fjxOd */
	movaps xmm1, [esp + _fjyO] /* xmm1= fjyOa  fjyOb  fjyOc  fjyOd */ 
	unpcklps xmm0, xmm1    	   /* xmm0= fjxOa  fjyOa  fjxOb  fjyOb */
	movaps xmm1, [esp + _fjzO]
	movaps xmm2, [esp + _fjxH1]
	movhlps  xmm3, xmm0	   /* xmm3= fjxOb  fjyOb */ 
	unpcklps xmm1, xmm2	   /* xmm1= fjzOa  fjxH1a fjzOb  fjxH1b */
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	unpcklps xmm4, xmm5	   /* xmm4= fjyH1a fjzH1a fjyH1b fjzH1b */
	movaps xmm5, [esp + _fjxH2]
	movaps xmm6, [esp + _fjyH2]
	movhlps  xmm7, xmm4	   /* xmm7= fjyH1b fjzH1b */
	unpcklps xmm5, xmm6	   /* xmm5= fjxH2a fjyH2a fjxH2b fjyH2b */
	movlhps  xmm0, xmm1    	   /* xmm0= fjxOa  fjyOa  fjzOa  fjxH1a */
	shufps   xmm3, xmm1, 0b11100100
                                   /* xmm3= fjxOb  fjyOb  fjzOb  fjxH1b */
	movlhps  xmm4, xmm5   	   /* xmm4= fjyH1a fjzH1a fjxH2a fjyH2a */
	shufps   xmm7, xmm5, 0b11100100
                                   /* xmm7= fjyH1b fjzH1b fjxH2b fjyH2b */
	movups   xmm1, [edi + eax*4]
	movups   xmm2, [edi + eax*4 + 16]
	movups   xmm5, [edi + ebx*4]
	movups   xmm6, [edi + ebx*4 + 16]
	addps    xmm1, xmm0
	addps    xmm2, xmm4
	addps    xmm5, xmm3
	addps    xmm6, xmm7
	movss    xmm0, [edi + eax*4 + 32]
	movss    xmm3, [edi + ebx*4 + 32]
	
	movaps   xmm4, [esp + _fjzH2]
	movaps   xmm7, xmm4
	shufps   xmm7, xmm7, 1
	
	movups   [edi + eax*4],     xmm1
	movups   [edi + eax*4 + 16],xmm2
	movups   [edi + ebx*4],     xmm5
	movups   [edi + ebx*4 + 16],xmm6	
	addss    xmm0, xmm4
	addss    xmm3, xmm7
	movss    [edi + eax*4 + 32], xmm0
	movss    [edi + ebx*4 + 32], xmm3	

	/* then do the second pair (c & d) */
	movaps xmm0, [esp + _fjxO] /* xmm0= fjxOa  fjxOb  fjxOc  fjxOd */
	movaps xmm1, [esp + _fjyO] /* xmm1= fjyOa  fjyOb  fjyOc  fjyOd */ 
	unpckhps xmm0, xmm1	   /* xmm0= fjxOc  fjyOc  fjxOd  fjyOd */
	movaps xmm1, [esp + _fjzO]
	movaps xmm2, [esp + _fjxH1]
	movhlps  xmm3, xmm0	   /* xmm3= fjxOd  fjyOd */ 
	unpckhps xmm1, xmm2	   /* xmm1= fjzOc  fjxH1c fjzOd  fjxH1d */
	movaps xmm4, [esp + _fjyH1]
	movaps xmm5, [esp + _fjzH1]
	unpckhps xmm4, xmm5	   /* xmm4= fjyH1c fjzH1c fjyH1d fjzH1d	*/
	movaps xmm5, [esp + _fjxH2]
	movaps xmm6, [esp + _fjyH2]
	movhlps  xmm7, xmm4	   /* xmm7= fjyH1d fjzH1d */	 
	unpckhps xmm5, xmm6	   /* xmm5= fjxH2c fjyH2c fjxH2d fjyH2d */
	movlhps  xmm0, xmm1	   /* xmm0= fjxOc  fjyOc  fjzOc  fjxH1c */
	shufps   xmm3, xmm1, 0b11100100
                                   /* xmm3= fjxOd  fjyOd fjzOd  fjxH1d */
	movlhps  xmm4, xmm5	   /* xmm4= fjyH1c fjzH1c fjxH2c fjyH2c  */
	shufps   xmm7, xmm5, 0b11100100
                                   /* xmm7= fjyH1d fjzH1d fjxH2d fjyH2d */
	movups   xmm1, [edi + ecx*4]
	movups   xmm2, [edi + ecx*4 + 16]
	movups   xmm5, [edi + edx*4]
	movups   xmm6, [edi + edx*4 + 16]
	addps    xmm1, xmm0
	addps    xmm2, xmm4
	addps    xmm5, xmm3
	addps    xmm6, xmm7
	movss    xmm0, [edi + ecx*4 + 32]
	movss    xmm3, [edi + edx*4 + 32]
	
	movaps   xmm4, [esp + _fjzH2]
	movaps   xmm7, xmm4
	shufps   xmm4, xmm4, 0b10
	shufps   xmm7, xmm7, 0b11
	movups   [edi + ecx*4],     xmm1
	movups   [edi + ecx*4 + 16],xmm2
	movups   [edi + edx*4],     xmm5
	movups   [edi + edx*4 + 16],xmm6	
	addss    xmm0, xmm4
	addss    xmm3, xmm7
	movss    [edi + ecx*4 + 32], xmm0
	movss    [edi + edx*4 + 32], xmm3	
	
	/* should we do one more iteration? */
	sub   [esp + _innerk],  4
	jl    .i3330_single_check
	jmp   .i3330_unroll_loop
.i3330_single_check:
	add   [esp + _innerk],  4
	jnz   .i3330_single_loop
	jmp   .i3330_updateouterdata
.i3330_single_loop:
	mov   edx, [esp + _innerjjnr]     /* pointer to jjnr[k] */
	mov   eax, [edx]	
	add   [esp + _innerjjnr],  4	

	mov esi, [ebp + _pos]
	lea   eax, [eax + eax*2]  

	/* fetch j coordinates */
	xorps xmm3, xmm3
	xorps xmm4, xmm4
	xorps xmm5, xmm5
	movss xmm3, [esi + eax*4]
	movss xmm4, [esi + eax*4 + 4]
	movss xmm5, [esi + eax*4 + 8]

	movlps xmm6, [esi + eax*4 + 12]
	movhps xmm6, [esi + eax*4 + 24]	/* xmm6=jxH1 jyH1 jxH2 jyH2 */
	/* fetch both z coords in one go, to positions 0 and 3 in xmm7 */
	movups xmm7, [esi + eax*4 + 20] /* xmm7=jzH1 jxH2 jyH2 jzH2 */
	shufps xmm6, xmm6, 0b11011000    /* xmm6=jxH1 jxH2 jyH1 jyH2 */
	movlhps xmm3, xmm6      	/* xmm3= jxO   0  jxH1 jxH2 */
	movaps  xmm0, [esp + _ixO]     
	movaps  xmm1, [esp + _iyO]
	movaps  xmm2, [esp + _izO]	
	shufps  xmm4, xmm6, 0b11100100 /* xmm4= jyO   0   jyH1 jyH2 */
	shufps xmm5, xmm7, 0b11000100  /* xmm5= jzO   0   jzH1 jzH2 */
	/* store all j coordinates in jO */ 
	movaps [esp + _jxO], xmm3
	movaps [esp + _jyO], xmm4
	movaps [esp + _jzO], xmm5
	subps  xmm0, xmm3
	subps  xmm1, xmm4
	subps  xmm2, xmm5
	movaps [esp + _dxOO], xmm0
	movaps [esp + _dyOO], xmm1
	movaps [esp + _dzOO], xmm2
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	addps xmm0, xmm1
	addps xmm0, xmm2	/* have rsq in xmm0 */
	
	/* do invsqrt */
	rsqrtps xmm1, xmm0
	movaps  xmm2, xmm1	
	mulps   xmm1, xmm1
	movaps  xmm3, [esp + _three]
	mulps   xmm1, xmm0
	subps   xmm3, xmm1
	mulps   xmm3, xmm2							
	mulps   xmm3, [esp + _half] /* rinv iO - j water */

	movaps  xmm1, xmm3
	mulps   xmm1, xmm0	/* xmm1=r */
	movaps  xmm0, xmm3	/* xmm0=rinv */
	mulps  xmm1, [esp + _tsc]
	
	movhlps xmm2, xmm1	
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2
        movd ebx, mm6
        movd ecx, mm7
        psrlq mm7, 32
        movd edx, mm7		/* table indices in ebx,ecx,edx */

	mov esi, [ebp + _VFtab]
	
        lea   ebx, [ebx + ebx*2]
        lea   ecx, [ecx + ecx*2]
        lea   edx, [edx + edx*2]
	
        movlps xmm5, [esi + ebx*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */
        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + ebx*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */

	xorps  xmm3, xmm3
	/* fetch charges to xmm3 (temporary) */
	movss   xmm3, [esp + _qqOO]
	movhps  xmm3, [esp + _qqOH]
		
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point xmm5 contains vcoul and xmm3 fijC */
	
        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5
        /* put scalar force on stack temporarily */
        movaps [esp + _fstmp], xmm3

        /* dispersion */
	movss  xmm4, [esi + ebx*4 + 16]	
	movss  xmm5, [esi + ebx*4 + 20]	
	movss  xmm6, [esi + ebx*4 + 24]	
	movss  xmm7, [esi + ebx*4 + 28]
        /* dispersion table ready, in xmm4-xmm7 */
        mulss  xmm6, xmm1       /* xmm6=Geps */
        mulss  xmm7, xmm2       /* xmm7=Heps2 */
        addss  xmm5, xmm6
        addss  xmm5, xmm7       /* xmm5=Fp */
        mulss  xmm7, [esp + _two]       /* two*Heps2 */
        addss  xmm7, xmm6
        addss  xmm7, xmm5 /* xmm7=FF */
        mulss  xmm5, xmm1 /* xmm5=eps*Fp */
        addss  xmm5, xmm4 /* xmm5=VV */
	xorps  xmm4, xmm4
        movss  xmm4, [esp + _c6]
        mulps  xmm7, xmm4        /* fijD */
        mulps  xmm5, xmm4        /* vnb6 */
        addps  xmm7, [esp + _fstmp] /* add to fscal */

        /* put scalar force on stack Update vnbtot directly */
        addps  xmm5, [esp + _vnbtot]
        movaps [esp + _fstmp], xmm7
        movaps [esp + _vnbtot], xmm5

        /* repulsion */
	movss  xmm4, [esi + ebx*4 + 32]	
	movss  xmm5, [esi + ebx*4 + 36]	
	movss  xmm6, [esi + ebx*4 + 40]	
	movss  xmm7, [esi + ebx*4 + 44]
        /* table ready, in xmm4-xmm7 */
        mulss  xmm6, xmm1       /* xmm6=Geps */
        mulss  xmm7, xmm2       /* xmm7=Heps2 */
        addss  xmm5, xmm6
        addss  xmm5, xmm7       /* xmm5=Fp */
        mulss  xmm7, [esp + _two]       /* two*Heps2 */
        addss  xmm7, xmm6
        addss  xmm7, xmm5 /* xmm7=FF */
        mulss  xmm5, xmm1 /* xmm5=eps*Fp */
        addss  xmm5, xmm4 /* xmm5=VV */

	xorps  xmm4, xmm4
        movss  xmm4, [esp + _c12]
        mulps  xmm7, xmm4 /* fijR */
        mulps  xmm5, xmm4 /* vnb12 */
        addps  xmm7, [esp + _fstmp] 

        addps  xmm5, [esp + _vnbtot]
        movaps [esp + _vnbtot], xmm5
        xorps  xmm1, xmm1

        mulps xmm7, [esp + _tsc]
        mulps xmm7, xmm0
        subps  xmm1, xmm7

	movaps xmm0, xmm1
	movaps xmm2, xmm1		

	mulps   xmm0, [esp + _dxOO]
	mulps   xmm1, [esp + _dyOO]
	mulps   xmm2, [esp + _dzOO]
	/* initial update for j forces */
	xorps   xmm3, xmm3
	xorps   xmm4, xmm4
	xorps   xmm5, xmm5
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixO]
	addps   xmm1, [esp + _fiyO]
	addps   xmm2, [esp + _fizO]
	movaps  [esp + _fixO], xmm0
	movaps  [esp + _fiyO], xmm1
	movaps  [esp + _fizO], xmm2

	
	/* done with i O Now do i H1 & H2 simultaneously first get i particle coords: */
	movaps  xmm0, [esp + _ixH1]
	movaps  xmm1, [esp + _iyH1]
	movaps  xmm2, [esp + _izH1]	
	movaps  xmm3, [esp + _ixH2] 
	movaps  xmm4, [esp + _iyH2] 
	movaps  xmm5, [esp + _izH2] 
	subps   xmm0, [esp + _jxO]
	subps   xmm1, [esp + _jyO]
	subps   xmm2, [esp + _jzO]
	subps   xmm3, [esp + _jxO]
	subps   xmm4, [esp + _jyO]
	subps   xmm5, [esp + _jzO]
	movaps [esp + _dxH1O], xmm0
	movaps [esp + _dyH1O], xmm1
	movaps [esp + _dzH1O], xmm2
	movaps [esp + _dxH2O], xmm3
	movaps [esp + _dyH2O], xmm4
	movaps [esp + _dzH2O], xmm5
	mulps xmm0, xmm0
	mulps xmm1, xmm1
	mulps xmm2, xmm2
	mulps xmm3, xmm3
	mulps xmm4, xmm4
	mulps xmm5, xmm5
	addps xmm0, xmm1
	addps xmm4, xmm3
	addps xmm0, xmm2	/* have rsqH1 in xmm0 */
	addps xmm4, xmm5	/* have rsqH2 in xmm4 */

	/* start with H1, save H2 data */
	movaps [esp + _rsqH2O], xmm4
	
	/* do invsqrt */
	rsqrtps xmm1, xmm0
	rsqrtps xmm5, xmm4
	movaps  xmm2, xmm1
	movaps  xmm6, xmm5
	mulps   xmm1, xmm1
	mulps   xmm5, xmm5
	movaps  xmm3, [esp + _three]
	movaps  xmm7, xmm3
	mulps   xmm1, xmm0
	mulps   xmm5, xmm4
	subps   xmm3, xmm1
	subps   xmm7, xmm5
	mulps   xmm3, xmm2
	mulps   xmm7, xmm6
	mulps   xmm3, [esp + _half] /* rinv H1 - j water */
	mulps   xmm7, [esp + _half] /* rinv H2 - j water */ 

	/* start with H1, save H2 data */
	movaps [esp + _rinvH2O], xmm7

	movaps xmm1, xmm3
	mulps  xmm1, xmm0	/* xmm1=r */
	movaps xmm0, xmm3	/* xmm0=rinv */
	mulps  xmm1, [esp + _tsc]
	
	movhlps xmm2, xmm1	
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2
        movd ebx, mm6
        movd ecx, mm7
        psrlq mm7, 32
        movd edx, mm7		/* table indices in ebx,ecx,edx */

        lea   ebx, [ebx + ebx*2]
        lea   ecx, [ecx + ecx*2]
        lea   edx, [edx + edx*2]
	
        movlps xmm5, [esi + ebx*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */
        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + ebx*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */

	xorps  xmm3, xmm3
	/* fetch charges to xmm3 (temporary) */
	movss   xmm3, [esp + _qqOH]
	movhps  xmm3, [esp + _qqHH]
		
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point xmm5 contains vcoul and xmm3 fijC */
        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5	

        xorps  xmm1, xmm1

        mulps xmm3, [esp + _tsc]
        mulps xmm3, xmm0
        subps  xmm1, xmm3
	
	movaps  xmm0, xmm1
	movaps  xmm2, xmm1
	mulps   xmm0, [esp + _dxH1O]
	mulps   xmm1, [esp + _dyH1O]
	mulps   xmm2, [esp + _dzH1O]
	/* update forces H1 - j water */
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixH1]
	addps   xmm1, [esp + _fiyH1]
	addps   xmm2, [esp + _fizH1]
	movaps  [esp + _fixH1], xmm0
	movaps  [esp + _fiyH1], xmm1
	movaps  [esp + _fizH1], xmm2
	/* do table for H2 - j water interaction */
	movaps xmm0, [esp + _rinvH2O]
	movaps xmm1, [esp + _rsqH2O]
	mulps  xmm1, xmm0	/* xmm0=rinv, xmm1=r */
	mulps  xmm1, [esp + _tsc]
	
	movhlps xmm2, xmm1	
        cvttps2pi mm6, xmm1
        cvttps2pi mm7, xmm2     /* mm6/mm7 contain lu indices */
        cvtpi2ps xmm3, mm6
        cvtpi2ps xmm2, mm7
	movlhps  xmm3, xmm2
	subps    xmm1, xmm3	/* xmm1=eps */
        movaps xmm2, xmm1
        mulps  xmm2, xmm2       /* xmm2=eps2 */
        pslld mm6, 2
        pslld mm7, 2
        movd ebx, mm6
        movd ecx, mm7
        psrlq mm7, 32
        movd edx, mm7		/* table indices in ebx,ecx,edx */

        lea   ebx, [ebx + ebx*2]
        lea   ecx, [ecx + ecx*2]
        lea   edx, [edx + edx*2]
	
        movlps xmm5, [esi + ebx*4]
        movlps xmm7, [esi + ecx*4]
        movhps xmm7, [esi + edx*4] /* got half coulomb table */
        movaps xmm4, xmm5
        shufps xmm4, xmm7, 0b10001000
        shufps xmm5, xmm7, 0b11011101

        movlps xmm7, [esi + ebx*4 + 8]
        movlps xmm3, [esi + ecx*4 + 8]
        movhps xmm3, [esi + edx*4 + 8] /* other half of coulomb table */ 
        movaps xmm6, xmm7
        shufps xmm6, xmm3, 0b10001000
        shufps xmm7, xmm3, 0b11011101
        /* coulomb table ready, in xmm4-xmm7 */ 
        mulps  xmm6, xmm1       /* xmm6=Geps */
        mulps  xmm7, xmm2       /* xmm7=Heps2 */
        addps  xmm5, xmm6
        addps  xmm5, xmm7       /* xmm5=Fp */
        mulps  xmm7, [esp + _two]       /* two*Heps2 */

	xorps  xmm3, xmm3
	/* fetch charges to xmm3 (temporary) */
	movss   xmm3, [esp + _qqOH]
	movhps  xmm3, [esp + _qqHH]
		
        addps  xmm7, xmm6
        addps  xmm7, xmm5 /* xmm7=FF */
        mulps  xmm5, xmm1 /* xmm5=eps*Fp */
        addps  xmm5, xmm4 /* xmm5=VV */
        mulps  xmm5, xmm3 /* vcoul=qq*VV */ 
        mulps  xmm3, xmm7 /* fijC=FF*qq */
        /* at this point xmm5 contains vcoul and xmm3 fijC */
        addps  xmm5, [esp + _vctot]
        movaps [esp + _vctot], xmm5	

        xorps  xmm1, xmm1

        mulps xmm3, [esp + _tsc]
        mulps xmm3, xmm0
        subps  xmm1, xmm3
	
	movaps  xmm0, xmm1
	movaps  xmm2, xmm1
	
	mulps   xmm0, [esp + _dxH2O]
	mulps   xmm1, [esp + _dyH2O]
	mulps   xmm2, [esp + _dzH2O]
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	subps   xmm3, xmm0
	subps   xmm4, xmm1
	subps   xmm5, xmm2
	mov     esi, [ebp + _faction]
	movaps  [esp + _fjxO], xmm3
	movaps  [esp + _fjyO], xmm4
	movaps  [esp + _fjzO], xmm5
	addps   xmm0, [esp + _fixH2]
	addps   xmm1, [esp + _fiyH2]
	addps   xmm2, [esp + _fizH2]
	movaps  [esp + _fixH2], xmm0
	movaps  [esp + _fiyH2], xmm1
	movaps  [esp + _fizH2], xmm2

	/* update j water forces from local variables */
	movlps  xmm0, [esi + eax*4]
	movlps  xmm1, [esi + eax*4 + 12]
	movhps  xmm1, [esi + eax*4 + 24]
	movaps  xmm3, [esp + _fjxO]
	movaps  xmm4, [esp + _fjyO]
	movaps  xmm5, [esp + _fjzO]
	movaps  xmm6, xmm5
	movaps  xmm7, xmm5
	shufps  xmm6, xmm6, 0b10
	shufps  xmm7, xmm7, 0b11
	addss   xmm5, [esi + eax*4 + 8]
	addss   xmm6, [esi + eax*4 + 20]
	addss   xmm7, [esi + eax*4 + 32]
	movss   [esi + eax*4 + 8], xmm5
	movss   [esi + eax*4 + 20], xmm6
	movss   [esi + eax*4 + 32], xmm7
	movaps   xmm5, xmm3
	unpcklps xmm3, xmm4
	unpckhps xmm5, xmm4
	addps    xmm0, xmm3
	addps    xmm1, xmm5
	movlps  [esi + eax*4], xmm0 
	movlps  [esi + eax*4 + 12], xmm1 
	movhps  [esi + eax*4 + 24], xmm1 
	
	dec dword ptr [esp + _innerk]
	jz    .i3330_updateouterdata
	jmp   .i3330_single_loop
.i3330_updateouterdata:
	mov   ecx, [esp + _ii3]
	mov   edi, [ebp + _faction]
	mov   esi, [ebp + _fshift]
	mov   edx, [esp + _is3]

	/* accumulate  Oi forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixO]
	movaps xmm1, [esp + _fiyO] 
	movaps xmm2, [esp + _fizO]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4]
	movss  xmm4, [edi + ecx*4 + 4]
	movss  xmm5, [edi + ecx*4 + 8]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4],     xmm3
	movss  [edi + ecx*4 + 4], xmm4
	movss  [edi + ecx*4 + 8], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	movaps xmm6, xmm0
	movss xmm7, xmm2
	movlhps xmm6, xmm1
	shufps  xmm6, xmm6, 0b1000	

	/* accumulate H1i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH1]
	movaps xmm1, [esp + _fiyH1]
	movaps xmm2, [esp + _fizH1]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 in xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 12]
	movss  xmm4, [edi + ecx*4 + 16]
	movss  xmm5, [edi + ecx*4 + 20]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 12], xmm3
	movss  [edi + ecx*4 + 16], xmm4
	movss  [edi + ecx*4 + 20], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* accumulate H2i forces in xmm0, xmm1, xmm2 */
	movaps xmm0, [esp + _fixH2]
	movaps xmm1, [esp + _fiyH2]
	movaps xmm2, [esp + _fizH2]

	movhlps xmm3, xmm0
	movhlps xmm4, xmm1
	movhlps xmm5, xmm2
	addps  xmm0, xmm3
	addps  xmm1, xmm4
	addps  xmm2, xmm5 /* sum is in 1/2 i xmm0-xmm2 */

	movaps xmm3, xmm0	
	movaps xmm4, xmm1	
	movaps xmm5, xmm2	

	shufps xmm3, xmm3, 1
	shufps xmm4, xmm4, 1
	shufps xmm5, xmm5, 1
	addss  xmm0, xmm3
	addss  xmm1, xmm4
	addss  xmm2, xmm5	/* xmm0-xmm2 has single force in pos0 */

	/* increment i force */
	movss  xmm3, [edi + ecx*4 + 24]
	movss  xmm4, [edi + ecx*4 + 28]
	movss  xmm5, [edi + ecx*4 + 32]
	addss  xmm3, xmm0
	addss  xmm4, xmm1
	addss  xmm5, xmm2
	movss  [edi + ecx*4 + 24], xmm3
	movss  [edi + ecx*4 + 28], xmm4
	movss  [edi + ecx*4 + 32], xmm5

	/* accumulate force in xmm6/xmm7 for fshift */
	addss xmm7, xmm2
	movlhps xmm0, xmm1
	shufps  xmm0, xmm0, 0b1000	
	addps   xmm6, xmm0

	/* increment fshift force */ 
	movlps  xmm3, [esi + edx*4]
	movss  xmm4, [esi + edx*4 + 8]
	addps  xmm3, xmm6
	addss  xmm4, xmm7
	movlps  [esi + edx*4],    xmm3
	movss  [esi + edx*4 + 8], xmm4

	/* get group index for i particle */
	mov   edx, [ebp + _gid]      /* get group index for this i particle */
	mov   edx, [edx]
	add   [ebp + _gid],  4  /* advance pointer */

	/* accumulate total potential energy and update it */
	movaps xmm7, [esp + _vctot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vc]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* accumulate total lj energy and update it */
	movaps xmm7, [esp + _vnbtot]
	/* accumulate */
	movhlps xmm6, xmm7
	addps  xmm7, xmm6	/* pos 0-1 in xmm7 have the sum now */
	movaps xmm6, xmm7
	shufps xmm6, xmm6, 1
	addss  xmm7, xmm6		

	/* add earlier value from mem */
	mov   eax, [ebp + _Vnb]
	addss xmm7, [eax + edx*4] 
	/* move back to mem */
	movss [eax + edx*4], xmm7 
	
	/* finish if last */
	mov   ecx, [ebp + _nri]
	dec ecx
	jecxz .i3330_end
	/* not last, iterate once more! */ 
	mov [ebp + _nri], ecx
	jmp .i3330_outer
.i3330_end:
	emms
	mov eax, [esp + _salign]
	add esp, eax
	add esp, 1508
	pop edi
	pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
	leave
	ret

