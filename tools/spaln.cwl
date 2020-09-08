#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:
  SoftwareRequirement:
    packages:
      - package: spaln
        version: [ "2.4.03" ]
        specs: [ "https://github.com/ogotoh/spaln" ]
  DockerRequirement:
    dockerPull: quay.io/biocontainers/spaln:2.4.03--pl526he513fc3_0

inputs:
  genome_fasta:
    type: File
    format: edam:format_1929
    inputBinding:
      position: 10
  query_fasta:
    type: File
    format: edam:format_1929
    inputBinding:
      position: 20
  species:
    type: string?
    inputBinding:
      position: 1
      prefix: -T
  output_format:
    type: int?
    inputBinding:
      position: 1
      prefix: -O

stdout: spaln_output.txt

outputs:
  spaln_out:
    type: stdout

baseCommand: [ spaln ]

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.18.owl