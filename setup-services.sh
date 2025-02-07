#!/bin/sh

echo "🔄 Initializing services..."

COMMON_LIBRARY="./sources/bsCommonLibrary"
SERVICES_DIR="./sources"

if [ ! -d "$COMMON_LIBRARY" ]; then
    echo "❌ Error: Common library '$COMMON_LIBRARY' does not exist."
    exit 1
fi

for SERVICE in "$SERVICES_DIR"/*; do
    if [ -d "$SERVICE/src" ]; then
        SHARED_FOLDER="$SERVICE/src/shared"

        if [ -e "$SHARED_FOLDER" ] || [ -L "$SHARED_FOLDER" ]; then
            echo "🗑️  Removing existing shared folder or symlink in $SHARED_FOLDER"
            rm -rf "$SHARED_FOLDER"
        fi

        echo "🔗 Copy all files: $COMMON_LIBRARY/shared -> $SHARED_FOLDER"
        cp -r "$COMMON_LIBRARY/shared" "$SHARED_FOLDER"

        if [ -f "$SERVICE/package.json" ]; then
            echo "📦 Running npm install in $SERVICE..."
            (cd "$SERVICE" && npm install)
        else
            echo "⚠️  Skipping npm install: No package.json found in $SERVICE"
        fi

        echo "🔗 Creating symlink: $SHARED_FOLDER -> $COMMON_LIBRARY/shared"
        ln -s ../../bsCommonLibrary/shared "$SHARED_FOLDER"
    fi
done

echo "✅ Service setup complete!"
