#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:
  SoftwareRequirement:
    packages:
      - package: python
  DockerRequirement:
    dockerPull: python:3.8-slim-buster

inputs:
  script:
    type: File
    default:
      class: File
      basename: "process_spaln_output.py"
      contents:
        $include: "process_spaln_output.py"
    inputBinding:
      position: 1
  spaln_outputs:
    type: File[]
    inputBinding:
      position: 2

outputs:
  combined_spaln_output:
    type: File
    outputBinding:
      glob: spaln_out.gff3

baseCommand: [ python ]

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.18.owl