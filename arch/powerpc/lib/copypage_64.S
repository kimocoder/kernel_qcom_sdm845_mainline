/* SPDX-License-Identifier: GPL-2.0-or-later */
/*
 * Copyright (C) 2008 Mark Nelson, IBM Corp.
 */
#include <linux/export.h>
#include <asm/page.h>
#include <asm/processor.h>
#include <asm/ppc_asm.h>
#include <asm/asm-offsets.h>
#include <asm/feature-fixups.h>

_GLOBAL_TOC(copy_page)
BEGIN_FTR_SECTION
	lis	r5,PAGE_SIZE@h
FTR_SECTION_ELSE
#ifdef CONFIG_PPC_BOOK3S_64
	b	copypage_power7
#endif
ALT_FTR_SECTION_END_IFCLR(CPU_FTR_VMX_COPY)
	ori	r5,r5,PAGE_SIZE@l
#ifdef CONFIG_PPC_KERNEL_PCREL
	/*
	 * Hack for toolchain - prefixed instructions cause label difference to
	 * be non-constant even if 8 byte alignment is known, so they can not
	 * be put in FTR sections.
	 */
	LOAD_REG_ADDR(r10, ppc64_caches)
BEGIN_FTR_SECTION
#else
BEGIN_FTR_SECTION
	LOAD_REG_ADDR(r10, ppc64_caches)
#endif
	lwz	r11,DCACHEL1LOGBLOCKSIZE(r10)	/* log2 of cache block size */
	lwz     r12,DCACHEL1BLOCKSIZE(r10)	/* get cache block size */
	li	r9,0
	srd	r8,r5,r11

	mtctr	r8
.Lsetup:
	dcbt	r9,r4
	dcbz	r9,r3
	add	r9,r9,r12
	bdnz	.Lsetup
END_FTR_SECTION_IFSET(CPU_FTR_CP_USE_DCBTZ)
	addi	r3,r3,-8
	srdi    r8,r5,7		/* page is copied in 128 byte strides */
	addi	r8,r8,-1	/* one stride copied outside loop */

	mtctr	r8

	ld	r5,0(r4)
	ld	r6,8(r4)
	ld	r7,16(r4)
	ldu	r8,24(r4)
1:	std	r5,8(r3)
	std	r6,16(r3)
	ld	r9,8(r4)
	ld	r10,16(r4)
	std	r7,24(r3)
	std	r8,32(r3)
	ld	r11,24(r4)
	ld	r12,32(r4)
	std	r9,40(r3)
	std	r10,48(r3)
	ld	r5,40(r4)
	ld	r6,48(r4)
	std	r11,56(r3)
	std	r12,64(r3)
	ld	r7,56(r4)
	ld	r8,64(r4)
	std	r5,72(r3)
	std	r6,80(r3)
	ld	r9,72(r4)
	ld	r10,80(r4)
	std	r7,88(r3)
	std	r8,96(r3)
	ld	r11,88(r4)
	ld	r12,96(r4)
	std	r9,104(r3)
	std	r10,112(r3)
	ld	r5,104(r4)
	ld	r6,112(r4)
	std	r11,120(r3)
	stdu	r12,128(r3)
	ld	r7,120(r4)
	ldu	r8,128(r4)
	bdnz	1b

	std	r5,8(r3)
	std	r6,16(r3)
	ld	r9,8(r4)
	ld	r10,16(r4)
	std	r7,24(r3)
	std	r8,32(r3)
	ld	r11,24(r4)
	ld	r12,32(r4)
	std	r9,40(r3)
	std	r10,48(r3)
	ld	r5,40(r4)
	ld	r6,48(r4)
	std	r11,56(r3)
	std	r12,64(r3)
	ld	r7,56(r4)
	ld	r8,64(r4)
	std	r5,72(r3)
	std	r6,80(r3)
	ld	r9,72(r4)
	ld	r10,80(r4)
	std	r7,88(r3)
	std	r8,96(r3)
	ld	r11,88(r4)
	ld	r12,96(r4)
	std	r9,104(r3)
	std	r10,112(r3)
	std	r11,120(r3)
	std	r12,128(r3)
	blr
EXPORT_SYMBOL(copy_page)
