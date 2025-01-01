#!/bin/bash

# Define variables
CCS_WORKSPACE="$HOME/PROJECTS/EMBEDDED_PROJECTS/workspace"  # CCS workspace directory
REPO_PATH="$HOME/PROJECTS/EMBEDDED_PROJECTS/GSE_ControlSystem"  # Root of the firmware projects
CCS="/home/gena/ti/ccs1271/ccs/eclipse/ccstudio"  # Path to the CCS executable

# Projects to import
PROJECTS=(
    "$REPO_PATH/bootloader"
    "$REPO_PATH/led_application"
)

# Create CCS workspace if it doesn’t exist
if [ ! -d "$CCS_WORKSPACE" ]; then
    echo "Creating CCS workspace at $CCS_WORKSPACE..."
    mkdir -p "$CCS_WORKSPACE"
fi

# Import projects into CCS workspace
echo "Importing projects into CCS workspace..."
for PROJECT in "${PROJECTS[@]}"; do
    if [ -d "$PROJECT" ] && [ -f "$PROJECT/.project" ]; then
        echo "Importing project from $PROJECT..."
        "$CCS" -noSplash -data "$CCS_WORKSPACE" \
            -application com.ti.ccstudio.apps.projectImport \
            -ccs.location "$PROJECT"
    else
        echo "ERROR: No valid CCS project found at $PROJECT!"
    fi
done

echo "Projects imported successfully!"
