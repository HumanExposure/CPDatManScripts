import glob
import os
import re
import csv




def readfixline(text_line, key_str):
	str_clean=[]
	str_raw = [s for s in text_line if key_str in s]
	if str_raw:
		str_raw_1 = str_raw[0].split("  ")
		for line in str_raw_1:
			if line.rstrip():
				str_clean.append(line.rstrip().lstrip())
	else:
		str_clean = [key_str, "N/A"]
	if len(str_clean)>2:
		str_clean[1] = ' '.join(str_clean[1:])
		str_clean[2:] = []
	return str_clean


###########################################
### begin to parse chemcial composition ###
###########################################

def parse_comp(text_line):
	### locate begin and end of chemcial composition table ###
	try:
		Ingredients_begin = text_line.index([s for s in text_line if "Chemical Name" in s][0])
		Ingredients_end = text_line.index([s for s in text_line if "FIRST AID MEASURES" in s][0])

	except:
		Ingredients_begin = "NA"

	if (Ingredients_begin != "NA"):

	### select table of strings ###
		Chemicals = text_line[(Ingredients_begin+2):Ingredients_end]

		###  remove empty line ###
		Chemicals_comp=[line for line in Chemicals if line.strip()]

		# print Chemicals_comp 
		# return Chemicals_comp


		### Use fixed width to parse tabular table ###
		dataline_all = []
		data_string = []
		for line in Chemicals_comp:
			dataline = [ele.strip() for ele in line.split("  ") if ele.strip()]
			if len(dataline) == 1:
				dataline = dataline+["","","",""]

			dataline_all.append(dataline)
			data_string.append([len(kk) for kk in dataline])

			# print "dataline===", dataline
		# print "dataline_all===", dataline_all
		# print "data_string===", data_string

	###############################################################################
		# ### Use fixed width to parse tabular table ###
		# columns = ((0,42), (43,67), (68,94), (95,107), (108,131))

		# dataline_all = []
		# data_string = []
		# for line in Chemicals_comp:
		# 	dataline = [line[c[0]:c[1]].strip() for c in columns]
		# 	dataline_all.append(dataline)
		# 	data_string.append([len(kk) for kk in dataline])
	###############################################################################
		# 	# print "dataline====", dataline

		### find wrapped lines by checing each line contains 
		# zero_index = [j for j in range(len(data_string)) if 0 in data_string[j]]
		zero_index = []
		for j in range(len(data_string)):
			if 0 in data_string[j]:
				zero_index.append(j)

		# print "zero_index===", zero_index


		### group wrappinged lines into one list, which will be assembled later ###
		from operator import itemgetter
		from itertools import groupby
		wrap_line_index = [map(itemgetter(1), g) for k, g in groupby(enumerate(zero_index), lambda (i,x):i-x)]
		# print "wrap_line_index===", wrap_line_index

		for z in wrap_line_index:
			z.insert(0, z[0]-1)
		# print "wrap_line_index===", wrap_line_index

		wrap_line_pool_index = [item for sublist in wrap_line_index for item in sublist]
		# print "wrap_line_pool_index===", wrap_line_pool_index

		### find non wrapped lines ###
		non_wrap_line_index = list(set(range(len(Chemicals_comp))) - set(wrap_line_pool_index))
		# print "non_wrap_line_index===", non_wrap_line_index

		non_wrap_line_index = [[i] for i in non_wrap_line_index]
		# print "non_wrap_line_index===", non_wrap_line_index

		### combine wrapped and non-wrapped line indices and sort ###
		full_line_index = non_wrap_line_index+wrap_line_index
		full_line_index.sort(key=lambda x: x[0])
		# print "full_line_index===", full_line_index

		full_table_content = []
		for zz in full_line_index:
			# print "zz==", zz
			temp = [' '.join(l) for l in zip(*[dataline_all[k] for k in zz])]
			# print "temp==", temp
			clean_str_all = []
			for z1, z2 in enumerate(temp):
				if z1==0:
					clean_str_all.append(z2)
				elif z1!=4:
					clean_str_all.append(''.join(z2.split()))
				elif z1==4:
					str_ele=''.join(z2.split())
					clean_str_all.append(str_ele)
					clean_str_all.extend(str_ele.split("-"))
			clean_str_all.append("Weight %")
			full_table_content.append(clean_str_all)
	else:
		full_table_content = [[]]
	return full_table_content


