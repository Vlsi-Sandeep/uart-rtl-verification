UART RTL Design & Verification

An 8-bit UART transmitter and receiver designed in Verilog HDL and verified using Siemens Questa 2024.1.

📌 Project Overview

This project implements a complete UART communication path at RTL level.

Key Features

8-bit UART Transmitter

8-bit UART Receiver

Baud/timing tick generator

TX → RX serial loopback

FSM-based control

Self-checking testbench

Multiple data-pattern verification

Questa waveform analysis

🏗️ Architecture

                         UART SYSTEM
                              │
                              ▼
                    ┌──────────────────┐
                    │   Baud Tick      │
                    │    Generator     │
                    └────────┬─────────┘
                             │
                             │ Timing Tick
                             ▼
       ┌──────────────┐              ┌──────────────┐
       │              │              │              │
Data ──►   UART TX    ├─── Serial ──►│   UART RX    ├───► Data Out
       │              │    TX → RX    │              │
       └──────────────┘   Loopback    └──────────────┘
              │                              │
              ▼                              ▼
            Busy                           Done

Data Flow

Parallel Data
     │
     ▼
┌──────────┐
│ UART TX  │
└────┬─────┘
     │
     │ Serial UART Frame
     ▼
┌──────────┐
│ UART RX  │
└────┬─────┘
     │
     ▼
Parallel Data

The transmitted serial signal is internally connected back to the receiver for loopback verification.

🔄 UART Frame Format

Field

Size

Description

Start Bit

1 bit

Indicates beginning of transmission

Data

8 bits

Payload data, transmitted LSB first

Stop Bit

1 bit

Indicates end of frame

Idle     Start          Data Bits                 Stop
  1        0       D0 D1 D2 D3 D4 D5 D6 D7          1
───┐      ┌──────────────────────────────────────┐
   └──────┘                                      └──────

Example: 41h

41h = 01000001

UART transmission → 1 0 0 0 0 0 1 0
                    ↑
                  LSB first

🧩 RTL Modules

Module

Purpose

baud_tick.v

Generates the timing tick used by the UART

uart_tx.v

Converts 8-bit parallel data into serial UART data

uart_rx.v

Samples serial data and reconstructs the original byte

uart_top.v

Connects TX and RX together for loopback operation

uart_top_tb.v

Self-checking testbench for automated verification

⚙️ Transmitter Flow

        IDLE
          │
       send = 1
          ▼
       START
          │
         tick
          ▼
        DATA
          │
     8 bits sent
          ▼
        STOP
          │
         tick
          ▼
        IDLE

The transmitter uses a shift register to send data LSB first.

⚙️ Receiver Flow

        IDLE
          │
     Detect RX = 0
          ▼
       START
          │
    Verify start bit
          ▼
        DATA
          │
    Sample 8 bits
          ▼
        STOP
          │
   Verify stop bit
          ▼
       DATA OUT

The receiver samples the serial input and reconstructs the original 8-bit data.

⏱️ Simulation Parameters

Parameter

Value

System Clock

10 MHz

Clock Period

100 ns

Timing Tick

1 MHz

Tick Period

1 µs

Data Width

8 bits

Start Bits

1

Stop Bits

1

The timing values are intentionally simplified for RTL simulation and learning rather than targeting a standard UART baud rate.

🧪 Verification Strategy

The testbench uses a self-checking verification approach.

       Test Data
           │
           ▼
     ┌───────────┐
     │ UART TX   │
     └─────┬─────┘
           │
           ▼
      Serial TX
           │
           ▼
     ┌───────────┐
     │ UART RX   │
     └─────┬─────┘
           │
           ▼
      Received Data
           │
           ▼
    Compare with
     Sent Data
           │
      ┌────┴────┐
      ▼         ▼
    PASS       FAIL

🔍 Test Cases

Test

Transmitted

Received

Purpose

1

41h

41h

Normal data pattern

2

55h

55h

Alternating bits

3

AAh

AAh

Inverse alternating bits

4

00h

00h

All zeros

5

FFh

FFh

All ones

Verification Result

PASS: Sent = 41, Received = 41
PASS: Sent = 55, Received = 55
PASS: Sent = aa, Received = aa
PASS: Sent = 00, Received = 00
PASS: Sent = ff, Received = ff

-----------------------------
ALL TESTS COMPLETED
-----------------------------

Result: 5/5 test cases passed ✅

📊 Simulation Results

1. Complete UART Loopback

The complete loopback simulation shows multiple data transactions from data_in through TX, the serial connection, and RX to data_out.
![https://github.com/Vlsi-Sandeep/uart-rtl-verification/blob/01d4aa4e72a22f3a02667e9ba808d2c3ec227a2d/doc/Screenshot%202026-10-05%20192255.png]


What this shows:

Input data changes between test cases

TX generates the serial waveform

RX reconstructs the transmitted byte

busy indicates active transmission

done indicates successful reception

2. UART Transmitter
   ![https://github.com/Vlsi-Sandeep/uart-rtl-verification/blob/01d4aa4e72a22f3a02667e9ba808d2c3ec227a2d/doc/Screenshot%202026-10-05%20192530.png]



What this shows:

data = 41h

send starts transmission

tx generates the UART serial frame

Data is transmitted LSB first

busy remains active during transmission

done indicates completion

3. UART Receiver
![https://github.com/Vlsi-Sandeep/uart-rtl-verification/blob/01d4aa4e72a22f3a02667e9ba808d2c3ec227a2d/doc/Screenshot%202026-10-05%20192622.png]


What this shows:

Serial data enters through rx

Receiver detects the start bit

Individual data bits are sampled

The byte is reconstructed

data = 41h after successful reception

done generates a completion pulse

4. Automated Verification Output

![https://github.com/Vlsi-Sandeep/uart-rtl-verification/blob/01d4aa4e72a22f3a02667e9ba808d2c3ec227a2d/doc/Screenshot%202026-10-05%20192154.png]

The Questa transcript demonstrates that the testbench automatically compared transmitted and received data.

All five test patterns passed successfully.

🖼️ Project Poster



📁 Repository Structure

uart-rtl-verification/
│
├── rtl/
│   ├── baud_tick.v
│   ├── uart_tx.v
│   ├── uart_rx.v
│   └── uart_top.v
│
├── tb/
│   └── uart_top_tb.v
│
├── docs/
│   ├── uart_loopback.png
│   ├── uart_tx.png
│   ├── uart_rx.png
│   └── verification_results.png
│
├── .gitignore
└── README.md

🛠️ Tools & Technologies

Category

Technology

HDL

Verilog

Simulation

Siemens Questa 2024.1

Verification

Self-checking Testbench

Debugging

Questa Waveform Viewer

Version Control

Git / GitHub

🎯 Key Concepts Demonstrated

RTL Design · FSM · UART Protocol · Shift Registers · Sequential Logic · Serial Communication · TX/RX Loopback · Testbench Development · Self-Checking Verification · Waveform Debugging

🚀 Future Improvements

Standard baud-rate support such as 9600 and 115200

Configurable baud-rate generator

Parity-bit support

Framing-error detection

SystemVerilog assertions

Functional and code coverage

Constrained-random verification

SystemVerilog/UVM verification environment

👨‍💻 Author

Sandeep C

B.Tech ECE | VLSI | RTL Design | Functional Verification

GitHub
