from __future__ import print_function, division
import sys

input_filename = sys.argv[1]
if len(sys.argv) == 3:
    fuzz = int(sys.argv[2])
else:
    fuzz = 0
input_file = open(input_filename)

count = 0
for line in input_file:
    if not line.startswith(">"):
        continue
    count += 1
    contig_regions_file = open("contig_regions{}.txt".format(count), "w")
    proteins_list_file = open("proteins{}.txt".format(count), "w")
    fields = line.split("|")
    protein_id = fields[0][1:]
    contig_id = fields[1]
    r_start = int(fields[6])
    if r_start > fuzz:
        r_start = r_start - fuzz
    r_end = int(fields[7]) + fuzz
    print("{}:{}-{}".format(contig_id, r_start, r_end), file=contig_regions_file)
    print(protein_id, file=proteins_list_file)
    contig_regions_file.close()
    proteins_list_file.close()
