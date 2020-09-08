#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

# EDAM formats:
# format_1929 - FASTA
# format_1964 - plain text

hints:
  SoftwareRequirement:
    packages: 
      - package: samtools
        version: [ "1.10" ]
        specs: [ "https://bio.tools/samtools" ]
  DockerRequirement:
    dockerPull: quay.io/biocontainers/samtools:1.10--h2e538c0_3 

inputs:
    fasta_file:
        type: File
        format: edam:format_1929
        secondaryFiles:
            - .fai
        inputBinding:
            position: 10
    region_file:
        type: File
        format: edam:format_1964
        inputBinding:
            position: 1
            prefix: --region-file
    line_length:
        type: int?
        doc: "Length of FASTA sequence line"
        inputBinding:
            position: 1
            prefix: --length
    continue:
        type: boolean?
        doc: "Continue after trying to retrieve missing region"
        inputBinding:
            position: 1
            prefix: --continue
    reverse_complement:
        type: boolean?
        doc: "Reverse complement sequences"
        inputBinding:
            position: 1
            prefix: --reverse-complement
    strand_mark:
        type: string?
        doc: "How to add strand indicator to sequence name"
        inputBinding:
            position: 1
            prefix: --mark-strand

outputs:
    extracted_fasta:
        type: File
        format: $(inputs.fasta_file.format)
        outputBinding:
            glob: output.fasta

arguments:
    - valueFrom: "output.fasta"
      prefix: --output
      position: 1

baseCommand: [ samtools, faidx ]

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.18.owl