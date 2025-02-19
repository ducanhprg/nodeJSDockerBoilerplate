#!/bin/bash

START_DIR=$(pwd)

REPO_MAPPINGS=(
    ". git@gitlab.com:nodejs-brz/bsboilerplate.git"
    "./sources/bsCommonLibrary git@gitlab.com:nodejs-brz/bscommonlibrary.git"
    "./sources/bsValidator git@gitlab.com:nodejs-brz/bsvalidator.git"
    "./sources/plRequestHandler git@gitlab.com:nodejs-brz/plrequesthandler.git"
    "./sources/plVendorGDE git@gitlab.com:nodejs-brz/plvendorgde.git"
    "./sources/plVendorShipSaving git@gitlab.com:nodejs-brz/plvendorshipsaving.git"
    "./sources/rs_monitor git@gitlab.com:nodejs-brz/rsmonitor.git"
    "./sources/rs_producer git@gitlab.com:nodejs-brz/rsproducer.git"
    "./sources/rs_consumer git@gitlab.com:nodejs-brz/rsconsumer.git"
)

for MAPPING in "${REPO_MAPPINGS[@]}"; do
    LOCAL_PATH=$(echo "$MAPPING" | cut -d ' ' -f1)
    GITLAB_URL=$(echo "$MAPPING" | cut -d ' ' -f2)

    if [[ "$LOCAL_PATH" == "." ]]; then
        LOCAL_PATH="$START_DIR"
    fi

    if [[ -d "$LOCAL_PATH" ]]; then
        if [[ -d "$LOCAL_PATH/.git" ]]; then
            echo "🔄 Switching repository at: $LOCAL_PATH"
            cd "$LOCAL_PATH" || exit

            git remote set-url origin "$GITLAB_URL"
            echo "✅ Updated remote for: $(basename "$LOCAL_PATH")"

            git remote -v
        else
            echo "⚠️  Skipping: $LOCAL_PATH (Not a Git repository)"
        fi
    else
        echo "❌ Directory not found: $LOCAL_PATH"
    fi

    cd "$START_DIR" || exit
done

echo "🎉 All repositories have been checked and updated where applicable!"
