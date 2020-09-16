cwlVersion: v1.0
class: CommandLineTool

hints:
  SoftwareRequirement:
    packages:
      - package: sort
        specs:
          - "https://packages.debian.org/coreutils"
  DockerRequirement:
    dockerPull: alpine

inputs:
  in_file:
    type: File
    inputBinding:
      position: 10
  key:
    type: string?
    inputBinding:
      position: 1
      prefix: -k
  numeric_sort:
    type: boolean?
    inputBinding:
      position: 1
      prefix: -n
  field_delimiter:
    type: string?
    inputBinding:
      position: 1
      prefix: -t

stdout: sorted_output.txt

outputs:
  sorted_output:
    type: stdout

baseCommand: [ sort ]
