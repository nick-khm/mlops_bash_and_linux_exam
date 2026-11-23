# -----------------------------------------------------------------------------
# Ce script train.sh exécute le programme Python src/train.py
# Ce programme entraîne un modèle de prédiction et enregistre le modèle final
# dans le répertoire model/. Le script enregistre également tous les détails
# de l'exécution dans le fichier logs/train.logs.
# -----------------------------------------------------------------------------


#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="$PROJECT_DIR/logs/train.logs"

mkdir -p "$PROJECT_DIR/logs"
cd "$PROJECT_DIR"

log() {
    echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $1" >> "$LOG_FILE"
}

log "INFO: Début de l'entraînement"

if ! command -v uv >/dev/null 2>&1; then
    log "ERROR: uv est introuvable"
    exit 1
fi

if [[ ! -f "src/train.py" ]]; then
    log "ERROR: src/train.py introuvable"
    exit 1
fi

if uv run python src/train.py >> "$LOG_FILE" 2>&1; then
    log "INFO: Entraînement terminé avec succès"
else
    status=$?
    log "ERROR: Échec de l'entraînement (code=$status)"
    exit "$status"
fi

