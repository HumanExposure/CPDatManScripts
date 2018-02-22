## Name: collect_palmo_fuse_data.R
## Author: Katherine A. Phillips
## Date Created: July 2015
## Purpose: Collects Palmolive functional use data from a text file resulting from copying
##          and pasting HTML table found on webpage.

import os,sys,string

def text_to_csv(file):

    clean = lambda dirty: ''.join(filter(string.printable.__contains__, dirty))

    ## Open file with data
    ifile = open(file,'r')

    ## Open file for writing parsed data
    ofile = open("PalmoliveIngredients.csv",'w')

    ## Write the headers for the file
    ofile.write("ChemicalName,FunctionalUse,Rank,Product\n")

    ## Loop over the lines in the text file
    for line in ifile:

        ## Get the columns from the line of the file
        cline = clean(line)
        cline = cline.strip()
        cline = cline.lower()
        cline = cline.split("\t")

        ## Find out if the row only contains the product name, if it does, clean it and
        ## store it for writing with the ingredients.
        if len(cline) == 1:
           nchems = 0
           product = cline[0].lower()
           product = product.replace(",","")
           product = product.replace("+","and")
           product = product.replace("&","and")
           product = product.replace(" ","_")

        ## Get the ingredients and add stored product name to elements in row
        if len(cline) != 1:
           comp = "".join([x.replace(" ","") for x in cline])
           if (comp == "ingredient(inciname)purpose"): continue
           nchems += 1
           cline.append(str(nchems))
           cline.append(product)

            ## write information to row in csv file
           ofile.write(",".join(cline)+"\n")

    ## Close input and output files
    ifile.close()
    ofile.close()
    return

def main():

    text_to_csv("ingredients.txt")

    return

if __name__ == "__main__": main()
