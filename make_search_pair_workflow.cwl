#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

inputs:
  all_contig_fasta:
    type: File
    secondaryFiles:
      - .fai
    format: edam:format_1929
  all_protein_fasta:
    type: File
    secondaryFiles:
      - .fai
    format: edam:format_1929
  contig_region:
    type: File
    format: edam:format_1964
  protein:
    type: File
    format: edam:format_1964

outputs:
  contig_fasta:
    type: File
    outputSource:
      extract_contig/extracted_fasta
  protein_fasta:
    type: File
    outputSource:
      extract_protein/extracted_fasta

steps:
  extract_contig:
    run: tools/samtools_faidx_extract.cwl
    in:
      fasta_file: all_contig_fasta
      region_file: contig_region
    out:
      - extracted_fasta
  extract_protein:
    run: tools/samtools_faidx_extract.cwl
    in:
      fasta_file: all_protein_fasta
      region_file: protein
    out:
      - extracted_fasta

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.18.owl
