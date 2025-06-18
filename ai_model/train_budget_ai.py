import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error
import pickle
from pathlib import Path

# Lokasi dokumen aplikasi
docs_path = Path.home() / "Documents" / "fridgify"
csv_path = docs_path / "budget_data.csv"
pkl_path = docs_path / "budget_predictor.pkl"

# 1. Load dataset
df = pd.read_csv(csv_path)

# 2. Pilih fitur dan target
X = df[["total_spent", "num_items", "avg_item_price", "last_month_budget"]]
y = df["next_month_budget"]

# 3. Split data jadi train dan test
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# 4. Buat model dan latih
model = LinearRegression()
model.fit(X_train, y_train)

# 5. Evaluasi model
r2_score = model.score(X_test, y_test)
y_pred = model.predict(X_test)
mae = mean_absolute_error(y_test, y_pred)

print(f"R^2 Score: {r2_score:.2f}")
print(f"Mean Absolute Error: Rp {mae:,.0f}")

# 6. Simpan model ke file .pkl
with open(pkl_path, "wb") as f:
    pickle.dump(model, f)

print(f"Model berhasil disimpan ke '{pkl_path.name}'")

# 7. Prediksi bulan berikutnya
last_row = df.iloc[-1]
features = pd.DataFrame([{
    "total_spent": last_row["total_spent"],
    "num_items": last_row["num_items"],
    "avg_item_price": last_row["avg_item_price"],
    "last_month_budget": last_row["last_month_budget"]
}])
predicted_budget = model.predict(features)[0]
rounded_prediction = int(round(predicted_budget / 1000.0)) * 1000

print(f"📊 Prediksi next_month_budget bulan depan: Rp {rounded_prediction:,}")
