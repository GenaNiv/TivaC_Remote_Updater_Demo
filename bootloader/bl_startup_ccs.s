;;*****************************************************************************
;;
;; bl_startup_ccs.s - Boot loader startup code for Code Composer Studio
;;
;; Copyright (c) 2009-2017 Texas Instruments Incorporated.  All rights reserved.
;; Software License Agreement
;; 
;; Texas Instruments (TI) is supplying this software for use solely and
;; exclusively on TI's microcontroller products. The software is owned by
;; TI and/or its suppliers, and is protected under applicable copyright
;; laws. You may not combine this software with "viral" open-source
;; software in order to form a larger program.
;; 
;; THIS SOFTWARE IS PROVIDED "AS IS" AND WITH ALL FAULTS.
;; NO WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT
;; NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
;; A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. TI SHALL NOT, UNDER ANY
;; CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
;; DAMAGES, FOR ANY REASON WHATSOEVER.
;; 
;; This is part of revision 2.1.4.178 of the Tiva Firmware Development Package.
;;
;;*****************************************************************************

;;*****************************************************************************
;;
;; Include the boot loader configuration options.
;;
;;*****************************************************************************
    .cdecls C, NOLIST, WARN
    %{
        #include "hw_nvic.h"
        #include "hw_sysctl.h"
        #include "bl_config.h"
    %}

;;*****************************************************************************
;;
;; Export symbols from this file that are used elsewhere
;;
;;*****************************************************************************
    .global ResetISR, Delay, Vectors

;;*****************************************************************************
;;
;; Create the stack and put it in a section
;;
;;*****************************************************************************
    .global __stack
__stack:.usect  ".stack", STACK_SIZE * 4, 8

;;*****************************************************************************
;;
;; Put the assembler into the correct configuration.
;;
;;*****************************************************************************
    .thumb

;;*****************************************************************************
;;
;; This portion of the file goes into interrupt vectors section
;;
;;*****************************************************************************
    .sect ".intvecs"

