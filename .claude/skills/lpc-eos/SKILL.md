---
name: lpc-eos
description: Working with EOS storage specifically on the FNAL LPC (not any other site or grid environment) for this displaced leptons analysis -- listing, finding, and copying files under /store/user/lnestor (including the supplements directory), and reading EOS files from ROOT/uproot/python code. Use whenever a task touches EOS, /store/..., cmseos, xrdcp, xrootd, or the LPC personal storage space.
---

# EOS on the FNAL LPC

## Hard rule: never use direct filesystem paths

Never access EOS through `/eos/uscms/...` directly -- not with `ls`, `glob`, `open()`,
`ROOT.TFile`, `uproot`, or anything else -- even though it happens to be mounted and
"works" on LPC login nodes. This is an explicit FNAL LPC admin policy, not a style
preference. Always go through the xrootd redirector `root://cmseos.fnal.gov/`.

| Don't | Do |
|---|---|
| `ls /eos/uscms/store/user/lnestor/...` | `eos root://cmseos.fnal.gov/ ls /store/user/lnestor/...` |
| `open("/eos/uscms/store/...")` | `uproot.open("root://cmseos.fnal.gov//store/...")` |
| `glob.glob("/eos/uscms/store/.../*.root")` | `eos root://cmseos.fnal.gov/ find /store/.../` |

Note the path itself always starts with `/store/...` (no `/eos/uscms` prefix) -- the
redirector already points at the right namespace.

## Where things live

- Personal EOS space: `/store/user/lnestor`
- Supplement files for this analysis: `/store/user/lnestor/supplements`

## Running EOS commands

`eos` and `xrdcp` are LPC-side tools -- run them over SSH on `fnal-claude`, not locally.

```bash
ssh fnal-claude "eos root://cmseos.fnal.gov/ ls /store/user/lnestor/supplements"
```

### Listing / finding

```bash
# list a directory
eos root://cmseos.fnal.gov/ ls -l /store/user/lnestor/supplements

# recursive find (use instead of a broad local search over a mount)
eos root://cmseos.fnal.gov/ find /store/user/lnestor/supplements

# file/directory metadata
eos root://cmseos.fnal.gov/ stat /store/user/lnestor/supplements/<name>
```

### Copying files

```bash
# EOS -> local
xrdcp root://cmseos.fnal.gov//store/user/lnestor/supplements/<file> ./<file>

# local -> EOS
xrdcp ./<file> root://cmseos.fnal.gov//store/user/lnestor/supplements/<file>
```

If a copy or write fails with a permission/auth error, the operation may need the grid
certificate proxy set explicitly (see CLAUDE.md's "FNAL Mount" section):

```bash
ssh fnal-claude "X509_USER_PROXY=/uscms/home/lnestor/x509up_u16918 xrdcp ..."
```

### Deleting and moving/renaming

```bash
# delete a file or directory (recursively)
eos root://cmseos.fnal.gov/ rm -r /store/user/lnestor/<path>

# move/rename a file or directory within EOS
eos root://cmseos.fnal.gov/ mv /store/user/lnestor/<src> /store/user/lnestor/<dst>
```

These are destructive/hard-to-reverse -- confirm the exact path list with the user before
running `rm -r`, and check the destination doesn't already hold something unrelated before
`mv`.

### Reading EOS files from code (ROOT / uproot / coffea / PocketCoffea)

Pass the full redirector URL as the file path -- these libraries open xrootd URLs
natively, no local copy needed:

```python
import uproot
f = uproot.open("root://cmseos.fnal.gov//store/user/lnestor/supplements/<file>.root")
```

```cpp
TFile *f = TFile::Open("root://cmseos.fnal.gov//store/user/lnestor/supplements/<file>.root");
```

This applies to CRAB/PocketCoffea job outputs, keytree files, and any other `/store/...`
path -- always construct the path with the `root://cmseos.fnal.gov/` prefix, in both
production code and one-off checks.