def final_MSDS_out(text_line, parse_comp_all, file_url):
	final_header = []

	Product_Name = readfixline(text_line[1:30], "Product Name")
	Product_ID = readfixline(text_line[1:30], "Product ID")
	Product_Type = readfixline(text_line[1:30], "Product Type")
	Recommended_Use = readfixline(text_line[1:30], "Recommended Use")
	Restrictions_on_Use = readfixline(text_line[1:30], "Restrictions on Use")
	UPC = readfixline(text_line[1:30], "UPC")
	Manufacturer = readfixline(text_line[1:30], "Manufacturer")

	MSDS_header_begin = ["Product Name", "Product ID", "Product Type", "Recommended Use", "Restrictions on Use", "UPC", "Manufacturer"]
	MSDS_header_end = ["Link to original data source", "PDF Name", "ICF"]
	table_header = ["Chemical Name", "Synonyms", "Trade Secret", "CAS-No", 
		            "Concentration or composition", "Minimum concentration or composition", "Maximum concentration or composition",
		            "Unit"]
	MSDS_header = MSDS_header_begin + table_header + MSDS_header_end
	# print file_url
	MSDS_common_begin = [Product_Name[1], Product_ID[1], Product_Type[1], Recommended_Use[1], Restrictions_on_Use[1], UPC[1], Manufacturer[1]]
	MSDS_common_end = [file_url[0], file_url[1], "ICF"]

	MSDS_all = [MSDS_header]

	for line in parse_comp_all:
		line = MSDS_common_begin + line + MSDS_common_end
		# print "line==", line

		MSDS_all.append(line)
	return MSDS_all


def natural_sort(l): 
    convert = lambda text: int(text) if text.isdigit() else text.lower() 
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
    return sorted(l, key = alphanum_key)



path = "I:/Dropbox/_ICF_project/WA 0-37/MSDS_extraction/P_G_text"
# fname = 'C:/Users/33855/Dropbox/_ICF_project/WA 0-37/MSDS_extraction/test/1_DREFT_powder-table.txt'
# fname = 'I:/Dropbox/_ICF_project/WA 0-37/MSDS_extraction/test/1_DREFT_powder-table.txt'
os.chdir(path)


import csv
with open('P_G_URL_name_list.csv', 'rb') as f:
    reader = csv.reader(f)
    p_g_url_list = list(reader)

all_text = glob.glob("*.txt")
all_text_sort = natural_sort(all_text)
all_text_sort_1 = all_text_sort


for fname in all_text_sort_1:
	file_url = p_g_url_list[int(fname.split("_")[0])-1][1:3]

	# print p_g_url_list[fname.split("_")[0]]
	with open(fname) as f:
	    content = f.readlines()

	parse_comp_all = parse_comp(content)

	try:
		MSDS_all = final_MSDS_out(content, parse_comp_all, file_url)
		fname_out = fname.split("_")[0]+".csv"
		with open(fname_out, "wb") as f:
		    writer = csv.writer(f)
		    writer.writerows(MSDS_all)
	except:
		print fname



# 	print "temp==", temp

	# clean_str_all = []
	# for z1, z2 in enumerate(temp):
	# 	if z1==0:
	# 		clean_str_all.append(z2)
	# 	elif z1!=4:
	# 		clean_str_all.append(''.join(z2.split()))
	# 	elif z1==4:
	# 		str_ele=''.join(z2.split())
	# 		clean_str_all.append(str_ele)
	# 		clean_str_all.extend(str_ele.split("-"))
	# clean_str_all.append("Weight %")
	# full_table_content.append(clean_str_all)



# CAS Number
# Chemical name
# Product Name
# Product UPC
# Type of product
# Maximum concentration or composition
# Minimum concentration or composition
# Concentration or composition
# Units for concentration/composition
# Functional use in product (e.g., surfactant,fragrance)
# Manufacturer
# Link to original data source
# Data collected
# Collected by whom (eg., "ICF")
# PDF or txt-formatted MSDS for archival (if available)

