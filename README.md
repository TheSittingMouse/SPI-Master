# VHDL SPI Master

`spi_master` is a synchronous, full-duplex SPI master written in VHDL. It generates `o_sck`, `o_ss`, and `o_mosi`, samples `i_miso`, and presents simple ready/valid-style interfaces for transmit requests and received words.

The design uses `ieee.std_logic_1164` and `ieee.numeric_std` only. Its frequency, word width, clock polarity, and clock phase are generic parameters, making it a small reusable building block for FPGA designs that need a single SPI master with an automatically controlled slave-select signal.

## Overview

On an accepted transmit request, the master asserts the active-low `o_ss` output and clocks one `c_WIDTH`-bit word out on `o_mosi` while sampling one word from `i_miso`. The completed received word is held on `o_rx_data` and announced by `o_rx_ready` until the consumer asserts `i_rx_valid` at an eligible system-clock edge.

The master can retain one additional transmit word while the current word is shifting. If that look-ahead buffer is populated, the `FINISH` state starts the next word without releasing `o_ss`; otherwise the controller restores `o_sck` to `c_CPOL`, deasserts `o_ss`, and returns to `IDLE`. A received word that is not acknowledged before the next word completes is overwritten and reported through `o_rx_overrun`.

## Interface

The main synthesizable entity is `spi_master` in `rtl/spi_master.vhd`.

### Generics

| Generic / Parameter | Default | Description |
| ------------------- | ------- | ----------- |
| `c_WIDTH` | `8` | SPI word width in bits. The RTL requires a value of at least 2, recommended value is 8. |
| `c_MAIN_CLK_FREQ` | `100_000_000` | Input clock frequency in hertz. |
| `c_SPI_FREQ` | `1_000_000` | Requested serial-clock frequency in hertz. `c_MAIN_CLK_FREQ` must be evenly divisible by this value, and the resulting clock-cycle count must be even. |
| `c_CPOL` | `'1'` | Idle polarity of `o_sck`. |
| `c_CPHA` | `'1'` | SPI clock phase. `'0'` samples on the leading edge; `'1'` samples on the trailing edge. |

### Ports

| Port | Direction | Description |
| ---- | --------- | ----------- |
| `i_clk` | in | Main system clock. All sequential logic, including the synchronous reset and both data handshakes, uses its rising edge. |
| `i_rst` | in | Active-high synchronous reset. It returns the controller to idle, releases `o_ss`, restores `o_sck` to `c_CPOL`, clears buffers and status, and drives `o_mosi` low. |
| `i_tx_data` | in | Next transmit word, `c_WIDTH` bits wide. It is sampled on a rising edge that accepts `i_tx_valid`. |
| `o_rx_data` | out | Registered received word, `c_WIDTH` bits wide. It remains until a later receive completion or reset; `o_rx_ready` qualifies its availability. |
| `o_sck` | out | Generated SPI serial clock. It idles at `c_CPOL`. |
| `o_ss` | out | Automatically controlled, active-low slave-select output. It is low during an active word and remains low between queued words. |
| `o_mosi` | out | Master-out serial-data bit stream, shifted most-significant bit first. |
| `i_miso` | in | Master-in serial-data bit stream, sampled on the edge selected by `c_CPOL` and `c_CPHA`. |
| `i_tx_valid` | in | Transmit request. A word is accepted on an `i_clk` rising edge when `o_tx_ready` is high. |
| `o_tx_ready` | out | High in `IDLE`, and during `TRANSFER` while the one-word transmit look-ahead buffer is empty. Low in `FINISH` or when that buffer is full. |
| `i_rx_valid` | in | Consumer acknowledgement for the word indicated by `o_rx_ready`. Despite its name, the RTL uses it as the receive-side ready/consume input. |
| `o_rx_ready` | out | High when `o_rx_data` contains an unacknowledged received word. |
| `o_tx_buffer_full` | out | High when the one-word transmit look-ahead buffer holds a queued word. |
| `o_busy` | out | High whenever the controller state is not `IDLE`. |
| `o_rx_overrun` | out | High when a just-completed received word overwrites an older unacknowledged word. A normal eligible `i_rx_valid` acknowledgement or reset clears it. |


## Implementation Details

`p_MAIN` in `rtl/spi_master.vhd` implements the controller as a single process with three states: `IDLE`, `TRANSFER`, and `FINISH`. `IDLE` holds `o_ss` high and `o_sck` at `c_CPOL`. On a transmit handshake it initializes `r_tx_reg` and `r_rx_reg`, asserts `r_ss`, and enters `TRANSFER`. For `c_CPHA = '0'`, the first MOSI bit is driven before the first clock edge; for `c_CPHA = '1'`, the first bit is driven at the first shift edge.

The clock divider derives `c_CLK_CYCLES_PER_SCK` from `c_MAIN_CLK_FREQ / c_SPI_FREQ`. `r_clk_count` counts each half period (`c_HALF_SCK_CYCLES`), and `r_sck` toggles at its terminal count. At each toggle point, `v_leading_edge` is derived from the current clock level and `v_sample_edge` selects sampling or shifting from `c_CPHA`. Receive bits shift into `r_rx_reg`; transmit bits shift out of `r_tx_reg`, both most-significant bit first.

When `r_bit_count` reaches the final sampled bit, the assembled word transfers to `r_rx_data`. If `r_rx_ready` was already high, the new word replaces the old one and sets `r_rx_overrun`; otherwise the controller raises `r_rx_ready`. The receive storage is therefore one word deep. The acknowledgement logic clears `r_rx_ready` and `r_rx_overrun` only when `i_rx_valid = '1'`, `r_rx_ready = '1'`, and `r_bit_count /= c_WIDTH - 1`.

