# =============================================================================
# Ce script preprocessed.sh exécute le programme src/preprocessed.py
# et enregistre les détails de son exécution dans le fichier de log
# logs/preprocessed.logs.
# =============================================================================


#!/usr/bin/env bash

set -euo pipefail

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="$PROJECT_DIR/logs/preprocessed.logs"

# Initialisation
mkdir -p "$PROJECT_DIR/logs"
cd "$PROJECT_DIR"

log() {
    echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $1" >> "$LOG_FILE"
}

log "INFO: Début du prétraitement"

# Vérifier que uv est disponible
if ! command -v uv >/dev/null 2>&1; then
    log "ERROR: uv est introuvable"
    exit 1
fi

# Vérifier que le script Python existe
if [[ ! -f "src/preprocessed.py" ]]; then
    log "ERROR: src/preprocessed.py introuvable"
    exit 1
fi

# Exécuter le prétraitement
if uv run python src/preprocessed.py >> "$LOG_FILE" 2>&1; then
    log "INFO: Prétraitement terminé avec succès"
else
    status=$?
    log "ERROR: Échec du prétraitement (code=$status)"
    exit "$status"
fi

exit 0

