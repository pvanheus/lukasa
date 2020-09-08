#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

# EDAM formats:
# format_1929 - FASTA
# format_1964 - plain text

hints:
  SoftwareRequirement:
    packages: 
      - package: python

requirements:
  InitialWorkDirRequirement:
    listing:
      - entryname: extract_regions.py
        entry: |
          from __future__ import print_function, division
          import sys

          input_filename = sys.argv[1]
          if len(sys.argv) == 3:
            fuzz = int(sys.argv[2])
          else:
            fuzz = 0
          input_file = open(input_filename)

          count = 0
          for line in input_file:
            if not line.startswith('>'):
              continue
            count += 1
            contig_regions_file = open('contig_regions{}.txt'.format(count), 'w')
            proteins_list_file = open('proteins{}.txt'.format(count), 'w')
            fields = line.split('|')
            protein_id = fields[0][1:]
            contig_id = fields[1]
            r_start = int(fields[6])
            if r_start > fuzz:
              r_start = r_start - fuzz
            r_end = int(fields[7]) + fuzz
            print('{}:{}-{}'.format(contig_id, r_start, r_end), file=contig_regions_file)
            print(protein_id, file=proteins_list_file)
            contig_regions_file.close()
            proteins_list_file.close()

        
inputs:
  metaeuk_fasta:
    type: File
    format: edam:format_1929
    inputBinding:
      position: 1
  fuzz_length:
    type: int?
    doc: number of bases to add to the start and end of the region to extract
    inputBinding:
      position: 2

baseCommand: [ python, extract_regions.py ]

outputs:
  contig_regions_files:
    type: File[]
    format: edam:format_1964
    outputBinding:
      glob: contig_regions*.txt
  proteins_lists:
    type: File[]
    format: edam:format_1964
    outputBinding:
      glob: proteins*.txt

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.18.owl