#!/usr/bin/env python

import argparse
import json
import os
from os.path import abspath
import subprocess
import sys
import tempfile

template = """contigs_fasta:
  class: File
  format: edam:format_1929
  path: {}
proteins_fasta:
  class: File
  format: edam:format_1929
  path: {}
{}

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.18.owl
"""


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
    parser.add_argument("--output_filename", default='spaln_out.gff3')
    parser.add_argument("--workflow_dir", default=cwl_workflow_dir)
    parser.add_argument("contigs_filename", help="File with genomic contigs")
    parser.add_argument("proteins_filename", help="File with proteins to map")
    parser.add_argument("--species_table", help="spaln species table to use")
    args = parser.parse_args()
    if not is_fasta(args.contigs_filename) or not is_fasta(args.proteins_filename):
        sys.exit("Error: Input files must be in FASTA format")

    cwl_input_file = tempfile.NamedTemporaryFile(delete=False, mode="w")
    if args.species_table is not None:
        species_table_string = 'species_table: {}'.format(args.species_table)
    else:
        species_table_string = ''
    cwl_input_file.write(
        template.format(
            abspath(args.contigs_filename), abspath(args.proteins_filename), species_table_string
        )
    )
    cwl_input_file.close()

    workflow_file = "{}/lukasa.cwl".format(args.workflow_dir)
    cwl_commandline = ["cwltool", "--no-container", workflow_file, cwl_input_file.name]
    workflow_output_str = subprocess.check_output(cwl_commandline)

    os.unlink(cwl_input_file.name)

    workflow_output = json.loads(workflow_output_str)
    os.rename(workflow_output['spaln_out']['path'], args.output_filename)
