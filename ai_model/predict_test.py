import joblib
import pandas as pd
import json
import os
from pathlib import Path

# Akses folder 'Documents/fridgif
from pathlib import Path

# Path file JSON di folder dokumen lokal (sesuai path_provider)
docs_path = Path.home() / "Documents" / "fridgify"
data_path = docs_path / "budget_summary.json"  # atau budget_prediction.json kalau itu yang dipakai
model_path = "budget_predictor.pkl"

# Cek apakah file model dan data ada
if not os.path.exists(model_path):
    print("❌ Model budget_predictor.pkl tidak ditemukan.")
    exit()

if not os.path.exists(data_path):
    print("❌ File budget_summary.json tidak ditemukan.")
    exit()

# Load model
model = joblib.load(model_path)

# Load data terakhir dari budget_summary.json
with open(data_path, "r") as f:
    summaries = json.load(f)

if not summaries:
    print("❌ Data budget_summary.json kosong.")
    exit()

latest = summaries[-1]

# Validasi data
required_fields = ["month", "totalSpent", "numItems", "avgItemPrice", "initialBudget"]
if not all(field in latest for field in required_fields):
    print("❌ Data terakhir tidak memiliki field lengkap.")
    exit()

# Buat DataFrame satu baris untuk prediksi
input_df = pd.DataFrame([{
    "month": int(latest["month"]),
    "total_spent": float(latest["totalSpent"]),
    "num_items": int(latest["numItems"]),
    "avg_item_price": float(latest["avgItemPrice"]),
    "last_month_budget": float(latest["initialBudget"])
}])

# Prediksi
prediction = model.predict(input_df)[0]
print(f"📊 Prediksi budget bulan depan: Rp {prediction:,.0f}")

# Simpan hasil ke file JSON agar bisa dibaca oleh Flutter
with open("assets/data/budget_prediction.json", "w") as out_file:
    json.dump({"predicted_budget": round(prediction)}, out_file)
