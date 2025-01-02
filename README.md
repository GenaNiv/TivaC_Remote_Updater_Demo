# GSE_ControlSystem

## Overview
The **GSE_ControlSystem** is a comprehensive project for managing firmware updates and controlling embedded devices. This project includes a bootloader, a demo application, and a host firmware updater to simplify and streamline firmware update processes.

---

## Features
### Bootloader
- **Firmware Update via UART**:
  - Handles firmware update commands from the host.
  - Programs and erases flash memory.
- **Application Switching**:
  - Executes the updated application after firmware programming.
- **Fault Handling**:
  - Ensures integrity during the firmware update process with validation mechanisms.

### LED Application
- **Basic Functionality**:
  - Demonstrates GPIO usage by toggling an LED.
- **Configurable Memory Location**:
  - Operates from a memory address defined by the bootloader.

### Firmware Updater (Host Application)
- **Command-Based Communication**:
  - Supports commands like `PING`, `DOWNLOAD`, `SEND_DATA`, `RUN` and `RESET`.
- **Error Recovery**:
  - Retries failed transmissions for robust updates.
- **Cross-Platform**:
  - Python-based, runs on Linux, macOS, and Windows.

### Tools
- **Automation**:
  - Includes scripts for setting up Code Composer Studio (CCS) projects.
- **Simplified Development**:
  - Workspace and environment setup scripts to streamline onboarding.

---

## Project Structure
```plaintext
.
├── bootloader             # Source code for the custom bootloader
│   ├── Debug              # Build artifacts
│   └── targetConfigs      # Target configuration files
├── led_application        # Source code for the LED application
│   ├── Debug              # Build artifacts
│   └── targetConfigs      # Target configuration files
├── firmware_updater       # Python-based host application for firmware updates
│   ├── main.py            # Entry point for the updater
│   ├── packet_handler.py  # Handles communication with the bootloader
│   └── uart_handler.py    # Manages UART communication
└── tools                  # Utilities and setup scripts
    └── ccs_project_setup.sh # Script to set up the CCS environment

graph TD
    subgraph Bootloader
        A[Handles firmware update commands]
        B[Programs and erases flash memory]
        C[Switches to updated application]
        D[Ensures integrity with validation]
    end

    subgraph LED Application
        E[Toggles an LED]
        F[Operates from memory address defined by Bootloader]
    end

    subgraph Firmware Updater (Host Application)
        G[Sends PING, DOWNLOAD, SEND_DATA, RUN, RESET commands]
        H[Retries failed transmissions]
        I[Cross-platform: Linux, macOS, Windows]
    end

    Host -->|Command-based communication| Bootloader
    Bootloader -->|Executes updated application| LED_Application
    Firmware -->|Validates & Transfers Firmware| Bootloader
    LED_Application -->|Visual demonstration via LED toggle| User


Getting Started
Prerequisites
Hardware:
Tiva C Series microcontroller (TM4C123GH6PM or equivalent).
Software:
Code Composer Studio (CCS)
Python 3.x with the pyserial library installed.

Setup
Clone this repository:
git clone https://github.com/your-username/GSE_ControlSystem.git
cd GSE_ControlSystem

Set up the CCS workspace using the provided script:
bash tools/ccs_project_setup.sh

Build the bootloader and LED application projects in CCS.

Program the bootloader to the target device using CCS.

Usage
Update Firmware:
Use the main.py script in the firmware_updater directory to send firmware to the target device.
bash
Copy code
python3 firmware_updater/main.py
Observe Behavior:
The bootloader switches to the LED application upon successful update.
Verify the LED toggles as expected.