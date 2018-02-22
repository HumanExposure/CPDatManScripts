#!/usr/bin/env python

## Name: parse_pg_ingdisc_data.py
## Author: Katherine A. Phillips
## Date Created: Sep 2015
## Purpose: Parses text from Proctor and Gamble Ingredient Disclosures that were collected
##          from the P&G website as PDF files. The PDFs were then converted to TXT files
##          using the pdftotext.exe application with the following command:
##          pdftotext.exe -table -nopgbrk foo.pdf


import os     ## Allows operating system commands to be performed though Python
import sys    ## Allows you to exit a Python script for testing
import shutil ## Allows movement of files from one directory to another
import string ## Fancy string manipulations
import  glob  ## Global searching of strings as files

## Function to check that there are no un-printable characters in a line
clean = lambda dirty: ''.join(filter(string.printable.__contains__, dirty))

## Change to the current working directory
pwd = ["C:/Users/kphillip/Documents/",
       "FunctionalUseConcentrationCollection/",
       "Procter_and_Gamble_Ingredients/ScrapedFiles"]
os.chdir("".join(pwd))
pwd = os.getcwd()

## Within the current working directory there is a folder containing all of the
## text files that came from the downloaded PDFs
files = glob.glob("TXTs/*.txt")

## I want to store all of the information that I am going to scrape from the TXT
## files in a CSV file, so I will open that up for writing
ofile = open("Proctor_and_Gamble.csv",'w')

## Write the column headers for the file
ofile.write("ChemicalName,FunctionalUse,ChemicalRank,RawFilePath,ScrapedTextFile\n")


## These are MSDSs and have none of the information we need
## I only found this out by trial and error. I am aadding them to this list, so
## that as I build the parser, I can skip them for parsing.
msds_list = ["ingredients_swiffer_bissell_steamboost_pad_sds_061013_final_pdf",
             "ingredients_swiffer_dry_sheets_and_dusters_msds_final",
             "ingredients_swiffer_furniturespray_msds_jan_13",
             "ingredients_swiffer_wet_jet_ab_cleaner_msds_1011",
             "ingredients_swiffer_wet_msds_final",
             "ingredients_swiffer_wetjet_multipurpose_cleaner_msds_final",
             "ingredients_swiffer_wetjet_wood_cleaner_msds_final"]


## Crest products are in a completely different form than any other product list
## -- they need a different script to process them. So they are in another list
## that will get skipped for now.
crest_list = ["ingredients_crest_complete_multibenefit_toothpastes",
              "ingredients_crest_pro_health_toothpastes",
              "ingredients_crest_prohealth_mouthwash_and_rinse",
              "ingredients_fixodent",
              "ingredients_kids_crest",
              "ingredients_crest_3d_toothpaste",
              "ingredients_crest_3d_white_crest_whitening_rinses",
              "ingredients_crest_3d_white_polishing_treatment",
              "ingredients_crest_baking_soda_and_peroxide_family_protection_whitening_expressions_whitening_plus_scope_toothpastes",
              "ingredients_crest_be_toothpaste",
              "ingredients_crest_cavity_protection_toothpaste",
              "ingredients_crest_sensitive_toothpastes",
              "ingredients_crest_tartar_control_tartar_protection_gels_toothpastes",
              "ingredients_crest_whitestrips"]



## Again, I've found out these products' disclosures cover multiple pages by
## trial and error and have added them to a list so that I can handle them
## separately
multipage_list = ["ingredients_liq_tide_plus_with_febreze_freshness_sport_he_active_fresh",
                  "ingredients_cheer_bright_clean_he_fresh_clean_scent"]

