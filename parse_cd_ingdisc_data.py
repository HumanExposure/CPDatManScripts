## Name: parse_cd_ingdisc_data.R
## Author: Katherine A. Phillips
## Date Created: July 2015
## Purpose: Parses TXT ingredient disclosures from Church & Dwight (Arm & Hammer). The TXT
##          files are the result of using the pdftotext command on PDF files downloaded
##          directly from Church & Dwight's website (see collect_cd_ingdisc_data.R)


import os,sys,string
from glob import glob
from shutil import move, copy


def clean_file_names(path,files):

    for file in files:
         temp = file.replace("__","_")
         temp = temp.replace(" ","_")
         temp = temp.replace("(","")
         temp = temp.replace(")","")
         temp = temp.replace("-","_")
         temp = temp.lower()
         if not os.path.isfile(os.path.join(path,temp)):
            move(os.path.join(path,file),os.path.join(path,temp))
    return files



def pdf_to_text(files):

    execfile = "pdftotext.exe"

    for file in files:
        pdf = '"'+file+'"'
        cmd = " ".join([execfile,"-table","-nopgbrk",pdf])
        print cmd
        os.system(cmd)
    return

def text_to_csv(files):

    clean = lambda dirty: ''.join(filter(string.printable.__contains__, dirty))
    ofile = open("ChurchAndDwightChemicals.csv",'w')
    ofile.write("ChemicalName,SecondaryName,FunctionalUse,Rank,File\n")
    for file in files:
      # if file == files[0]:
         ifile = open(file,'r')
         record = False
         nlines = 0
         for line in ifile:
             if line == "\n": continue
             cline = clean(line)
             cline = cline.strip()
             cline = cline.lower()
             compressed = "".join([x.replace(" ","") for x in cline])
             if record:
                cline = cline.split(" "*3)
                cline = [x for x in cline if x != ""]
                cline = [x for x in cline if x.strip() != "name"]
                cline = [x.replace(",","_") for x in cline]
                cline = [x.replace("*","") for x in cline]
                cline = [x.strip() for x in cline]
                if len(cline) == 1:continue
                if len(cline) < 3:
                   if ("technical" in "".join(cline)): continue
                   if ("only" in "".join(cline)): continue
                   if ("present" in "".join(cline)): continue
                   cline.insert(1,"NA")
                   # print ",".join(cline)
                if len(cline) > 3:
                   cline = [cline[0],cline[1]," ".join(cline[2:])]
                   # print ",".join(cline)
                nlines += 1
                cline.append(str(nlines))
                cline.append(file)
                ofile.write(",".join(cline)+"\n")
             if not record:
                if ("labelnametechnicalorothernamefunction" in compressed): record = True
                # if (cline == "ingredients"): record = True
         ifile.close()
    ofile.close()
    ofile.close()
    return

def merge_files():
    ofile1 = open("ChurchAndDwightChemicals.csv","a+")
    ofile2 = open("non_pdf_data.csv","r")
    for line in ofile2:
        ofile1.write(line.lower())
    ofile1.close();ofile2.close()
    return

def main():
    os.chdir("C:/Users/kphillip/Documents/ArmAndHammer")
    pwd = os.getcwd()

    file_list = glob("*.pdf")
    n_files = len(file_list)

    file_list = clean_file_names(pwd,file_list)

    n_text_files = len(glob("*.txt"))

    if (n_text_files < n_files): pdf_to_text(file_list)

    n_text_files = len(glob("*.txt"))
    if (n_text_files == n_files):
       file_list = glob("*.txt")
       text_to_csv(file_list)
       merge_files()
    return

if __name__ == "__main__": main()
