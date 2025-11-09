/*** HELP START ***//*

Macro: cutoff_delete
  Purpose:
    Delete records where a date/datetime variable is strictly greater than
    the cutoff value.
  Parameters:
    domain=   Target dataset (e.g., DM)
    var=      Variable to compare (e.g., RFICDTC)
    type=     DATE | DATETIME
  Audit:
    - Starts dataset audit, deletes records, writes audit to audit_<domain>,
      and terminates audit.
  Notes:
    - Comparison is string-based as written; ensure ISO 8601 formatting for safety.
  Usage Example:  
  %cutoff_delete(domain=ae, var=AESTDTC, type=DATE);

*//*** HELP END ***/

%macro cutoff_delete(
domain=
, var=
, type=DATE);
proc datasets nolist nowarn ; 
 audit &domain.; 
initiate;
quit; 
%if %upcase(&type)=DATE %then %do;
proc sql;
   delete  from &domain.
   where  "&cutoff__date" < &var. ;
quit;
%end;
%if %upcase(&type)=DATETIME %then %do;
proc sql;
   delete  from &domain.
   where  "&cutoff__datetime" < &var. ;
quit;
%end;
data __audit_&domain.;
 set &domain.(type=audit);
 domain=cats(upcase("&domain"));
 var=cats("&var");
 value=cats(&var);
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
