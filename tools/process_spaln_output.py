from __future__ import print_function, division
from operator import itemgetter
import re
import sys


def fix(attrs, region_name, number):
    id_re = re.compile(r"(\D+)(\d+)")
    attr_kv = dict(map(lambda x: x.split("="), attrs.split(";")))
    id_match = id_re.match(attr_kv["ID"])
    assert id_match is not None, "Could not match ID from {}".format(attrs)
    type_str = id_match.group(1)
    attr_kv["ID"] = id_match.group(1) + "{:05}".format(number)
    if "Parent" in attr_kv:
        attr_kv["ID"] = type_str + "{}_{}".format(number, id_match.group(2))
        if type_str == "mRNA":
            attr_kv["Parent"] = "gene{:05}".format(number)
        else:
            attr_kv["Parent"] = re.sub(
                r"(\D+)(\d+)", r"mRNA{}_\2".format(number), attr_kv["Parent"]
            )
    else:
        attr_kv["ID"] = type_str + "{:05}".format(number)
    attr_kv["Name"] = region_name + "_" + str(number)
    new_attrs = ""
    for keyword in ("ID", "Parent", "Name", "Target"):
        if keyword in attr_kv:
            new_attrs += keyword + "=" + attr_kv[keyword] + ";"
    new_attrs = new_attrs.rstrip(";") + "\n"
    return new_attrs


output_filename = "spaln_out.gff3"
output_file = open(output_filename, "w")
print("##gff-version\t3", file=output_file)
input_filenames = sys.argv[1:]
seen_header = False
gene_number = 0
annotation_parts = {}
start_position = {}
end_position = {}
max_end = 0
for input_filename in input_filenames:
    region_name = None
    for line in open(input_filename):
        if line.startswith("##sequence-region"):
            parts = line.split()
            orig_region_name = parts[1]
            location_parts = parts[1].split(":")
            region_name = location_parts[0]
            start = int(location_parts[1].split("-")[0])
            if region_name not in annotation_parts:
                annotation_parts[region_name] = []
            annotation_parts[region_name].append((start, region_name, input_filename))
        elif not line.startswith("#"):
            fields = line.rstrip().split("\t")
            seq_type = fields[2]
            if seq_type == "gene":
                # end is fields[4]
                max_end = int(fields[4]) + start
    else:
        if region_name is not None:
            # if region_name is None it means that we processed an empty file
            if region_name not in end_position or end_position[region_name] < max_end:
                end_position[region_name] = max_end
            if region_name not in start_position or start_position[region_name] > start:
                start_position[region_name] = start

for annotation_part, locations in sorted(annotation_parts.items(), key=itemgetter(1)):
    # locations is a list of tuples (starting_position, region_name, filename)
    sequence_region_added = False
    for start, region_name, input_filename in sorted(locations, key=itemgetter(0)):
        if not sequence_region_added:
            assert (
                start == start_position[region_name]
            ), "mismatch between this start position {} and computed start position {} for {}".format(
                start, start_position[region_name], region_name
            )
            # started a new contig, add a sequence region header that describes the region under annotation
            print(
                "##sequence-region\t{} {} {}".format(
                    region_name, start, end_position[region_name]
                ),
                file=output_file,
            )
            sequence_region_added = True

        for line in open(input_filename):
            if line.startswith("##sequence-region") or line.startswith("##gff-version"):
                continue
            elif line.startswith("##FASTA"):
                break
            elif line.startswith("##"):
                print(
                    "Warning: unexpected directive {}".format(line.strip()),
                    file=output_file,
                )
                continue
            fields = line.rstrip().split("\t")
            seq_type = fields[2]
            if seq_type == "gene":
                gene_number += 1
            fields[0] = region_name
            fields[2] = "CDS" if fields[2] == "cds" else fields[2]
            fields[3] = str(int(fields[3]) + start - 1)
            fields[4] = str(int(fields[4]) + start - 1)
            fields[8] = fix(fields[8], region_name, gene_number)
            new_line = "\t".join(fields)
            print(new_line, end="", file=output_file)
output_file.close()
