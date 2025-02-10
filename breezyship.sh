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

            if [ "$FRESH" == "true" ]; then
                echo "🗑️  Removing existing shared folder or symlink in $SHARED_FOLDER"
                rm -rf "$SHARED_FOLDER"

                echo "🔗 Copy all files: $COMMON_LIBRARY/shared -> $SHARED_FOLDER"
                cp -r "$COMMON_LIBRARY/shared" "$SHARED_FOLDER"

                echo "🔗 Creating symlink: $SHARED_FOLDER -> $COMMON_LIBRARY/shared"
                ln -s ../../bsCommonLibrary/shared "$SHARED_FOLDER"
            fi

            if [ -f "$SERVICE/package.json" ]; then
                echo "📦 Running npm install in $SERVICE..."
                (cd "$SERVICE" && npm install)
            else
                echo "⚠️  Skipping npm install: No package.json found in $SERVICE"
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
