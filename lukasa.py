#!/usr/bin/env python3

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
from os.path import abspath


def build_template(
    contig_path: str,
    protein_path: str,
    species_table: str = "",
    max_intron: str = "",
    min_intron: str = "",
    min_coverage: str = "",
    e_val: str = ""
):
    template = f"""
    contigs_fasta:
      class: File
      format: edam:format_1929
      path: {contig_path}
    proteins_fasta:
      class: File
      format: edam:format_1929
      path: {protein_path}
    {max_intron}
    {min_intron}
    {min_coverage}
    {e_val}
    {species_table}

    $namespaces:
      edam: http://edamontology.org/
    $schemas:
      - http://edamontology.org/EDAM_1.18.owl
    """
    return template


def is_fasta(input_filename):
    with open(input_filename) as input_file:
        data = input_file.read(100)
        if data.lstrip().startswith(">"):
            return True
        else:
            return False


if __name__ == "__main__":
    if "CONDA_PREFIX" in os.environ:
        cwl_workflow_dir = os.environ["CONDA_PREFIX"] + "/share/lukasa"
    else:
        cwl_workflow_dir = "."
    parser = argparse.ArgumentParser(
        description="Wrapper to simplify running the lukasa protein evidence mapping workflow on the command line"
    )
    parser.add_argument("--output_filename", default="spaln_out.gff3")
    parser.add_argument("--workflow_dir", default=cwl_workflow_dir)
    parser.add_argument("--max_intron", type=int, help="Maximum intron length")
    parser.add_argument("--min_intron", type=int, help="Minimum intron length")
    parser.add_argument("--min_coverage", type=float, help="Minimum proportion of a gene that is exons")
    parser.add_argument("--eval", type=float, help="Maximum E-value for MetaEuk")
    parser.add_argument("--debug", action="store_true", default=False)
    parser.add_argument("contigs_filename", help="File with genomic contigs")
    parser.add_argument("proteins_filename", help="File with proteins to map")
    parser.add_argument("--species_table", help="spaln species table to use")
    args = parser.parse_args()
    if not is_fasta(args.contigs_filename) or not is_fasta(args.proteins_filename):
        sys.exit("Error: Input files must be in FASTA format")

    cwl_input_file = tempfile.NamedTemporaryFile(delete=False, mode="w")

    species_table = max_intron = min_intron = min_coverage = e_val = ""
    if args.species_table is not None:
        species_table = "species_table: {}".format(args.species_table)
    if args.max_intron is not None:
        max_intron = f"max_intron: {args.max_intron}"
    if args.min_intron is not None:
        min_intron = f"min_intron: {args.min_intron}"
    if args.min_coverage is not None:
        min_coverage = f"min_coverage: {args.min_coverage}"
    if args.eval is not None:
        e_val = f"eval: {args.eval}"
    cwl_input = build_template(
            abspath(args.contigs_filename),
            abspath(args.proteins_filename),
            species_table=species_table,
            max_intron=max_intron,
            min_intron=min_intron,
            min_coverage=min_coverage,
            e_val=e_val
        )
    if args.debug:
        print(cwl_input, file=sys.stderr, end='')
    cwl_input_file.write(cwl_input)
    cwl_input_file.close()

    workflow_file = "{}/lukasa.cwl".format(args.workflow_dir)
    if args.debug:
        debug = "--debug"
    else:
        debug = ""
    cwl_commandline = ["cwltool", "--no-container"]
    if args.debug:
        cwl_commandline += ['--debug']
    cwl_commandline += [workflow_file, cwl_input_file.name]
    workflow_output_str = subprocess.check_output(cwl_commandline)

    os.unlink(cwl_input_file.name)

    workflow_output = json.loads(workflow_output_str)
    shutil.move(workflow_output["spaln_out"]["path"], args.output_filename)
