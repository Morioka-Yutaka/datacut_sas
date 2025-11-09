/*** HELP START ***//*

Macro: output_and_report
  Purpose:
    Export all WORK datasets to the configured output library and create an
    Excel report summarizing the audit trails.
  Parameters:
    report_path=  Folder path to write the Excel report (cutoff_report.xlsx)
    exclude=      Names to exclude when copying from WORK to c_outlib
  Outputs:h
    - Excel file: &report_path\cutoff_report.xlsx
    - Datasets: all WORK datasets (except excluded) copied to c_outlib
  Notes:
    - Consumes audit_* tables via SET audit_:
    - Adds cutoff date/time text blocks to the report.
 Usage Example
 %output_and_report(report_path=D:\audit_test\out, exclude=dlds);

*//*** HELP END ***/

%macro output_and_report(report_path=, exclude=);

data all_audit;
 set audit_:;
 label domain="Domain" var="Field" _ATOBSNO_="Observation No"  DR="Before" DW="After" DD="Delete Record";
 drop  _NAME_ _LABEL_;
run;

ods excel file="&report_path\cutoff_report.xlsx";
ods excel options( SHEET_INTERVAL = "NONE" );
 proc odstext;
  p"Cutoff date: &cutoff__date.";
  p"Cutoff date time: &cutoff__datetime.";
 run;

 proc print data=all_audit noobs label;

 run;
ods excel close;

proc copy inlib=work outlib=c_outlib;
 exclude   _: dummy all_audit audit: &exclude.; 
run;
%mend;
