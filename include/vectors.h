/**
 * @file   let0/include/vectors.h
 * @author Peter Züger
 * @date   17.4.2018
 * @brief  ARM Interrupt vectors
 *
 * This file is part of let0 (https://gitlab.com/peterzuger/let0).
 * Copyright (c) 2019 Peter Züger.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#ifndef LET0_VECTORS_H
#define LET0_VECTORS_H

void _start(void);

void NonMaskableIRQ(void);
void HardFault(void);
void MemManage(void);
void BusFault(void);
void UsageFault(void);
void SVCall(void);
void DebugIRQ(void);
void PendSV(void);
void SysTick(void);

extern char __stack_start__;

typedef void(*fp)(void);

typedef struct{
    char* stack;
    fp Reset;
    fp NonMaskableIRQ;
    fp HardFault;
    fp MemManage;
    fp BusFault;
    fp UsageFault;
    fp RESERVED0[4];
    fp SVCall;
    fp DebugIRQ;
    fp RESERVED1;
    fp PendSV;
    fp SysTick;
    fp irq[IRQ_COUNT];
}vectors;

extern vectors __attribute__((section(".vectors"))) vector_table;

#endif /* LET0_VECTORS_H */
