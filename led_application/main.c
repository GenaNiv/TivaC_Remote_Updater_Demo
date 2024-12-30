#include <stdint.h>
#include <stdbool.h>
#include "inc/hw_memmap.h"       // For hardware memory map
#include "driverlib/sysctl.h"    // For system control functions
#include "driverlib/gpio.h"      // For GPIO control
#include "driverlib/uart.h"      // For UART control
#include "driverlib/pin_map.h"   // For pin mapping

// Define the update signal address and value
#define UPDATE_SIGNAL_ADDR  ((uint32_t *)0x20007FFC)  // Reserved SRAM location
#define UPDATE_SIGNAL_VALUE 0xA5A5A5A5                // Predefined signal value

// UART Command Definitions
#define UART_UPDATE_COMMAND 0x55  // Single-byte command for update

// Function prototypes
void InitHardware(void);
void InitUART(void);
void BlinkLED(void);
void CheckForUpdateCommand(void);
void TriggerFirmwareUpdate(void);

int main(void)
{
    // Initialize the hardware
    InitHardware();
    InitUART();

    while (1)
    {
        // Blink the LED
        BlinkLED();

        // Check for update command through UART
        CheckForUpdateCommand();
    }
}

// Initialize the hardware
void InitHardware(void)
{
    // Set the clocking to run at 50 MHz from the PLL with the main oscillator
    SysCtlClockSet(SYSCTL_SYSDIV_4 | SYSCTL_USE_PLL | SYSCTL_OSC_MAIN | SYSCTL_XTAL_16MHZ);

    // Enable the GPIO port for the LED
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF);

    // Wait for the GPIO module to be ready
    while (!SysCtlPeripheralReady(SYSCTL_PERIPH_GPIOF)) {}

    // Configure the GPIO pin for the LED (PF1 - Red LED)
    GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_1);
}

// Initialize UART
void InitUART(void)
{
    // Enable the UART0 peripheral
    SysCtlPeripheralEnable(SYSCTL_PERIPH_UART0);
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOA);

    // Wait for the UART module to be ready
    while (!SysCtlPeripheralReady(SYSCTL_PERIPH_UART0)) {}

    // Configure GPIO pins for UART (PA0: RX, PA1: TX)
    GPIOPinConfigure(GPIO_PA0_U0RX);
    GPIOPinConfigure(GPIO_PA1_U0TX);
    GPIOPinTypeUART(GPIO_PORTA_BASE, GPIO_PIN_0 | GPIO_PIN_1);

    // Configure UART for 115200 baud rate, 8 data bits, 1 stop bit, no parity
    UARTConfigSetExpClk(UART0_BASE, SysCtlClockGet(), 115200,
                        (UART_CONFIG_WLEN_8 | UART_CONFIG_STOP_ONE | UART_CONFIG_PAR_NONE));
}

// Blink the LED
void BlinkLED(void)
{
    // Turn on the LED
    GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1, GPIO_PIN_1);
    SysCtlDelay(SysCtlClockGet() / 6);  // Delay ~500ms

    // Turn off the LED
    GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1, 0);
    SysCtlDelay(SysCtlClockGet() / 6);  // Delay ~500ms
}

// Check for update command through UART
void CheckForUpdateCommand(void)
{
    // Check if data is available in UART
    while (UARTCharsAvail(UART0_BASE))
    {
        char receivedChar = UARTCharGet(UART0_BASE);

        // Check if the received character matches the update command
        if (receivedChar == UART_UPDATE_COMMAND)
        {
            // Trigger firmware update if the command matches
            TriggerFirmwareUpdate();
        }
    }
}

// Trigger firmware update
void TriggerFirmwareUpdate(void)
{
    // Set the update signal
    *UPDATE_SIGNAL_ADDR = UPDATE_SIGNAL_VALUE;

    // Perform a system reset to enter the bootloader
    SysCtlReset();
}
