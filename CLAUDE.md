# Displaced Leptons Analysis — Local Setup

This directory is the local home base for the displaced leptons CMS analysis. Work is done primarily on the FNAL LPC. Most edits should be done there. Often times the codebase on the LPC is up to date, while the local copy is behind. Assume the user means on the LPC unless specified.

---

## Remote Servers

### FNAL LPC (`fnal-claude`)
- **Host**: `cmslpc-el9.fnal.gov` (use alias `fnal-claude` for all SSH commands; `fnal` is the user's own session; `fnal-el8` for EL8 node)
- **Auth**: Kerberos — requires a valid `kinit lnestor@FNAL.GOV` ticket; ControlMaster auto-opens on first use and persists 10 min
- **Use**: Running CMSSW code (OSUNano), running PocketCoffea Condor jobs

---

## FNAL Mount

The CMSSW source tree on `fnal` is mounted locally via SSHFS. Use this when the user requests to make changes directly on the LPC. Manage it with:

```bash
scripts/fnal-mount.sh {mount|umount|status}
```

| Mount point | Remote path | Purpose |
|---|---|---|
| `mnt/fnal-displaced-leptons/` | `/uscms_data/d3/lnestor/displaced_leptons` | Running run 3 PocketCoffea-based analysis code |
| `mnt/fnal-DisplacedSUSY/` | `/uscms_data/d3/lnestor/DisplacedLeptons_CMSSW/Work/CMSSW_10_2_22/src` | Running run 2 CMSSW-based analysis code for comparison |
| `mnt/fnal-supplement-cmssw-15/` | `/uscms_data/d3/lnestor/CMSSW_15_0_10/src` | Supplement file generation, Signal MC generation steps 3 and 4 |
| `mnt/fnal-supplement-cmssw-14/` | `/uscms_data/d3/lnestor/CMSSW_14_0_21/src` | Signal MC generation steps 1 and 2 |

**Always use the mount for file reading and editing** — use normal Read/Edit tools on the relevant mount point above. If the mount is not up, ask the user to run `scripts/fnal-mount.sh mount`.

SSHFS is slow for broad searches. If you ever need to find a file, locate it through SSH first. When running the `find` command on a CMSSW environment, run it from the `src/` subdirectory.

For anything requiring the CMSSW environment (compilation, cmsRun, etc.), you need to run cmsenv in the specific CMSSW environment. For example, if CMSSW_15_0_10 is needed:

```bash
ssh fnal-claude "cd /uscms_data/d3/lnestor/nano/CMSSW_15_0_10 && cmsenv && <command>"
```

If a grid certificate is needed, you must set the environment variable directly. It is not set in non-interactive ssh sessions. The path to the certificate is `/uscms/home/lnestor/x509up_u16918`.

```bash
ssh fnal-claude "X509_USER_PROXY=/uscms/home/lnestor/x509up_u16918 <command>"
```

---

## Local Clones

While most code is run remotely, there are many local copies to make reading and editing easier. All reference code should be read from the local copies. Do not read references from remote servers unless asked to. Reading locally is easier.

**Active:**

| Directory | Purpose |
|---|---|
| `displaced_leptons/` | Main analysis config/scripts for this Run 3 analysis |
| `DisplacedLeptonsSupplement/` | CMSSW package for producing supplement files |

**Reference (`ref/`):**

| Directory | Purpose |
|---|---|
| `ref/PocketCoffea/` | PocketCoffea framework source |
| `ref/coffea/` | coffea library source — read from here when debugging coffea internals |
| `ref/cmssw/` | CMSSW source. This is a sparse checkout — if a needed directory is missing, ask the user to add it to the sparse checkout. |
| `ref/DisplacedSUSY/` | Run 2 analysis framework — reference only; read for physics logic and making sure the run 3 analysis matches, not code style |
| `ref/OSUT3Analysis/` | Run 2 OSU framework underlying DisplacedSUSY — reference only |
| `ref/DisappTrks/` | Disappearing tracks analysis sharing OSUNano — read when changes to OSUNano may affect it |
| `ref/HiggsAnalysis-CombinedLimit/` | CMS combine tool — reference only |
| `ref/exo-datacards/` | EXO group datacards — reference only |
| `ref/OSUNano/` | Used for custom NanoAOD generation. Not used anymore, only here for reference. |

If any of these local clones don't exist and are needed, tell the user to clone it.

---

## EOS Paths

On the LPC, my personal EOS space is at `/store/user/lnestor`. An important subdirectory is `/store/user/lnestor/supplements`, which holds supplement files for the displaced leptons analysis. When reading from EOS, always use the `eos <redirector> <cmd>` pattern, not using `ls` directly. For example, use `eos root://cmseos.fnal.gov/ ls` to view a directory.

---

## Style Guidelines

Always use ASCII characters only when writing code. Do not use em-dashes. Use hyphens instead. Do not use Greek letters, write them out instead (i.e. mu). Do not write excessive comments.

---

## Miscellaneous

There are other local directories that are less often needed:
 - `notes`: contains analysis note PDFs
 - `scripts`: used for one-off scripts. Any analysis specific scripts should go under the relevant project
 - `plots`: saving plots
 - `tmp`: anything temporary
