/**
 * generic arm linker script
 * must be pre processed with gcc -E
 * symbols that must be defined:
 *     FLASH_ORIGIN  -> FLASH start address
 *     FLASH_SIZE    -> FLASH size eg. 1024k 512k 1M ...
 *     RAM_ORIGIN    -> RAM start address
 *     RAM_SIZE      -> RAM size eg. 256k 64k ...
 *     HEAP_SIZE     -> set to the required heap size used for __heap_X__
 *     STACK_SIZE    -> set to the minimum stack size you need
 *                      will throw a linker error if not enoug is left over
 *
 *     interrupt vectors see under SECTIONS{.isrvect:{  }}
 *
 * symbols defined by this script
 *     __preinit_array_start
 *     __preinit_array_end
 *     __ctors_start__
 *     __ctors_end__
 *     __init_array_start
 *     __init_array_end
 *     __fini_array_start
 *     __fini_array_end
 *     __dtors_start__
 *     __dtors_end__
 *
 *     __data_load__
 *     __data_start__
 *     __data_end__
 *     __bss_start__
 *     __bss_end__
 */
MEMORY
{
  FLASH (rx) : ORIGIN = FLASH_ORIGIN, LENGTH = FLASH_SIZE
  RAM (rwx)  : ORIGIN = RAM_ORIGIN  , LENGTH = RAM_SIZE
}

ENTRY(_start)

