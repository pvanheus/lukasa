#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:
  SoftwareRequirement:
    packages:
      - package: python

requirements:
  InitialWorkDirRequirement:
    listing:
      - entryname: process_spaln_output.py
        entry: |
          from __future__ import print_function, division
          import sys

          output_filename = 'spaln_out.gff3'
          output_file = open(output_filename, 'w')
          input_filenames = sys.argv[1:]
          seen_header = False
          for input_filename in input_filenames:
            for line in open(input_filename):
              if line.startswith('#'):
                if not seen_header:
                  if line.startswith('##sequence-region'):
                    parts = line.split()
                    orig_region_name = parts[1]
                    location_parts = parts[1].split(':')
                    region_name = location_parts[0]
                    start = int(location_parts[1].split('-')[0])
                    print('##sequence-region\t{}'.format(region_name), file=output_file)
                    seen_header = True
                  else:
                    print(line, end='', file=output_file)
              else:
                fields = line.split('\t')
                fields[0] = region_name
                fields[3] = str(int(fields[3]) + start)
                fields[4] = str(int(fields[4]) + start)
                fields[8] = fields[8].replace(orig_region_name, region_name)
                new_line = '\t'.join(fields)
                print(new_line, end='', file=output_file)
          output_file.close()

inputs:
  spaln_outputs:
    type: File[]
    inputBinding:
      position: 1

outputs:
  combined_spaln_output:
    type: File
    outputBinding:
      glob: spaln_out.gff3

baseCommand: [ python, process_spaln_output.py ]

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.18.owl