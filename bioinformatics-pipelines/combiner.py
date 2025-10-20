import argparse
import pandas as pd

parser = argparse.ArgumentParser()
parser.add_argument('-f1', '--file1', required=True, help='Path to first TSV file')
parser.add_argument('-f2', '--file2', required=True, help='Path to second TSV file')
parser.add_argument('-f3', '--file3', required=True, help='Path to third TSV file')
parser.add_argument('-o', '--output', required=True, help='Output Excel filename')
args = parser.parse_args()

df1 = pd.read_csv(args.file1, sep='\t', low_memory=False)
df2 = pd.read_csv(args.file2, sep='\t', low_memory=False)
df3 = pd.read_csv(args.file3, sep='\t', low_memory=False)

with pd.ExcelWriter(args.output, engine='xlsxwriter') as writer:
    df1.to_excel(writer, sheet_name='SNV', index=False)
    df2.to_excel(writer, sheet_name='LID', index=False)
    df3.to_excel(writer, sheet_name='CNV', index=False)
