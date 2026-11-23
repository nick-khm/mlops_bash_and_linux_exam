#!/bin/bash

# ==============================================================================
# Script : collect.sh
# Description :
#   Ce script interroge une API afin de récupérer les ventes des modèles de cartes graphiques suivants :
#     - rtx3060
#     - rtx3070
#     - rtx3080
#     - rtx3090
#     - rx6700
#
#   Les données collectées sont ajoutées à une copie du fichier :
#     data/raw/sales_data.csv
#
#   Le fichier de sortie est sauvegardé au format :
#     data/raw/sales_YYYYMMDD_HHMM.csv
#   avec les colonnes suivantes :
#     timestamp, model, sales
#
#   L’activité de collecte (requêtes, modèles interrogés, résultats, erreurs)
#   est enregistrée dans un fichier de log :
#     logs/collect.logs
#
#   Le log est lisible et doit inclure :
#     - La date et l’heure de chaque requête
#     - Les modèles interrogés
#     - Les ventes récupérées
#     - Les éventuelles erreurs
# ==============================================================================



set -euo pipefail

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

API_URL="http://localhost:5000"
SOURCE_FILE="$PROJECT_DIR/data/raw/sales_data.csv"
LOG_FILE="$PROJECT_DIR/logs/collect.logs"

FILE_DATE=$(date -u +"%Y%m%d_%H%M")
OUTPUT_FILE="$PROJECT_DIR/data/raw/sales_${FILE_DATE}.csv"

MODELS=(rtx3060 rtx3070 rtx3080 rtx3090 rx6700)

# Fonctions
log() {
    echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $1" >> "$LOG_FILE"
}

# Initialisation
mkdir -p "$PROJECT_DIR/data/raw" "$PROJECT_DIR/logs"

if [[ ! -f "$SOURCE_FILE" ]]; then
    log "ERROR: Fichier source introuvable : $SOURCE_FILE"
    exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
    log "ERROR: curl n'est pas installé"
    exit 1
fi

# Copie des données historiques
if ! cp "$SOURCE_FILE" "$OUTPUT_FILE"; then
    log "ERROR: Impossible de copier $SOURCE_FILE"
    exit 1
fi

log "INFO: Début de la collecte : $OUTPUT_FILE"

# Collecte des ventes
errors=0

for model in "${MODELS[@]}"; do
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    url="$API_URL/$model"

    log "INFO: Requête GET $url"

    if ! sales=$(curl -fsS --max-time 10 "$url" 2>>"$LOG_FILE"); then
        log "ERROR: Échec de la requête pour $model"
        ((errors += 1))
        continue
    fi

    # Validation : entier positif ou nul
    if [[ ! "$sales" =~ ^[0-9]+$ ]]; then
        log "ERROR: Valeur invalide pour $model : $sales"
        ((errors += 1))
        continue
    fi


    # Ajouter un saut de ligne si le fichier n'en possède pas à la fin
    if [[ -n $(tail -c 1 "$OUTPUT_FILE") ]]; then
        printf '\n' >> "$OUTPUT_FILE"
    fi

    # Ajout au fichier CSV
    if ! printf '%s,%s,%s\n' "$timestamp" "$model" "$sales" >> "$OUTPUT_FILE"; then
        log "ERROR: Impossible d'écrire les ventes de $model"
        exit 1
    fi

    log "INFO: Modèle=$model, ventes=$sales"
done

if (( errors > 0 )); then
    log "ERROR: Collecte terminée avec $errors erreur(s)"
    exit 1
fi

log "INFO: Collecte terminée avec succès"
exit 0

