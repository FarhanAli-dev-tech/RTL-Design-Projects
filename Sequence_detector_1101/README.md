# 1101 Sequence Detector (Moore FSM)

## Problem Statement
Design a Moore-type finite state machine that detects the serial bit
pattern `1101` on a single-bit input stream. On detection, the
`detected` output goes high for one clock cycle. This implementation
handles **overlapping** sequences — meaning if the last two bits of a
detected pattern ("11") can also serve as the start of the next match,
that overlap is reused instead of restarting from scratch.

## State Diagram


<img width="568" height="319" alt="image" src="https://github.com/user-attachments/assets/5f5a8a28-94b7-4c10-acae-8302df4f6dd8" />




| State | Meaning (bits matched so far) |
|---|---|
| S0 | No match |
| S1 | "1" |
| S2 | "11" |
| S3 | "110" |
| S4 | "1101" → detected |

## State Table

| Present State | din = 0 (Next State) | din = 1 (Next State) | Output (detected) |
|---|---|---|---|
| S0 | S0 | S1 | 0 |
| S1 | S0 | S2 | 0 |
| S2 | S3 | S2 | 0 |
| S3 | S0 | S4 | 0 |
| S4 | S0 | S2 (overlap) | 1 |

## Design Details
- **Type:** Moore machine — output depends only on the present state, not the input.
- **Reset:** Asynchronous, active-high (`posedge rst` in the state register's sensitivity list).
- **Overlap handling:** From `S4`, if `din = 1`, the FSM moves to `S2` instead of `S1`, since the trailing "11" of the just-detected pattern can seed the next match.
- **Encoding:** 5 states as a synthesizable `typedef enum logic [2:0]` (`S0`–`S4`).

## Files
```
01-sequence-detector-1101/
├── rtl/
│   └── seq1101_moore.sv        # DUT — Moore FSM
├── tb/
│   └── tb_seq1101_moore.sv     # Testbench with clock/reset generation and $monitor
└── README.md
```

## Testbench Summary
The testbench applies the serial stream `1 1 0 1 1 0 1 0 0` and
verifies two detections:

| Event | din stream so far | detected |
|---|---|---|
| 4th bit | ...1101 | **1** (first match) |
| 7th bit | ...1101101 | **1** (second, overlapping match) |

## How to Simulate (Icarus Verilog)
```bash
iverilog -g2012 -o sim rtl/seq1101_moore.sv tb/tb_seq1101_moore.sv
vvp sim
```

To view waveforms, add a `$dumpfile` / `$dumpvars` block to the
testbench and open the generated `.vcd` in GTKWave:
```bash
gtkwave dump.vcd
```

## Sample Simulation Output
```
Time    clk  rst  din  detected
55000   1    0    1    1     <- first "1101" detected
85000   1    0    0    1     <- second "1101" detected (overlap)
```
## Output wave 

<img width="1072" height="190" alt="image" src="https://github.com/user-attachments/assets/81f29e77-e915-44f7-84e1-130c47b5edc1" />



## Tools Used
- Language: SystemVerilog
- Simulator: Icarus Verilog
- Waveform Viewer: EPAWave

