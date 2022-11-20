#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

inputs:
  contigs_fasta:
    label: "Genomic contigs (FASTA)"
    type: File
    format: edam:format_1929
  proteins_fasta:
    label: "Proteins (FASTA)"
    type: File
    format: edam:format_1929
  species_table:
    label: "Spaln species table to use (optional)"
    type: string?
  eval:
    label: "Maximum e-val for stage 1"
    type: float?
    doc: "Maximum e-val to accept for the region_finding step (stage 1)"
  max_intron:
    label: "Maximum intron length"
    type: int?
    doc: "Maximum intron length, passed to metaeuk"
  min_intron:
    label: "Minimum intron length"
    type: int?
    doc: "Minimum intron length, passed to metaeuk and spaln"
  min_coverage:
    label: "Minimum coverage"
    type: float?
    doc: "Minimum proportion of a gene structure covered by exons"    
outputs:
  spaln_out:
    type: File
    outputSource:
      process_spaln_output/combined_spaln_output
requirements:
  ResourceRequirement:
    ramMin: 4096
    coresMin: 1

steps:
  metaeuk:
    run: tools/metaeuk_easy_predict.cwl
    in:
      contigs: contigs_fasta
      query: proteins_fasta
      max_intron: max_intron
      min_intron: min_intron
      eval: eval
      min_coverage: min_coverage
    out:
      - output_fasta
  samtools_index_contigs:
    run: bio-cwl-tools:samtools/samtools_faidx.cwl
    in:
      sequences: contigs_fasta
    out:
      - sequences_with_index
  samtools_index_protein:
    run: bio-cwl-tools:samtools/samtools_faidx.cwl
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
      min_intron: min_intron
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

$namespaces:
  edam: http://edamontology.org/
  bio-cwl-tools: https://raw.githubusercontent.com/common-workflow-library/bio-cwl-tools/release/
$schemas:
  - http://edamontology.org/EDAM_1.18.owl

