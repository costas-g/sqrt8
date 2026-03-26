# 8-bit Integer Square Root
VHDL design of a module that computes the integer square root.
### Input
8-bit unsigned integer + valid signal
### Output
4-bit unsigned integer + valid signal

## Algorithm used
Digit-by-Digit Calculation, non-restoring remainder.

## Design
4-stage pipeline. So output latency is 4 clock cycles. 

Each stage computes the next MSB of the output result. 

## Device Implementation and Simulation
Implemented on a Zynq-7000 (xc7z020clg484-1).

Worst Negative Slack (WNS) at a 10 ns clock: 6.355 ns

### Maximum frequency achieved 
250 Hz clock frequency with correct results in Post-Implementation Timing Simulation