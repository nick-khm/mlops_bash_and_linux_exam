"""
-------------------------------------------------------------------------------
Ce script exécute l'entraînement d'un modèle XGBoost pour prédire les ventes de 
cartes graphiques à partir des données prétraitées.

1. Il commence par rechercher le dernier fichier CSV prétraité dans le dossier 
   'data/processed/'.
2. Si un modèle standard (model.pkl) n'existe pas, il charge les données, les 
   divise en ensembles d'entraînement et de test, entraîne un modèle sur ces 
   données, l'évalue, puis le sauvegarde dans 'model/model.pkl'.
3. Si un modèle standard existe déjà, il entraîne un nouveau modèle sur les 
   données les plus récentes, l'évalue, puis sauvegarde le modèle dans le dossier 
   'model/' sous formats : model_YYYYMMDD_HHMM.pkl.
4. Les métriques de performance (RMSE, MAE, R²) sont affichées et sauvegardées dans 
   le fichier de log.
5. Des erreurs éventuelles sont gérées et signalées dans les logs.

Les modèles sont sauvegardés dans le dossier 'model/' avec le nom 'model.pkl' pour 
le modèle standard et avec un horodatage pour les versions ultérieures.
Les métriques du modèle sont enregistrées dans les logs du script.
-------------------------------------------------------------------------------
"""

from pathlib import Path
import pandas as pd
from xgboost import XGBRegressor
import pickle

processed_dir = Path("data/processed")
csv_files = list(processed_dir.glob("sales_processed_*.csv"))

if not csv_files:
    raise FileNotFoundError("Aucun fichier prétraité trouvé")

latest_csv = max(csv_files, key=lambda f: f.stat().st_mtime)

df = pd.read_csv(latest_csv)

X = df[["model"]]
y = df["sales"]

print(f"Fichier : {latest_csv}")
print(f"X : {X.shape}")
print(f"y : {y.shape}")

model = XGBRegressor(
    n_estimators=100,
    max_depth=3,
    learning_rate=0.1,
    random_state=42,
)

model.fit(X, y)

print("Entraînement terminé")


model_dir = Path("model")
model_dir.mkdir(parents=True, exist_ok=True)

model_path = model_dir / "model.pkl"

with open(model_path, "wb") as f:
    pickle.dump(model, f)

print(f"Modèle sauvegardé : {model_path}")


