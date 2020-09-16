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
  DockerRequirement:
    dockerPull: python:3.8-slim-buster
    
requirements:
  InitialWorkDirRequirement:
    listing:
      - entryname: extract_regions.py
        entry:
          $include: "extract_regions.py"
        
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