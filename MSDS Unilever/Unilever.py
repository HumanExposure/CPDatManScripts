import glob
import os
import re
import csv

###########################################
### begin to parse chemcial composition ###
###########################################

def parse_comp(text_line):
	### locate begin and end of chemcial composition table ###
	try:
		Ingredients_begin = text_line.index([s for s in text_line if "Ingredients as defined by 29 CFR" in s][0])
		Ingredients_end = text_line.index([s for s in text_line if "SECTION IV" in s][0])
	except:
		try:
			Ingredients_begin = text_line.index([s for s in text_line if "Active ingredient" in s][0])
			Ingredients_end = text_line.index([s for s in text_line if "SECTION IV" in s][0])
		except:
			Ingredients_begin = "NA"
			Ingredients_end = "NA"

	dataline_all = []

	if (Ingredients_begin != "NA"):
		### select table of strings ###
		Chemicals = text_line[(Ingredients_begin+4):(Ingredients_end-1)]

		###  remove empty line ###
		Chemicals_comp=[line for line in Chemicals if line.strip()]

		### Use fixed width to parse tabular table ###
		for line in Chemicals_comp:
			dataline = [ele.strip() for ele in line.split("  ") if ele.strip()]
			if len(dataline) != 3:
				empty = 3-len(dataline)
				dataline = dataline+empty*[""]
			dataline_all.append(dataline)

	return dataline_all


def final_MSDS_out(text_line, parse_comp_all, exter_info):
	final_header = []

	Product_Name = exter_info[1]
	Product_ID = exter_info[3]
	Product_Type = "N/A"
	Recommended_Use = "N/A"
	Restrictions_on_Use = "N/A"
	UPC = "N/A"
	Manufacturer = exter_info[2]
	URL = exter_info[4]
	PDF_name = exter_info[5]
	
	MSDS_header_begin = ["Product Name", "Product ID", "Product Type", "Recommended Use", "Restrictions on Use", "UPC", "Manufacturer"]
	MSDS_header_end = ["Link to original data source", "PDF Name", "ICF"]
	table_header = ["Chemical Name", "Synonyms", "Trade Secret", "CAS-No", 
		            "Concentration or composition", "Minimum concentration or composition", "Maximum concentration or composition",
		            "Unit"]
	MSDS_header = MSDS_header_begin + table_header + MSDS_header_end
	MSDS_common_begin = [Product_Name, Product_ID, Product_Type, Recommended_Use, Restrictions_on_Use, UPC, Manufacturer]
	MSDS_common_end = [URL, PDF_name, "ICF"]

	MSDS_all = [MSDS_header]

	for line in parse_comp_all:
		line = MSDS_common_begin + line + MSDS_common_end
		MSDS_all.append(line)
	return MSDS_all

# function to sort string and numbers #
def natural_sort(l): 
    convert = lambda text: int(text) if text.isdigit() else text.lower() 
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
    return sorted(l, key = alphanum_key)

path = "I:/Dropbox/_ICF_project/WA 0-37/MSDS_extraction/UNL_text"
os.chdir(path)

### UNL_namelist.xlsx contains product name, MSDS #, and URL to the MSDS file ###
with open('UNL_namelist.csv', 'rb') as f:
    reader = csv.reader(f)
    p_g_url_list = list(reader)

all_text = glob.glob("*.txt")
all_text_sort = natural_sort(all_text)
all_text_sort_1 = all_text_sort

# begin to parse chemcial composition table in a loop #
for fname in all_text_sort_1:
	exter_info = p_g_url_list[int(fname.split(".txt")[0])-1]
	with open(fname) as f:
	    content = f.readlines()
	parse_comp_all = parse_comp(content)

	try:
		MSDS_all = final_MSDS_out(content, parse_comp_all, exter_info)
		fname_out = fname+".csv"
		with open(fname_out, "wb") as f:
		    writer = csv.writer(f)
		    writer.writerows(MSDS_all)
	except:
		print fname
