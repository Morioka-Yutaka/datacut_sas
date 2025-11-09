/*** HELP START ***//*

Macro: cutoff_setting
  Purpose:
    Initialize the cutoff environment:
      - Save cutoff date/datetime to global macro variables
      - Clear WORK and target OUTLIB (optional) libraries
      - Copy all datasets from input library to WORK
  Parameters:
    inlib=           Path or libref of the input library to copy from
    outlib=          Path or libref of the output library to export later
    cutoff_date=     Cutoff date in ISO 8601 (YYYY-MM-DD)
    cutoff_datetime= Cutoff datetime in ISO 8601 (YYYY-MM-DDThh:mm[[:ss]])
  Globals Created:
    cutoff__date, cutoff__datetime
  Side Effects:
    - Deletes all DATA members in WORK (and DATA members in c_outlib)
    - Creates librefs c_inlib and c_outlib
  Notes:
    - This macro does not perform any transformations, only environment setup.
  Usage Example:  
      %cutoff_setting(
      inlib = D:\in
      ,outlib=D:\out
      ,cutoff_date=2025-11-01
      ,cutoff_datetime=2022-11-01T00:00
      );

*//*** HELP END ***/

%macro cutoff_setting(
inlib =
,outlib=
,cutoff_date=
,cutoff_datetime=
);

libname c_inlib "&inlib";
libname c_outlib "&outlib";
%global cutoff__date cutoff__datetime;
%let cutoff__date=&cutoff_date;
%let cutoff__datetime=&cutoff_datetime;

proc datasets lib=work kill nolist memtype=data;
quit;
proc datasets lib=c_outlib kill nolist memtype=data;
quit;

proc copy inlib=c_inlib outlib=work;
run;
%mend;