;;*****************************************************************************
;;
;; The minimal vector table for a Cortex-M3 processor.
;;
;;*****************************************************************************
Vectors:
    .ref    __STACK_TOP
    .word   __STACK_TOP                     ;; Offset 00: Initial stack pointer
    .word   ResetISR - 0x20000000           ;; Offset 04: Reset handler
    .word   NmiSR - 0x20000000              ;; Offset 08: NMI handler
    .word   FaultISR - 0x20000000           ;; Offset 0C: Hard fault handler
    .word   IntDefaultHandler               ;; Offset 10: MPU fault handler
    .word   IntDefaultHandler               ;; Offset 14: Bus fault handler
    .word   IntDefaultHandler               ;; Offset 18: Usage fault handler
    .word   0                               ;; Offset 1C: Reserved
    .word   0                               ;; Offset 20: Reserved
    .word   0                               ;; Offset 24: Reserved
    .word   0                               ;; Offset 28: Reserved
    .word   UpdateHandler - 0x20000000      ;; Offset 2C: SVCall handler
    .word   IntDefaultHandler               ;; Offset 30: Debug monitor handler
    .word   0                               ;; Offset 34: Reserved
    .word   IntDefaultHandler               ;; Offset 38: PendSV handler
 .if $$defined(ENET_ENABLE_UPDATE)
    .ref    SysTickIntHandler
    .word   SysTickIntHandler               ;; Offset 3C: SysTick handler
 .else
    .word   IntDefaultHandler               ;; Offset 3C: SysTick handler
 .endif
 .if $$defined(UART_ENABLE_UPDATE) & $$defined(UART_AUTOBAUD)
    .ref    GPIOIntHandler
    .word   GPIOIntHandler                  ;; Offset 40: GPIO port A handler
 .else
    .word   IntDefaultHandler               ;; Offset 40: GPIO port A handler
 .endif
 .if ($$defined(USB_ENABLE_UPDATE) | (APP_START_ADDRESS != VTABLE_START_ADDRESS))
    .word   IntDefaultHandler               ;; Offset 44: GPIO Port B
    .word   IntDefaultHandler               ;; Offset 48: GPIO Port C
    .word   IntDefaultHandler               ;; Offset 4C: GPIO Port D
    .word   IntDefaultHandler               ;; Offset 50: GPIO Port E
    .word   IntDefaultHandler               ;; Offset 54: UART0 Rx and Tx
    .word   IntDefaultHandler               ;; Offset 58: UART1 Rx and Tx
    .word   IntDefaultHandler               ;; Offset 5C: SSI0 Rx and Tx
    .word   IntDefaultHandler               ;; Offset 60: I2C0 Master and Slave
    .word   IntDefaultHandler               ;; Offset 64: PWM Fault
    .word   IntDefaultHandler               ;; Offset 68: PWM Generator 0
    .word   IntDefaultHandler               ;; Offset 6C: PWM Generator 1
    .word   IntDefaultHandler               ;; Offset 70: PWM Generator 2
    .word   IntDefaultHandler               ;; Offset 74: Quadrature Encoder 0
    .word   IntDefaultHandler               ;; Offset 78: ADC Sequence 0
    .word   IntDefaultHandler               ;; Offset 7C: ADC Sequence 1
    .word   IntDefaultHandler               ;; Offset 80: ADC Sequence 2
    .word   IntDefaultHandler               ;; Offset 84: ADC Sequence 3
    .word   IntDefaultHandler               ;; Offset 88: Watchdog timer
    .word   IntDefaultHandler               ;; Offset 8C: Timer 0 subtimer A
    .word   IntDefaultHandler               ;; Offset 90: Timer 0 subtimer B
    .word   IntDefaultHandler               ;; Offset 94: Timer 1 subtimer A
    .word   IntDefaultHandler               ;; Offset 98: Timer 1 subtimer B
    .word   IntDefaultHandler               ;; Offset 9C: Timer 2 subtimer A
    .word   IntDefaultHandler               ;; Offset A0: Timer 2 subtimer B
    .word   IntDefaultHandler               ;; Offset A4: Analog Comparator 0
    .word   IntDefaultHandler               ;; Offset A8: Analog Comparator 1
    .word   IntDefaultHandler               ;; Offset AC: Analog Comparator 2
    .word   IntDefaultHandler               ;; Offset B0: System Control
    .word   IntDefaultHandler               ;; Offset B4: FLASH Control
 .endif
 .if ($$defined(USB_ENABLE_UPDATE) | (APP_START_ADDRESS != VTABLE_START_ADDRESS))
    .word   IntDefaultHandler               ;; Offset B8: GPIO Port F
    .word   IntDefaultHandler               ;; Offset BC: GPIO Port G
    .word   IntDefaultHandler               ;; Offset C0: GPIO Port H
    .word   IntDefaultHandler               ;; Offset C4: UART2 Rx and Tx
    .word   IntDefaultHandler               ;; Offset C8: SSI1 Rx and Tx
    .word   IntDefaultHandler               ;; Offset CC: Timer 3 subtimer A
    .word   IntDefaultHandler               ;; Offset D0: Timer 3 subtimer B
    .word   IntDefaultHandler               ;; Offset D4: I2C1 Master and Slave
 .if ($$defined(TARGET_IS_TM4C129_RA0) | $$defined(TARGET_IS_TM4C129_RA1) | $$defined(TARGET_IS_TM4C129_RA2))
    .word   IntDefaultHandler               ;; Offset D8: CAN0
    .word   IntDefaultHandler               ;; Offset DC: CAN1
    .word   IntDefaultHandler               ;; Offset E0: Ethernet
    .word   IntDefaultHandler               ;; Offset E4: Hibernation module
 .if $$defined(USB_ENABLE_UPDATE)
    .ref    USB0DeviceIntHandler
    .word   USB0DeviceIntHandler            ;; Offset E8: USB 0 Controller
 .else
    .word   IntDefaultHandler               ;; Offset E8: USB 0 Controller
 .endif
    .word   IntDefaultHandler               ;; Offset EC: PWM Generator 3
    .word   IntDefaultHandler               ;; Offset F0: uDMA 0 Software
 .else
    .word   IntDefaultHandler               ;; Offset D8: Quadrature Encoder 1
    .word   IntDefaultHandler               ;; Offset DC: CAN0
    .word   IntDefaultHandler               ;; Offset E0: CAN1
    .word   IntDefaultHandler               ;; Offset E4: CAN2
    .word   IntDefaultHandler               ;; Offset E8: Ethernet
    .word   IntDefaultHandler               ;; Offset EC: Hibernation module
 .if $$defined(USB_ENABLE_UPDATE)
    .ref    USB0DeviceIntHandler
    .word   USB0DeviceIntHandler            ;; Offset F0: USB 0 Controller
 .else
    .word   IntDefaultHandler               ;; Offset F0: USB 0 Controller
 .endif
 .endif
 .endif

