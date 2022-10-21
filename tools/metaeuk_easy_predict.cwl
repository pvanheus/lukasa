#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
$namespaces:
  edam: http://edamontology.org/

requirements:
  InlineJavascriptRequirement: {}

inputs:
  contigs:
    type: File
    format: edam:format_1929
    inputBinding:
      position: 10
  eval:
    type: float?
    inputBinding:
      prefix: --metaeuk-eval
      position: 1
  max_intron:
    type: int?
    inputBinding:
      prefix: --max-intron
      position: 1
  min_coverage:
    type: float?
    inputBinding:
      prefix: --metaeuk-tcov
      position: 1
  min_intron:
    type: int?
    inputBinding:
      prefix: --min-intron
      position: 1
  min_length:
    type: int?
    inputBinding:
      prefix: --min-length
      position: 1
  output_name:
    type: string
    default: metaeuk_output.fasta
    inputBinding:
      position: 30
  query:
    type: File
    format: edam:format_1929
    inputBinding:
      position: 20
  segment_eval:
    type: float?
    inputBinding:
      prefix: -e
      position: 1
  temp_dir:
    type: string
    default: ''
    inputBinding:
      position: 40
      valueFrom: '$(self ? self : runtime.tmpdir)'
  threads:
    type: int?
    inputBinding:
      prefix: --threads
      position: 1

outputs:
  output_fasta:
    type: File
    format: $(inputs.contigs.format)
    outputBinding:
      glob: $(inputs.output_name).fas

baseCommand:
- metaeuk
- easy-predict

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/metaeuk:6.a5d39d9--pl5321hf1761c0_1
  SoftwareRequirement:
    packages:
      metaeuk:
        specs:
        - https://github.com/soedinglab/metaeuk
        version:
        - 6.a5d39d9--pl5321hf1761c0_1
$schemas:
- http://edamontology.org/EDAM_1.18.owl
