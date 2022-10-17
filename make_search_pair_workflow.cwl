#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
$namespaces:
  edam: http://edamontology.org/
  iana: https://www.iana.org/assignments/media-types/

inputs:
  all_contig_fasta:
    type: File
    format: edam:format_1929
    secondaryFiles:
    - .fai
  all_protein_fasta:
    type: File
    format: edam:format_1929
    secondaryFiles:
    - .fai
  contig_region:
    type: File
    format: iana:text/plain
  protein:
    type: File
    format: iana:text/plain

outputs:
  contig_fasta:
    type: File
    format: $(inputs.all_contig_fasta.format)
    outputSource: extract_contig/extracted_fasta
  protein_fasta:
    type: File
    format: $(inputs.all_protein_fasta.format)
    outputSource: extract_protein/extracted_fasta

steps:
  extract_contig:
    in:
      fasta_file: all_contig_fasta
      region_file: contig_region
    run: tools/samtools_faidx_extract.cwl
    out:
    - extracted_fasta
  extract_protein:
    in:
      fasta_file: all_protein_fasta
      region_file: protein
    run: tools/samtools_faidx_extract.cwl
    out:
    - extracted_fasta
$schemas:
- http://edamontology.org/EDAM_1.18.owl
