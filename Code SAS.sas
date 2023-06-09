/* Créer votre propre library SAS */
libname Projet "/home/u60605666/sasuser.v94";

/* Importer les données Excel */
proc import datafile="/home/u60605666/Projet/Fast_food.xlsx" 
     dbms=xlsx 
     out=initial_sample;
     getnames=Yes;
run;

/* Étape 2 : Définition des paramètres */
%let initial_obs = 143; /* Nombre d'observations de l'échantillon initial */
%let final_obs = 143;   /* Nombre d'observations souhaité dans l'échantillon final */
%let num_bootstrap = %eval(&final_obs - &initial_obs); /* Nombre d'itérations de bootstrap */

/* Étape 3 : Boucle de bootstrap */
%macro bootstrap;
  %do i = 1 %to &num_bootstrap;
    data bootstrap_&i;
      /* Étape 3a : Échantillonnage aléatoire avec remplacement */
      set initial_sample;
      obs_id = rand("integer", 1, &initial_obs);
      output;
    run;

    /* Étape 3b : Ajout de l'observation bootstrap à l'échantillon final */
    data final_sample;
      set final_sample bootstrap_&i (keep=obs_id rename=(obs_id=obs_id_bootstrap));
      if _n_ = &i then output;
      else if obs_id = obs_id_bootstrap then output;
      drop obs_id_bootstrap;
    run;

  %end;
%mend bootstrap;

/* Étape 4 : Appel de la macro de bootstrap */
data final_sample;
  set initial_sample;
run;
%bootstrap;


/* 1)- Profil des répondants */

/* Visualiser le profil des répondants selon le sexe en utilisant le graphe circulant */
goption reset=global gunit=pct cback=white htitle=4 htext=2 border;
pattern1 value=psolid color=Pink;
pattern2 value=psolid color=blue;
proc gchart data=final_sample;
pie Sexe / tYpe=percent ;
TITLE "Répartition des répondants selon le sexe";
run;
quit;

/* Créer une variable catégorielle à partir d'une variable numérique Age */
DATA final_sample;
    SET Data_rest;

    IF Age < 15 THEN Groupe_aage = "Moins de 15 ans";
    ELSE IF Age >= 15 AND Age <= 20 THEN Groupe_aage = "15-20 ans";
    ELSE IF Age >= 21 AND Age <= 25 THEN Groupe_aage = "21-25 ans";
    ELSE Groupe_aage = "26 ans et plus";

RUN;

/* De même pour la variable Dépense */
DATA Data_rest;
    SET Data_rest;

    IF Dépense_repas < 50 THEN DEP = "Moins de 50€";
    ELSE IF Dépense_repas >= 50 AND Age <= 100 THEN DEP = "50-100€";
    ELSE IF Dépense_repas >= 21 AND Age <= 25 THEN DEP = "101-150€";
    Else DEP = " ";

RUN;

/* Statistiques descriptives pour les variables "Age" et "Dépense" */
proc means data=Data_rest n nmiss mean std median min max lclm uclm maxdec=2 ;
var Age Dépense;
title "Statistiques descriptives pour les variables age et dépense";
run;


/* Vérifier la normalité des variables "Age" et "Dépense" */
PROC UNIVARIATE DATA=final_sample normal plot;
var Age;
run;

PROC UNIVARIATE DATA=final_sample normal plot;
var Dépense;
run;
/* Les hypothèses de normalité ne sont pas accéptées 

/* Mesure de corrélation entre les variables "Age" et "Dépense" en utilisant le test Spearman */
proc CORR data=final_samplet spearman;
var Age Dépense;
run;


/* Visualiser le profil des répondants selon le groupe d'âge en utilisant le graphe circulant */
proc gchart data=final_sample;
 vbar Groupe_age;
 TITLE "Répartition des répondants selon le groupe d'âge";
 run;

 proc freq  data=final_sample;
 table Groupe_age;
 run;
 
 PROC SGPLOT data=final_sample;
  VBAR Sexe / RESPONSE=Consom_Fast_Food;
 RUN;
 
 PROC sgplot data=final_sample;
 dot Groupe_age / FILLATTRS=(COLOR=steelblue) GROUP=1 GROUPDISPLAY=STACK DATACONTRASTCOLORS=steelblue;
