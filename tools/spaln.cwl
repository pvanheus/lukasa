#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
$namespaces:
  edam: http://edamontology.org/

inputs:
  genome_fasta:
    type: File
    format: edam:format_1929
    inputBinding:
      position: 10
  min_intron:
    type: int?
    inputBinding:
      prefix: -yL
      position: 1
  output_format:
    type: int?
    inputBinding:
      prefix: -O
      position: 1
  query_fasta:
    type: File
    format: edam:format_1929
    inputBinding:
      position: 20
  species:
    type: string?
    inputBinding:
      prefix: -T
      position: 1

outputs:
  spaln_out:
    type: stdout
stdout: spaln_output.txt

baseCommand:
- spaln

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/spaln:2.4.13--pl5321h9f5acd7_0
  SoftwareRequirement:
    packages:
    - package: spaln
      specs:
      - https://github.com/ogotoh/spaln
      version:
      - 2.4.13
$schemas:
- http://edamontology.org/EDAM_1.18.owl
