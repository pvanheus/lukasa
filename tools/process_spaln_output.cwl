#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:
  SoftwareRequirement:
    packages:
      - package: python
  DockerRequirement:
    dockerPull: python:3.8-slim-buster

requirements:
  InitialWorkDirRequirement:
    listing:
      - entryname: process_spaln_output.py
        entry: 
          $include: "process_spaln_output.py"

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