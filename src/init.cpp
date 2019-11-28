/**
 * @file   let0/src/init.c
 * @author Peter Züger
 * @date   17.4.2018
 * @brief  low level C init
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
#include <cstddef>

#include <FPU.hpp>

extern int main(void);

extern "C" void __attribute__((flatten,noreturn)) _start(void){
    extern uint32_t __data_load__;
    extern uint32_t __data_start__;
    extern uint32_t __data_end__;

    // do global/static data initialization
    uint32_t *src  = &__data_load__;
    uint32_t *dest = &__data_start__;

    while( dest < &__data_end__ )
        *dest++ = *src++;

    extern uint32_t __bss_start__;
    extern uint32_t __bss_end__;

    // clear out uninitialized variables
    dest = &__bss_start__;
    while(dest < &__bss_end__)
        *dest++ = 0;

    {
        size_t count, i;
        extern void (*__preinit_array_start [])(void) __attribute__((weak));
        extern void (*__preinit_array_end [])(void) __attribute__((weak));

        count = __preinit_array_end - __preinit_array_start;
        for (i = 0; i < count; i++)
            __preinit_array_start[i]();
    }

#if defined(HAS_FPU)
    let::FPU::EnableFPU();
#endif /* defined(HAS_FPU) */

    {
        size_t count, i;
        extern void (*__ctors_start__[])(void) __attribute__((weak));
        extern void (*__ctors_end__[])(void) __attribute__((weak));

        count = __ctors_end__ - __ctors_start__;
        for (i = 0; i < count; i++)
            __ctors_start__[i]();
    }

    {
        size_t count, i;
        extern void (*__init_array_start [])(void) __attribute__((weak));
        extern void (*__init_array_end [])(void) __attribute__((weak));

        count = __init_array_end - __init_array_start;
        for (i = 0; i < count; i++)
            __init_array_start[i]();
    }

#pragma GCC diagnostic ignored "-Wpedantic"
    main();
#pragma GCC diagnostic warning "-Wpedantic"

    {
        size_t count, i;
        extern void (*__fini_array_start [])(void) __attribute__((weak));
        extern void (*__fini_array_end [])(void) __attribute__((weak));

        count = __fini_array_end - __fini_array_start;
        for (i = count - 1; i; i--)
            __fini_array_start[i]();
    }

    {
        size_t count, i;
        extern void (*__dtors_start__[])(void) __attribute__((weak));
        extern void (*__dtors_end__[])(void) __attribute__((weak));

        count = __dtors_end__ - __dtors_start__;
        for (i = count - 1; i; i--)
            __dtors_start__[i]();
    }

    while(1);
}
