# Traffic Light Controller (Moore FSM)
## Problem Statement
Design a Moore-type finite state machine that controls a standard
3-light traffic signal (Red → Yellow → Green → Yellow → Red), cycling
through states synchronously on every clock edge.
## State Diagram

<img width="537" height="176" alt="image" src="https://github.com/user-attachments/assets/35e33f7d-ca86-498e-9fa7-09e02d92bce0" />

| State | Encoding | Meaning |
|---|---|---|
| RED_STATE | 2'b00 | Stop |
| YELLOW1_STATE | 2'b01 | Red → Green transition |
| GREEN_STATE | 2'b10 | Go |
| YELLOW2_STATE | 2'b11 | Green → Red transition |
## State Table
| Present State | Next State | red | yellow | green |
|---|---|---|---|---|
| RED_STATE | YELLOW1_STATE | 1 | 0 | 0 |
| YELLOW1_STATE | GREEN_STATE | 0 | 1 | 0 |
| GREEN_STATE | YELLOW2_STATE | 0 | 0 | 1 |
| YELLOW2_STATE | RED_STATE | 0 | 1 | 0 |
## Design Details
- **Type:** Moore machine — each output (`red`, `yellow`, `green`) depends only on the present state, not any input.
- **Reset:** Asynchronous, active-high (`posedge rst` in the state register's sensitivity list), forces the FSM to `RED_STATE`.
- **Transition rule:** Unconditional — the FSM advances to the next state on every clock edge (no external input drives the sequence). A real-world controller would add per-state timers to hold each light for a set duration.
- **Encoding:** 4 states as a synthesizable `typedef enum logic [1:0]` (`RED_STATE`, `YELLOW1_STATE`, `GREEN_STATE`, `YELLOW2_STATE`).
## Files
```
02-traffic-light-fsm/
├── rtl/
│   └── traffic_light_fsm.sv        # DUT — Moore FSM
├── tb/
│   └── tb_traffic_light_fsm.sv     # Testbench with clock/reset generation and $monitor
└── README.md
```
## Testbench Summary
The testbench resets the FSM, releases reset, and lets it free-run,
capturing every clock-driven state transition. Expected cycle order
(one state advance per clock edge, repeating):
```
RED -> YELLOW1 -> GREEN -> YELLOW2 -> RED -> YELLOW1 -> GREEN -> YELLOW2 -> ...
```
## How to Simulate (Icarus Verilog)
```bash
iverilog -g2012 -o sim rtl/traffic_light_fsm.sv tb/tb_traffic_light_fsm.sv
vvp sim
```
To view waveforms, add a `$dumpfile` / `$dumpvars` block to the
testbench and open the generated `.vcd` in GTKWave:
```bash
gtkwave dump.vcd
```
## Sample Simulation Output
```
Time    clk  rst  red  yellow  green
15000   1    0    0    1       0     <- YELLOW1
25000   1    0    0    0       1     <- GREEN
35000   1    0    0    1       0     <- YELLOW2
45000   1    0    1    0       0     <- RED
55000   1    0    0    1       0     <- YELLOW1 (cycle repeats)
```
## Output wave
<img width="1059" height="185" alt="image" src="https://github.com/user-attachments/assets/73d7b5ef-4731-4af5-ac30-fa786c9d2671" />

## Tools Used
- Language: SystemVerilog
- Simulator: Icarus Verilog
- Waveform Viewer: EPWave