SECTIONS
{
    /**
     * Space for the ISR vector table
     * place data here with __attribute__((section(".vectors")))
     * working example :
     * const void * Vectors[] __attribute__((section(".vectors")))
     * should be the first thing in FLASH at FLASH_ORIGIN
     */
    .isrvect :
    {
        KEEP(*(.vectors))
    } > FLASH

    /**
     * executable code and glue code if arm and! thumb was used
     * start is 4 byte aligned
     */
    .text ALIGN(4):
    {
        *(.text*)        /** all remaining code */
        *(.text.*)

        /**
         * a rodata1 section should maybe be placed to reserve space for a checksum
         * or something along those lines
         */
        *(.rodata*)      /** read-only data (constants) */
        *(.rodata.*)
        *(.constdata*)
        *(.constdata.*)

        *(vtable)       /** C++ virtual tables */

        /** .gnu.warning sections are handled specially by elf32.em.  */
        *(.gnu.warning)
        *(.gnu.linkonce.t*)

        /**
         * Stub sections generated by the linker, to glue together
         * ARM and Thumb code. .glue_7 is used for ARM code calling
         * Thumb code, and .glue_7t is used for Thumb code calling
         * ARM code. Apparently always generated by the linker, for some
         * architectures, so better leave them here.
         */
        *(.glue_7)
        *(.glue_7t)
    } > FLASH

    /**
     * init and fini sections technicaly not needed by ARM code (x86)
     */
    .init ALIGN(4):
    {
        KEEP (*(.init))
    }
    .fini ALIGN(4):
    {
        KEEP (*(.fini))
    }

    /**
     * .eh_frame_hdr is sorted, so has to go in its own output section.
     * this section contains a pointer to the .eh_frame section which is
     * accessible to the runtime support code of a C++ application.
     * this section may also contain a binary search table which may
     * be used by the runtime support code to more efficiently
     * access records in the .eh_frame section.
     */
    .eh_frame_hdr : ALIGN (4)
    {
        KEEP (*(.eh_frame_hdr))
    } > FLASH
    /**
     * this section contains information necessary for frame unwinding
     * during exception handling. only used on x86
     */
    .eh_frame : ALIGN (4)
    {
        KEEP (*(.eh_frame))
    } > FLASH


    /**
     * .ctors .dtors are used for c++ constructors/destructors
     * added by Martin Thomas 4/2005 based on Anglia Design example
     */
    .preinit_array ALIGN(4):
    {
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP(*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);
    } > FLASH

    .ctors ALIGN(4):
    {
        PROVIDE(__ctors_start__ = .);
        KEEP(*(SORT(.ctors.*)))
        KEEP(*(.ctors))
        PROVIDE(__ctors_end__ = .);
    } > FLASH

    .init_array ALIGN(4):
    {
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE_HIDDEN (__init_array_end = .);
    } > FLASH

    .fini_array ALIGN(4):
    {
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array))
        PROVIDE_HIDDEN (__fini_array_end = .);
    } > FLASH

    .dtors ALIGN(4):
    {
        PROVIDE(__dtors_start__ = .);
        KEEP(*(SORT(.dtors.*)))
        KEEP(*(.dtors))
        PROVIDE(__dtors_end__ = .);
    } > FLASH

    /*
     * Stack unwinding and exception handling sections.
     *
     * ARM compilers emit object files with .ARM.extab and .ARM.exidx sections
     * when using C++ exceptions. Also, at least GCC emits those sections when
     * dividing large numbers (64-bit) in C. So we have to handle them.
     *
     * (ARM uses .ARM.extab and .ARM.exidx instead of the .eh_frame section
     * used on x86.)
     */
    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } > FLASH

    __exidx_start = .;
    .ARM.exidx :
    {
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > FLASH
    __exidx_end = .;

    /**
     * Location counter can end up 2byte aligned with narrow Thumb code but
     * __text_end__ is assumed by startup code to be the LMA of a section in RAM
     * which must be 4byte aligned
     */
    . = ALIGN(4);
    __text_end__ = .;

    /*
     * This address is used by the startup code to
     * initialise the .data section.
     * creates 2 sections one in FLASH with the initial data
     * and one in RAM where the values are copyed over by the startup code
     * the FLASH section is placed at __text_end__ in FLASH
     * the .data section is first one in RAM
     */
    .data : AT (__text_end__)
    {
        . = ALIGN(4);
        __data_start__ = .;

        *(.data_begin .data_begin.*)
        *(vtable)
        *(.data)
        *(.data.*)
        *(.data_end .data_end.*)
        *(.gnu.linkonce.d*)

        . = ALIGN(4);
        /* All data end */
        __data_end__ = .;

        /**
         * compiled JAVA classes
         */
        KEEP(*(.jcr*))

        /**
          * these sections are placed here so that a user
          * can store a checksum or something simular
          */
        *(.data1)
        *(.data1.*)
    } > RAM /*AT > FLASH*/
    __data_load__ = LOADADDR(.data);

    .bss (NOLOAD):
    {
        . = ALIGN(4);
        __bss_start__ = .;

        *(.bss_begin .bss_begin.*)
        *(.bss)
        *(.bss.*)
        *(COMMON)
        *(.bss_end .bss_end.*)

        . = ALIGN(4);
        __bss_end__ = .;
    } > RAM

    .heap (NOLOAD):
    {
        . = ALIGN(4);
        __heap_start__ = .;
        . += HEAP_SIZE;
        . = ALIGN(4);
        __heap_end__ = .;
    } > RAM

    __heap_size__ = HEAP_SIZE;

    /**
     * do not use this section it is only here to ensure that
     * enough RAM space is left over
     * stack is 8 byte aligned
     * __stack_end__ can be checked against the stack pointer (r13)
     * to check for stack overflow -> https://stackoverflow.com
     * will issue a linker error if not enough RAM is left
     */
    .stack :
    {
        . = ALIGN(8);
        __stack_end__ = .;
        . += STACK_SIZE;
        . = ALIGN(8);
        __stack_start__ = .;
    } > RAM

    __stack_size__ = STACK_SIZE;

    /* This can remove the debugging information from the standard libraries */
#if defined(STDDEBUG)
    DISCARD :
    {
        libc.a ( * )
        libcpp.a ( * )
    }
#endif /* defined(NDEBUG) */

    /* Stabs debugging sections.  */
    .stab          0 : { *(.stab) }
    .stabstr       0 : { *(.stabstr) }
    .stab.excl     0 : { *(.stab.excl) }
    .stab.exclstr  0 : { *(.stab.exclstr) }
    .stab.index    0 : { *(.stab.index) }
    .stab.indexstr 0 : { *(.stab.indexstr) }
    .comment       0 : { *(.comment) }
    /*
     * DWARF debug sections.
     * Symbols in the DWARF debugging sections are relative to the beginning
     * of the section so we begin them at 0.
     */
    /* DWARF 1 */
    .debug          0 : { *(.debug) }
    .line           0 : { *(.line) }
    /* GNU DWARF 1 extensions */
    .debug_srcinfo  0 : { *(.debug_srcinfo) }
    .debug_sfnames  0 : { *(.debug_sfnames) }
    /* DWARF 1.1 and DWARF 2 */
    .debug_aranges  0 : { *(.debug_aranges) }
    .debug_pubnames 0 : { *(.debug_pubnames) }
    /* DWARF 2 */
    .debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
    .debug_abbrev   0 : { *(.debug_abbrev) }
    .debug_line     0 : { *(.debug_line) }
    .debug_frame    0 : { *(.debug_frame) }
    .debug_str      0 : { *(.debug_str) }
    .debug_loc      0 : { *(.debug_loc) }
    .debug_macinfo  0 : { *(.debug_macinfo) }
    .debug_ranges   0 : { *(.debug_ranges) }
    /* SGI/MIPS DWARF 2 extensions */
    .debug_weaknames 0 : { *(.debug_weaknames) }
    .debug_funcnames 0 : { *(.debug_funcnames) }
    .debug_typenames 0 : { *(.debug_typenames) }
    .debug_varnames  0 : { *(.debug_varnames) }
}
