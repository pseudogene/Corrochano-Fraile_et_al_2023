#!/usr/bin/env python3
# coding=utf-8
# title           :split_vcf
# description     :Split and merge chromosome with only one SNP
# date            :20230421
# version         :1.1
# copyright       :Michael Bekaert
# ==============================================================================
import argparse
import os
import re

parser = argparse.ArgumentParser()
parser.add_argument('--output', '-out', dest='output', type=str, default='output.vcf', help='output VCF file')
parser.add_argument('--input', '-in', dest='input', type=str, required=True, help='original VCF file')
parser.add_argument('--imputed', '-im', dest='imputed', type=str, help='imputed VCF file')
args = parser.parse_args()

if os.path.exists(args.input):

	markers = {}
	chrom = {}
	datablock = []

	contigs = re.compile(r'ID=(\w+\.\d+)')
	with open(args.input, 'r') as handle:
		for line in handle:
			if line.startswith('##contig=<ID='):
				m = contigs.search(line)
				if m is not None:
					chrom[m.group(1)] = line
			elif not line.startswith('#'):
				tabs = line[:-1].split('\t')
				if len(tabs) > 9 and tabs[1].isnumeric():
					if tabs[0] not in markers:
						markers[tabs[0]] = {}
					if int(tabs[1]) in markers[tabs[0]]:
						print('DUPLICATED ENTRY Chr: ' + tabs[0] + ' at ' + tabs[1])
					markers[tabs[0]][int(tabs[1])] = line
			elif line.startswith('##INFO') or line.startswith('##FORMAT') or line.startswith('#CHROM'):
				datablock.append(line)

	markers_singleton = {}
	markers_multiple = {}

	for chrm in markers:
		if len(markers[chrm]) > 1:
			markers_multiple[chrm] = markers[chrm]
		else:
			markers_singleton[chrm] = markers[chrm]

	if args.imputed is None:
		with open(args.output, 'w') as multiple:
			multiple.write('##fileformat=VCFv4.3\n')
			for chrm in sorted(markers_multiple.keys()):
				multiple.write(chrom[chrm])
			multiple.write(''.join(datablock))
			for chrm in sorted(markers_multiple.keys()):
				for marker in sorted(markers_multiple[chrm].keys()):
					multiple.write(markers_multiple[chrm][marker])
		print('bgzip -l9 ' + args.output + '\n' + 'java -jar beagle.22Jul22.46e.jar gt=' + args.output + '.gz out=output.imputed' + '\n' + 'bgzip -d output.imputed.vcf.gz' + '\n' + './split_vcf.py -in ' + args.input + ' --imputed output.imputed.vcf -out ' + args.output + '\n')

	elif args.imputed is not None and os.path.exists(args.imputed):
		markers_multiple = {}
		datablock2 = []

		with open(args.imputed, 'r') as handle:
			for line in handle:
				if not line.startswith('#'):
					tabs = line[:-1].split('\t')
					if len(tabs) > 9 and tabs[1].isnumeric():
						if tabs[0] not in markers_multiple:
							markers_multiple[tabs[0]] = {}
						if int(tabs[1]) in markers_multiple[tabs[0]]:
							print('ERRORS Chr: ' + tabs[0] + ' at ' + tabs[1])
						markers_multiple[tabs[0]][int(tabs[1])] = line
				elif line.startswith('#CHROM'):
					datablock2.append(line)

		for chrm in markers:
			if len(markers[chrm]) > 1:
				markers[chrm] = markers_multiple[chrm]
			else:
				for single in markers[chrm].keys():
					tabs = markers[chrm][single][:-1].split('\t')
					if len(tabs) > 9 and tabs[1].isnumeric():
						tabs[7] = '.'
						tabs[8] = 'GT'
						for ids in range(9, len(tabs)):
							tabs[ids] = tabs[ids][0:3].replace('/', '|')
					markers[chrm][single] = '\t'.join(tabs) + '\n'

		with open(args.output, 'w') as vcf:
			vcf.write('##fileformat=VCFv4.3\n')
			for chrm in sorted(chrom.keys()):
				vcf.write(chrom[chrm])
			vcf.write('##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">\n')
			vcf.write(''.join(datablock2))
			for chrm in sorted(markers.keys()):
				for marker in sorted(markers[chrm].keys()):
					vcf.write(markers[chrm][marker])
