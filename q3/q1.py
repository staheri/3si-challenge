import csv
from collections import Counter
import sys


def get_top_frequencies(file_path, col, N):
    """
    Print top N most frequent words of a column.
    
    Inputs:
        file_path: Path to the input file
        col: Target column
        N: Top most frequent
    """
    col2_counter = Counter()

    with open(file_path, 'r', newline='', encoding='utf-8') as file:
        reader = csv.reader(file)
        for row in reader:
            if len(row) < 3:
                continue  # skip malformed lines
            col_2_value = row[col].strip()
            col2_counter[col_2_value] += 1

    top_8 = col2_counter.most_common(N)
    for value, freq in top_8:
        print(f"{value}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python q1.py <filename>")
        sys.exit(1)
    file_path = sys.argv[1]
    get_top_frequencies(file_path, 1, 8)