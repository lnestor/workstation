#!/usr/bin/env bash
set -e

check_ssh_config() {
    local ssh_config="$HOME/.ssh/config"
    if grep -qE '^Host( +[^ ]+)* +fnal( +|$)' "$ssh_config" 2>/dev/null \
        && grep -qE '^Host( +[^ ]+)* +fnal-claude( +|$)' "$ssh_config" 2>/dev/null; then
        return
    fi

    cat <<'EOF'

No 'fnal' / 'fnal-claude' SSH aliases found in ~/.ssh/config.
Run the following to add them (adjust the User if needed):

cat <<'SSHEOF' >> ~/.ssh/config

Host fnal
    Hostname cmslpc-el9.fnal.gov
    User lnestor

Host fnal-claude
    Hostname cmslpc-el9.fnal.gov
    User lnestor
    ControlMaster auto
    ControlPath ~/.ssh/cm-claude-%r@%h:%p
    ControlPersist 10m

Host cmslpc*.fnal.gov fnal fnal-claude
    GSSAPIAuthentication yes
    GSSAPIDelegateCredentials yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
SSHEOF

EOF
}

clone_if_missing() {
    local url="$1"
    local dir="$2"
    if [ -d "$dir" ]; then
        echo "Already exists, skipping: $dir"
    else
        git clone "$url" "$dir"
    fi
}

clone_if_missing git@github.com:lnestor/displaced_leptons.git displaced_leptons
clone_if_missing git@github.com:OSU-CMS/OSUNano.git OSUNano

mkdir -p ref

clone_if_missing git@github.com:OSU-CMS/OSUT3Analysis.git ref/OSUT3Analysis
clone_if_missing git@github.com:DisplacedSUSY/DisplacedSUSY.git ref/DisplacedSUSY
clone_if_missing git@github.com:PocketCoffea/PocketCoffea.git ref/PocketCoffea
clone_if_missing git@github.com:scikit-hep/coffea.git ref/coffea

if [ -d "ref/cmssw" ]; then
    echo "Already exists, skipping: ref/cmssw"
else
    git clone git@github.com:cms-sw/cmssw.git --no-checkout ref/cmssw --depth 1
    cd ref/cmssw
    git sparse-checkout init --cone
    git sparse-checkout set DataFormats PhysicsTools
    git checkout
    cd ../..
fi

check_ssh_config
