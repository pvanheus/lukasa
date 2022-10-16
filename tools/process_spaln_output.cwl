#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
$namespaces:
  edam: http://edamontology.org/

inputs:
  script:
    type: File
    default:
      class: File
      basename: process_spaln_output.py
      contents:
        $include: process_spaln_output.py
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

baseCommand:
- python

hints:
  DockerRequirement:
    dockerPull: python:3.10-slim-buster
  SoftwareRequirement:
    packages:
    - package: python
$schemas:
- http://edamontology.org/EDAM_1.18.owl
