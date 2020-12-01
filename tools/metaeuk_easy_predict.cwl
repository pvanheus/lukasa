#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:
  SoftwareRequirement:
    packages:
      metaeuk:
        version: [ "2.ddf2742" ]
        specs: [ "https://github.com/soedinglab/metaeuk" ]
  DockerRequirement:
    dockerPull: quay.io/biocontainers/metaeuk:2.ddf2742--h2d02072_0

requirements:
  InlineJavascriptRequirement: {}

inputs:
  contigs:
    type: File
    format: edam:format_1929
    inputBinding:
      position: 10
  query:
    type: File
    format: edam:format_1929
    inputBinding:
      position: 20
  output_name:
    type: string
    default: "metaeuk_output.fasta"
    inputBinding:
      position: 30
  temp_dir:
    type: string
    default: ""
    inputBinding:
      valueFrom: "$(self ? self : runtime.tmpdir)"
      position: 40
  threads:
    type: int?
    inputBinding:
      position: 1
      prefix: --threads
  min_length:
    type: int?
    inputBinding:
      position: 1
      prefix: --min-length
  segment_eval:
    type: float?
    inputBinding:
      position: 1
      prefix: -e
  eval:
    type: float?
    inputBinding:
      position: 1
      prefix: --metaeuk-eval
  min_coverage:
    type: float?
    inputBinding:
      position: 1
      prefix: --metaeuk-tcov
  max_intron:
    type: float?
    inputBinding:
      position: 1
      prefix: --max-intron
  min_intron:
    type: float?
    inputBinding:
      position: 1
      prefix: --min-intron

baseCommand: [ metaeuk, easy-predict ]

outputs:
  output_fasta:
    type: File
    format: $(inputs.contigs.format)
    outputBinding:
      glob: $(inputs.output_name)

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.18.owl
