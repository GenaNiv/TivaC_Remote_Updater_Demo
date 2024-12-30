/******************************************************************************
 *
 * Default Linker Command file for the Texas Instruments TM4C123GH6PM
 *
 * This is derived from revision 15071 of the TivaWare Library.
 *
 *****************************************************************************/

--retain=g_pfnVectors

MEMORY
{
    FLASH (RX) : origin = 0x00002800, length = 0x0000D800  /* Application starts after the bootloader */
    SRAM (RWX) : origin = 0x20000000, length = 0x00010000  /* 32 KB SRAM */
}


/* The following command line options are set as part of the CCS project.    */
/* If you are building using the command line, or for some reason want to    */
/* define them here, you can uncomment and modify these lines as needed.     */
/* If you are using CCS for building, it is probably better to make any such */
/* modifications in your CCS project and leave this file alone.              */
/*                                                                           */
/* --heap_size=0                                                             */
/* --stack_size=256                                                          */
/* --library=rtsv7M4_T_le_eabi.lib                                           */

/* Section allocation in memory */

SECTIONS
{
    .intvecs:   > 0x00002800          /* Interrupt vector table at app start address */
    .text   :   > FLASH               /* Code */
    .const  :   > FLASH               /* Constants */
    .cinit  :   > FLASH               /* C initialization table */
    .pinit  :   > FLASH               /* Constructor initialization table */
    .init_array : > FLASH             /* C++ init array */

    .vtable :   > 0x20000000          /* Dynamic vector table in SRAM */
    .data   :   > SRAM                /* Initialized variables */
    .bss    :   > SRAM                /* Uninitialized variables */
    .sysmem :   > SRAM                /* Heap */
    .stack  :   > SRAM                /* Stack */
}

__STACK_TOP = __stack + 512;
