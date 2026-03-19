FPGA UART Data Reception & Display on 7-Segment
Project Overview
This project implements UART communication on an FPGA to receive serial data from a PC (via C program) and display the received ASCII values on:

LEDs (binary format)

7-segment display (decimal representation)

 Features
✅ Receives serial data using UART RX
✅ Displays ASCII value in binary on LEDs
✅ Converts ASCII data to decimal and shows it on a multiplexed 7-segment display
✅ Uses FPGA clock & baud rate synchronization for reliable communication

Project Architecture
The project consists of the following key modules:

1️. UART Receiver (uart_rx.v)
Captures serial data at 9600 baud rate

Detects start bit, reads 8 data bits, and latches received data

Implements a state machine for accurate reception

2️. Display Controller (uart_display.v)
Stores received ASCII character

Extracts tens and ones digits for decimal conversion

Uses multiplexing to display digits on a dual 7-segment display

3️. C Program (uart_sender.c)
Sends user input via serial communication

Uses Windows COM port for UART transmission

Hardware & Tools Used
1. FPGA Board: XC7S15GTB Edge Spartan-7 FPGA
2. Software: Xilinx Vivado, GCC for C programming
3. Language: Verilog, C

 How to Run the Project
1️. FPGA Setup
Synthesize and upload uart_rx.v and uart_display.v to the FPGA

Ensure UART RX pin is correctly connected

2️. Run the C Program
Compile the uart_sender.c file:

bash
Copy
Edit
gcc uart_sender.c -o uart_sender.exe
Execute the program and enter a character:

bash
Copy
Edit
./uart_sender.exe 

3️. Verify Output
The LEDs should show the binary representation of the ASCII character

The 7-segment display should show the decimal equivalent

-> Project Demo
Watch the full project in action: (https://www.youtube.com/watch?v=dF5c20NIxpw)


-> Connect With Me
LinkedIn Profile - https://www.linkedin.com/in/ayush-dwivedi-a9aa40238/
