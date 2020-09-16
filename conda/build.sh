#!/bin/bash

WORKFLOW_DIR=$PREFIX/share/protein_evidence_mapping
mkdir -p $WORKFLOW_DIR
cp protein_evidence_mapping.cwl $WORKFLOW_DIR/
cp -r tools $WORKFLOW_DIR/

mkdir -p $WORKFLOW_DIR/bin/
cp pem.py $WORKFLOW_DIR/bin/