;;*****************************************************************************
;;
;; This portion of the file goes into the text section.
;;
;;*****************************************************************************
    .text

;;*****************************************************************************
;;
;; Initialize the processor by copying the boot loader from flash to SRAM, zero
;; filling the .bss section, and moving the vector table to the beginning of
;; SRAM.  The return address is modified to point to the SRAM copy of the boot
;; loader instead of the flash copy, resulting in a branch to the copy now in
;; SRAM.
;;
;;*****************************************************************************
    .ref    bss_run
bss_start   .word bss_run
    .ref    __STACK_TOP
bss_end     .word __STACK_TOP

    .thumbfunc ProcessorInit
ProcessorInit: .asmfunc
    ;;
    ;; Copy the code image from flash to SRAM.
    ;;
    movs    r0, #0x0000
    movs    r1, #0x0000
    movt    r1, #0x2000
    ldr     r2, bss_start
copy_loop:
        ldr     r3, [r0], #4
        str     r3, [r1], #4
        cmp     r1, r2
        blt     copy_loop

    ;;
    ;; Zero fill the .bss section.
    ;;
    movs    r0, #0x0000
    ldr     r2, bss_end
zero_loop:
        str     r0, [r1], #4
        cmp     r1, r2
        blt     zero_loop

    ;;
    ;; Set the vector table pointer to the beginning of SRAM.
    ;;
    movw    r0, #(NVIC_VTABLE & 0xffff)
    movt    r0, #(NVIC_VTABLE >> 16)
    movs    r1, #0x0000
    movt    r1, #0x2000
    str     r1, [r0]

    ;;
    ;; Set the return address to the code just copied into SRAM.
    ;;
    orr     lr, lr, #0x20000000

    ;;
    ;; Return to the caller.
    ;;
    bx      lr
    .endasmfunc

;;*****************************************************************************
;;
;; The reset handler, which gets called when the processor starts.
;;
;;*****************************************************************************
    .thumbfunc ResetISR
ResetISR: .asmfunc
    ;;
    ;; Enable the floating-point unit.  This must be done here in case any
    ;; later C functions use floating point.  Note that some toolchains will
    ;; use the FPU registers for general workspace even if no explicit floating
    ;; point data types are in use.
    ;;
    movw    r0, #0xED88
    movt    r0, #0xE000
    ldr     r1, [r0]
    orr     r1, r1, #0x00F00000
    str     r1, [r0]

    ;;
    ;; Initialize the processor.
    ;;
    bl      ProcessorInit

    ;;
    ;; Call the user-supplied low level hardware initialization function
    ;; if provided.
    ;;
 .if $$defined(BL_HW_INIT_FN_HOOK)
    .ref    BL_HW_INIT_FN_HOOK
    bl      BL_HW_INIT_FN_HOOK
 .endif

    ;;
    ;; See if an update should be performed.
    ;;
    .ref    CheckForceUpdate
    bl      CheckForceUpdate
    cbz     r0, CallApplication

    ;;
    ;; Configure the microcontroller.
    ;;
    .thumbfunc EnterBootLoader
