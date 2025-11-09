# datacut_sas
SAS macros to prepare SDTM for data-cut analyses: remove post-cutoff records, overwrite with the cutoff date/time, drop subjects, and null flags. Supports multiple cutoff operations and generates an Excel report summarizing all applied changes.

<img width="360" height="360" alt="Image" src="https://github.com/user-attachments/assets/882b5390-e3cf-4a81-8a33-091db49217c8" />

## Example
### test data
~~~sas
libname c_inlib "D:\in";
data c_inlib.dm;
length USUBJID RFSTDTC RFXSTDTC RFPENDTC DTHDTC DTHFL $200.;
USUBJID="A-001";RFSTDTC="2025-11-02";RFXSTDTC="2025-11-02T10:00";RFPENDTC="2025-12-01";DTHDTC="";DTHFL="";output;
USUBJID="A-002";RFSTDTC="2025-10-01";RFXSTDTC="2025-10-01T10:00";RFPENDTC="2025-10-30";;DTHDTC="";DTHFL="";output;
USUBJID="A-003";RFSTDTC="2025-10-02";RFXSTDTC="2025-11-02T10:00";RFPENDTC="2025-12-01";;DTHDTC="";DTHFL="";output;
USUBJID="A-004";RFSTDTC="2025-10-05";RFXSTDTC="2025-10-12T10:00";RFPENDTC="2025-12-05";;DTHDTC="2025-12-05";DTHFL="Y";output;
USUBJID="A-005";RFSTDTC="";RFXSTDTC="";RFPENDTC="";DTHDTC="";DTHFL="";output;
USUBJID="A-006";RFSTDTC="";RFXSTDTC="";RFPENDTC="";DTHDTC="";DTHFL="";output;
run;
data c_inlib.ae;
length USUBJID AESTDTC  $200.;
USUBJID="A-003";AESTDTC="2025-11-02";output;
USUBJID="A-004";AESTDTC="2025-10-10";output;
run;
data c_inlib.ts;
TSPARAMCD="ACTSUB";
run;
~~~
<img width="160" height="142" alt="Image" src="https://github.com/user-attachments/assets/1a9696ad-6957-4d3d-872a-94217746bfab" /> 
<img width="579" height="178" alt="Image" src="https://github.com/user-attachments/assets/0b3ac31a-8f3b-4ceb-977d-ae38a25f12f4" />  
 
~~~sas
/*Setting and All SDTM Datasets import to Work*/
%cutoff_setting(
inlib = D:\in
,outlib=D:\out
,cutoff_date=2025-11-01
,cutoff_datetime=2022-11-01T00:00
);

/*------
 DM domain
------*/
/*Change the flag and death date to missing for deaths occurring after the cutoff date*/
%cutoff_missing(domain=dm, ref_var=DTHDTC ,missing_var=DTHFL, type=DATE);
%cutoff_missing(domain=dm, ref_var=DTHDTC ,missing_var=DTHDTC, type=DATE);
/*List dataset for deletion at USUBJID level*/
data dlds;
length USUBJID $200.;
USUBJID="A-005";output;
USUBJID="A-006";output;
run;
/*Delete at the participant level based on the list dataset*/
%delete_participants(domain=dm ,delete_list_ds=dlds);
/*Delete records with RFSTDTC after the cutoff date*/
%cutoff_delete(domain=dm, var=RFSTDTC, type=DATE);
/*Overwrite the RFPENDTC that has been exceeded by the cutoff date with the cutoff date.*/
%cutoff_overwrite(domain=dm, var=RFPENDTC, type=DATE);
/*Overwrite the RFXSTDTC that has been exceeded by the cutoff datetime with the cutoff datetime.*/
%cutoff_overwrite(domain=dm, var=RFXSTDTC, type=DATETIME);
/*------
AE domain
------*/
/*Delete at the participant level based on the list dataset*/
%delete_participants(domain=ae ,delete_list_ds=dlds);
/*Delete records with AESTDTC after the cutoff date*/
%cutoff_delete(domain=ae, var=AESTDTC, type=DATE);
/*------
Export and Report output
------*/
/*Move all datasets in Work to the cutoff data output library and generate a cutoff processing report.*/
%output_and_report(report_path=D:\out, exclude=dlds);

~~~

## `%cutoff_setting()` macro <a name="cutoffsetting-macro-4"></a> ######
  Purpose:　　
    Initialize the cutoff environment:  
      - Save cutoff date/datetime to global macro variables  
      - Clear WORK and target OUTLIB (optional) libraries  
      - Copy all datasets from input library to WORK  
  Parameters:  
  ~~~text
    inlib=           Path or libref of the input library to copy from
    outlib=          Path or libref of the output library to export later
    cutoff_date=     Cutoff date in ISO 8601 (YYYY-MM-DD)
    cutoff_datetime= Cutoff datetime in ISO 8601 (YYYY-MM-DDThh:mm[[:ss]])
~~~
  Globals Created:  
    cutoff__date, cutoff__datetime
  Side Effects:  
    - Deletes all DATA members in WORK (and DATA members in c_outlib)  
    - Creates librefs c_inlib and c_outlib  
  Notes:  
    - This macro does not perform any transformations, only environment setup.  
  Usage Example:    
  ~~~sas
      %cutoff_setting(
      inlib = D:\in
      ,outlib=D:\out
      ,cutoff_date=2025-11-01
      ,cutoff_datetime=2022-11-01T00:00
      );
~~~

  
---
