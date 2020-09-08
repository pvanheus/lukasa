#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

inputs:
  contigs_fasta:
    type: File
    format: edam:format_1929
  proteins_fasta:
    type: File
    format: edam:format_1929
  species_table:
    type: string
  gff_sort_key:
    type: string
    default: "4"
  gff_sort_numeric:
    type: boolean
    default: true
  gff_sort_delimiter:
    type: string
    default: "\t"
outputs:
  spaln_out:
    type: File
    outputSource:
      sort_gff3/sorted_output

steps:
  metaeuk:
    run: tools/metaeuk_easy_predict.cwl
    in:
      contigs: contigs_fasta
      query: proteins_fasta
    out:
      - output_fasta
  samtools_index_contigs:
    run: tools/samtools_faidx.cwl
    in:
      sequences: contigs_fasta
    out:
      - sequences_with_index
  samtools_index_protein:
    run: tools/samtools_faidx.cwl
    in:
      sequences: proteins_fasta
    out:
      - sequences_with_index
  extract_region_specs:
    run: tools/metaeuk_to_regions.cwl
    in:
      metaeuk_fasta: metaeuk/output_fasta
    out:
      - contig_regions_files
      - proteins_lists
  extract_region_pairs:
    requirements:
      - class: ScatterFeatureRequirement
      - class: SubworkflowFeatureRequirement
    scatter:
      - contig_region
      - protein
    scatterMethod: dotproduct
    run: make_search_pair_workflow.cwl
    in:
      all_contig_fasta: samtools_index_contigs/sequences_with_index
      all_protein_fasta: samtools_index_protein/sequences_with_index
      contig_region: extract_region_specs/contig_regions_files
      protein: extract_region_specs/proteins_lists
    out:
      - contig_fasta
      - protein_fasta
  spaln:
    requirements:
      - class: ScatterFeatureRequirement
    scatter:
      - genome_fasta
      - query_fasta
    scatterMethod: dotproduct
    run: tools/spaln.cwl
    in:
      genome_fasta: extract_region_pairs/contig_fasta
      query_fasta: extract_region_pairs/protein_fasta
      species: species_table
      output_format:
        default: 0
    out:
      - spaln_out
  process_spaln_output:
    run: tools/process_spaln_output.cwl
    in:
      spaln_outputs: spaln/spaln_out
    out:
      - combined_spaln_output
  sort_gff3:
    run: tools/sort.cwl
    in:
      in_file: process_spaln_output/combined_spaln_output
      key: gff_sort_key
      field_delimiter: gff_sort_delimiter
      numeric_sort: gff_sort_numeric
    out:
      - sorted_output

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - http://edamontology.org/EDAM_1.18.owl