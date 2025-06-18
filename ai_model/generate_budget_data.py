import json
import csv
import os

from pathlib import Path

docs_path = Path.home() / "Documents" / "fridgify"
json_path = docs_path / "budget_summary.json"
csv_path = 'budget_data.csv'

def convert_json_to_csv():
    # Pastikan file JSON ada
    if not os.path.exists(json_path):
        print(f"File '{json_path}' tidak ditemukan.")
        return

    with open(json_path, 'r') as json_file:
        data = json.load(json_file)

    # Validasi data format list
    if not isinstance(data, list):
        print("Format JSON tidak valid. Harus berupa list.")
        return

    rows = []

    for i in range(1, len(data)):
        prev = data[i - 1]
        current = data[i]

        row = {
            'month': current.get('month'),
            'total_spent': current.get('totalSpent'),
            'num_items': current.get('numItems'),
            'avg_item_price': current.get('avgItemPrice'),
            'last_month_budget': prev.get('initialBudget'),
            'next_month_budget': current.get('initialBudget')
        }
        rows.append(row)

    if not rows:
        print("Data tidak cukup (minimal 2 bulan) untuk membuat dataset.")
        return

    with open(csv_path, 'w', newline='') as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)

    print(f"✅ Dataset berhasil dibuat di: {csv_path}")


if __name__ == '__main__':
    convert_json_to_csv()
