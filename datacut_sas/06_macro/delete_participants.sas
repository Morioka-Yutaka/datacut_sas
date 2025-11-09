/*** HELP START ***//*

Macro: delete_participants
  Purpose:
    Delete records for participants listed in a separate dataset (USUBJID-level).
  Parameters:
    domain=          Target dataset (e.g., DM)
    delete_list_ds=  Dataset with a column USUBJID listing rows to delete
  Audit:
    - Starts dataset audit, deletes by IN-subquery, writes audit to audit_<domain>,
      and terminates audit.
  Notes:
    - Assumes the key variable is USUBJID.
  Usage Example:  
 %delete_participants(domain=dm ,delete_list_ds=dlds);

*//*** HELP END ***/

%macro delete_participants(
domain=
,delete_list_ds=dlds
);
proc datasets nolist nowarn ; 
 audit &domain.; 
initiate;
quit; 
proc sql;
  delete from &domain.
  where USUBJID in (select USUBJID from &delete_list_ds.);
quit;

data __audit_&domain.;
 set &domain.(type=audit);
 domain=cats(upcase("&domain"));
 var=cats("USUBJID");
 value=cats(USUBJID);
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
