---
name: lpc-locate-job
description: Finding which physical FNAL LPC login node a dask scheduler/driver process (e.g. a PocketCoffea dask-on-condor run) is actually running on. Use whenever a task touches "where is my job running", locating a dask scheduler, or a PocketCoffea/Coffea run started in tmux on cmslpc-el9.
---

# Locating a dask driver/scheduler's login node on the LPC

A PocketCoffea (or other dask-on-condor) run is launched by hand in a `tmux`
session on an LPC login node, behind the `cmslpc-el9.fnal.gov` alias, which
round-robins across several distinct physical nodes (e.g. `cmslpc361`,
`cmslpc366`, ...). The driver script starts a local dask scheduler and isn't
itself a condor job, so it never shows up in `condor_q` directly, and the
node you're currently SSH'd into is not necessarily the one running the tmux
session started earlier.

The trick: every condor **worker** job the driver spawns is told the
scheduler's address on its command line. Read that back out of the worker's
classad instead of hunting across login nodes or looping over jobs.

Run all of this over SSH on `fnal-claude`.

## Single driver

```bash
condor_q -af Arguments
```

Find the `tcp://<ip>:<port>` inside the `dask_worker` invocation -- that IP is
the scheduler's (and therefore the driver's tmux session's) login node:

```
python -m distributed.cli.dask_worker tcp://131.225.188.242:10058 --nthreads 1 ...
```

Resolve it to a hostname:

```bash
host 131.225.188.242
# -> cmslpc366.fnal.gov
```

## Multiple drivers running at once

Pull all unique scheduler addresses in one shot instead of checking job by
job -- each unique `tcp://` address is a separate driver/scheduler:

```bash
condor_q -af Arguments | grep -oE 'tcp://[0-9.]+:[0-9]+' | sort -u
```

To label which address belongs to which run, pull the log path alongside it
(PocketCoffea's dask log paths usually encode the run name):

```bash
condor_q -af Arguments Out | grep -oE 'tcp://[0-9.]+:[0-9]+|pocketcoffea_dask_logs/[^/]+'
```

## Using the result

Once resolved, `ssh` directly to that hostname (e.g. `ssh cmslpc366.fnal.gov`)
and `tmux attach` to reach the driver's session.

## Notes

- This only works while the driver has at least one condor worker currently
  running -- if all its workers are idle/unmatched or it hasn't submitted any
  yet, there's nothing in `Arguments` to read.
- `condor_userprio`/`condor_status -negotiator` can be flaky or slow when the
  pool is under heavy load -- this doesn't affect `condor_q -af Arguments`,
  which only hits the schedd.
