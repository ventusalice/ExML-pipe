import pandas as pd
import argparse
import re
import os

def main():
    parser = argparse.ArgumentParser(description='Process annotated TSV file, add Franklin and Varsome links, extract Zygosity, reorder columns.')
    
    parser.add_argument('-i', '--input', required=True, help='Input TSV filename')
    parser.add_argument('-o', '--output', required=True, help='Output TSV filename')
    
    args = parser.parse_args()
    
    # Load TSV
    df = pd.read_csv(args.input, sep='\t', low_memory=False)
    
    # Copy gnomad41_exome_AF to AF_popmax
    df['AF_popmax'] = df['gnomad41_exome_AF'] if 'gnomad41_exome_AF' in df.columns else pd.NA
    
    # Extract raw genotype string (e.g. "0/1") as Zygosity from sample column
    base_filename = os.path.basename(args.input)
    genotype_col_match = re.match(r'^([^\.]+)', base_filename)
    genotype_col = genotype_col_match.group(1) if genotype_col_match else None
    
    def extract_zygosity(val):
    	if pd.isna(val) or val == '.':
        	return '.'
    	return val.split(':')[0]

    if genotype_col and genotype_col in df.columns:
        df['Zygosity'] = df[genotype_col].apply(extract_zygosity)
    else:
        # Fallback: choose first genotype-format like column or empty column
        df['Zygosity'] = '.'
    
    # Generate Franklin and Varsome variant links
    df['Franklin'] = df.apply(lambda r: f"https://franklin.genoox.com/clinical-db/variant/snp/{r['Chr']}-{r['Start']}-{r['Ref']}-{r['Alt']}-hg38", axis=1)
    df['Varsome'] = df.apply(lambda r: f"https://varsome.com/variant/hg38/{r['Chr']}-{r['Start']}-{r['Ref']}-{r['Alt']}", axis=1)
    
    # Ensure priority columns exist
    priority_cols = [
        'Gene.refGene',
        'Prediction_ACMG_tapes',
        'Franklin',
        'Varsome',
        'Zygosity',
        'Chr',
#        'Inheritance',
        'CLNSIG',
        'AF_popmax',
        'Start',
        'Pheno',
        'End',
        'Ref',
        'Alt',
        'Func.refGene'
    ]
    for col in priority_cols:
        if col not in df.columns:
            df[col] = pd.NA

   # Replace empty or NaN in Inheritance with "."
#    df['Inheritance'] = df['Inheritance'].fillna('.')
#    df.loc[df['Inheritance'] == '', 'Inheritance'] = '.'
    
    # Reorder columns: priority first, then others
    other_cols = [c for c in df.columns if c not in priority_cols]
    df = df[priority_cols + other_cols]
    
    # Write output TSV
    df.to_csv(args.output, sep='\t', index=False)
    print(f"Processed file saved to {args.output}")

if __name__ == "__main__":
    main()
