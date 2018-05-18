# Event Counter 

## What and why

This project  is a implementation  of a simple,  yet flexible event  counter, or
simply put, **counter**.

It can be  used in countless implementations. However, I  initially design it to
be used in FSMs. Mostly of my HDL  related work is on network processing, so for
the  sake of  designs  modularization and  reuse, I  needed  to standardize  how
different  events (packets,  header  fields, AXI-Stream  words,  or even  system
*clock*, etc) are tracked and use them to trigger FSMs transitions.

## Module parameters

A number of module parameters are available:

* `TARGET_WIDTH`: Bit  width necessary  to represent  the maximum  counter value
  that can be stored. Basically it must be ceil rounded log2 of that number.
* `EVENT_IS_CLOCK`:  Make this  to  `1` if  event  in clock,  so  module can  be
  synthesized in a optimum way for that.
* `HAS_ENABLE`:  Creates the  `ENABLE` port  logic to  counter only  when it  is
  asserted. Otherwise, the module will be *always* enabled.
* `RESET_IF_REACHED`:  Should the  counter  be reset  after  target number  be
  reached ?
