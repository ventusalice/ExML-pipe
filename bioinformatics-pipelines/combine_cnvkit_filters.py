import argparse
import pandas as pd

def main(input_ci, input_cn, input_sem, output):
    # Load filtered call files with different criteria
    call_ci = pd.read_table(input_ci)
    call_cn = pd.read_table(input_cn)
    call_sem = pd.read_table(input_sem)

    # Merge on genomic coordinates and call value to find common segments passing all filters
    merged = call_ci.merge(call_cn, how='inner')
    merged = merged.merge(call_sem, how='inner')

    # Save combined filtered calls output
    merged.to_csv(output, sep="\t", index=False)
    print(f"Filtered combined calls saved to {output}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Combine CNVkit filtered call files by intersection")
    parser.add_argument("--input_ci", required=True, help="Input CNVkit call file filtered by ci")
    parser.add_argument("--input_cn", required=True, help="Input CNVkit call file filtered by cn")
    parser.add_argument("--input_sem", required=True, help="Input CNVkit call file filtered by sem")
    parser.add_argument("--output", required=True, help="Output combined filtered call file")

    args = parser.parse_args()
    main(args.input_ci, args.input_cn, args.input_sem, args.output)
