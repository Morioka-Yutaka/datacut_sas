/*** HELP START ***//*

Macro: cutoff_missing
  Purpose:
    Set a target variable to missing when a reference date/datetime variable
    is strictly greater than the cutoff.
  Parameters:
    domain=       Target dataset (e.g., DM)
    ref_var=      Variable used for comparison to the cutoff (e.g., DTHDTC)
    missing_var=  Variable to set missing (e.g., DTHFL or DTHDTC)
    type=         DATE | DATETIME
  Audit:
    - Starts dataset audit, updates the target variable to missing,
      writes audit to audit_<domain>, and terminates audit.
  Usage Example:  
  %cutoff_missing(domain=dm, ref_var=DTHDTC ,missing_var=DTHFL, type=DATE);
  %cutoff_missing(domain=dm, ref_var=DTHDTC ,missing_var=DTHDTC, type=DATE);

*//*** HELP END ***/

%macro cutoff_missing(
domain=
, ref_var=
 ,missing_var=
, type=DATE);
proc datasets nolist nowarn; 
 audit &domain.; 
initiate;
quit; 
%if %upcase(&type)=DATE %then %do;
  proc sql;
     update  &domain.
     set       &missing_var = null
     where  "&cutoff__date." < &ref_var. ;
  quit;
%end;
%if %upcase(&type)=DATETIME %then %do;
proc sql;
     update  &domain.
     set       &missing_var = null
     where  "&cutoff__datetime." < &ref_var. ;
quit;
%end;
data __audit_&domain.;
 set &domain.(type=audit);
 domain=cats(upcase("&domain."));
 var=cats("&missing_var.");
 value=cats(&missing_var.);
 keep USUBJID domain var value _ATOBSNO_ _ATOPCODE_ ;
run;

proc sort data=__audit_&domain.;
by USUBJID domain var  _ATOBSNO_ _ATOPCODE_ ;
run;

proc transpose data=__audit_&domain. out=_audit_&domain.;
var value ;
by USUBJID domain var  _ATOBSNO_  ;
id _ATOPCODE_;
run;

data dummy;
length USUBJID domain var $200.  _ATOBSNO_ 8. DR DW DD _NAME_ _LABEL_ $200.;
call missing(of _all_);
stop;
run;

data _audit_&domain.;
set dummy _audit_&domain.;
if ^missing(_ATOBSNO_);
run;


proc append base=audit_&domain. data=_audit_&domain. force;
run;


proc datasets nolist ; 
 audit &domain.; 
 terminate;
quit; 

%mend;
