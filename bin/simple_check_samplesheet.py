#!/usr/bin/env python

import csv
import argparse

# checks the header names
# checks file formats
# checks all same number of columns for all rows, and assigns correct single_end boolean
# convert spaces to underscores for sample name
# check uniqueness of sample names

EXPECTED_HEADER = ["sample", "fastq_1", "fastq_2"]
OUTPUT_HEADER = ["sample", "fastq_1", "fastq_2", "single_end"]


def check_samplesheet(csv_file):
    samples = set()
    single_end = None
    rows = []

    with open(csv_file, "r") as file:
        reader = csv.DictReader(file)

        # Check header names
        assert set(reader.fieldnames) == set(EXPECTED_HEADER), "Invalid header names"

        for row in reader:
            # Check file formats
            for field in ["fastq_1", "fastq_2"]:
                value = row[field].strip()
                if value and not (
                    value.endswith(".fastq.gz") or value.endswith(".fq.gz")
                ):
                    raise AssertionError(f"Invalid fastq format")

            # Convert spaces to underscores for sample name
            row["sample"] = row["sample"].replace(" ", "_").strip()
            assert row["sample"] != "", "Sample name is empty"

            # Check uniqueness of sample names
            if row["sample"] in samples:
                raise AssertionError(f"Duplicate sample name")
            samples.add(row["sample"])

            # Check number of columns and assign single_end boolean
            if row["fastq_1"].strip() and not row["fastq_2"].strip():
                if single_end is None:
                    single_end = True
                elif not single_end:
                    raise AssertionError(f"Inconsistent number of columns")
            elif row["fastq_1"].strip() and row["fastq_2"].strip():
                if single_end is None:
                    single_end = False
                elif single_end:
                    raise AssertionError(f"Inconsistent number of columns")
            else:
                raise AssertionError(f"Missing values in fastq fields")

            row["single_end"] = str(single_end)
            rows.append(row)

    assert single_end is not None, "Invalid CSV: single_end value not determined"
    return rows


def write_samplesheet(output_file, rows):
    with open(output_file, "w", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=OUTPUT_HEADER)
        writer.writeheader()
        writer.writerows(rows)


def main():
    parser = argparse.ArgumentParser(description="Validate a CSV samplesheet.")
    parser.add_argument("samplesheet", help="Path to the samplesheet CSV file")
    parser.add_argument(
        "-o",
        "--output",
        default="validated_samplesheet.csv",
        help="Output filename for validated samplesheet",
    )
    args = parser.parse_args()

    samplesheet_path = args.samplesheet
    output_file = args.output

    rows = check_samplesheet(samplesheet_path)
    write_samplesheet(output_file, rows)


if __name__ == "__main__":
    main()
