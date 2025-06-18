import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
import pickle
import math

# 1. Load dataset
df = pd.read_csv("budget_data.csv")

# 2. Pilih fitur dan target
X = df[["total_spent", "num_items", "avg_item_price", "last_month_budget"]]
y = df["next_month_budget"]

# 3. Split data jadi train dan test
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# 4. Buat model dan latih
model = LinearRegression()
model.fit(X_train, y_train)

# 5. Evaluasi model (print skor akurasi)
score = model.score(X_test, y_test)
print(f"Akurasi model (R^2): {score:.2f}")

# 6. Simpan model ke file .pkl
with open("budget_predictor.pkl", "wb") as f:
    pickle.dump(model, f)

print("Model berhasil disimpan ke budget_predictor.pkl")

# 7. Prediksi untuk bulan berikutnya (2026-01) berdasarkan data bulan terakhir

# Ambil data bulan terakhir (baris terakhir)
last_row = df.iloc[-1]

# Ambil fitur-fitur yang diperlukan
features = pd.DataFrame([{
    "total_spent": last_row["total_spent"],
    "num_items": last_row["num_items"],
    "avg_item_price": last_row["avg_item_price"],
    "last_month_budget": last_row["next_month_budget"]  # Budget bulan sebelumnya = budget bulan terakhir
}])

# Prediksi
predicted_budget = model.predict(features)[0]
print(f"Prediksi next_month_budget untuk 2026-01: Rp {predicted_budget:.0f}")