EnterBootLoader:
 .if $$defined(ENET_ENABLE_UPDATE)
    .ref    ConfigureEnet
    bl      ConfigureEnet
 .elseif $$defined(CAN_ENABLE_UPDATE)
    .ref    ConfigureCAN
    bl      ConfigureCAN
 .elseif $$defined(USB_ENABLE_UPDATE)
    .ref    ConfigureUSB
    bl      ConfigureUSB
 .else
    .ref    ConfigureDevice
    bl      ConfigureDevice
 .endif

    ;;
    ;; Call the user-supplied initialization function if provided.
    ;;
 .if $$defined(BL_INIT_FN_HOOK)
    .ref    BL_INIT_FN_HOOK
    bl      BL_INIT_FN_HOOK
 .endif

    ;;
    ;; Branch to the update handler.
    ;;
 .if $$defined(ENET_ENABLE_UPDATE)
    .ref    UpdateBOOTP
    b       UpdateBOOTP
 .elseif $$defined(CAN_ENABLE_UPDATE)
    .ref    UpdaterCAN
    b       UpdaterCAN
 .elseif $$defined(USB_ENABLE_UPDATE)
    .ref    UpdaterUSB
    b       UpdaterUSB
 .else
    .ref    Updater
    b       Updater
 .endif
    .endasmfunc

    ;;
    ;; This is a second symbol to allow starting the application from the boot
    ;; loader the linker may not like the perceived jump.
    ;;
    .global StartApplication
    .thumbfunc StartApplication
StartApplication:
    ;;
    ;; Call the application via the reset handler in its vector table.  Load
    ;; the address of the application vector table.
    ;;
    .thumbfunc CallApplication
CallApplication: .asmfunc
    ;;
    ;; Copy the application's vector table to the target address if necessary.
    ;; Note that incorrect boot loader configuration could cause this to
    ;; corrupt the code!  Setting VTABLE_START_ADDRESS to 0x20000000 (the start
    ;; of SRAM) is safe since this will use the same memory that the boot loader
    ;; already uses for its vector table.  Great care will have to be taken if
    ;; other addresses are to be used.
    ;;
 .if (APP_START_ADDRESS != VTABLE_START_ADDRESS)
    movw    r0, #(VTABLE_START_ADDRESS & 0xffff)
 .if (VTABLE_START_ADDRESS > 0xffff)
    movt    r0, #(VTABLE_START_ADDRESS >> 16)
 .endif
    movw    r1, #(APP_START_ADDRESS & 0xffff)
 .if (APP_START_ADDRESS > 0xffff)
    movt    r1, #(APP_START_ADDRESS >> 16)
 .endif

    ;;
    ;; Calculate the end address of the vector table assuming that it has the
    ;; maximum possible number of vectors.  We don't know how many the app has
    ;; populated so this is the safest approach though it may copy some non
    ;; vector data if the app table is smaller than the maximum.
    ;;
    movw    r2, #(70 * 4)
    adds    r2, r2, r0
