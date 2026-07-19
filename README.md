# RTL-Design-Projects

A collection of digital design projects implemented in SystemVerilog,
covering FSM design, memory structures, and serial protocol handling.
Each project includes RTL code, a testbench, a dedicated README with
the state diagram/table, and simulation results — with any issues
found during verification documented honestly rather than hidden.

## Tools Used
- **Language:** SystemVerilog
- **Simulator:** Icarus Verilog
- **Waveform Viewer:** GTKWave

## Projects

| # | Project | Description | Concepts |
|---|---------|-------------|----------|
| 01 | [Sequence Detector (1101)](./Sequence_detector_1101) | Moore FSM detecting overlapping "1101" pattern in a serial bit stream | FSM, Moore Machine |
| 02 | [Traffic Light FSM](./Traffic%20Light%20Fsm) | 4-state controller cycling Red → Yellow → Green → Yellow | FSM, Sequential Logic |
| 03 | [Vending Machine](./Vending%20Machine) | Coin-based controller (Rs 5 / Rs 10) with dispense and change-return logic | FSM, Datapath |
| 04 | [8-bit FIFO](./8-bit%20FIFO) | Synchronous FIFO with write/read/full/empty handling | Memory, Pointers, Synchronous Design |
| 05 | [PS/2 Receiver](./PS2-RECEIVER) | Serial PS/2 protocol receiver with parity and frame-error checking | Protocol, Serial Communication |

## Repository Structure
```
RTL-Design-Projects/
├── README.md
├── Sequence_detector_1101/
│   ├── rtl/
│   ├── tb/
│   └── README.md
├── Traffic Light Fsm/
│   ├── rtl/
│   ├── tb/
│   └── README.md
├── Vending Machine/
│   ├── rtl/
│   ├── tb/
│   └── README.md
├── 8-bit FIFO/
│   ├── rtl/
│   ├── tb/
│   └── README.md
└── PS2-RECEIVER/
    ├── rtl/
    ├── tb/
    └── README.md
```

## How to Run Any Project
```bash
iverilog -g2012 -o sim <project>/rtl/<file>.sv <project>/tb/<file>.sv
vvp sim
```
To view waveforms, add a `$dumpfile` / `$dumpvars` block to the
testbench and open the generated `.vcd` file in GTKWave:
```bash
gtkwave dump.vcd
```

## Author
Farhan — Computer Engineering Graduate, SSUET
