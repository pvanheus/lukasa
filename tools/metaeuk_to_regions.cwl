#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
$namespaces:
  edam: https://edamontology.org/
  iana: https://www.iana.org/assignments/media-types/

inputs:
  fuzz_length:
    doc: number of bases to add to the start and end of the region to extract
    type: int?
    inputBinding:
      position: 3
  metaeuk_fasta:
    type: File
    format: edam:format_1929
    inputBinding:
      position: 2
  scripts:
    type: File
    default:
      class: File
      basename: extract_regions.py
      contents:
        $include: extract_regions.py
    inputBinding:
      position: 1

outputs:
  contig_regions_files:
    type: File[]
    format: iana:text/plain
    outputBinding:
      glob: contig_regions*.txt
  proteins_lists:
    type: File[]
    format: iana:text/plain
    outputBinding:
      glob: proteins*.txt

baseCommand:
- python

hints:
  DockerRequirement:
    dockerPull: python:3.10-slim-buster
  SoftwareRequirement:
    packages:
    - package: python
$schemas:
- https://edamontology.org/EDAM_1.18.owl
