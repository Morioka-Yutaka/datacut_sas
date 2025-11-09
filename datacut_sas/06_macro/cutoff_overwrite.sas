/*** HELP START ***//*

Purpose:
    Overwrite values in a date/datetime variable with the cutoff value when
    the existing value is strictly greater than the cutoff.
  Parameters:
    domain=   Target dataset (e.g., DM)
    var=      Variable to overwrite (e.g., RFSTDTC/RFPENDTC/RFXSTDTC)
    type=     DATE | DATETIME (controls comparison and assigned value)
  Audit:
    - Starts dataset audit, applies update, materializes audit trail into
      audit_<domain>, and terminates audit.
  Notes:
    - Comparison is string-based as written; ensure ISO 8601 formatting for safety.
  Usage Example:
  %cutoff_overwrite(domain=dm, var=RFPENDTC, type=DATE);
  %cutoff_overwrite(domain=dm, var=RFXSTDTC, type=DATETIME);

*//*** HELP END ***/

%macro cutoff_overwrite(
domain=
, var=
, type=DATE);
proc datasets nolist nowarn; 
 audit &domain.; 
initiate;
quit; 
%if %upcase(&type)=DATE %then %do;
  proc sql;
     update  &domain.
     set       &var. = "&cutoff__date."
     where  "&cutoff__date." < &var. ;
  quit;
%end;
%if %upcase(&type)=DATETIME %then %do;
proc sql;
   update  &domain.
   set       &var. = "&cutoff__datetime."
   where  "&cutoff__datetime." < &var. ;
quit;
%end;
data __audit_&domain.;
 set &domain.(type=audit);
 domain=cats(upcase("&domain"));
 var=cats("&var.");
 value=cats(&var.);
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
