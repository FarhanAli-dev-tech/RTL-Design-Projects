# 8-bit Synchronous FIFO
## Problem Statement
Design a synchronous FIFO (First-In-First-Out) memory buffer, 8 bits
wide and 8 entries deep, supporting independent write and read
requests on the same clock, with `full` and `empty` status flags and
correct behavior when a read and write happen on the same cycle.

| Signal | Direction | Width | Description |
|---|---|---|---|
| clk | input | 1 | System clock |
| rst | input | 1 | Asynchronous, active-high reset |
| wr_en | input | 1 | Write enable |
| rd_en | input | 1 | Read enable |
| data_in | input | 8 | Data to write |
| data_out | output | 8 | Data read (registered) |
| full | output | 1 | High when FIFO holds `DEPTH` entries |
| empty | output | 1 | High when FIFO holds 0 entries |
## Operating Cases

| Case | Condition | Behavior |
|---|---|---|
| Write only | `wr_en=1, rd_en=0, !full` | `data_in` stored at `wr_ptr`, `wr_ptr++`, `count++` |
| Read only | `rd_en=1, wr_en=0, !empty` | `data_out <= mem[rd_ptr]`, `rd_ptr++`, `count--` |
| Simultaneous read+write | `rd_en=1, wr_en=1` | Read happens if `!empty`, write happens if `!full`, both in the same cycle — `count` stays net unchanged if both occur |
| FIFO full | `wr_en=1, full=1` | Write is blocked (no overflow) |
| FIFO empty | `rd_en=1, empty=1` | Read is blocked (no underflow) |
## Design Details
- **Depth:** 8 entries (`parameter DEPTH = 8`), each 8 bits wide.
- **Pointers:** `wr_ptr` and `rd_ptr` are 3-bit pointers (cover indices 0–7); `count` is a 4-bit counter (needs to represent up to 8).
- **Reset:** Asynchronous, active-high — clears both pointers, the counter, and `data_out`.
- **Flags:** `full = (count == DEPTH)`, `empty = (count == 0)`, both combinationally derived from `count`.
- **Data output:** Registered (`data_out` updates one cycle after `rd_en` is asserted), consistent with a synchronous-read FIFO.
## Files
```
04-fifo-8bit/
├── rtl/
│   └── fifo_8bit.sv        # DUT — Synchronous FIFO
├── tb/
│   └── tb_fifo.sv          # Testbench with clock/reset generation and $monitor
└── README.md
```
## Testbench Summary
The testbench covers the **write-only** and **read-only** cases:
1. Writes `0x11`, `0x22`, `0x33` on three consecutive cycles.
2. Stops writing, then reads back for four cycles.
3. Verifies data comes out in the same order it was written (FIFO order), and `empty` correctly asserts once all entries are drained.

> Note: this testbench does not exercise the **full** condition or the
> **simultaneous read+write** case — worth adding as follow-up tests
> if the lab requires full-coverage verification.
## How to Simulate (Icarus Verilog)
```bash
iverilog -g2012 -o sim rtl/fifo_8bit.sv tb/tb_fifo.sv
vvp sim
```
To view waveforms, add a `$dumpfile` / `$dumpvars` block to the
testbench and open the generated `.vcd` in GTKWave:
```bash
gtkwave dump.vcd
```
## Sample Simulation Output
```
Time    wr_en  rd_en  data_in  data_out  full  empty
15000   1      0      11       00              0     1     <- write 0x11
25000   1      0      22       00              0     0     <- write 0x22
35000   1      0      33       00              0     0     <- write 0x33
55000   0      1      33       00              0     0     <- read starts
65000   0      1      33       11              0     0     <- data_out = 0x11
75000   0      1      33       22              0     0     <- data_out = 0x22
85000   0      0      33       33              0     1     <- data_out = 0x33, FIFO empty
```
## Output wave
<img width="1058" height="260" alt="image" src="https://github.com/user-attachments/assets/29825978-9be6-4222-b289-4b89ee381119" />

## Tools Used
- Language: SystemVerilog
- Simulator: Icarus Verilog
- Waveform Viewer: EPWave