run;
 
 PROC freq data=final_sample;
 table Statut_Professionel;
 run;
 
goption reset=global gunit=pct cback=white htitle=4 htext=2 border;
pattern1 value=psolid color=royalblue;
pattern2 value=psolid color=yellow;
proc gchart data=final_sample;
pie Consom_Fast_Food / tYpe=percent ;
TITLE "Consommation des fast-foods";
run;
quit;

 PROC freq data=final_sample;
 table Consom_Fast_Food;
 run;

proc freq data=final_sample;
TABLE Davantage_Fast_Food;
run;



PROC SGPLOT data=final_sample;
 HBAR ' Fréquence_Consom'n;
TITLE "Fréquence de consommation";
RUN;
 
goption reset=global gunit=pct cback=white htitle=4 htext=2 border;
pattern1 value=psolid color=gray;
pattern2 value=psolid color=blanchedalmond;
pattern3 value=psolid color=brown;
proc gchart data=final_sample;
pie Mode_Consom / tYpe=percent ;
TITLE "Mode de consommation";
run;
quit;
 
goption reset=global gunit=pct cback=white htitle=4 htext=2 border;
pattern1 value=psolid color=BLUEVIOLET;
pattern2 value=psolid color=GREEN;
pattern3 value=psolid color=ORANGE;
proc gchart data=final_sample;
pie Dépense_repas / tYpe=percent ;
TITLE "Dépense moyenne par semaine";
run;
quit;


PROC SGPLOT data=final_sample;
 HBAR Rai_Cons;
TITLE "Raisons de consommation de la restauration rapide";
RUN;

PROC SGPLOT data=final_sample;
 HBAR Rai_Non_Cons;
TITLE "Raisons de non-consommation de la restauration rapide";
RUN;

PROC FREQ DATA=final_sample;
table Rai_Cons;
run;

PROC freq data=final_sample;
 table ' Raisons_Consom / Raisons_Non_Con'n;

RUN;

/* Etudier la liason entre les variables */

/*  Sexe x Consom_Fast_Food */
PROC freq data=final_sample;
 table Sexe*Consom_Fast_Food / list chisq ;
RUN;

/*  Groupe_Age x Consom_Fast_Food */
PROC freq data=final_sample;
 table Groupe_Age*Consom_Fast_Food / list chisq ;
RUN;

/*  Statut_Professionel x Consom_Fast_Food */
PROC freq data=final_sample;
 table Statut_Professionel*Consom_Fast_Food / list chisq ;
RUN;

/*  Région x Consom_Fast_Food */
PROC freq data=final_sample;
 table Région*Consom_Fast_Food / list chisq ;
RUN;

/*  Dépense_repas x Consom_Fast_Food */
PROC freq data=final_sample;
 table Dépense_repas*Consom_Fast_Food / list chisq ;
RUN;


/*  Statut_Professionel x Mode_Consom */
PROC freq data=final_sample;
 table Statut_Professionel*Mode_Consom / list chisq ;
RUN;

/*  Sexe x Mode_Consom */
PROC freq data=final_sample;
 table Sexe*Mode_Consom / list chisq ;
RUN;

/*  Groupe_age x Mode_Consom*/
PROC freq data=final_sample;
 table Groupe_age*Mode_Consom / list chisq ;
RUN;

/*  Région x Mode_Consom */
PROC freq data=final_sample;
 table Région*Mode_Consom / list chisq ;
RUN;

/*  Test de comparaison (Proportions) */
proc freq data=final_sample;
table Sexe / binomial (level="Masculin" p=0.5);
run;

proc freq data=final_sample;
table Coupon_réduction / binomial (level="oui" p=0.5);
run;