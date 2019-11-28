/**
 * @file   let0/src/vectors.c
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
#include "vectors.h"

vectors __attribute__((section(".vectors"))) vector_table = {
    .stack          = &__stack_start__,
    .Reset          = _start,
    .NonMaskableIRQ = NonMaskableIRQ,
    .HardFault      = HardFault,
    .MemManage      = MemManage,
    .BusFault       = BusFault,
    .UsageFault     = UsageFault,
    .SVCall         = SVCall,
    .DebugIRQ       = DebugIRQ,
    .PendSV         = PendSV,
    .SysTick        = SysTick
};
