
/*Importing File*/

 PROC IMPORT OUT= WORK.chd1
            DATAFILE= "C:\Users\aysha\Documents\Daily Schedule\652\Project\bigml_5a9b2947eba31d3b440003a5.csv"
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2;
RUN;

/*Exploring the data*/

proc contents data=chd1;
run;

/*Summary Statistics for data*/

proc means data=chd;
run;


/*Check for Missing Values*/

proc format;
 value $missfmt ' '='Missing' other='Not Missing';
 value  missfmt  . ='Missing' other='Not Missing';
run;

/*Checking the number and column's with missing value */

proc freq data=chd1;
format _CHAR_ $missfmt.; /* apply format for the duration of this PROC */
tables _CHAR_ / missing missprint nocum nopercent;
format _NUMERIC_ missfmt.;
tables _NUMERIC_ / missing missprint nocum nopercent;
run;
/*Checking for missing values*/

data mis_chd1;
set chd1;
if (tobacco ~='' OR ldl~='' OR obesity~='' OR alcohol ~='') then  output;
run;

/*Replacing missing values by mean*/

proc stdize data=chd1 reponly method=mean out=Complete_data_mean;
var tobacco ldl obesity alcohol;
run;

/*Replacing missing values by median*/

proc stdize data=chd1 reponly method=median out=Complete_data_median;
var tobacco ldl obesity alcohol;
run;

/*Plotting frequency table for chd variable*/

Proc freq data=Complete_data_mean;
table chd;
run;

/*Checking correlation between data*/

proc corr data=chd;
var sbp	tobacco	ldl	adiposity typea	obesity	alcohol	age	chd;
run;
/*Using Stepwise variable reduction */

proc reg data=chd;
model chd=sbp tobacco ldl adiposity typea obesity alcohol age / vif selection=stepwise slstay=.05 slentry=.05;
run;

/*Scatter Plot to check whether the data is normally distributed or not*/

proc univariate data=chd1;
   histogram;
run;

/*Realtion with the coronary heart disease with various attributes given*/

proc sgplot data=chd1;
  scatter x=tobacco y=chd ;
run;

proc sgplot data=chd;
  scatter x=alcohol y=chd ;
run;

proc sgplot data=chd;
  scatter x=age y=chd ;
run;

proc sgplot data=chd;
  scatter x=obesity y=chd ;
run;


/* High correclations
Obesity-Adiposity
ldl-adiposity typea
adiposity- ldl age
typea- age
age -tobacco adiposity*/

/*Using factor analysis*/
proc factor data=train simple corr outstat=chd_fac;
run;

/*Using Principal component analysis*/
proc princomp data=chd1 out=chd_pca;
var sbp	tobacco	ldl	adiposity typea	obesity	alcohol	age	chd;
run;
/*Dividing into test and train */
PROC SURVEYSELECT DATA=chd1 outall OUT=all METHOD=srs SAMPRATE=0.3;

RUN;
data test;
set all;
if Selected=0 then delete;
run;

data Train;
set All;
if Selected=1 then delete;
run;

/*Logitic regression on training data and then using it on test without factor and PCA*/
   ods graphics on;
      proc logistic data=Train;
        model chd(event="1") = sbp tobacco ldl adiposity typea obesity alcohol age / outroc=troc;
        score data=Test out=valpred outroc=vroc;
        roc; roccontrast;
        run;

/*Using Principal component analysis train data*/
proc princomp data=chd1 out=chd_pca_train;
var sbp	tobacco	ldl	adiposity typea	obesity	alcohol	age	chd;
run;


/*Using Principal component analysis Test*/
proc princomp data=Test out=chd_pca_test;
var sbp	tobacco	ldl	adiposity typea	obesity	alcohol	age	chd;
run;


/*Logistic regression with PCA*/


      proc logistic data=Chd_pca_train;
        model chd(event="1") = Prin1 Prin2 Prin3 Prin4/ outroc=troc;
        score data=chd_pca_test out=valpred outroc=vroc;
        roc; roccontrast;
        run;


/*Random Forest Algorithm*/


		Proc HPFOREST data=chd1;
		Target chd/ level=nominal;
		input sbp tobacco ldl adiposity typea obesity alcohol age / level = nominal;
		run;




