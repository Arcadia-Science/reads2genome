#!/usr/bin/env python

import csv
import argparse

# checks the header names
# checks file formats
# checks all same number of columns for all rows, and assigns correct single_end boolean
# convert spaces to underscsores for sample name
# check uniqueness of sample names


def check_samplesheet(samplesheet):
    with open(samplesheet, "r") as file:
        reader = csv.reader(file)
        header = next(reader)

        # Check header names
        expected_header = ["sample", "fastq_1", "fastq_2"]
        if len(header) != 3 or header != expected_header:
            print(f"Invalid header names! Expected header names: {expected_header}, Input header names: {header}")
            return False

        sample_index = header.index("sample")
        fastq1_index = header.index("fastq_1")
        fastq2_index = header.index("fastq_2")

        rows = list(reader)

        # Check row format consistency
        is_single_end = None
        for row in rows:
            if len(row) == 3:
                if row[fastq2_index].strip() == "":
                    if is_single_end is None:
                        is_single_end = True
                    elif not is_single_end:
                        return False
                else:
                    if is_single_end is None:
                        is_single_end = False
                    elif is_single_end:
                        return False
            else:
                print(
                    f"Inconsistent samplesheet format! Must either contain samples with all single-end fastq files (single fastq) or all paired-end fastq files (two expected fastq files)!"
                )
                return False

            # Check fastq_1 and fastq_2 formats
            if row[fastq1_index] and not (
                row[fastq1_index].endswith(".fastq.gz") or row[fastq1_index].endswith(".fq.gz")
            ):
                print(f"Invalid file extension given for fastq_1! Must end in .fq.gz or .fastq.gz!")
                return False
            if row[fastq2_index] and not (
                row[fastq2_index].endswith(".fastq.gz") or row[fastq2_index].endswith(".fq.gz")
            ):
                print(f"Invalid file extension given for fastq_2! Must end in .fq.gz or .fastq.gz!")
                return False

            # Convert spaces in the sample column to underscores
            row[sample_index] = row[sample_index].replace(" ", "_")

        # Check uniqueness of sample entries
        samples = [row[sample_index] for row in rows]
        if len(samples) != len(set(samples)):
            print(
                f"Non-unique sample names provided for multiple samples! Must input unique sample names for each row!"
            )
            return False

        # Add single end column if necessary
        if is_single_end is not None:
            header.append("single_end")
            for row in rows:
                row.append(str(is_single_end))

    return header, rows


def write_samplesheet(output_file, header, rows):
    with open(output_file, "w", newline="") as file:
        writer = csv.writer(file)
        writer.writerow(header)
        writer.writerows(rows)


def main():
    parser = argparse.ArgumentParser(description="Validate a CSV samplesheet.")
    parser.add_argument("samplesheet", help="Path to the samplesheet CSV file")
    parser.add_argument(
        "-o", "--output", default="validated_samplesheet.csv", help="Output filename for validated samplesheet"
    )
    args = parser.parse_args()

    samplesheet_path = args.samplesheet
    output_file = args.output

    result = check_samplesheet(samplesheet_path)

    if result:
        header, rows = result
        write_samplesheet(output_file, header, rows)
        print("Valid samplesheet generated:", output_file)
    else:
        print("Invalid samplesheet!")


if __name__ == "__main__":
    main()
