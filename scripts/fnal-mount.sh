#!/bin/bash

BASE=/home/lnestor/projects/displaced_leptons/mnt
NOBACKUP=/uscms_data/d3/lnestor

MOUNTS=(
    "fnal-cmssw15-src:$NOBACKUP/DisplacedLeptons_CMSSW/CMSSW_15_0_10/src"
    "fnal-cmssw10-src:$NOBACKUP/DisplacedLeptons_CMSSW/testint/CMSSW_10_2_22/src"
    "fnal-nobackup-displaced-leptons:/uscms/homes/l/lnestor/nobackup/displaced_leptons"
    "fnal-DisplacedSUSY:$NOBACKUP/DisplacedLeptons_CMSSW/Work/CMSSW_10_2_22/src"
)

cmd_mount() {
    # Ensure master connection is up
    if ! ssh -O check fnal &>/dev/null; then
        echo "Starting SSH master connection to fnal..."
        ssh -N -f fnal
    fi

    for entry in "${MOUNTS[@]}"; do
        local name="${entry%%:*}"
        local remote="${entry##*:}"
        local mountpoint="$BASE/$name"

        if mountpoint -q "$mountpoint"; then
            echo "Already mounted: $name"
        else
            echo "Mounting $name..."
            sshfs fnal:"$remote" "$mountpoint" \
                -o reconnect \
                -o ServerAliveInterval=15 \
                -o ServerAliveCountMax=3 \
                -o follow_symlinks \
                && echo "  OK" || echo "  FAILED"
        fi
    done
}

cmd_umount() {
    for entry in "${MOUNTS[@]}"; do
        local name="${entry%%:*}"
        local mountpoint="$BASE/$name"

        if mountpoint -q "$mountpoint"; then
            echo "Unmounting $name..."
            fusermount -u "$mountpoint" && echo "  OK" || echo "  FAILED"
        else
            echo "Not mounted: $name"
        fi
    done
}

cmd_status() {
    for entry in "${MOUNTS[@]}"; do
        local name="${entry%%:*}"
        local mountpoint="$BASE/$name"

        if mountpoint -q "$mountpoint"; then
            echo "  [mounted]   $name"
        else
            echo "  [unmounted] $name"
        fi
    done

    echo ""
    ssh -O check fnal 2>&1 && echo "SSH master: active" || echo "SSH master: inactive"
}

case "${1:-}" in
    mount)   cmd_mount ;;
    umount)  cmd_umount ;;
    status)  cmd_status ;;
    *)
        echo "Usage: $0 {mount|umount|status}"
        exit 1
        ;;
esac
