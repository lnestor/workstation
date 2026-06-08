# Displaced Leptons Analysis — Local Setup

This directory is the local home base for the displaced leptons CMS analysis. Work is done primarily on the FNAL LPC. Less often, work can be done on the OSU tier 3.

---

## Remote Servers

### FNAL LPC (`fnal`)
- **Host**: `cmslpc-el9.fnal.gov` (alias `fnal`; `fnal-el8` for EL8 node)
- **Auth**: Kerberos — run `kinit lnestor@FNAL.GOV` before connecting; ControlMaster persists 10 min after first connection
- **Use**: Running CMSSW code (DisplacedLeptonsSupplement), running PocketCoffea Condor jobs

### OSU Tier3 (`tier3`)
- **Host**: `aurora.asc.ohio-state.edu` (alias `tier3`)
- **Use**: running Condor jobs with PocketCoffea
- **Do not SSH to the T3** — ask the user to run any Tier3 commands manually because you have to go through a jump host with 2FA

---

## FNAL Mount

The CMSSW source tree on `fnal` is mounted locally via SSHFS. Use this when the user requests to make changes directly on the LPC. Manage it with:

```bash
scripts/fnal-mount.sh {mount|umount|status}
```

| Mount point | Remote path |
|---|---|
| `mnt/fnal-cmssw15-src/` | `/uscms_data/d3/lnestor/DisplacedLeptons_CMSSW/CMSSW_15_0_10/src` |
| `mnt/fnal-cmssw10-src/` | `/uscms_data/d3/lnestor/DisplacedLeptons_CMSSW/testint/CMSSW_10_2_22/src` |
| `mnt/fnal-nobackup-displaced-leptons/` | `/uscms/homes/l/lnestor/nobackup/displaced_leptons` |
| `mnt/fnal-DisplacedSUSY/` | `/uscms_data/d3/lnestor/DisplacedLeptons_CMSSW/Work/CMSSW_10_2_22/src` |

**Always use the mount for file reading and editing** — use normal Read/Edit tools on `mnt/fnal-cmssw15-src/`. If the mount is not up, ask the user to run `scripts/fnal-mount.sh mount`.

SSHFS is slow for broad searches. If you ever need to find a file, locate it through SSH first.

For anything requiring the CMSSW environment (compilation, cmsRun, etc.), you need to run cmsenv in the specific CMSSW environment. For example, if CMSSW_15_0_10 is needed:

```bash
ssh fnal "cd /uscms_data/d3/lnestor/DisplacedLeptons_CMSSW/CMSSW_15_0_10 && cmsenv && <command>"
```

---

## Local Clones

While most code is run remotely, there are many local copies to make reading and editing easier. All reference code should be read from the local copies. Do not read references from remote servers unless asked to. Reading locally is easier.

**Active:**

| Directory | Purpose |
|---|---|
| `displaced_leptons/` | Main analysis config/scripts for this Run 3 analysis |
| `DisplacedLeptonsSupplement/` | Local copy of the CMSSW NanoAOD supplement |

**Reference (`ref/`):**

| Directory | Purpose |
|---|---|
| `ref/PocketCoffea/` | PocketCoffea framework source |
| `ref/coffea/` | coffea library source — read from here when debugging coffea internals |
| `ref/cmssw/` | CMSSW source. This is a sparse checkout — if a needed directory is missing, ask the user to add it to the sparse checkout. |
| `ref/DisplacedSUSY/` | Run 2 analysis framework — reference only; read for physics logic and making sure the run 3 analysis matches, not code style |
| `ref/OSUT3Analysis/` | Run 2 OSU framework underlying DisplacedSUSY — reference only |
| `ref/HiggsAnalysis-CombinedLimit/` | CMS combine tool — reference only |
| `ref/exo-datacards/` | EXO group datacards — reference only |

---

## Style Guidelines

Always use ASCII characters only when writing code. Do not use em-dashes. Use hyphens instead. Do not use Greek letters, write them out instead (i.e. mu).