## This one is strange becasue it does not list the function of each ingredient
## in the product, but rather groups of chemicals in the product. As I cannot be
## certain which chemical does what, I will skip this disclosure.
norecord = ["ingredients_swiffer_sweeper_wet_cloths_all_varieties"]
for file in files:

    ## Drop the file path from the file
    basename = os.path.basename(file)[:-4]

    ## If the file is on the msds_list, skip it
    if (basename in msds_list): continue

    ## If the file is on the crest_list, skip it
    if (basename in crest_list): continue

    ## IF the file is on the multipage_list, skip it
    if (basename in multipage_list): continue

    ## If the file is on the norecord list, skip it
    if (basename in norecord): continue

    ## Now, get rid of dashes in the product file name
    product = basename.replace("-","")

    ## Split the product name by underscores. For example,
    ## >>"ingredients_swiffer_sweeper_wet_cloths_all_varieties.pdf".split("_")
    ##   ['ingredients','swiffer','sweeper','wet','cloths','all','varieties.pdf']
    product = product.split("_")

    ## This is the product string that you will likely see in the text file
    ## This gets used as a key for searching for where the ingredient list
    ## starts in a file.
    product = "".join(product[-3:]).lower()


    ## Okay, finally open up the file that you want to extract information from
    ifile = open(file,'r')

    ## Assume that we do not want to record any information from this file,
    ## until we have found an ingredient list in the file
    record = False

    ## Reset the line number counter for the file
    nlines = 0

    ## Loop over all of the lines in the file
    for line in ifile:

        ## There are some lines that are just blank lines, skip them
        if line == "\n": continue

        ## Okay, the first function in this file cleans any un-printable
        ## characters from a string, so run that on each non-blank line
        cline = clean(line)

        ## Make all of the letters lower-cased,
        ## so that case is uniform throughout
        cline = cline.lower()

        ## Replace punctuation marks with underscores,
        ## so that strings have uniform marks
        cline = cline.replace(",","_")
        cline = cline.replace(";","_")

        ## Sometimes the product name will have "click here for more information"
        ## following its name, just keep the product name
        cline = cline.split("click")[0]

        ## Get rid of whitespace before and after the remainder of the line
        cline = cline.strip()

        # print cline
        ## Get rid of spaces in a line, this is used to check if the product
        ## name is on the current line or if the word ingredient is on the line
        tline = "".join(cline.split())

        ## The next two commands essentially get rid of two consecutive spaces
        ## on a line, and leaves the line as a list of strings on either side of
        ## the consecutive spaces. I do this because the chemicals and their
        ## functions get translated as two columns with a lot of space between
        ## them. For example, if cline looked like this:
        ## 'citric acid                                        captures soil'
        ## Then is would look like this after the next two commands:
        ## ['citric acid','captures soil']
        ## which is, conveniently, an ingredient at the 0-element and function
        ## at the 1-element.
        cline = cline.split("  ")
        cline = [x.strip() for x in cline if x != ""]

        ## Here's what to do with cline if you are recording information about
        ## the product (i.e., record = True)
        if record:

            ## Only deal with lines with more than one word on the line
            if (len(cline) > 1):
                ## But really, I only want clines that have a chemical-function
                ## pair
                if (len(cline) == 2):

                    ## nlines is keeping track of the order of the ingredient on
                    ## the ingredient list in the file
                    nlines += 1

                    ## So, cline now has
                    ## chemical as 0-element,
                    ## function as 1-element
                    ## but I will append the ingredient list order as 2-element,
                    ## the pdf file name as 3-element,
                    ## and the converted text file as 4-element
                    cline.append(str(nlines))
                    cline.append(os.path.join(pwd,"PDFs",basename+".pdf"))
                    cline.append(os.path.join(pwd,file))

                    ## Now write cline, as a comma separated line to the csv file
                    ofile.write(",".join(cline)+"\n")

                ## By trial and error, if len(cline) != 2, it is usually not an
                ## ingredient, so skip it, but print it so that you know why it
                ## it was skipped
                else:
                    if ("for more information" in cline[0]):continue
                    print cline

        ## If you are not recording the information in the file to open csv file
        ## (i.e., record=False), the keep scanning to look for the beginning of
        ## the ingredient list.
        if not record:

            ## Beginning of the table is usually set of by a title that says
            ## either the name of the product, or contains the word "ingredient"
            ## but due to the conversion of the PDF to a TXT, there is usually a
            ## large space in the middle of this line, so cline's length should
            ## be equal to 2 first only for this line when record = False
            if (len(cline) == 2):
                if ("ingredient" in tline.lower()):
                     record = True
                elif (product in tline.lower()):
                     record = True

    ## If you couldn't find an ingredient list in the file by the end, add the
    ## file name to the norecord list
    if not record: norecord.append(basename)

    ## close the file for reading
    ifile.close()

## These were collected from norecord and modified so that information can be
## scraped
## The parsing is very similar to the loop above.
files = glob.glob("BadTXTs/*.txt")
badfiles = ["Ingredients_Swiffer_Bissell_SteamBoost62013.txt",
            "Ingredients_Perfume_and_Scents.txt",
            "Ingredients_Flavor1.txt"]
print("\n\n\n")
for file in files:
    if os.path.basename(file) in badfiles: continue
    ifile = open(file,'r')
    nlines = 0
    for line in ifile:
       cline = clean(line)
       if ("  " in cline):
          cline = cline.strip()
          cline = cline.replace(",","_")
          cline = cline.split("  ")
          cline = [c.strip() for c in cline if c!= ""]
          nlines += 1
          cline.append(str(nlines))
          cline.append(os.path.join(pwd,"PDFs",os.path.basename(file)[:-4]+".pdf"))
          cline.append(os.path.join(pwd,file))
          ofile.write(",".join(cline)+"\n")
    ifile.close()
ofile.close()
