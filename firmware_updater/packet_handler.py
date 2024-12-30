from uart_handler import UARTHandler

class PacketHandler:
    """
    PacketHandler class manages bootloader packets, including construction,
    transmission, reception, and validation.
    """

    def __init__(self, uart: UARTHandler):
        """
        Initializes the PacketHandler with a UARTHandler instance.
        :param uart: An instance of UARTHandler for communication.
        """
        self.uart = uart

    @staticmethod
    def calculate_checksum(data: bytes) -> int:
        """
        Calculates an 8-bit checksum for the given data.
        :param data: Data bytes.
        :return: Calculated checksum as an integer.
        """
        return sum(data) % 256

    def create_packet(self, payload: bytes) -> bytes:
        """
        Creates a bootloader packet with size, checksum, and payload.
        :param payload: Data payload for the packet.
        :return: Complete packet as bytes.
        """
        size = len(payload) + 2  # Add 2 bytes (size and checksum)
        checksum = self.calculate_checksum(payload)
        return bytes([size, checksum]) + payload

    def send_packet(self, payload: bytes) -> None:
        """
        Sends a packet to the target device.
        :param payload: Data payload for the packet.
        :return: None
        """
        packet = self.create_packet(payload)  # Create the packet
        self.uart.send(packet)  # Send the packet over UART
        print(f"Packet sent: {packet.hex()}")

    def wait_for_ack_or_nak(self, timeout: float = 1.0) -> str:
        """
        Waits for an ACK or NAK response from the target.
        :param timeout: Timeout for receiving the response.
        :return: "ACK" if acknowledgment received, "NAK" if no acknowledgment, or raises an error.
        """
        try:
            response = self.uart.receive(2)  # Expecting [0x00, 0xCC] or [0x00, 0x33]
        except TimeoutError:
            raise TimeoutError("Timeout waiting for ACK or NAK.")

        if response == bytes([0x00, 0xCC]):  # COMMAND_ACK
            print("ACK received.")
            return "ACK"
        elif response == bytes([0x00, 0x33]):  # COMMAND_NAK
            print("NAK received.")
            return "NAK"
        else:
            raise ValueError(f"Unexpected response: {response.hex()}")

    def send_and_confirm(self, payload: bytes, retries: int = 3) -> bool:
        """
        Sends a packet and waits for acknowledgment (ACK or NAK).
        :param payload: Data payload for the packet.
        :param retries: Number of retries for sending the packet if NAK is received.
        :return: True if ACK received, False otherwise.
        """
        for attempt in range(retries):
            print(f"Attempt {attempt + 1}/{retries} to send packet.")
            # Flush RX buffer before sending the command
            self.uart.flush()
        
            self.send_packet(payload)  # Send the packet

            try:
                response = self.wait_for_ack_or_nak()  # Wait for ACK or NAK
                if response == "ACK":
                    return True  # Packet sent and acknowledged successfully
                elif response == "NAK":
                    print("NAK received. Retrying...")
            except TimeoutError:
                print("Timeout waiting for ACK or NAK. Retrying...")
            except ValueError as e:
                print(f"Unexpected response: {e}. Retrying...")

        print("Failed to receive ACK after maximum retries.")
        return False

    def send_ack(self):
        """
        Sends an acknowledgment (ACK) to the target.
        """
        COMMAND_ACK = 0xCC
        self.uart.send(bytes([0x00, COMMAND_ACK]))
        print("ACK sent to target.")

    def send_nak(self):
        """
        Sends a no-acknowledgment (NAK) to the target.
        """
        COMMAND_NAK = 0x33
        self.uart.send(bytes([0x00, COMMAND_NAK]))
        print("NAK sent to target.")


    def receive_packet(self) -> bytes:
        """
        Receives a complete packet from the target device, handling fragmentation.
        Sends an acknowledgment (ACK) back to the target if the packet is valid.
        :return: Payload of the received packet.
        :raises RuntimeError: If the packet is invalid (e.g., checksum mismatch or malformed data).
        """
        # Step 1: Receive the size byte
        size = self.uart.receive(1)[0]
        if size == 0:
            raise RuntimeError("Invalid packet size: 0")

        # Step 2: Receive the rest of the packet (size - 1 bytes: checksum + payload)
        packet = self.uart.receive(size - 1)
        if len(packet) != size - 1:
            raise RuntimeError(f"Incomplete packet received. Expected {size - 1} bytes, got {len(packet)} bytes.")

        # Step 3: Extract checksum and payload
        checksum = packet[0]
        payload = packet[1:]  # Remaining bytes after the checksum

        # Step 4: Validate checksum
        calculated_checksum = self.calculate_checksum(payload)
        if checksum != calculated_checksum:
            self.send_nak()  # Send NAK to the target if the checksum is invalid
            raise RuntimeError(f"Checksum mismatch: expected {calculated_checksum}, got {checksum}")

        # Step 5: Send ACK to the target to acknowledge the valid packet
        self.send_ack()

        print(f"Received packet: {payload.hex()}")
        return payload




    def handle_get_status(self) -> int:
        """
        Sends the COMMAND_GET_STATUS command and retrieves the status from the target.
        :return: Status code returned by the target.
        :raises RuntimeError: If there are errors during communication or validation.
        """
        # COMMAND_GET_STATUS = 0x23
        command_get_status = bytes([0x23])

        # Send the command and wait for ACK
        if not self.send_and_confirm(command_get_status):
            raise RuntimeError("Failed to send COMMAND_GET_STATUS.")

        # Handle the response (status packet)
        try:
            status_packet = self.receive_packet()  # Receive the actual payload packet
            if len(status_packet) != 1:
                raise RuntimeError(f"Unexpected status packet length: {len(status_packet)}")

            # Return the status code (1-byte payload)
            status_code = status_packet[0]
            print(f"Status code received: {status_code:#04x}")
            return status_code
        except RuntimeError as e:
            print(f"Error receiving status packet: {e}")
            raise

    def handle_download(self, address: int, size: int) -> bool:
        """
        Sends the COMMAND_DOWNLOAD command to the target to initialize firmware download.
        :param address: The starting address in flash memory.
        :param size: The total size of the firmware in bytes.
        :return: True if the command is acknowledged, False otherwise.
        """
        # COMMAND_DOWNLOAD = 0x21
        command_code = 0x21

        # Convert address and size to 4-byte big-endian format
        address_bytes = address.to_bytes(4, byteorder='big')  # Big-endian
        size_bytes = size.to_bytes(4, byteorder='big')        # Big-endian

        # Construct the payload
        payload = bytes([command_code]) + address_bytes + size_bytes

        # Send the command and wait for acknowledgment
        if self.send_and_confirm(payload):
            print(f"Download command acknowledged: Address={address:#08x}, Size={size}")
            return True
        else:
            print(f"Download command failed: Address={address:#08x}, Size={size}")
            return False



    def handle_send_data(self, data: bytes) -> bool:
        """
        Sends the SEND_DATA command with a chunk of firmware data.
        :param data: Firmware data chunk to send.
        :return: True if acknowledged, False otherwise.
        """
        # COMMAND_SEND_DATA = 0x24
        command_code = 0x24

        # Ensure the chunk size does not exceed the bootloader's buffer size
        if len(data) > 128:
            raise ValueError("Data chunk size exceeds the maximum allowed size of 128 bytes.")

        # Construct the payload
        payload = bytes([command_code]) + data

        # Send the command and wait for acknowledgment
        if self.send_and_confirm(payload):
            print(f"Data chunk sent successfully: {len(data)} bytes")
            return True
        else:
            print("Failed to send data chunk.")
            return False

    def handle_run(self, address: int) -> bool:
        """
        Sends the COMMAND_RUN command to the target to execute the firmware.
        :param address: The starting address of the application.
        :return: True if the command is acknowledged, False otherwise.
        """
        # COMMAND_RUN = 0x22
        command_code = 0x22

        # Convert address to 4-byte big-endian format
        address_bytes = address.to_bytes(4, byteorder='big')  # Big-endian

        # Construct the payload
        payload = bytes([command_code]) + address_bytes

        # Send the command and wait for acknowledgment
        if self.send_and_confirm(payload):
            print(f"Run command acknowledged. Firmware execution started at address: {address:#08x}")
            return True
        else:
            print(f"Run command failed. Target did not acknowledge.")
            return False

    def handle_reset(self) -> bool:
        """
        Sends the RESET command to the target to reset the device.
        :return: True if the command is acknowledged, False otherwise.
        """
        command_code = 0x25

        # Send the command and wait for acknowledgment
        if self.send_and_confirm(bytes([command_code])):
            print("Reset command acknowledged. Device will restart.")
            return True
        else:
            print("Reset command failed.")
            return False