VectorCopyLoop:
        ldr     r3, [r1], #4
        str     r3, [r0], #4
        cmp     r0, r2
        blt     VectorCopyLoop
 .endif

    ;;
    ;; Set the application's vector table start address.  Typically this is the
    ;; application start address but in some cases an application may relocate
    ;; this so we can't assume that these two addresses are equal.
    ;;
    movw    r0, #(VTABLE_START_ADDRESS & 0xffff)
 .if (VTABLE_START_ADDRESS > 0xffff)
    movt    r0, #(VTABLE_START_ADDRESS >> 16)
 .endif
    movw    r1, #(NVIC_VTABLE & 0xffff)
    movt    r1, #(NVIC_VTABLE >> 16)
    str     r0, [r1]

    ;;
    ;; Load the stack pointer from the application's vector table.
    ;;
 .if (APP_START_ADDRESS != VTABLE_START_ADDRESS)
    movw    r0, #(APP_START_ADDRESS & 0xffff)
 .if (APP_START_ADDRESS > 0xffff)
    movt    r0, #(APP_START_ADDRESS >> 16)
 .endif
 .endif
    ldr     sp, [r0]

    ;;
    ;; Load the initial PC from the application's vector table and branch to
    ;; the application's entry point.
    ;;
    ldr     r0, [r0, #4]
    bx      r0
    .endasmfunc

;;*****************************************************************************
;;
;; The update handler, which gets called when the application would like to
;; start an update.
;;
;;*****************************************************************************
    .thumbfunc UpdateHandler
UpdateHandler: .asmfunc
    ;;
    ;; Initialize the processor.
    ;;
    bl      ProcessorInit

    ;;
    ;; Load the stack pointer from the vector table.
    ;;
    movs    r0, #0x0000
    ldr     sp, [r0]

    ;;
    ;; Call the user-supplied low level hardware initialization function
    ;; if provided.
    ;;
 .if $$defined(BL_HW_INIT_FN_HOOK)
    bl      BL_HW_INIT_FN_HOOK
 .endif

    ;;
    ;; Call the user-supplied re-initialization function if provided.
    ;;
 .if $$defined(BL_REINIT_FN_HOOK)
    .ref    BL_REINIT_FN_HOOK
    bl      BL_REINIT_FN_HOOK
 .endif

    ;;
    ;; Branch to the update handler.
    ;;
 .if $$defined(ENET_ENABLE_UPDATE)
    b       UpdateBOOTP
 .elseif $$defined(CAN_ENABLE_UPDATE)
    .ref    AppUpdaterCAN
    b       AppUpdaterCAN
 .elseif $$defined(USB_ENABLE_UPDATE)
    .ref    AppUpdaterUSB
    b       AppUpdaterUSB
 .else
    b       Updater
 .endif
    .endasmfunc

;;*****************************************************************************
;;
;; The NMI handler.
;;
;;*****************************************************************************
    .thumbfunc NmiSR
NmiSR: .asmfunc
 .if $$defined(ENABLE_MOSCFAIL_HANDLER)
    ;;
    ;; Grab the fault frame from the stack (the stack will be cleared by the
    ;; processor initialization that follows).
    ;;
    ldm     sp, {r4-r11}
    mov     r12, lr

    ;;
    ;; Initialize the processor.
    ;;
    bl      ProcessorInit

    ;;
    ;; Restore the stack frame.
    ;;
    mov     lr, r12
    stm     sp, {r4-r11}

    ;;
    ;; Save the link register.
    ;;
    mov     r9, lr

    ;;
    ;; Call the user-supplied low level hardware initialization function
    ;; if provided.
    ;;
 .if $$defined(BL_HW_INIT_FN_HOOK)
    bl      BL_HW_INIT_FN_HOOK
 .endif

    ;;
    ;; See if an update should be performed.
    ;;
    bl      CheckForceUpdate
    cbz     r0, EnterApplication

        ;;
        ;; Clear the MOSCFAIL bit in RESC.
        ;;
        movw    r0, #(SYSCTL_RESC & 0xffff)
        movt    r0, #(SYSCTL_RESC >> 16)
        ldr     r1, [r0]
        bic     r1, r1, #SYSCTL_RESC_MOSCFAIL
        str     r1, [r0]

        ;;
        ;; Fix up the PC on the stack so that the boot pin check is bypassed
        ;; (since it has already been performed).
        ;;
        ldr     r0, =EnterBootLoader
        bic     r0, #0x00000001
        str     r0, [sp, #0x18]

        ;;
        ;; Return from the NMI handler.  This will then start execution of the
        ;; boot loader.
        ;;
        bx      r9

    ;;
    ;; Restore the link register.
    ;;
EnterApplication:
    mov     lr, r9

    ;;
    ;; Copy the application's vector table to the target address if necessary.
    ;; Note that incorrect boot loader configuration could cause this to
    ;; corrupt the code!  Setting VTABLE_START_ADDRESS to 0x20000000 (the start
    ;; of SRAM) is safe since this will use the same memory that the boot loader
    ;; already uses for its vector table.  Great care will have to be taken if
    ;; other addresses are to be used.
    ;;
 .if (APP_START_ADDRESS != VTABLE_START_ADDRESS)
    movw    r0, #(VTABLE_START_ADDRESS & 0xffff)
 .if (VTABLE_START_ADDRESS > 0xffff)
    movt    r0, #(VTABLE_START_ADDRESS >> 16)
 .endif
    movw    r1, #(APP_START_ADDRESS & 0xffff)
 .if (APP_START_ADDRESS > 0xffff)
    movt    r1, #(APP_START_ADDRESS >> 16)
 .endif

    ;;
    ;; Calculate the end address of the vector table assuming that it has the
    ;; maximum possible number of vectors.  We don't know how many the app has
    ;; populated so this is the safest approach though it may copy some non
    ;; vector data if the app table is smaller than the maximum.
    ;;
    movw    r2, #(70 * 4)
    adds    r2, r2, r0
VectorCopyLoop2:
        ldr     r3, [r1], #4
        str     r3, [r0], #4
        cmp     r0, r2
        blt     VectorCopyLoop2
 .endif

    ;;
    ;; Set the application's vector table start address.  Typically this is the
    ;; application start address but in some cases an application may relocate
    ;; this so we can't assume that these two addresses are equal.
    ;;
    movw    r0, #(VTABLE_START_ADDRESS & 0xffff)
 .if (VTABLE_START_ADDRESS > 0xffff)
    movt    r0, #(VTABLE_START_ADDRESS >> 16)
 .endif
    movw    r1, #(NVIC_VTABLE & 0xffff)
    movt    r1, #(NVIC_VTABLE >> 16)
    str     r0, [r1]

    ;;
    ;; Remove the NMI stack frame from the boot loader's stack.
    ;;
    ldmia   sp, {r4-r11}

    ;;
    ;; Get the application's stack pointer.
    ;;
 .if (APP_START_ADDRESS != VTABLE_START_ADDRESS)
    movw    r0, #(APP_START_ADDRESS & 0xffff)
 .if (APP_START_ADDRESS > 0xffff)
    movt    r0, #(APP_START_ADDRESS >> 16)
 .endif
 .endif
    ldr     sp, [r0, #0x00]

    ;;
    ;; Fix up the NMI stack frame's return address to be the reset handler of
    ;; the application.
    ;;
    ldr     r10, [r0, #0x04]
    bic     r10, #0x00000001

    ;;
    ;; Store the NMI stack frame onto the application's stack.
    ;;
    stmdb   sp!, {r4-r11}

    ;;
    ;; Branch to the application's NMI handler.
    ;;
    ldr     r0, [r0, #0x08]
    bx      r0
 .else
    ;;
    ;; Loop forever since there is nothing that we can do about a NMI.
    ;;
    b       NmiSR
 .endif
    .endasmfunc

;;*****************************************************************************
;;
;; The hard fault handler.
;;
;;*****************************************************************************
    .thumbfunc FaultISR
FaultISR: .asmfunc
    ;;
    ;; Loop forever since there is nothing that we can do about a hard fault.
    ;;
    b       FaultISR
    .endasmfunc

;;*****************************************************************************
;;
;; The default interrupt handler.
;;
;;*****************************************************************************
    .thumbfunc IntDefaultHandler
IntDefaultHandler: .asmfunc
    ;;
    ;; Loop forever since there is nothing that we can do about an unexpected
    ;; interrupt.
    ;;
    b       IntDefaultHandler
    .endasmfunc

;;*****************************************************************************
;;
;; Provides a small delay.  The loop below takes 3 cycles/loop.
;;
;;*****************************************************************************
;    .globl  Delay
    .thumbfunc Delay
Delay: .asmfunc
    subs    r0, #1
    bne     Delay
    bx      lr
    .endasmfunc

    .thumbfunc _c_int00
    .global _c_int00
_c_int00: .asmfunc
    b       ResetISR

;;*****************************************************************************
;;
;; This is the end of the file.
;;
;;*****************************************************************************
    .end
