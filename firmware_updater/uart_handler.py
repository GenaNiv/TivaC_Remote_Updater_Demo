import serial
from serial import SerialException

class UARTHandler:
    """
    UARTHandler class manages UART communication with a Singleton pattern.
    """

    _instance = None  # Class-level variable for Singleton instance

    @staticmethod
    def get_instance(port: str, baudrate: int = 115200, timeout: float = 1.0):
        """
        Singleton access method.
        Ensures only one instance of UARTHandler exists.
        """
        if UARTHandler._instance is None:
            UARTHandler._instance = UARTHandler(port, baudrate, timeout)
        return UARTHandler._instance

    def __init__(self, port: str, baudrate: int, timeout: float):
        """
        Initializes the UART handler.
        :param port: UART port (e.g., /dev/ttyUSB0).
        :param baudrate: Communication baud rate (default: 115200).
        :param timeout: Read timeout in seconds (default: 1 second).
        """
        if UARTHandler._instance is not None:
            raise Exception("UARTHandler is a singleton class. Use get_instance() instead.")

        self.port = port
        self.baudrate = baudrate
        self.timeout = timeout
        self.serial = None

    def open(self):
        """
        Opens the UART connection.
        """
        try:
            self.serial = serial.Serial(
                port=self.port,
                baudrate=self.baudrate,
                timeout=self.timeout
            )
            if self.serial.is_open:
                print(f"UART connection established on {self.port} at {self.baudrate} bps.")
        except SerialException as e:
            raise RuntimeError(f"Failed to open UART port {self.port}: {e}")

    def close(self):
        """
        Closes the UART connection.
        """
        if self.serial and self.serial.is_open:
            self.serial.close()
            print(f"UART connection on {self.port} closed.")

    def send(self, data: bytes):
        """
        Sends data over UART.
        :param data: Bytes to send.
        """
        if not self.serial or not self.serial.is_open:
            raise RuntimeError("UART connection is not open.")
        self.serial.write(data)
        print(f"Sent: {data.hex()}")

    def receive(self, size: int) -> bytes:
        """
        Receives data from UART.
        :param size: Number of bytes to read.
        :return: Bytes received.
        """
        if not self.serial or not self.serial.is_open:
            raise RuntimeError("UART connection is not open.")
        data = self.serial.read(size)
        print(f"Received: {data.hex()}")
        return data

    def flush(self):
        """
        Flushes UART input and output buffers.
        """
        if self.serial and self.serial.is_open:
            self.serial.reset_input_buffer()
            self.serial.reset_output_buffer()
            print("UART buffers flushed.")

    def __del__(self):
        """
        Destructor to ensure the UART connection is closed.
        """
        self.close()


if __name__ == "__main__":
    # Access UARTHandler Singleton
    uart = UARTHandler.get_instance(port="/dev/ttyACM0", baudrate=115200)
    try:
        uart.open()
        uart.send(b'\x23')  # Example: Send COMMAND_GET_STATUS
        response = uart.receive(2)  # Receive 2 bytes
        print(f"Response: {response.hex()}")
    finally:
        uart.close()
