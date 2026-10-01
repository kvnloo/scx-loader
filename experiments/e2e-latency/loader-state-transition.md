# sched-ext loader/control-plane experiment

Core scheduler context: https://github.com/sched-ext/scx/issues/3750

## Goal

Separate scheduler behavior from control-plane behavior when `scx_lavd` is used for gaming on CachyOS.

The upstream report includes a case where stopping `scx_lavd` through a GUI did not remain effective and discussion points to power-profile / game-performance integration. This experiment covers only scheduler activation/state ownership. Core scheduler stalls belong in `sched-ext/scx`.

## State-transition matrix

Capture scheduler state before and after:

- boot
- manual `scxctl switch`
- manual stop
- GUI stop/switch
- game launch
- power-profile change
- `power-profiles-daemon` restart
- `scx_loader.service` stop/start

For each transition record:

- requested scheduler
- active scheduler
- initiator if observable
- timestamp
- relevant journal excerpt

## Gaming A/B

When the machine is free, compare on the same workload:

- default kernel scheduler
- current `scx_lavd`
- comparison `scx_lavd` version if useful
- one additional sched_ext scheduler

Capture:

- runnable-task-stall kernel messages
- scheduler ejection/fallback
- wake -> run latency where practical
- frame-time `p50/p95/p99/p99.9`
- visible/audio freezes

## Questions

- Can a scheduler explicitly stopped by the user be reactivated?
- Which component requests that transition?
- Does avoiding the transition eliminate the symptom?
- If scheduler state remains stable, can the stall reproduce independently of the loader?

## Promotion routing

- loader/control-plane finding -> `sched-ext/scx-loader` / CachyOS integration;
- scheduler correctness finding -> `sched-ext/scx#3750`.

Do not combine the conclusions unless a trace demonstrates a shared cause.
