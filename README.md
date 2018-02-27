# CPDatManScripts
Download scripts documented in the CPDat manuscript, for Scientific Data.

The data included in CPDat were collected over an 8-year time period using a variety of methods and organizations, including contract vehicles.  In some cases, these downloads were multi-step processes that involved (for example), 1) scraping a list of available PDF file names from the original data sources, 2) using specialized scripts to generation additional download scripts from the file list, 3) perform the final download of all data 4) translate PDF files to text, and 5) generate scripts to parse data and perform quality assurance. In those cases, we have attempted to capture the actual workflows and scripts.  In other cases, data downloads were performed interactively from command windows using command-line tools (e.g. wget). We also provide examples in these cases. 

MSDS Data

1) CPCPdb  
The CPCPdb MSDS data included in CPDat were downloaded directly from the EPA’s ACToR database. Methods for the collection of this data (which involved a custom-designed interactive curation interface) have been previously published (Goldsmith et al. 2014). 

2) MSDS Data from Proctor and Gamble  
ProcterGambleLinks.R (R code to generate a list of links to Procter and Gamble MSDS sheets for downloading the MSDS, and converting to .txt files)  
pdfminder_PG.py (Python code for analyzing the downloaded Procter and Gamble MSDS sheets and extracting to Excel spreadsheets)

3) MSDS Data from Unilever  
Unilever.R (R code to generate a list of links Unilever MSDS sheets for downloading the MSDS, and converting to .txt files)  
Unilever.py (Python code for analyzing the downloaded Unilever MSDS sheets and extracting to Excel spreadsheets)

Function (FUse) Data

1) EU Inventory of Cosmetic Ingredients (INCI) data  
Inci.bat (Batch file to download INCI HTML files using wget utility)  
Processinci.sas (SAS code to process downloaded INCI HTML files)

2) SpecialChem Data (including Adhesives, Coatings, Cosmetics, and Polymer Additives)  
getadhesives.bat (Batch file to download SpecialChem Adhesives functional use data)  
getomnexus.bat (Batch file to download SpecialChem Plastics and Elastomers functional use data)  
getpolymers.bat (Batch file to download SpecialChem Polymer Additives functional use data)  
clean_specialchem_adhesives.R (R file to clean SpecialChem Adhesives functional use data)  
clean_specialchem_coatings.R (R file to clean SpecialChem Coatings functional use data)  
clean_specialchem_cosmetics.R (R file to clean SpecialChem Cosmetics functional use data)  
clean_specialchem_polyadds.R (R file to clean SpecialChem Polymer Additives functional use data)  

3) American Cleaning Institute’s Ingredient Inventory  
clean_aci_fuse_data.R (R file to clean ACI’s functional use data)

4) Fl@vouring Substances Database (Fl@vis)  
clean_flavis_fuse_data.R	(R file to clean Fl@vis functional use data)

5) EPA’s Safer Choice Ingredient List (SCIL)  
clean_scil_fuse_data.R	(R file to clean SCIL functional use data)

6) International Fragrance Association’s Fragrance List  
collect_ifra_fuse_data.R	(R file to collect and clean IFRA’s fragrance list)

7) Method  
collect_method_fuse_data.R	(R file to collect and clean method’s ingredient functional use information)

8) Palmolive  
collect_palmo_fuse_data.py	(Python file to collect and parse information on Palmolives’ functional use information)

9) SC Johnson  
collect_scjohn_fuse_data.R	(R file to collect information from SC Johnson about ingredient functional use; data was then manually curated)

Ingredient List Data

1)	Church and Dwight  
collect_cd_ingdisc_data.R	(R file to download ingredient disclosures from Church & Dwight)  
parse_cd_ingdisc_data.py	(Python file to parse downloaded disclosures into data set)

2)	Clorox  
collect_clorox_ingdisc_data.R	(R file to collect and parse ingredient disclosure forms from Clorox)

3)	Procter and Gamble  
collect_pg_ingdisc_urls.R	(R file to download ingredient disclosures from Procter and Gamble)  
parse_pg_ingdisc_data.py	(Python file to parse disclosures into data set)

4)	Unilever (UK)  
collect_unil_ingdesc_htmls.R	(R file to download ingredient disclosures from Unilever)  
parse_unil_ingdesc_data.R	(R file to parse disclosures into data set)  

5) Drugstore.com  
download_drugstore.R  (R file access, download, and parse product pages (HTML) from Drugstore.com)  
processdata.R (R file to parse downloaded HTML data into data set)

