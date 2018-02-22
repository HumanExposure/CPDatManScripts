
libname dat "L:\Lab\NERL_Isaacs\kki-14-GENERIC_PRODUCT_FORMULATIONS\INCI Scrub\SASOUTPUT";


%macro read_all_inci;

%do i=1 %to 646;

proc import datafile="L:\Lab\NERL_Isaacs\kki-14-GENERIC_PRODUCT_FORMULATIONS\INCI Scrub\index.aspx@p=&i" dbms=TAB out=ImportFile replace;
datarow=1
guessingrows=800;
getnames=no;
run;

  data tmp&i;
   set Importfile;
   LENGTH namestr $200 CASstr $200 functionstr $1000 name $100 cas $200 function $500;
   retain namestr  CASstr  functionstr name cas function;
   if index(var1, "ingredient.aspx")>0 then do;
      namestr=var1;
    end; 
   if index(var1, "inciresultcelltd")>0 then do;
      casstr=var1;
    end; 
    if index(var1, "index.aspx?function=")>0 then do;
      functionstr=var1;
     *process name, CAS, ingredients;

	  k1=index(namestr,"properties")+12;
	  k2=index(namestr,"</a>")-k1;
	  name=substr(namestr,k1,k2);
     
	  k1=index(CASstr,">")+1;
	  k2=index(CASstr,"</td>")-k1;
	  CAS=substr(CASstr,k1,k2);

	  k1=index(CASstr,">")+1;
	  k2=index(CASstr,"</td>")-k1;
	  CAS=substr(CASstr,k1,k2);

	  function=compress(functionstr,'ABCDEFGHIJKLMNOPQRSTUVWXYZ|','k');

	  output;
       namestr="";
       casstr="";
       functionstr="";
    end;     

   keep cas name function;

  run;

%end;

%mend;

%read_all_inci;

%macro mergeit;

data alldata;
set 

%do i=1 %to 646;

tmp&i

%end;
;
run;

%mend;
%mergeit;

data dat.alldata_raw;
set alldata;
run;





*process to separate out multiple CAS numbers into records;

data alldata2;
set dat.alldata_raw;
if cas="&nbsp;" then delete; *remove missing CAS;

*count cas numbers;
k=compress(cas,"/",'k');
numcas=1;
if k ne "" then numcas=length(trim(left(k)))+1;
if numcas> 1 then do;
 *process;
   oldcas=cas;
   do i=1 to numcas;
     cas=scan(oldcas,i,"/");
     output;
   end;
end;
else do;
  output;
end;
run;

proc sort data=   alldata2; by CAS; run; 
*save as list with all uses as one record;

data dat.alldata_uses_as_one_record;
  set alldata2;
  by cas;
  if trim(left(name="DIATOMACEOUS EARTH")) then delete;
  if first.cas then output;
  keep name cas function;
run;






*create dataset with single functions;
data dat.Alldata_chemswithonefunction;
set alldata2;
if index(function,"|")=0 then output;
keep name cas function;
run;

*process to separate out multiple functional uses into records;

data alldata3;
set alldata2;

*count functions;
k=compress(function,"|",'k');
numf=1;
if k ne "" then numf=length(trim(left(k)))+1;
if numf> 1 then do;
 *process;
   oldf=function;
   do i=1 to numf;
     function=scan(oldf,i,"|");
     output;
   end;
end;
else do;
  output;
end;
run;

data dat.alldata_processed;
set alldata3;
if trim(left(name="DIATOMACEOUS EARTH")) then delete;
keep name cas function;
run;

proc sort data=alldata3; by cas; run;

data dat.chemlist;
  set alldata3; by cas;
  if trim(left(name="DIATOMACEOUS EARTH")) then delete;
  if first.cas then output;
  keep cas name;
run;

*clean up cas;
data dat.alldata_processed;
set dat.alldata_processed;
cas=trim(left(cas));
run;
proc sort data=dat.alldata_processed; by cas; run;



%let funclist=SKINCONDITIONING:
PERFUMING:
SURFACTANT:
EMULSIFYING:
EMOLLIENT:
HAIRCONDITIONING:
MASKING:
CLEANSING:
VISCOSITYCONTROLLING:
ANTISTATIC:
FILMFORMING:
ANTIOXIDANT:
SOLVENT:
HUMECTANT:
SKINPROTECTING:
TONIC:
ASTRINGENT:
ANTIMICROBIAL:
EMULSIONSTABILISING:
FOAMBOOSTING:
BINDING:
HAIRDYEING:
ABRASIVE:
COSMETICCOLORANT:
BUFFERING:
FOAMING:
PRESERVATIVE:
OPACIFYING:
BULKING:
HYDROTROPE:
ORALCARE:
SOOTHING:
CHELATING:
DEODORANT:
ABSORBENT:
PLASTICISER:
UVABSORBER:
ANTICAKING:
FLAVOURING:
HAIRFIXING:
MOISTURISING:
REDUCING:
REFRESHING:
STABILISING:
ANTIDANDRUFF:
HAIRWAVINGORSTRAIGHTENING:
DENATURANT:
BLEACHING:
ANTIPLAQUE:
SMOOTHING:
ANTIPERSPIRANT:
DEPILATORY:
UVFILTER:
ANTISEBORRHOEIC:
GELFORMING:
OXIDISING:
ANTICORROSIVE:
NAILCONDITIONING:
REFATTING:
ANTIFOAMING:
KERATOLYTIC:
PROPELLANT:
NOTREPORTED:
DETANGLING:
PEARLESCENT:
TANNING:
;


*MAKE DATASET FOR YES/NO MODELS;
options mprint;

*clean up cas;
data dat.Alldata_uses_as_one_record;
  set dat.Alldata_uses_as_one_record;
  cas=trim(left(cas));
run;

%macro  binary;
data dat.function_binary;
  set dat.Alldata_uses_as_one_record;
  %do i=1 %to 66; *numfuncs;
    %let func=%scan(&funclist, &i,":");
    if index(function,"&func")>0 then &func="YES";
    else &func="NO";
	keep &func;
 %end;
  keep name cas ;
run;

%mend;
%binary;


