# Vending Machine Controller (Moore/Mealy-style FSM)
## Problem Statement
Design an FSM that accepts Rs 5 and Rs 10 coins, tracks the total
amount inserted, dispenses the item once enough money is collected,
and returns change if the customer withdraws or overpays.
## State Diagram
<img width="549" height="274" alt="image" src="https://github.com/user-attachments/assets/470ab0da-8f5a-4103-8383-4e565e1c1050" />

| State | Encoding | Meaning |
|---|---|---|
| S0 | 2'b00 | Rs 0 collected |
| S1 | 2'b01 | Rs 5 collected |
| S2 | 2'b10 | Rs 10 collected |
## State Table
| Present State | in = 00 (no coin) | in = 01 (Rs 5) | in = 10 (Rs 10) |
|---|---|---|---|
| S0 | S0 | S1 | S2 |
| S1 | S0, change=01 (refund Rs5) | S2 | S0, out=1 (dispense) |
| S2 | S0, change=10 (refund Rs10) | S0, out=1 (dispense) | S0, out=1, change=01 (dispense + Rs5 change) |
## Design Details
- **Inputs:** `in[1:0]` — `00` = no coin, `01` = Rs 5 inserted, `10` = Rs 10 inserted.
- **Outputs:** `out` = item dispense pulse, `change[1:0]` = amount to return (`00`=none, `01`=Rs5, `10`=Rs10).
- **Reset:** Asynchronous, active-high (`posedge rst`), forces the FSM to `S0` (Rs 0 collected).
- **Item cost assumption:** Rs 15 — the FSM dispenses once total inserted reaches or exceeds Rs 15, returning any excess as change (e.g. Rs10 + Rs10 = Rs20 → dispense + Rs5 change back).
- **No-coin behavior:** If `in = 00` while money is already collected (`S1`/`S2`), the design treats it as a withdrawal request and refunds the amount collected so far.
- **Encoding:** 3 states as a synthesizable `typedef enum logic [1:0]` (`S0`, `S1`, `S2`).
## Files
```
03-vending-machine/
├── rtl/
│   └── vending_machine.sv        # DUT — FSM
├── tb/
│   └── tb_vending_machine.sv     # Testbench with clock/reset generation and $monitor
└── README.md
```
## Testbench Summary
The testbench drives two purchase scenarios:
| Scenario | Coin sequence | Expected result |
|---|---|---|
| Exact payment | Rs5 → Rs5 → Rs5 | `out = 1`, `change = 00` (dispense, no change) |
| Overpayment | Rs10 → Rs10 | `out = 1`, `change = 01` (dispense + Rs5 change back) |
## How to Simulate (Icarus Verilog)
```bash
iverilog -g2012 -o sim rtl/vending_machine.sv tb/tb_vending_machine.sv
vvp sim
```
To view waveforms, add a `$dumpfile` / `$dumpvars` block to the
testbench and open the generated `.vcd` in GTKWave:
```bash
gtkwave dump.vcd
```
## Sample Simulation Output
```
Time    State  In   Out  Change
25000   01     01   0    00     <- Rs5 collected (S1)
35000   10     01   1    00     <- 3rd Rs5 -> Rs15 total, dispensed
55000   00     10   0    00     <- fresh Rs10 inserted
65000   10     10   1    01     <- 2nd Rs10 -> Rs20 total, dispensed + Rs5 change
```
## Output wave
<img width="1057" height="201" alt="image" src="https://github.com/user-attachments/assets/5a741196-5924-456d-a0af-dd97132780f7" />

## Tools Used
- Language: SystemVerilog
- Simulator: Icarus Verilog
- Waveform Viewer: EPWave
