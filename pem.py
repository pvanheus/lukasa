#!/usr/bin/env python

import argparse
import os
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
species_table: {}

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.18.owl
"""

def is_fasta(input_filename):
    with open(input_filename) as input_file:
        data = input_file.read(100)
        if data.lstrip().startswith('>'):
            return True
        else:
            return False

if __name__ == '__main__':
    if 'CONDA_PREFIX' in os.environ:
        cwl_workflow_dir = os.environ['CONDA_PREFIX'] + '/share/protein_evidence_mapping'
    else:
        cwl_workflow_dir = '.'
    parser = argparse.ArgumentParser()
    parser.add_argument('--output_filename', default=cwl_workflow_dir)
    parser.add_argument('--workflow_dir', default=os.environ.get('PREFIX'))
    parser.add_argument('contigs_filename', help='File with genomic contigs')
    parser.add_argument('proteins_filename', help='File with proteins to map')
    parser.add_argument('species_table', help='spaln species table to use')
    args = parser.parse_args()
    if not is_fasta(args.contigs_filename) or not is_fasta(args.proteins_filename):
        sys.exit("Error: Input files must be in FASTA format")
    
    cwl_input_file = tempfile.NamedTemporaryFile(delete=False, mode='w')
    cwl_input_file.write(template.format(args.contigs_filename, args.proteins_filename, args.species_table))
    cwl_input_file.close()

    cwl_commandline = ['cwltool', '--no-container', '{}/protein_evidence_mapping.cwl'.format(args.workflow_dir), cwl_input_file.name]
    subprocess.check_call(cwl_commandline)

    os.unlink(cwl_input_file.name)
    # os.rename('sorted_output.txt', args.output_filename)
