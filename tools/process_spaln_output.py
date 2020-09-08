from __future__ import print_function, division
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
input_filenames = sys.argv[1:]
seen_header = False
gene_number = 0
for input_filename in input_filenames:
    for line in open(input_filename):
        if line.startswith("##sequence-region"):
            parts = line.split()
            orig_region_name = parts[1]
            location_parts = parts[1].split(":")
            region_name = location_parts[0]
            start = int(location_parts[1].split("-")[0])
            if not seen_header:
                pass
                # sequence-region must have a start and end coordinate - we don't now these
                # until we have seen the maximal output position, so leave this out
                # TODO: write script that samples all files, determines sort order
                # and uses this "global overview" to insert sequence-region line
                # print('##sequence-region\t{}'.format(region_name), file=output_file)
            seen_header = True
        elif line.startswith("#"):
            if not seen_header:
                print(line, end="", file=output_file)
            else:
                continue
        else:
            fields = line.rstrip().split("\t")
            type = fields[2]
            if type == "gene":
                gene_number += 1
            fields[0] = region_name
            fields[3] = str(int(fields[3]) + start)
            fields[4] = str(int(fields[4]) + start)
            fields[8] = fix(fields[8], region_name, gene_number)
            new_line = "\t".join(fields)
            print(new_line, end="", file=output_file)
output_file.close()