During `TRANSFER`, an accepted additional transmit request is copied into `r_tx_data_buffer` and sets `r_tx_data_buffer_full`. `FINISH` waits one half-SCK period after a word completes. If the buffer is full, it moves that word into the shift register, clears the buffer-full flag, and resumes `TRANSFER` with `o_ss` still low. Otherwise it deasserts `o_ss` and returns to `IDLE`. The `c_CPHA` branches restore or advance `r_sck` as needed at this boundary.

The entity has static parameter assertions for `c_WIDTH >= 2`, an integral main-clock-to-SCK ratio, and an even number of main-clock cycles per SCK period. Reset is synchronous: reset outputs and state take effect on an `i_clk` rising edge, not immediately when `i_rst` changes.

## Implementation Results

Measured results depend on the selected FPGA device, tool version, constraints, and generic values. This repository contains no constraints, synthesis reports, implementation reports, or documented measurements.

### Setup

| Item | Value |
| ---- | ----- |
| FPGA Part | Not provided |
| Tool Version | Not provided |
| Clock Constraint | Not provided |
| Important Configuration | No implemented configuration is documented |
| Report Type | No reports are included |

### Timing

| Metric | Value |
| ------ | ----- |
| Worst Negative Slack (WNS) | Not available |
| Total Negative Slack (TNS) | Not available |
| Worst Hold Slack (WHS) | Not available |
| Total Hold Slack (THS) | Not available |

### Utilization

| Resource | Used |
| -------- | ---- |
| LUT | Not available |
| LUTRAM | Not available |
| FF | Not available |
| BRAM | Not available |
| DSP | Not available |
| IO | Not available |

## Verification

`tb/spi_master_tb.vhd` is a behavioral, self-checking VHDL testbench. It instantiates two masters sharing a 100 MHz system clock: both use `c_CPOL = '0'`, with one instance at `c_CPHA = '0'` and the other at `c_CPHA = '1'`; `c_SPI_FREQ` is 10 MHz and `c_WIDTH` is 8. It drives MISO data at the phase-appropriate time, checks individual MOSI bits and observable control/status signals with VHDL assertions, and uses a clock-by-clock slave-select guard during continuous transfers. No simulator command, post-synthesis simulation, post-implementation simulation, or waveform capture is included.

The testbench reports individual `SUCCESS` messages and uses VHDL assertions to report failures. Its final `assert false` has severity `failure` and reports `ALL TESTS PASSED`; this intentional end-of-test marker normally produces a failure-severity simulator exit even when preceding checks pass.

The test procedures cover the following scenarios for both instantiated CPHA values:

- Idle and reset behavior: checks `o_ss`, `o_sck`, `o_mosi`, transmit readiness, receive state, buffer state, busy state, and overrun state after reset; then confirms no SPI activity occurs without `i_tx_valid`.
- One full-duplex word: verifies all MSB-first MOSI bits, phase-specific MISO sampling, the received word, acknowledgement of `o_rx_ready`, and return to idle.
- A continuous two-word transfer: queues one look-ahead word, verifies `o_ss` stays low across the byte boundary, checks the two serial exchanges and receive acknowledgements, and confirms a third request while `o_tx_ready` is low is rejected.
- Receive overrun: leaves the first received word unacknowledged, receives a second word, and checks replacement data, persistent `o_rx_ready`, assertion of `o_rx_overrun`, and clearing after acknowledgement.
- Reset during an active transfer: asserts reset after SCK begins and checks return to the configured idle outputs and cleared state.
- Reset after an overrun: creates an overrun and checks that reset clears `o_rx_overrun`, receive state, and SPI outputs.
- Simultaneous receive consume and replacement: acknowledges an old received word on the system-clock edge that completes the next word, expecting the new word without an overrun. This is an included check, but the current RTL excludes `r_bit_count = c_WIDTH - 1` from its acknowledgement condition, so the source behavior conflicts with the test expectation.

The testbench does not exercise `c_CPOL = '1'`, widths other than 8, or frequencies other than its 100 MHz / 10 MHz configuration.

## Waveforms

Waveforms and oscilloscope images will be added later.

## Notes / Limitations

- The implementation has one synchronous clock domain, `i_clk`; `o_sck` is generated by counting `i_clk` cycles rather than being an independent clock-domain interface.
- Only one slave-select output, `o_ss`, is provided, and its assertion/deassertion is automatic. There is no port for manual chip-select control or multiple slaves, I see how that can be very useful and it will be added.
- The transmit path has only one queued-word slot. `i_tx_valid` requests presented while `o_tx_ready` is low are not accepted.
- The receive path has only one storage word. An unacknowledged word is replaced by a later completion, with `o_rx_overrun` asserted; the overwritten word is not recoverable.
- An `i_rx_valid` acknowledgement on the exact system-clock edge that completes the next received word is not accepted by the current `r_bit_count /= c_WIDTH - 1` condition. The new word overwrites the old one and is marked as an overrun, contrary to the simultaneous consume-and-replace test's expectation.
- Valid frequency settings must satisfy the RTL assertions: `c_MAIN_CLK_FREQ` must divide exactly by `c_SPI_FREQ`, and that quotient must be even. No run-time error/status output reports invalid parameter values.
- The testbench covers CPHA values with `c_CPOL = '0'` only. Although `c_CPOL` is generic in the RTL, the other clock-polarity configurations are not covered by the included checks.
