from uart_handler import UARTHandler
from packet_handler import PacketHandler

if __name__ == "__main__":
    # Open UART connection
    uart = UARTHandler.get_instance(port="/dev/ttyACM0", baudrate=115200)
    uart.open()

    try:
        packet_handler = PacketHandler(uart)

        # Step 1: Verify communication with the bootloader
        print("Verifying communication with the bootloader...")
        if not packet_handler.send_and_confirm(bytes([0x20])):
            print("PING command failed. Aborting.")
            exit(1)
        print("PING command acknowledged!")
        if not packet_handler.send_and_confirm(bytes([0x20])):
            print("PING command failed. Aborting.")
            exit(1)
        print("PING command acknowledged!")
        
        if not packet_handler.send_and_confirm(bytes([0x20])):
            print("PING command failed. Aborting.")
            exit(1)
        print("PING command acknowledged!")
        

        # Step 2: Prepare firmware data
        firmware_address = 0x2800  # APP_START_ADDRESS
        firmware_file = "/home/gena/PROJECTS/EMBEDDED_PROJECTS/GSE_ControlSystem/firmware_updater/blink_led.bin"

        print(f"Reading firmware from: {firmware_file}")
        try:
            with open(firmware_file, "rb") as fw:
                firmware_data = fw.read()
        except FileNotFoundError:
            print(f"Firmware file not found: {firmware_file}")
            exit(1)

        # Detect firmware size and align to 4-byte boundaries
        firmware_size = (len(firmware_data) + 3) & ~3  # Align to 32-bit boundary
        firmware_data = firmware_data.ljust(firmware_size, b'\x00')  # Pad with zero bytes
        print(f"Prepared firmware data of size {firmware_size} bytes.")

        # Step 3: Send COMMAND_DOWNLOAD to initialize transfer
        if not packet_handler.handle_download(firmware_address, firmware_size):
            print("Download command failed. Aborting.")
            exit(1)
        print("Download command acknowledged!")

        # Step 4: Transfer firmware in chunks
        chunk_size = 64  # Maximum chunk size
        for i in range(0, len(firmware_data), chunk_size):
            chunk = firmware_data[i:i + chunk_size]
            print(f"Sending chunk {i // chunk_size + 1} of size {len(chunk)} bytes...")
            if not packet_handler.handle_send_data(chunk):
                print(f"SEND_DATA failed for chunk {i // chunk_size + 1}. Aborting.")
                exit(1)
        print("All firmware chunks sent successfully.")

        # Step 5: Confirm final status
        #status_code = packet_handler.handle_get_status()
        #print(f"Final Status Code: {status_code:#04x}")
        #if status_code != 0x40:  # Assuming 0x40 indicates success
        #    print("Final status indicates failure. Check bootloader logs.")
        #    exit(1)
        #print("Firmware transfer completed successfully!")

        if packet_handler.handle_reset():
            print("Reset command succeeded. Device will reboot and start the application.")
        else:
            print("Reset command failed.")


    finally:
        # Ensure UART is closed
        uart.close()
