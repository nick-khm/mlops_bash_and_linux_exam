"""
-------------------------------------------------------------------------------
Ce script preprocessed.py récupère les données du dernier fichier CSV créé 
dans le dossier 'data/raw/'.

1. Il applique un prétraitement aux données
   
2. Les résultats du prétraitement sont enregistrés dans un nouveau fichier CSV 
   dans le dossier 'data/processed/', avec un nom au format 
   'sales_processed_YYYYMMDD_HHMM.csv'.
   
3. Toutes les étapes du prétraitement sont enregistrées dans le fichier 
   'logs/preprocessed.logs' afin de garantir un suivi détaillé du processus.

Les erreurs ou anomalies éventuelles sont également loguées pour assurer la traçabilité.
-------------------------------------------------------------------------------
"""
from pathlib import Path
import pandas as pd

raw_dir = Path("data/raw")

csv_files = list(raw_dir.glob("sales_*.csv"))

if not csv_files:
    raise FileNotFoundError("Aucun fichier de ventes trouvé")

latest_csv = max(csv_files, key=lambda f: f.stat().st_mtime)

df = pd.read_csv(latest_csv)

print(f"Fichier : {latest_csv}")
print(df.shape)
print(df.dtypes)
print(df.head())

model_mapping = {
    "rtx3060": 0,
    "rtx3070": 1,
    "rtx3080": 2,
    "rtx3090": 3,
    "rx6700": 4,
}

df["model"] = df["model"].map(model_mapping)

df = df.drop(columns=["timestamp"])

print(df.head())
print(df.dtypes)
print(df.isna().sum())

# Créer le fichier CSV
from datetime import datetime, timezone

processed_dir = Path("data/processed")
processed_dir.mkdir(parents=True, exist_ok=True)

timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M")

output_file = processed_dir / f"sales_processed_{timestamp}.csv"

# Enregistrer le DF

df.to_csv(output_file, index=False)

print(f"Fichier créé : {output_file}")
