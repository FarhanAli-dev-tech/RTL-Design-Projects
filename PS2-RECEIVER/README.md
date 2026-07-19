# PS/2 Receiver
## Problem Statement
Design an FSM-based PS/2 protocol receiver that samples a serial
`ps2_data` line, assembles an 8-bit scan code (LSB first), checks the
odd-parity bit and stop bit, and reports the decoded scan code with
`data_ready`, `parity_error`, and `frame_error` flags.
## State Diagram
<img width="525" height="380" alt="image" src="https://github.com/user-attachments/assets/a4f5aff6-6fba-4f91-bd83-e5493904c11b" />


| State | Meaning |
|---|---|
| IDLE | Waiting for start bit (`ps2_data = 0` while `ps2_valid`) |
| START | Start bit acknowledged |
| DATA | Shifting in 8 data bits, LSB first |
| PARITY | Sampling the parity bit |
| STOP | Sampling the stop bit |
| CHECK | Validating stop bit, parity, and scan code table |
## State Table
| Present State | Condition | Next State |
|---|---|---|
| IDLE | `ps2_valid && ps2_data==0` | START |
| START | — | DATA |
| DATA | `bit_count == 8` | PARITY |
| PARITY | — | STOP |
| STOP | — | CHECK |
| CHECK | — | IDLE |
## Design Details
- **Frame format:** Start bit (0) → 8 data bits (LSB first) → parity bit (odd) → stop bit (1).
- **Scan code validation:** In `CHECK`, the stop bit is checked first, then odd parity, then the assembled byte is matched against a fixed table of valid make-codes (0–9, A–F); anything outside that table raises `frame_error`.
- **Reset:** Asynchronous, active-high (`posedge rst`), clears `state`, `bit_count`, and `shift_reg`.
## Files
```
05-ps2-receiver/
├── rtl/
│   └── ps2_receiver.sv        # DUT — PS/2 receiver FSM
├── tb/
│   └── tb_ps2_receiver.sv     # Testbench: 5 scenarios (valid keys, invalid code, parity error, stop-bit error)
└── README.md
```

## ⚠️ Known Issues (found during simulation)
While verifying this design, simulation surfaced a real functional bug —
documenting it here rather than hiding it, since it affects every test
after the first frame:

**`bit_count` is only reset on `rst`, never when the FSM returns to
`IDLE` after a frame completes.** Combined with an off-by-one in the
`DATA → PARITY` exit condition (one extra bit gets shifted in before
the transition fires), this causes:
- **Frame 1** to decode incorrectly — sending `0x1C` produces a final
  `shift_reg` of `0x0E` (misaligned by one bit) instead of `0x1C`,
  and incorrectly raises `parity_error`.
- **Every frame after the first** to never reach `CHECK` at all —
  `bit_count` keeps climbing past 8 (9, 10, 11…) and never lands back
  on 8, so the FSM gets stuck in `DATA` forever. `data_ready` never
  asserts even once across all 5 test cases in the provided testbench.

**Likely fix:** explicitly reset `bit_count <= 0` on the
`CHECK → IDLE` transition (or whenever `state == CHECK`), and correct
the `DATA` exit condition so it transitions after capturing exactly 8
bits, not 9.

*I can patch and re-verify the RTL if you'd like a working version for
the repo — just say the word.*

## Testbench Summary (as provided)
The testbench drives 5 scenarios via a `send_frame` task:

| Test | Scenario | Expected result |
|---|---|---|
| 1 | Valid key `0x1C` (A) | `data_ready = 1` |
| 2 | Valid key `0x2E` (5) | `data_ready = 1` |
| 3 | Invalid scan code `0x55` | `frame_error = 1` |
| 4 | Wrong parity bit | `parity_error = 1` |
| 5 | Wrong stop bit | `frame_error = 1` |

**Actual observed result:** none of the 5 tests produce `data_ready = 1`
due to the bug above — see Known Issues.
## How to Simulate (Icarus Verilog)
```bash
iverilog -g2012 -o sim rtl/ps2_receiver.sv tb/tb_ps2_receiver.sv
vvp sim
```
To view waveforms, add a `$dumpfile` / `$dumpvars` block to the
testbench and open the generated `.vcd` in GTKWave:
```bash
gtkwave dump.vcd
```
## Output wave
<img width="1057" height="247" alt="image" src="https://github.com/user-attachments/assets/01e10d70-a825-4867-8634-5a0f44d5ca0f" />

## Tools Used
- Language: SystemVerilog
- Simulator: Icarus Verilog
- Waveform Viewer: GTKWave
