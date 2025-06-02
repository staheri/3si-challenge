import duckdb
import time 
import sys 

def q4_solution(big_data_path):
    # Connect to DuckDB
    con = duckdb.connect()
    print("Loading...")
    # Load the httpfs extension
    con.execute("INSTALL httpfs;")
    con.execute("LOAD httpfs;")
    print("Query...")
    start_time = time.time()
    result = con.execute(f"""
        SELECT *
        FROM read_csv_auto('{big_data_path}', delim='\t', header=false)
        ORDER BY column3 DESC
        LIMIT 50;
    """).fetchdf()

    end_time = time.time()
    # Display the result
    print(result)
    print(f"Execution Time: {end_time - start_time:.2f} seconds")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python q4.py <filename>")
        sys.exit(1)
    file_path = sys.argv[1]
    q4_solution(file_path)
