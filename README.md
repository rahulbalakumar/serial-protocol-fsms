# SPI Master (SystemVerilog)

A from-scratch SPI master controller, built module by module with an FSM-first design approach. Currently implements SPI Mode 0 (CPOL=0, CPHA=0).

## Project goals

This project is a deliberate exercise in designing a **complex, multi-condition FSM** correctly from first principles — deriving states, inputs, outputs, and Mealy vs. Moore output timing directly from the SPI protocol's timing requirements, rather than starting from a template.

## Architecture

The design is split into independent modules by concern:

| Module | Responsibility | Status |
|---|---|---|
| `spi_fsm` | Control unit — sequences the transfer, drives control signals to the other modules | ✅ Complete |
| `spi_clock_gen` | Generates SCLK from the system clock via a programmable divider; produces `rising_edge` / `falling_edge` pulses | ⏳ Not started |
| `spi_shift_reg` | Bidirectional shift register — holds transfer data, shifts on `shift_en`, samples on `sample_en`, tracks bit position, reports `bit_count_done` | ⏳ Not started |
| `spi_top` | Top-level wiring of the above three modules; exposes SCLK/MOSI/MISO/CS and a simple start/busy control interface | ⏳ Not started |
| Testbench (fake slave) | Drives known data onto MISO on the correct edges and checks MOSI, to verify the master without real hardware | ⏳ Not started |

## `spi_fsm` — design notes

A 2-state Mealy machine: `IDLE`, `TRANSFER`.

**Ports**

```systemverilog
module spi_fsm (
    input  logic clk,
    input  logic rstn,          // async, active-low
    input  logic start,         // single-cycle pulse
    input  logic rising_edge,   // from spi_clock_gen, mutually exclusive with falling_edge
    input  logic falling_edge,  // from spi_clock_gen
    input  logic bit_count_done,// level signal from spi_shift_reg
    output logic cs,            // active-low chip select
    output logic sclk_en,       // enables spi_clock_gen
    output logic load,          // one-cycle pulse: latch new data into spi_shift_reg
    output logic sample_en,     // one-cycle pulse: capture incoming bit (rising edge)
    output logic shift_en,      // one-cycle pulse: shift out next bit (falling edge)
    output logic busy           // high while state == TRANSFER
);
```

**States and transitions**

- `IDLE → TRANSFER` on `start` (with `load` pulsed as the transition's output)
- `TRANSFER` self-loops on every clock edge except the final one:
  - `rising_edge` → pulse `sample_en` (data is sampled; this is Mode 0's sample edge)
  - `falling_edge && !bit_count_done` → pulse `shift_en` (data is shifted to the next bit)
  - `falling_edge && bit_count_done` → pulse `shift_en`, transition back to `IDLE`

**State diagram**

![spi_fsm state diagram](fsm_diagram.svg)

**Key design decisions (and why)**

- **No dedicated `LOAD` state.** `spi_shift_reg`'s registered load-to-output delay (1 cycle) is always ≤ `spi_clock_gen`'s enable-to-first-edge delay (≥1 cycle, since it's a divided clock), so data is guaranteed valid before SCLK's first real toggle — no race, no extra state needed.
- **No dedicated wrap-up state.** Dropping `cs` and resetting the bit counter both ride along on the `TRANSFER → IDLE` transition edge; nothing needs to observe them before the next `load` happens anyway.
- **Bit counter reset is implicit.** Rather than an explicit `counter_reset` output, the counter is simply reset as a side effect of the *next* `load` — one trigger, one place the reset logic lives.
- **`busy` (level) over `done` (pulse).** A level signal is always safely re-checkable by a downstream consumer regardless of when it's polled; a bare one-cycle pulse can be silently missed with no way to recover. `busy = (state == TRANSFER)` fully conveys "started" (0→1) and "finished" (1→0) to a consumer that waits correctly.
- **Two separate `always_comb` blocks for next-state vs. output logic**, both with explicit defaults (`next_state = state;` / `load, sample_en, shift_en = 0;`) to avoid inferring unintended latches for any unhandled input combination.

## Next steps

1. `spi_clock_gen` — derive `rising_edge`/`falling_edge` as mutually-exclusive pulses from a divided system clock, gated by `sclk_en`
2. `spi_shift_reg` — registered load/shift with a bit counter and `bit_count_done` output
3. `spi_top` — wire the above three modules together
4. Fake-slave testbench for end-to-end verification
5. Generalize to all 4 SPI modes (CPOL/CPHA as runtime inputs) once Mode 0 is fully verified