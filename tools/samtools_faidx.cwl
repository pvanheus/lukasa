#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
$namespaces:
  edam: https://edamontology.org/

requirements:
  SoftwareRequirement
    packages:
    - package: samtools
      specs:
      - https://bio.tools/samtools
      version:
      - 1.16.1    
  DockerRequirement:
    dockerPull: quay.io/biocontainers/samtools:1.16.1--h6899075_1
  InitialWorkDirRequirement:
    listing:
    - $(inputs.sequences)

inputs:
  sequences:
    doc: Input FASTA file
    type: File
    format: edam:format_1929

outputs:
  sequences_index:
    type: File
    outputBinding:
      glob: $(inputs.sequences.basename).fai
  sequences_with_index:
    type: File
    format: $(inputs.sequences.format)
    secondaryFiles:
    - .fai
    outputBinding:
      glob: $(inputs.sequences.basename)

baseCommand:
- samtools
- faidx
arguments:
- $(inputs.sequences.basename)

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/samtools:1.16.1--h6899075_1
$schemas:
- https://edamontology.org/EDAM_1.18.owl
