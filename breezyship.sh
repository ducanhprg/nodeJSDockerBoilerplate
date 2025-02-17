#!/bin/bash

set -e

COMMAND=$1
SERVICE_NAME=$2 
FLAGS="${@:2}"

COMMON_LIBRARY="./sources/bsCommonLibrary"
SERVICES_DIR="./sources"

FRESH=false
for arg in "$@"; do
    if [ "$arg" == "--fresh" ]; then
        FRESH=true
        FLAGS="${FLAGS/--fresh/}"
    fi
done

initialize_services() {
    echo "🔄 Initializing services..."

    if [ ! -d "$COMMON_LIBRARY" ]; then
        echo "❌ Error: Common library '$COMMON_LIBRARY' does not exist."
        exit 1
    fi

    for SERVICE in "$SERVICES_DIR"/*; do
        if [ -d "$SERVICE/src" ]; then
            SHARED_FOLDER="$SERVICE/src/shared"
            SERVICE_PACKAGE_JSON="$SERVICE/package.json"
            SERVICE_TSCONFIG_JSON="$SERVICE/tsconfig.json"
            SERVICE_NODE_MODULES="$SERVICE/node_modules"
            COMMON_PACKAGE_JSON="$COMMON_LIBRARY/package.json"
            COMMON_TSCONFIG_JSON="$COMMON_LIBRARY/tsconfig.json"

            if [ "$FRESH" == "true" ]; then
                echo "🗑️  Removing existing node_modules"
                rm -rf "$SERVICE_NODE_MODULES"

                if [ -e "$SHARED_FOLDER" ] || [ -L "$SHARED_FOLDER" ]; then
                    echo "🗑️  Removing existing shared folder or symlink in $SHARED_FOLDER"
                    rm -rf "$SHARED_FOLDER"
                fi
                echo "🔗 Creating symlink: $SHARED_FOLDER -> $COMMON_LIBRARY/shared"
                ln -s "$(realpath --relative-to="$SERVICE/src" "$COMMON_LIBRARY/shared")" "$SHARED_FOLDER"

                if [ -f "$SERVICE_PACKAGE_JSON" ] || [ -L "$SERVICE_PACKAGE_JSON" ]; then
                    echo "🗑️  Removing existing package.json in $SERVICE"
                    rm -rf "$SERVICE_PACKAGE_JSON"
                fi
                if [ -f "$COMMON_PACKAGE_JSON" ]; then
                    echo "🔗 Copying files: $SERVICE_PACKAGE_JSON -> $COMMON_PACKAGE_JSON"
                    cp -r "$COMMON_PACKAGE_JSON" "$SERVICE_PACKAGE_JSON"
                fi

                if [ -f "$SERVICE_TSCONFIG_JSON" ] || [ -L "$SERVICE_TSCONFIG_JSON" ]; then
                    echo "🗑️  Removing existing tsconfig.json in $SERVICE"
                    rm -rf "$SERVICE_TSCONFIG_JSON"
                fi
                if [ -f "$COMMON_TSCONFIG_JSON" ]; then
                    echo "🔗 Copying files: $SERVICE_TSCONFIG_JSON -> $COMMON_TSCONFIG_JSON"
                    cp -r "$COMMON_TSCONFIG_JSON" "$SERVICE_TSCONFIG_JSON"
                fi

                if [ -f "$COMMON_PACKAGE_JSON" ]; then
                    echo "📦 Running npm install in $SERVICE..."
                    (cd "$SERVICE" && npm install)
                else
                    echo "⚠️  Skipping npm install: No package.json found in $COMMON_LIBRARY"
                fi
            fi
        fi
    done

    echo "✅ Service setup complete!"
}

start_services() {
    echo "🚀 Starting Docker services..."
    initialize_services
    docker-compose up $FLAGS
}

stop_services() {
    echo "🛑 Stopping Docker services..."
    docker-compose down $FLAGS
}

build_services() {
    echo "🔨 Building Docker images..."
    initialize_services
    docker-compose build $FLAGS
}

restart_services() {
    echo "🔄 Restarting all services..."
    initialize_services
    docker-compose restart
}

restart_specific_service() {
    if [ -z "$SERVICE_NAME" ]; then
        echo "❌ Error: Please provide a service name to restart."
        echo "Usage: ./services.sh restart <container_name> [--fresh]"
        exit 1
    fi

    echo "🔄 Restarting service: $SERVICE_NAME..."
    initialize_services
    docker-compose restart "$SERVICE_NAME"
}

show_help() {
    echo "Usage: services.sh [command] [options]"
    echo "Commands:"
    echo "  up [-d] [--fresh]      Start services (use -d for detached mode, --fresh to recreate symlinks)"
    echo "  down [-v]              Stop services (use -v to remove volumes)"
    echo "  build [--no-cache]     Build services (use --no-cache to force rebuild)"
    echo "  restart [--fresh]      Restart all services (use --fresh to recreate symlinks)"
    echo "  restart <container>    Restart a specific container (add --fresh to refresh symlinks)"
    echo "  help                   Show this help message"
}

case "$COMMAND" in
    up) start_services ;;
    down) stop_services ;;
    build) build_services ;;
    restart) 
        if [ -n "$SERVICE_NAME" ]; then
            restart_specific_service
        else
            restart_services
        fi
    ;;
    help) show_help ;;
    *) 
        echo "❌ Unknown command: $COMMAND"
        show_help
        exit 1
    ;;
esac
