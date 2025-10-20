import argparse
import pandas as pd
import pysam
import pybedtools

def get_max_gnomad_af(chrom, start, end, vcf, af_fields):
    try:
        records = list(vcf.fetch(chrom, start, end))
    except ValueError:
        records = []

    max_af = 0.0
    for rec in records:
        for field in af_fields:
            af_val = rec.info.get(field)
            if af_val is not None and af_val > max_af:
                max_af = af_val
    if max_af == 0.0:
        return None
    return max_af

def annotate_scoresheet(scoresheet_file, vcf_file, output_file):
    df = pd.read_csv(scoresheet_file, sep='\t', dtype={'Chromosome': str})
    
    af_fields = ['SF_afr','SF_amr','SF_asj','SF_eas','SF_fin',
                 'SF_mid','SF_nfe','SF_sas','SF_remaining']

    vcf = pysam.VariantFile(vcf_file)

    af_list = []
    for idx, row in df.iterrows():
        chrom = row['Chromosome']
        start = int(row['Start'])
        end = int(row['End'])
        af = get_max_gnomad_af(chrom, start, end, vcf, af_fields)
        af_list.append(round(af, 4) if af is not None else 'NA')

    df['gnomAD_max_AF'] = af_list
    
    # Reorder columns: insert gnomAD_max_AF after 'Classification'
    cols = list(df.columns)
    if 'Classification' in cols:
        class_idx = cols.index('Classification') + 1
        # Remove gnomAD_max_AF from current position
        cols.remove('gnomAD_max_AF')
        # Insert it after Classification
        cols.insert(class_idx, 'gnomAD_max_AF')
        df = df[cols]

    df.to_csv(output_file, sep='\t', index=False)

def main():
    parser = argparse.ArgumentParser(description='Add max gnomAD AF to Scoresheet TXT')
    parser.add_argument('-i', '--input', required=True, help='Input Scoresheet TXT file')
    parser.add_argument('-v', '--vcf', required=True, help='gnomAD CNV VCF file (bgzipped + indexed)')
    parser.add_argument('-o', '--output', required=True, help='Output annotated TXT file')
    args = parser.parse_args()

    annotate_scoresheet(args.input, args.vcf, args.output)

if __name__ == "__main__":
    main()
