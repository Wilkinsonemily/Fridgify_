import pickle
import pandas as pd
import math

# Load model
with open("budget_predictor.pkl", "rb") as f:
    model = pickle.load(f)

# Data pengeluaran user bulan ini
input_data = pd.DataFrame([{
    "total_spent": 180000,
    "num_items": 16,
    "avg_item_price": 11250,
    "last_month_budget": 170000
}])

# Prediksi
predicted_budget = model.predict(input_data)[0]

# Bulatkan ke ribuan terdekat
rounded_budget = int(round(predicted_budget / 1000.0)) * 1000

print(f"Budget bulan depan disarankan: Rp {rounded_budget:.0f}")