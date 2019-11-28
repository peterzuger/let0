/**
 * @file   let0/src/handlers.cpp
 * @author Peter Züger
 * @date   14.08.2018
 * @brief  interrupt and exception handlers
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
#include <cstdint>

volatile uint32_t jiffies     = 0;
volatile int32_t milliseconds = 0;
volatile int32_t seconds      = 0;

extern "C"{

void NonMaskableIRQ(void){}
void HardFault(void){}
void MemManage(void){}
void BusFault(void){}
void UsageFault(void){}
void SVCall(void){}
void DebugIRQ(void){}
void PendSV(void){}
void SysTick(void){
    jiffies++;
    milliseconds++;
    if(milliseconds >= 1000){
        milliseconds -= 1000;
        seconds++;
    }
}

} /* extern "C" */
