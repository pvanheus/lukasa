#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
$namespaces:
  edam: http://edamontology.org/
  iana: https://www.iana.org/assignments/media-types/

inputs:
  continue:
    doc: Continue after trying to retrieve missing region
    type: boolean?
    inputBinding:
      prefix: --continue
      position: 1
  fasta_file:
    type: File
    format: edam:format_1929
    secondaryFiles:
    - .fai
    inputBinding:
      position: 10
  line_length:
    doc: Length of FASTA sequence line
    type: int?
    inputBinding:
      prefix: --length
      position: 1
  region_file:
    type: File
    format: iana:text/plain
    inputBinding:
      prefix: --region-file
      position: 1
  reverse_complement:
    doc: Reverse complement sequences
    type: boolean?
    inputBinding:
      prefix: --reverse-complement
      position: 1
  strand_mark:
    doc: How to add strand indicator to sequence name
    type: string?
    inputBinding:
      prefix: --mark-strand
      position: 1

outputs:
  extracted_fasta:
    type: File
    format: $(inputs.fasta_file.format)
    outputBinding:
      glob: output.fasta

baseCommand:
- samtools
- faidx
arguments:
- prefix: --output
  position: 1
  valueFrom: output.fasta

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/samtools:1.16.1--h6899075_1
  SoftwareRequirement:
    packages:
    - package: samtools
      specs:
      - https://bio.tools/samtools
      version:
      - 1.16.1
$schemas:
- http://edamontology.org/EDAM_1.18.owl
