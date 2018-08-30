

// Protected crossing design
// Copyright 2018 Pierre ROUZEAU AKA PRZ
// Program license GPL v3
// documentation licence cc BY-SA 4.0 and GFDL 1.2
// First version: 0.0 - 19 August 2018
// V 0.1: 22 August 2018 - bugs, generic vehicles, always bike advanced position, protective poles, precise light positioning.
// V 0.2: 28 August 2018 - bugs, own models, more checks, misc. improvements.
//All designs done with this application are free of right
// This uses my OpenSCAD library, attached, but you can find details here:
// https://github.com/PRouzeau/OpenScad-Library
//Bus model own design, 12 x 2.55 m, wheel base 5.9 m.
//bike model own design
//ground marking bikes own design

/* KNOWN BUGS:
*When there is an alley and the pavement separation is not sufficiently wide, the main traffic light position may not be correct
*Islands have problems if there is no bikeway on one side
*If there is too much assysmetry in the road (e.g. one pavement is much larger than the other), there could be troubles on the island
*When there is no deviation in lane because there is no bikeway on that side, but a deviation exists on the other side to reach the corner, the stop line don't start at the good position and part is missing
*If there is an alley not used for cycle path and a cycle lane, all crossing is wrong
*If the alley is not dedicated to cycle path, there are some misplaced pavements.
*The roundabout ground marking assumes symetrical lanes layout, which is not necessarily the case, you can have two inlet for one outlet.
*Double direction path have many problems and yet are not properly working. Parking lane shall be on the other side than the double cirection bike path.Islands are lost
Generally speaking, turns and ground marking are not handled well on double direction bike paths
Bikeway are not handled properly when there is a t cross and a double direction cycle path on the side of the t branch (there shall not be traversing bikeways) 
*/

/*fr+  
Conception de croisement protégés 'à la néerlandaise'
 Pour une explication de l'état de l'art, voyez le lien (en anglais):
	https://bicycledutch.wordpress.com/2011/04/07/state-of-the-art-bikeway-design-or-is-it/

Voir d'abord le fichier Lisez_moi.txt
Le fichier 'Presentation_fr.txt' donne un point de vue plus général sur la conception de cette application.

Seuls les versions de développement 'snapshot versions' d'OpenScad comportent Customizer, utilisez la dernière version (actuellemrnt le 1 Juin 2018)
Vous DEVEZ activer Customizer:
*Menu [Edition], selectionner [Préférences] puis ouvrir l'onglet [Fonctionnalités], cocher [Customizer], puis fermer la fenêtre.
*Dans le menu [Vues], vous devez désormais avoir une option [Hide customizer], que vous devez décocher.
*Dans l'écran de Customizer (pas encore traduit), sur la première ligne, sélectionner [Description only], ce qui fera une interface nettement plus sobre.
*Éventuellement vous fermerez la fenêtre d'édition avec le menu [Vues], option [Cacher l'éditeur].
*L'interface est par défaut dans le langage local (tel que configuré sur votrre ordinateur). Pour désactiver: menu [Edition][Préférences], onglet [Avancé], décocher l'option (en bas) [Activer la localisation de l'interface utilisateur (nécessite un redémarrage d'openSCAD)]. 
 
Quand vous êtes content de votre conception, vous pouvez l'enregister comme un 'dataset', utilisez le bouton [+] pour créer un nouveau dataset puis [save preset] pour les enregistrements ultérieurs, que vous pourrez rappeler plus tard en la sélectionnant dans le menu déroulant. RIEN n'est sauvegardé automatiquement.

Notez que pour les variables avec des flèches de modifications, quand vous cliquez sur le champ, vous pouvez alors modifier la valeur avec la roulette de la souris.
 
 notez les conventions
 0 neutralise les équipments
 n un nombre donne une valeur
 
 Repérage (conforme au repère OpenScad):
 Route X gauche droite
 Route Y nord-sud
 Pour chaque route il y a deux branches, A et B, mais il peut y avoir des paramètres communs a ces branches (voir plus loin).

 Les dimensions sont en m
 
 Utilisation: 
 La toute première chose que vous souhaitez, c'est de pouvoir manipuler l'image en trois dimensions sans voir celle-ci revenir à sa position par défaut a chaque calcul, ouvrez (dans customizer) l'onglet [Caméra] et décocher [Imposer la position de la caméra].
 
 Après ceci, vous êtes libre de modifier toute variable pour ajuster votre conception de croisement. Souvenez-vous que rien n'est sauvegardé tant que vous n'avez pas enregistré de 'dataset'.
 
BOGUES CONNUS:
 Voir en anglais plus loin
*/

/* 
Developer note:
 For translation utility, I made a Libre office macro, that you can find in separated file. See also my request here:
  https://github.com/openscad/openscad/issues/2434

todo:
*Bike path in an alley not using the whole alley - may be difficult and can broke the dataset
*Allow differentiated opposite branch
*Set localised deviations right-left for enlarged middle island for 2x2 lanes (or larger). 
*Expand the checking procedures

It shall be noted that height is used for ground marking, road surface, etc. to define what will be visible and priorities. All these is lost when projecting and you have a lot of normally invisible lines. It might be better to export an image and use image treatment, however the major advantage of projection is its capability to export dxf files.
To avoid Openscad artifacts, some elements have levels differentiated by a few mm (there are 'mirages' when substracting parts with same top or bottom levels).
*/ 
//*********************************
 include <Z_library.scad>
 include <Road_signs.scad>
/*[Hidden]*/ 
$fn=32;
glass_color = [128,128,128,180]/256;
// transparent 
debug=true;

//y road B side in continuity with A
XB_totwidth=0;
YB_totwidth=0;
XBr_pedcross_shift=0;
YBr_pedcross_shift=0;
XBr_pedcross_wd=0;
YBr_pedcross_wd=0;

/*[_Reserved-do not modify] not to be modified by user*/
//Merci de ne pas modifier les variables de cet onglet
//_=true;
//Version
pcross_version = 1;
//language
language = "fr";
//Coefficient d'unités principal, natif en mm, interface en m
cfu=1000;
//Coefficient d'unités pour les lignes
cfu_line=1;

//===================================
/*[Caméra]*/ 
//Imposer la position de la caméra
Dictate_camera_position=true; 
// The camera variables shall NOT be included in a module - a module CANNOT export variables
//Vue de dessus
Top_view = false;
//Distance de la caméra
Cimp = Dictate_camera_position||Top_view; 
$vpd=Cimp?Top_view?220000:110000:$vpd; 
//Vecteur de déplacement
$vpt=Cimp?[1150,900,700]:$vpt; 
//Vecteur de rotation
$vpr=Cimp?Top_view?[0,0,0]:[64,0,19]:$vpr; 
echo_camera();
//================================
/*[Affichage]*/
/*
//Affiche batiments (pas encore installé)
display_building = false;
*/
//Projection (pour exportation fichier dxf)
Projection=false;
//Affiche la route (sinon seulement trottoirs et marquage)
Display_road = true;
//Affiche avertissements et données dans la vues 3D
Disp_text = true;
//Affiche avertissements dans la console
inf_text = true;
//Afficher les véhicules
vh_disp = false;	
//== VEHICLES ===================
//see in vehicle chapter v_color and v_type for color and vehicle association 	
/*[Véhicules]*/
//-- Vehicle 1 -------------------
//Type du véhicule 1 à afficher
vh1_type = 1; // [0:"Aucun",1:"Voiture rouge",2:"Voiture bleue",3:"Bus",4:"Cycliste"]

//Éléments accessoires du véhicule 1
vh1_acc = 1; // [0:"None",1:"Vehicle line limit X (for cars)",2:"Vehicle line limit Y (for cars)",3:"Arrow",4:"Views angles"]
//::vh1_acc = 0; // [0:"Sans",1:"Limite du véhicule ligne X",2:"Limite du véhicule ligne Y",3:"Flèche",4:"Angles de vision"]

//Véhicule 1 position en X
vh1_X = 2.8; //[-22:0.1:22]
//Véhicule 1 position en Y
vh1_Y = 6; //[-22:0.1:22]
//Véhicule 1 angle
vh1_ang = 115;
//-- Vehicle 2 -------------------
//Type du véhicule 2 à afficher
vh2_type = 2; // [0:"Aucun",1:"Voiture rouge",2:"Voiture bleue",3:"Bus",4:"Cycliste"]

//Éléments accessoires du véhicule 2
vh2_acc = 0; // [0:"None",1:"Vehicle line limit X (for cars)",2:"Vehicle line limit Y (for cars)",3:"Arrow",4:"Views angles"]
//::vh2_acc = 0; // [0:"Sans",1:"Limite du véhicule ligne X",2:"Limite du véhicule ligne Y",3:"Flèche",4:"Angles de vision"]

//Véhicule 2 position en X
vh2_X = 8; //[-22:0.1:22]
//Véhicule 2 position en Y
vh2_Y = 2.5; //[-22:0.1:22]
//Véhicule 2 angle
vh2_ang = 180;
//-- Vehicle 3 -------------------
//Type du véhicule 3 à afficher
vh3_type = 3; // [0:"Aucun",1:"Voiture rouge",2:"Voiture bleue",3:"Bus",4:"Cycliste"]

//Éléments accessoires du véhicule 3
vh3_acc = 0; // [0:"None",1:"Vehicle line limit X (for cars)",2:"Vehicle line limit Y (for cars)",3:"Arrow",4:"Views angles"]
//::vh3_acc = 0; // [0:"Sans",1:"Limite du véhicule ligne X",2:"Limite du véhicule ligne Y",3:"Flèche",4:"Angles de vision"]

//Véhicule 3 position en X
vh3_X = -3.4; //[-22:0.1:22]
//Véhicule 3 position en Y
vh3_Y = -5.2; //[-22:0.1:22]
//Véhicule 3 angle
vh3_ang = -52;
//-- Vehicle 4 -------------------
//Type du véhicule 4 à afficher
vh4_type = 4; // [0:"Aucun",1:"Voiture rouge",2:"Voiture bleue",3:"Bus",4:"Cycliste"]

//Éléments accessoires du véhicule 4
vh4_acc = 0; // [0:"None",1:"Vehicle line limit X (for cars)",2:"Vehicle line limit Y (for cars)",3:"Arrow",4:"Views angles"]
//::vh4_acc = 0; // [0:"Sans",1:"Limite du véhicule ligne X",2:"Limite du véhicule ligne Y",3:"Flèche",4:"Angles de vision"]

//Véhicule 4 position en X
vh4_X = 4.4; //[-22:0.1:22]
//Véhicule 4 position en Y
vh4_Y = 8.8; //[-22:0.1:22]
//Véhicule 4 angle
vh4_ang = 155;

vh_type = [vh1_type,vh2_type,vh3_type,vh4_type];
vh_acc = [vh1_acc,vh2_acc,vh3_acc,vh4_acc];
vh_X = [vh1_X,vh2_X,vh3_X,vh4_X];
vh_Y = [vh1_Y,vh2_Y,vh3_Y,vh4_Y];
vh_ang = [vh1_ang,vh2_ang,vh3_ang,vh4_ang];

//==============================
/*[Texte Descriptif]*/
//Titre du projet
txt01 = "Titre du projet";
//Texte descriptif
txt02 = "description";
//_
txt03 = "";
//_
txt04 = "";
//_
txt05 = "";
//_
txt06 = "";
//_
txt07 = "";
//_
txt08 = "";
//_
txt09 = "";
//_
txt10 = "";
usertxt = [txt01,txt02,txt03,txt04,txt05,txt06,txt07,txt08,txt09,txt10];

//Concepteur
author="_";
//Date et révision
design="preliminary test";
//Licence
license="_";

designtxt = [str("Date, rev.: ",design), str("Author: ",author,"  License: ",license)];
//==============================
/*[Général]*/
//Coté de conduite à droite
right_drive = true;
//-------------
//Il y a des feux de circulation
traffic_light=true;
//------------
//Quelle route a priorité
road_priority = 1; //[0:"Aucune",1: "Route X", 2:"Route Y"]
//-----------
//Carrefour en 'T' (pas de branche B en Y)
t_cross = false;
//Le feu est installé après le passage piéton (quand on le regarde)
light_after_crossing = true; 
//décalage du centre de rayon des coins de trottoir (augmente le rayon mais diminue l'espace pour les piétons)
_corner_offset = 0.2; //[0:0.1:3]
corner_offset = _corner_offset*cfu; 
//Les ilôts de parking sont en béton (sinon ils sont peints)
parking_island_concrete = false;
//longueur de la branche de déviation voiture (depuis le début de la route, pas du centre du carrefour)
_dev_length = 16;
dev_length = _dev_length*cfu;
//longueur de la branche de déviation vélo (depuis le début de la route, pas du centre du carrefour)
_cydev_length = 10;
cydev_length = _cydev_length*cfu;
//Diamètre interne du rond-point, 0 si pas de rond-point
_round_int_diam=0; //[0:0.2:24]
round_int_diam=_round_int_diam*cfu;
//Partie diagonale des îlots de giratoire
_round_bias=6; //[0:0.2:15] 
round_bias = _round_bias*cfu;
//================================
/*[Nombre de voies principales]*/
//Route X branche A: nombre de voies à droite
XAr_nb_lanes = 2; // [0:1:4]
//Route X branche A, nombre de voies à gauche
XAl_nb_lanes = 1; // [0:4]
//Route X branche B, voies à droite
XBr_nb_lanes = 2; // [0:4]
//Route X branche B, voies à gauche
XBl_nb_lanes = 1; // [0:4]
//Route Y branche A: voies à droite
YAr_nb_lanes = 1; // [0:4]
//Route Y branche A, voies à gauche
YAl_nb_lanes = 1; // [0:4]
//Route Y branche B, voies à droite
YBr_nb_lanes = 1; // [0:4]
//Route Y branche B, voies à gauche
YBl_nb_lanes = 1; // [0:4]

//==============================
/*[Hidden]*/
//Road displayed length
_road_length = 46; //[40:2:100]
road_length = _road_length*cfu;
//echo(cfu=cfu, road_length =road_length);

//ground marking 
//Length where you shall not park before a pedestrian passage (by law in France)
_park_protect = 5;
park_protect = _park_protect*cfu;
//Length of one car parking space
_park_space = 5; //[4.5:0.1:6]
park_space = _park_space*cfu;
//cycle path triangle distance from line
_cycle_triangle_dist = 0.15; //[0.15:0.05:0.4]
cycle_triangle_dist = _cycle_triangle_dist*cfu;
//cycle path triangle width 
_cycle_triangle_wd = 0.4;
cycle_triangle_wd = _cycle_triangle_wd*cfu;
//cycle path triangle length
_cycle_triangle_lg = 0.6;
cycle_triangle_lg = _cycle_triangle_lg*cfu;
//cycle path triangle interval
_cycle_triangle_sp = 0.5;
cycle_triangle_sp = _cycle_triangle_sp*cfu;
//Misc dimensions
//hauteur du trottoir - depuis la route
_pavht=0.15; 
pavht=_pavht*cfu; 
//number of segment for pavement cylinder ends of 300mm diam. This is key to overall calculation time ??
pavseg=12;
//===============================
/*[Route X, parties communes]*/
//Right and left are from road when looking the crossing
//yet crossing is assumed to be straight and mirrorable
//Largeur de la route X (y compris les trottoirs)
XA_totwidth= 20; //[4:0.2:50]
//La branche B de la route X est en continuité de la branche A (même largeur, même trottoir, etc.)
XX = true; // [true]
//Trottoir de séparation médian
XA_central = 0; //[0:0.1:2]
//Largeur passage piéton (0: pas de passage)
XA_pedcross_wd = 2.5; // [0,2.5,3]
//Distance du passage piéton au bord de la route perpendiculaire
XA_pedcross_shift = 3; // [0.4:0.2:6]
//Types de flèches au sol branche A (remplir tableau valeurs:"vers droite","tout droit","tout droit et droite")
XAr_lane_arrows = ["vers droite","tout droit","tout droit","tout droit"];
//["straight","right","straight right"]
//Types de flèches au sol branche en face (B) (remplir tableau valeurs:"vers droite","tout droit","tout droit et droite")
XBr_lane_arrows = ["vers droite","tout droit","tout droit","tout droit"];
//["straight","right","straight right"]
//permet une déviation automatique, branche A (pour optimiser l'espace intérieur)
XA_allow_dev=true;
//permet une déviation automatique, branche B (pour optimiser l'espace intérieur)
XB_allow_dev=true;

//==============================
/*[Route X coté droite, branche A]*/
//Largeur trottoir - au carrefour
XAr_pavement = 2; // [0.5:0.1:6]
//Largeur allée de coté (pour voitures ou vélos)
XAr_alley = 2; // [0:0.1:6]
//Is the alley a cycle path (-> change color)
//Allée entièrement réservée à la piste cyclable
XAr_cycle_path=true; 
//La piste cyclable est en double sens
XAr_cycle_double = false;
//Largeur trottoir séparation entre allée et route, s'il y a une allée
XAr_alley_pav = 0.6; //[0.2:0.1:8]
//Largeur file de parking
XAr_park_lane=2; //[0,2,2.1,2.2]
//Largeur bande cyclable
XAr_cycle_lane = 0; //[0:0.1:2.5]
//déviation de la piste cyclable (nécessite un trottoir de séparation large)
XAr_pavdev = 0; //[0:0.1:6]
//Voie bus (pas installé)
XAr_bus_lane = false;
//Voie bus (pas installé)
XBr_bus_lane = false;
/*/Buildings (decorative purpose only)
//Distance immeuble/trottoir (pas installé)
XAr_building = 0;
*/

//===============================
/*[Route X coté gauche, branche A]*/
//Largeur trottoir - au carrefour
XAl_pavement = 2;  // [0.5:0.1:6]
//Largeur contre-allée
XAl_alley = 2; // [0:0.1:6]
//La contre-allée est une piste cyclable
XAl_cycle_path=true; 
//La piste cyclable est à double sens
XAl_cycle_double = false;
//Largeur trottoir séparation entre allée et route, s'il y a une allée
XAl_alley_pav = 0.6; //[0.2:0.1:8]
//Largeur file de parking
XAl_park_lane = 0; //[0,2,2.1,2.2]
//Largeur bande cyclable
XAl_cycle_lane = 0; //[0:0.1:2.5]
//déviation de la piste cyclable (nécessite un trottoir de séparation large)
XAl_pavdev = 0; //[0:0.1:6]
//Voie de bus 
XAl_bus_lane = false;
//Voie de bus sur la branche B
XBl_bus_lane = false;
/*/fr:Distance des bâtiments au bord de la route (décoratif uniquement)
//distance between building and road 
XAl_building = 0;
*/
//===================================
/*[Route Y, parties communes]*/
//Largeur de la route Y (y compris les trottoirs)
YA_totwidth= 16; //[4:0.2:50]
//La branche B de la route Y est en continuité de la branche A (même largeur, même trottoir, etc.)
YY = true; // [true]
//Trottoir de séparation médian
YA_central = 0; //[0:0.1:2]
//Largeur passage piéton (0: pas de passage)
YA_pedcross_wd = 2.5; //[0,2.5,3]
//Distance du passage piéton au bord de la route perpendiculaire
YA_pedcross_shift = 3; // [0.4:0.2:6]
//Types de flèches au sol branche A (remplir tableau valeurs:"vers droite","tout droit","tout droit et droite")
YAr_lane_arrows = ["","straight","straight","straight"];
///fr:Types de flèches au sol branche en face (B) (remplir tableau valeurs:"vers droite","tout droit","tout droit et droite")
//Road marking arrows facing branch (B)-(fill in array, values "right","straight","straight right")
YBr_lane_arrows = ["vers droite","tout droit","tout droit","tout droit"];
//permet une déviation automatique, branche A (pour optimiser l'espace intérieur)
YA_allow_dev=true;
//permet une déviation automatique, branche B (pour optimiser l'espace intérieur)
YB_allow_dev=true;
  
//===================================
/*[Route Y coté droite, branche A]*/
//Largeur trottoir - au carrefour
YAr_pavement = 2; // [0.5:0.1:6]
//Largeur contre-allée
YAr_alley = 0; // [0:0.1:6]
//La contre-allée est une piste cyclable
YAr_cycle_path=true; 
//La piste cyclable est à double sens
YAr_cycle_double = false;
//Largeur trottoir séparant contre-allée et route
YAr_alley_pav = 0.7; // [0.2:0.1:8]
//Largeur file de parking
YAr_park_lane = 0; //[0,2,2.1,2.2]
//Largeur bande cyclable
YAr_cycle_lane = 2; //[0:0.1:2.5]
//déviation de la piste cyclable (nécessite un trottoir de séparation large)
YAr_pavdev = 0; //[0:0.1:6]
//Largeur file de parking
YAr_park_lane = 0; //[0,2,2.1,2.2]
//Voie de bus 
YAr_bus_lane = false;
//Voie de bus sur la branche B
YBr_bus_lane = false;
/*/fr:Distance des bâtiments au bord de la route (décoratif uniquement)
//distance between building and road 
YAr_building = 0;
*/
//===================================
/*[Route Y coté gauche, branche A]*/
//Largeur trottoir - au carrefour
YAl_pavement = 2;  // [0.5:0.1:6]
//Largeur contre-allée
YAl_alley = 0; // [0:0.1:6]
//La contre-allée est une piste cyclable
YAl_cycle_path=true; 
//La piste cyclable est à double sens
YAl_cycle_double = false;
//Largeur trottoir séparation entre allée et route, s'il y a une allée
YAl_alley_pav = 0.7; //[0.2:0.1:8]
//Largeur file de parking
YAl_park_lane = 2; // [0,2,2.1,2.2]
//Largeur bande cyclable
YAl_cycle_lane = 2; //[0:0.1:2.5]
//déviation de la piste cyclable (nécessite un trottoir de séparation large)
YAl_pavdev = 0; //[0:0.1:6]
//Voie de bus 
YAl_bus_lane = false;
//Voie de bus branche B
YBl_bus_lane = false;
/*/fr:Distance des bâtiments au bord de la route (décoratif uniquement)
//distance between building and road 
YAl_building = 0;
*/
//====================================
/*[Marquage sol]*/
// en France, voir https://fr.wikipedia.org/wiki/Signalisation_routi%C3%A8re_horizontale_en_France
// u en ville = 5 cm
// u SUR les pistes cyclable = 3 cm
//Largeur ligne centrale
_road_cent_line = 150; // 3 u
//Largeur ligne séparation de voies (mm)
_road_sep_line = 100; // 2 u
//Largeur ligne voie bus (mm)
_bus_lane_line = 250; // 5 u
//Largeur ligne bande cyclables  (mm)
_cycle_lane_line = 250; // 5 u
//Largeur ligne piste cyclable (dans carrefour)  (mm)
//Cycle path side line thickness (in road crossing) (mm)
_cycle_cross_line = 250; // 5 u
//Largeur ligne séparation double sens piste cyclable (mm)
_cycle_cent_line = 90; //3u (u=30 for cycle)
//-- Stop line intervals if dashed ---
//Intervalle entre marques de ligne de stop piéton (mm)
_stop_line_lg = 1000;
//Espace entre marques de ligne de stop piéton (mm)
_stop_line_sp =200; //[0,200]
// according Vienna convention
//Largeur ligne de stop passage piéton  (mm)
_stop_line_thk =500; //[500,600]
//Le passage piéton est de type 'Zèbre'
pedcross_zebra = true;
//Largeur lignes passages piéton en zèbre (mm)
_ped_zebra_line = 500;
//Largeur lignes latérale passages sans 'zèbre' (mm)
_pedcross_side_line = 200; // ??
//===================================
/*[Hidden]*/
road_cent_line= _road_cent_line*cfu_line;
road_sep_line = _road_sep_line*cfu_line; 
bus_lane_line = _bus_lane_line*cfu_line; 
cycle_lane_line = _cycle_lane_line*cfu_line; 
cycle_cross_line= _cycle_cross_line*cfu_line;
cycle_cent_line = _cycle_cent_line*cfu_line; 
stop_line_lg = _stop_line_lg*cfu_line;
stop_line_sp = _stop_line_sp*cfu_line;
stop_line_thk = _stop_line_thk*cfu_line;
ped_zebra_line = _ped_zebra_line*cfu_line;
pedcross_side_line=_pedcross_side_line*cfu_line;
cycle_cent_line = _cycle_cent_line*cfu_line;
//====================================
/*[Réglages fins]*/
//Augmentation du rayon de virage pour avoir un parcours plus circulaire. Réduit l'espace de stockage des véhicules motorisés
_rad_increase = 0; //[0:0.2:10]
rad_increase = _rad_increase*cfu;
//Réduction de la longueur droite pour gagner de l'espace de stockage des véhicules motorisés (valeur négative)
_straight_decrease = -1; //[-6:0.2:0]
straight_decrease = _straight_decrease*cfu;
//Rayon virage voiture (trottoir surbaissé)
_car_radius = 5; //[3.5:0.2:8]
car_radius = _car_radius*cfu;
//Rayon virage camions (trottoir pleine hauteur)
_truck_radius = 9; //[8:0.2:12]
truck_radius = _truck_radius*cfu;
//Augmentation de la largeur des pistes à l'intérieur du carrefour
_cycle_wd_extent_crossing = 0.25; //[0:0.05:0.80]
cycle_wd_extent_crossing = _cycle_wd_extent_crossing*cfu;
//Distance du trottoir au rayon de virage théorique (vers l'intérieur)
_radius_clearance = 0.25; //[0.1:0.1:0.8]
radius_clearance = _radius_clearance*cfu;
//---------------------------------
//Distance de la ligne de stop au passage piéton (m)
_stop_line = 4;
stop_line = _stop_line*cfu;
//Distance du poteau de feu au bord du trottoir (m)
_light_pole_dist = 0.3; //[0.3:0.05:1]
light_pole_dist = _light_pole_dist*cfu;
//Diamètre des feux principaux (en mm)
traffic_light_diam = 200; // [200,300]
//Distance entre le rond-point et la piste cyclable (m)
_roundabout_space = 6; //[5:0.5:12]
roundabout_space = _roundabout_space*cfu;

/*[Hidden]*/
//What follow is legacy of former island design, but it have effect on bike light and protection pavement. To be deprecated or at least revised
//Correction position 1 ilot au coin C1
C1_island_pos1 = 0; //[-1.5:0.1:2.5]
//Correction position 2 ilot au coin C1
C1_island_pos2 = 0; //[0:0.1:2.5]
//-----------
//Correction position 1 ilot au coin C2
C2_island_pos1 = 0; //[-1.5:0.1:2.5]
//Correction position 2 ilot au coin C2
C2_island_pos2 = 0; //[0:0.1:2.5]
//------------------------------
//Correction position 1 ilot au coin C3
C3_island_pos1 = 0; //[-1.5:0.1:2.5]
//Correction position 2 ilot au coin C3
C3_island_pos2 = 0; //[0:0.1:2.5]
//---------------
//Correction position 1 ilot au coin C4
C4_island_pos1 = 0; //[-1.5:0.1:2.5]
//Correction position 2 ilot au coin C4
C4_island_pos2 = 0; //[0:0.1:2.5]

//Ajustement position feu piste double, coin C1
C1_dbl_light_adj = 0; //[0:0.1:2.5]
//Ajustement position feu piste double, coin C2
C2_dbl_light_adj = 0; //[0:0.1:2.5]
//Ajustement position feu piste double, coin C3
C3_dbl_light_adj = 0; //[0:0.1:2.5]
//Ajustement position feu piste double, coin C4
C4_dbl_light_adj = 0; //[0:0.1:2.5]
//====================================
/*[Couleurs]*/
//colors (web designation)
//color_road = "darkslategray";
//
//color_road = [0,0.06,0.012];
//Couleur de la route
color_road = "dimgray";
//Cycle lane or path color
//color_cycle = "firebrick";
//Couleur des voies cyclables
color_cycle = [0.78,0.1,0.1];
//Couleur bord de trottoir
color_pavement_border = "darkgray";
//Couleur trottoir
color_pavement = "lightgray";
/*/fr:Couleur bâtiments
//Buildings color
color_building = "cream";
//Couleur espace route/bâtiments
color_building_sep = "darkgreen";
*/
//===================================
//-- indexes ----------------------
/*[Hidden]*/
vX = 0;
vY = 1;
vA = 0;
vB = 1;
vright = 0;
vleft = 1;

Wang = [[0,180],[90,270]];
//===================================
totwidth = [[XA_totwidth*cfu,(XB_totwidth?XB_totwidth:XA_totwidth)*cfu],[YA_totwidth*cfu,(YB_totwidth?YB_totwidth:YA_totwidth)*cfu]];
// width of perpendicular road
perpwidth = [[totwidth[1][0],totwidth[1][1]],[totwidth[0][0],totwidth[0][1]]];

//??? cross
//if (XX) {
	XBr_pavement = XAl_pavement;
	XBl_pavement = XAr_pavement;
//}
//if (YY) {
	YBl_pavement = YAr_pavement;
	YBr_pavement = YAl_pavement;
//}	

Wpavement = [[[XAr_pavement*cfu,XBr_pavement*cfu],[XAl_pavement*cfu,XBl_pavement*cfu]],[[YAr_pavement*cfu,YBr_pavement*cfu],[YAl_pavement*cfu,YBl_pavement*cfu]]];
//echo (XAr_pavement=XAr_pavement, Wpavement=Wpavement); 

// Deviation on pavement arrival
XBr_pavdev = XAl_pavdev;
XBl_pavdev = XAr_pavdev;
YBr_pavdev = YAl_pavdev;
YBl_pavdev = YAr_pavdev;

Wpavdev = [[[XAr_pavdev*cfu,XBr_pavdev*cfu],[XAl_pavdev*cfu,XBl_pavdev*cfu]],[[YAr_pavdev*cfu,YBr_pavdev*cfu],[YAl_pavdev*cfu,YBl_pavdev*cfu]]];

//???
XBr_alley = XAl_alley;
XBl_alley = XAr_alley;

YBr_alley = YAl_alley;
YBl_alley = YAr_alley;

Walley = [[[XAr_alley*cfu,XBr_alley*cfu],[XAl_alley*cfu,XBl_alley*cfu]],[[YAr_alley*cfu,YBr_alley*cfu],[YAl_alley*cfu,YBl_alley*cfu]]];

//???
XBr_alley_pav = XAl_alley_pav;
XBl_alley_pav = XAr_alley_pav;

YBr_alley_pav = YAl_alley_pav;
YBl_alley_pav = YAr_alley_pav;

Walley_pavement = [[[XAr_alley_pav*cfu,XBr_alley_pav*cfu],[XAl_alley_pav*cfu,XBl_alley_pav*cfu]],[[YAr_alley_pav*cfu,YBr_alley_pav*cfu],[YAl_alley_pav*cfu,YBl_alley_pav*cfu]]];
//echo(Wpavement =Wpavement, Walley=Walley);
//-----------------------------------
pvXrA = XAr_alley?XAr_alley_pav:0;
pvXlA = XAl_alley?XAl_alley_pav:0;
pvYrA = YAr_alley?YAr_alley_pav:0;
pvYlA = YAl_alley?YAl_alley_pav:0;

pvXrB = XBr_alley?XBr_alley_pav:0;
pvXlB = XBl_alley?XBl_alley_pav:0;
pvYrB = YBr_alley?YBr_alley_pav:0;
pvYlB = YBl_alley?YBl_alley_pav:0;

Wpav_alley = [[[pvXrA*cfu,pvXlA*cfu],[pvXrB*cfu,pvXlB*cfu]],[[pvYrA*cfu,pvYlA*cfu],[pvYrB*cfu,pvYlB*cfu]]];

//Real alley pavement width
real_alley_pav = Wpav_alley-Wpavdev;

//---------------------------------
//??? cross lanes
// use cfu if cycle path became a width ???
XBr_cycle_path = XAl_cycle_path;
XBl_cycle_path = XAr_cycle_path;

YBr_cycle_path = YAl_cycle_path;
YBl_cycle_path = YAr_cycle_path;

Wcycle_path = [[[XAr_cycle_path,XBr_cycle_path],[XAl_cycle_path,XBl_cycle_path]],[[YAr_cycle_path,YBr_cycle_path],[YAl_cycle_path,YBl_cycle_path]]];
//----------------------------------
//??? cross cycle_double
XBr_cycle_double = XAl_cycle_double;
XBl_cycle_double = XAr_cycle_double;

YBr_cycle_double = YAl_cycle_double;
YBl_cycle_double = YAr_cycle_double;

Wcycle_double = [[[XAr_cycle_double,XBr_cycle_double],[XAl_cycle_double,XBl_cycle_double]],[[YAr_cycle_double,YBr_cycle_double],[YAl_cycle_double,YBl_cycle_double]]];
//----------------------------------
//??? cross lanes
XBr_park_lane = XAl_park_lane;
XBl_park_lane = XAr_park_lane;

YBr_park_lane = YAl_park_lane;
YBl_park_lane = YAr_park_lane;

Wpark_lane = [[[XAr_park_lane*cfu,XAl_park_lane*cfu],[XBr_park_lane*cfu,XBl_park_lane*cfu]],[[YAr_park_lane*cfu,YAl_park_lane*cfu],[YBr_park_lane*cfu,YBl_park_lane*cfu]]];
//----------------------------------
//??? cross lanes
XBr_cycle_lane = XAl_cycle_lane;
XBl_cycle_lane = XAr_cycle_lane;

YBr_cycle_lane = YAl_cycle_lane;
YBl_cycle_lane = YAr_cycle_lane;

Wcycle_lane = [[[XAr_cycle_lane*cfu,XAl_cycle_lane*cfu],[XBr_cycle_lane*cfu,XBl_cycle_lane*cfu]],[[YAr_cycle_lane*cfu,YAl_cycle_lane*cfu],[YBr_cycle_lane*cfu,YBl_cycle_lane*cfu]]];
//echo(Wpark_lane=Wpark_lane, Wcycle_lane=Wcycle_lane);
//---------------------------------
//Next 8 pos vector is required for vector substraction, as totwidth is a 4 pos vector
Wtotwidth =[[[totwidth[vX][vA],totwidth[vX][vA]],[totwidth[vX][vB],totwidth[vX][vB]]] , [[totwidth[vY][vA],totwidth[vY][vA]],[totwidth[vY][vB],totwidth[vY][vB]]] ];

Wroad_start = Wtotwidth/2-Wpavement-Walley-Wpav_alley;
Wmain_start = Wroad_start-Wpark_lane-Wcycle_lane;

//echo(Wmain_start =Wmain_start,Wmain_start2 =Wmain_start2, Wcycle_lane=Wcycle_lane, Wpark_lane=Wpark_lane );

//echo(Wpav_alley=Wpav_alley ,Wroad_start=Wroad_start);
//-------------------------------
//??? check
XBr_lane_arrows = XAr_lane_arrows;
YBr_lane_arrows = YAr_lane_arrows;

Wlane_arrows = [[XAr_lane_arrows,XBr_lane_arrows],[YAr_lane_arrows,YBr_lane_arrows]];
//echo (Wlane_arrows);
//---------------------------------
Wpedcross_wd = [[XA_pedcross_wd*cfu,(XX?XA_pedcross_wd:XBr_pedcross_wd)*cfu],[YA_pedcross_wd*cfu,(YY?YA_pedcross_wd:YBr_pedcross_wd)*cfu]];

Wpedcross_shift = [[XA_pedcross_shift*cfu,(XX?XA_pedcross_shift:XBr_pedcross_shift)*cfu],[YA_pedcross_shift*cfu,(YY?YA_pedcross_shift:YBr_pedcross_shift)*cfu]];
//echo(Wpedcross_shift =Wpedcross_shift);
//???
XBr_central = XA_central;

YBr_central = YA_central;

Wcentral = [[XA_central*cfu,XBr_central*cfu],[YA_central*cfu,YBr_central*cfu]];

//-- calculated variables -----------
//determine road display
disp_road=Display_road&&!Projection;

//Road priorities
Wpriority = [traffic_light || (road_priority==1)||(road_priority==0),traffic_light || (road_priority==2)||(road_priority==0)];

//pedestrian crossings and road limits
  //start of the inside surface ??
Wpav_start = Wtotwidth/2-Wpavement;

Allow_dev = [[XA_allow_dev,XB_allow_dev],[YA_allow_dev,YB_allow_dev]];

//== Fonctions ======================
// width with central pavement
function Wusewidth (axis,branch) = Wmain_start[axis][branch][vleft]+Wmain_start[axis][branch][vright]; 

// width excluding central pavement
function Wintwidth (axis,branch) = Wusewidth (axis,branch)-Wcentral[axis][branch];

function Wlane_wd2 (axis,branch) = Wintwidth(axis,branch)/(Wnb_lanes[axis][branch][vleft]+Wnb_lanes[axis][branch][vright]); 

// lanes are crossed 
Wnb_lanes = [[[XAr_nb_lanes,XAl_nb_lanes],[XBr_nb_lanes,XBl_nb_lanes]],[[YAr_nb_lanes,YAl_nb_lanes],[YBr_nb_lanes,YBl_nb_lanes]]]; 

//echo(Wnb_lanes=Wnb_lanes);
////test = [["x","xB"],["y","yB"]];
//test = [[["xAr","xAl"],["xBr","xBl"]],[["yAr","yAl"],["yBr","yBl"]]];
//decho ("tab test; XAl, YAr,YBr,YBl",test[vX][vA][vleft],test[vY][vA][vright],test[vY][vB][vright],test[vY][vB][vleft]);
//===================================
//Space between the road and the bike way, to set light (on right) and estimate bike storage space (on left).
function spacerk (a,b,side) = 
totwidth[a][b]/2-Wpavement[a][b][side]-Wcycle_wd(a,b,side)-Wmain_start[a][b][side]+(side?1:-1)*ispartdev(a,b,cr_border_r(a,b)); //*/

function Waxis_shift(a,b,side) = 
	Wmain_start[a][b][side]-Wlane_wd2(a,b)*Wnb_lanes[a][b][side]-Wcentral[a][b]/2;	
	
function Waxis (a,b) = 
	(Wmain_start[a][b][vleft]-Wmain_start[a][b][vright])/2-isdev(a,b);	

function Wcycle_pos2 (a,b,side) = 	Wcycle_lane[a][b][side]?(Wpark_lane[a][b][side])?Wroad_start[a][b][side]-Wpark_lane[a][b][side]:Wroad_start[a][b][side]:(Walley[a][b][side] && Wcycle_path[a][b][side])?totwidth[a][b]/2-Wpavement[a][b][side]:Wmain_start[a][b][side];
// if there is no cycle way, the cycling way is considered to be the beginning of the usable road

function Wcycle_wd (axis,branch, side) = Wcycle_lane[axis][branch][side]?Wcycle_lane[axis][branch][side]-cycle_lane_line:(Walley[axis][branch][side] && Wcycle_path[axis][branch][side])?Walley[axis][branch][side]:0;

//----------------------------------
// perpendicular branches
function paxis (axis) = axis?vX:vY;
function pbranch (axis,branch) = axis?(branch?vA:vB):(branch?vB:vA);
// previous branch (for border)
function prevbranch (axis,branch) = axis?(branch?vB:vA):(branch?vA:vB);
//-----------------------------------
//* ??? replace below by functions ? 
C1_radius= max(Wpavement[vX][vA][vright],Wpavement[vY][vA][vleft])+corner_offset; 
corner_C1 =[totwidth[vY][0]/2+C1_radius-YAl_pavement*cfu,totwidth[vX][0]/2+C1_radius-Wpavement[vX][vA][vright]];
//---------
C2_radius= max(Wpavement[vX][vB][vleft],Wpavement[vY][vA][vright])+corner_offset; 
corner_C2 =[-totwidth[vY][0]/2-C2_radius+YAr_pavement*cfu,totwidth[vX][0]/2+C2_radius-Wpavement[vX][vB][vleft]];
//----------
C3_radius= max(Wpavement[vX][vB][vright],Wpavement[vY][vB][vleft])+corner_offset; 
corner_C3 =[-totwidth[vY][0]/2-C3_radius+YAr_pavement*cfu,-totwidth[vX][0]/2-C3_radius+XAl_pavement*cfu];
//----------
C4_radius= max(Wpavement[vX][vA][vleft],Wpavement[vY][vB][vright])+corner_offset; 
corner_C4 =[totwidth[vY][0]/2+C4_radius-YAl_pavement*cfu,-totwidth[vX][0]/2-C4_radius+XAl_pavement*cfu];
//*/

radius1 = [[C1_radius,C3_radius],
[C2_radius,C4_radius]];
cy_radius1 = radius1;

corner1 = [[corner_C1,
[-corner_C3[0],-corner_C3[1]]],
[[corner_C2[1],-corner_C2[0]],
[-corner_C4[1],corner_C4[0]]]];
cy_corner1 = corner1;

function corner_pass(a,b) = radius1[a][b]-1.414*corner_offset;

corner_txt = str(
  round100(corner_pass(vX,vA)),"/",
	round100(corner_pass(vY,vA)),"/",
	round100(corner_pass(vX,vB)),"/",
	round100(corner_pass(vY,vB))," m"
);

//bikepath middle radius
function bk_radius(a,b) = (radius1[a][b]+radius1[paxis(a)][pbranch(a,b)])/2+rad_increase+Wcycle_wd(a,b,vright)/2+cycle_wd_extent_crossing/2;

//Bikepath radiuses for each branch XA to YB 
radius_txt = str(
	round100(bk_radius(vY,vB)),"/",
  round100(bk_radius(vX,vA)),"/",
	round100(bk_radius(vY,vA)),"/",
	round100(bk_radius(vX,vB))," m"
);

// bikelight adjust ~review that ???
island_pos1 = [[C1_island_pos1*cfu,C3_island_pos1*cfu],
[C2_island_pos1*cfu,C4_island_pos1*cfu]];

island_pos2 = [[C1_island_pos2*cfu,C3_island_pos2*cfu],
[C2_island_pos2*cfu,C4_island_pos2*cfu]];

//bike light adjust on double cycle path
dbl_light_adj = [[C1_dbl_light_adj*cfu,C3_dbl_light_adj*cfu],
[C2_dbl_light_adj*cfu,C4_dbl_light_adj*cfu]];

// t_cross bend shift 
tc_rshift = t_cross?Wpavement[vX][vA][vleft]:0;

//The following functions are all to define the external border Y coordinate of the bikeway in the crossing, as defined in the bikeway_cross(). This suppose all lanes end up contacting the main pavement corner, whatever alley, lanes, parking lane or else exists. This is the right lane continuing from the considered segment.
	
//-- External radius	
function cr_rad_ext (a,b) = (cy_radius1[a][b]+cy_radius1[paxis(a)][pbranch(a,b)])/2 + Wcycle_wd(a,b,vright)+cycle_wd_extent_crossing+rad_increase;

// External border position
function cr_border1 (a,b) = cy_corner1[a][b][1]-cy_radius1[a][b]*1.414+cy_corner1[a][b][0]-Waxis(paxis(a),pbranch(a,b))-(Wusewidth(paxis(a),pbranch(a,b))+straight_decrease)/2-cr_rad_ext(a,b)*0.414;

function cr_border2 (a,b) = cy_corner1[paxis(a)][pbranch(a,b)][0]-cy_radius1[paxis(a)][pbranch(a,b)]*1.414+cy_corner1[paxis(a)][pbranch(a,b)][1]-(Wusewidth(paxis(a),pbranch(a,b))+straight_decrease)/2-cr_rad_ext(a,b)*0.414+Waxis(paxis(a),pbranch(a,b));
//-- Final border result ---------- 
function cr_border_r (a,b) = min(cr_border1(paxis(a),prevbranch(a,b)),cr_border2(paxis(a),prevbranch(a,b)));

//-- Calculate road radius of a roundabout --
function round_road_radius() = 
min (
cr_border_r(vX,vA)-Wcycle_wd(vY,vB, vright),
cr_border_r(vY,vA)-Wcycle_wd(vX,vA, vright),
cr_border_r(vX,vB)-Wcycle_wd(vY,vA, vright),
cr_border_r(vY,vB)-Wcycle_wd(vX,vB, vright))-cycle_wd_extent_crossing;

d_roundline = 2*(round_road_radius()-roundabout_space);

//-- angle shape to cut islands --
module cutcorner (a, b, bottom=-100, ht=500, extent=true) {
	ap = paxis(a);
	bp = pbranch(a,b);
	bprev = prevbranch(a,b);
	wshift = Waxis(a,b);
  wshiftp = Waxis(ap,bp);
	border = cr_border_r(a,b);
	borderp = cr_border_r(ap,bp);
	way_tot = Wcycle_wd(ap,bprev,vright)+cycle_wd_extent_crossing;
	way_totp = Wcycle_wd(a,b,vright)+cycle_wd_extent_crossing;
	rad_ext = cr_rad_ext (ap,bprev);
	rad_extp = cr_rad_ext (a,b);
	xshift = cr_border1(ap,bprev)-cr_border2(ap,bprev);
	xshiftp = cr_border1(a,b)-cr_border2(a,b);
	usewd = Wusewidth(a,b)+straight_decrease;
	usewdp = Wusewidth(ap,bp)+straight_decrease;
	lgstrseg = usewd+abs(xshift);
	lgstrsegp = usewdp+abs(xshiftp);
	strshift = wshift+xshift/2;
	strshiftp = wshiftp+xshiftp/2;
	//start corner
	t(0,strshift) 
		t(border, lgstrseg/2,bottom) {
				rotz (-90)mirrory() 
					seg(way_tot, rad_ext, ht, false);	
			if(extent)
				cubez(way_tot,4000,ht,-way_tot/2,-2000);
		}	
	//end corner				
	t(strshiftp) 
		t(lgstrsegp/2,borderp,bottom) {
				mirrorx() mirrory() 
					seg(way_totp, rad_extp, ht, false);
			if(extent)
				cubez(4000,way_totp,ht,-2000,-way_totp/2);
		}	
	// straight junction				
	hull() {				
		t(strshiftp) 
			t(lgstrsegp/2,borderp,bottom)
				t(0,-rad_extp)
					rotz(-45) 
						cubez(1,way_totp,ht, 0,rad_extp-way_totp/2);
		t(0,strshift) 
			t(border, lgstrseg/2,bottom)
				t(-rad_ext,0)
					rotz(45) 
						cubez(way_tot,1,ht,rad_ext-way_tot/2);		
	}//hull()	
} //cutcorner()

//----------------------------------
//Give the off-centering of the main way without deviation 
function off_axis (a,b) = (Wmain_start[a][b][vleft]-
	Wmain_start[a][b][vright])/2;

//A deviation for centering main way is created if possible to optimize space for cars. This can be disallowed for each branch . 

function isdev (a,b) = 
	Allow_dev[a][b]?(
		off_axis(a,b)>500?min(Wpark_lane[a][b][vright],off_axis(a,b)):(off_axis(a,b)<-500?-min(Wpark_lane[a][b][vleft],abs(off_axis(a,b))):0)
	):0; 

//due to the angle, the deviation may be partial when not arrived to road junction, so we adapt - dev start at road side, but dist is coordinate (from center)
function ispartdev (a,b,dist,devlg = dev_length) = 
	isdev(a,b)*(1-(dist-totwidth[paxis(a)][prevbranch(a,b)]/2)/devlg);

//Cycle way is deviated toward the pavement corner
function iscycledev (axis,branch,side) = Wcycle_lane[axis][branch][side]?Wpark_lane[axis][branch][side]:0;

//--------------------------------
module disp_br (axis,branch) {
  if (!(axis&&branch&&t_cross)) children();	
}
// select branches and rotate according T cross
module rotroad(axis,branch) {
	disp_br(axis,branch)	
		rotz(Wang[axis][branch])
			children();
}

//-- Specification text ------  
basetext = [
"Spécification",	
  traffic_light?"Il y a des feux de trafic":str("PAS de feux de trafic",road_priority==1?", la route X a priorité":road_priority==2?", la route Y a priorité":", aucune route prioritaire"),
	str("Emprise route X branche A/B: ",XA_totwidth,"/",XB_totwidth?XB_totwidth:XA_totwidth,"m" ),
	str("Emprise route Y branche A/B: ",YA_totwidth,"/",YB_totwidth?YB_totwidth:YA_totwidth," m" ),

str("Route X branche A/BB largeur voie: ",round100(Wlane_wd2(vX,vA)),"/",round100(Wlane_wd2(vX,vB)),"m" ),	
str("Route Y branche A/BB largeur voie: ",round100(Wlane_wd2(vY,vA)),"/",round100(Wlane_wd2(vY,vB))," m" ),

str("Route X voie cyclable br.A droite/gauche: ",round100(Wcycle_wd(vX,vA,vright)),"/",round100(Wcycle_wd(vX,vA,vleft))," m"),
  str("Route Y br.A droite/gauche: ",round100(Wcycle_wd(vY,vA,vright)),"/",round100(Wcycle_wd(vY,vA,vleft))," m"),
  str("Passage au coin: ",corner_txt)
];

function roundabout_text() = round_int_diam?["Rond-point:",str("- Diamètre interne: ",_round_int_diam," m"),str("- Diamètre externe: ",round100(d_roundline)," m"),str("- Diamètre interne piste cyclable: ",round100(d_roundline+roundabout_space*2)," m")]:[]; 

spectxt = concat(
	basetext,
	roundabout_text(),
str("Rayon piste cyclable: ",radius_txt)  	
);

//*** program execution ***********
//*********************************
if (Projection) {
  disp_road=false;
  mirrorx(!right_drive) 
    projection() all();
} 
else {
  mirrorx(!right_drive) 
    all();
}

module all () {
	road(); // road, pavement and cycle path
  crossing(); // crossing
	disp_pedcross();
  disp_lanes(); // lanes marking, parking and bike lanes
  disp_arrows();
  disp_bike_signs();
  disp_islands();
	disp_roundabout();
	if (disp_road&&vh_disp) 
		disp_vehicles();
  check(); 
  red() disp_text();
	disp_signature();
}  

//------------------------------------
module road () { 
// Select according t_cross	
	Upvstart = [[[corner_C1[0],t_cross?0:corner_C4[0]],[t_cross?0:-corner_C3[0],-corner_C2[0]]],[[corner_C2[1],corner_C1[1]],[-corner_C4[1],-corner_C3[1]]]];
	//test = [[["xAr","xAl"],["xBr","xBl"]],[["yAr","yAl"],["yBr","yBl"]]];
	//axis=1;	branch=0;	side=0;
	for(axis=[0:1],branch=[0:1],side=[0:1]) 
		rotroad(axis,branch) {
			if (side==vright) {
				//-- road ------------------
				if(disp_road)
				color(color_road)
					cubex(road_length,totwidth[axis][branch],18, 0,0,-10);
			 //-- Main pavement corners --	
				t(perpwidth[axis][branch]/2,totwidth[axis][branch]/2)
					pav_corner(Wpavement[axis][branch][vright],Wpavement[paxis(axis)][pbranch(axis,branch)][vleft]);
			}	
			//All side pavement
			all_pav(axis, branch, side);
		}	// rotroad 

	module all_pav(axis, branch, side) {
		devpav=Wpavdev[axis][branch][side];
		tot2 = totwidth[axis][branch]/2;
		perp2 = perpwidth[axis][branch]/2;
		cycledouble = Wcycle_double[axis][branch][side];
		cyclepath=Wcycle_path[axis][branch][side];
		pav = Wpavement[axis][branch][side];
		pavalley = Wpav_alley[axis][branch][side];
		Ualley = Walley[axis][branch][side];
		park = Wpark_lane[axis][branch][side];
		
		pedshift = Wpedcross_shift[axis][branch];
		ped = Wpedcross_wd[axis][branch];
		upvst = Upvstart[axis][branch][side];
		recess = ped?perp2+pedshift+ped/2-upvst:0;
		recess_wd=ped?ped-500:0;
		dev = isdev(axis,branch);
		//echo(dev=dev);
		module side_alley (bottom, top, width=Ualley) {
			t(upvst,tot2-pav-Ualley/2-devpav, bottom) {
				//coef 0.985 rough correction for tangent, adapt to angle ?
					line2(width,-140,cydev_length+170,0,1000,0,top,devpav*0.985);
					line2(width,cydev_length,road_length-upvst+100,0,1000,0,top);
			}
	  }
		mirrory(side) {
			color(color_pavement)
				diff() {	
				// main pavement + pavalley
					hull() {
						t(upvst, tot2) 
							pavement(pav,road_length-upvst, false, recess, recess_wd);
						if(Walley[axis][branch][side])
							t(perp2+pedshift+ped, tot2-pav-Ualley)
						pavement(pavalley,road_length-perp2-ped-pedshift, true);
					}//hull() //:::::::::::
					//== CUT ============
					if (Ualley) 	
						side_alley(-100,400);
					//pedestrian crossing
					cubey (ped,-20000,600, perp2+pedshift+ped/2,tot2-pav-Ualley+100);
					//pedestrian recess
					if(recess)
						t(recess+upvst,tot2-pav-10, 1)
							ramp(2000);
				} //diff()	
				//pavement separating alley and road		 
				if(Ualley)
					t(perp2+pedshift+ped, tot2-pav-Ualley){
						//pavement start side shift when cycle way deviated
						pavshift = devpav*(pedshift-(upvst-perp2))/cydev_length;
						t (0,-pavshift)
							pav_start(-ped,pavalley-pavshift,0,400);
						border_start = cr_border_r(axis,branch)-perpwidth[axis][branch]/2+250;
						//Protection of deviated lanes
						dev2 = side==vleft?(dev>0?dev:0):dev<0?-dev:0;
						if (dev2) {
							t(-ped-pedshift,-pavalley)	
								protect_dev(border_start,pedshift,ped,0,dev2);
						}	
						//protection of parking lanes when cycle path
						if(park)
							t(-ped-pedshift,-pavalley)	
								protect_dev(pedshift-500,pedshift,ped,park,-(side?-1:1)*dev,false);	
					} //t()
		 //If cycle path alley ???
			// build protection for cycle lanes also ???		
			if(disp_road && cyclepath) {
				startcycle=t_cross&&axis==vX&&((branch==vA&&side==vleft)||(branch==vB&&side==vright))?0:perp2;
				color(color_cycle) 
				  side_alley(10,20);
				//	t(startcycle, tot2-pav-Ualley/2)
				//	cubex(road_length-perp2,Ualley,20, 0,0,10);
			white()
				if(cyclepath && cycledouble)
					side_alley(10,25, cycle_cent_line);
				/*	t(0, tot2-pav-Ualley/2) {
						line2(cycle_cent_line,perp2,road_length,0,1000,0,22);
					} */	//cubex(road_length-perp2,cycle_cent_line,20, 0,0,15);
			}
		} // mirrory
		// Central separation - central lane width left to 2.7m.
		central = Wcentral[axis][branch];
		coord = Wmain_start[axis][branch][vright]-Wnb_lanes[axis][branch][vright]*Wlane_wd2(axis,branch)-central/2;
		if (Wnb_lanes[axis][branch][vleft]>=2 && Wnb_lanes[axis][branch][vright] && side==vright) {
			wdc2 = (Wlane_wd2(axis,branch)-2700);
			devped = dev*(1-(ped+pedshift+150)/dev_length);
			devped2 = dev*(1-(pedshift-150)/dev_length);
			white() {
		    cylz (150,1000,perp2+dev_length,coord);	
				cylz (150,1000,perp2+pedshift-250,coord+devped2);	
			}	
			color (color_pavement) {
				hull() {
					t(perp2+dev_length, coord)
					dmirrory()
						cylz(300,pavht,0,central?central/2-150:0,0,pavseg);
					  
					t(perp2+dev_length/2,coord+dev/2)
						dmirrory()
							cylz(300,pavht,0,wdc2+central/2-150,0,pavseg);
					
					t(perp2+ped+pedshift+150,coord+devped)
						dmirrory()
							cylz(300,pavht,0,wdc2++central/2-150,0,pavseg);
				} //hull() 
				// before ped crossing
				hull(){
				  t(perp2+pedshift-150,coord+devped2)	  dmirrory() duplx(-200)
							cylz(300,pavht,0,wdc2++central/2-150,0,pavseg);
				}
			}	
		} // central block/enlargement if 2x2	
	}	//all_pav()	-------------------	
}// road()
//--------------------------------
module protect_dev (start=0,pcross_shift,pcross_wd,park,dev, trian=true) {
	diam= 300;
	dev1 = park+dev*(1-(pcross_shift)/dev_length);
	dev2 = park+dev*(1-(pcross_shift+pcross_wd)/dev_length);
	color (color_pavement) { 
		hull()
			duply(-dev1+200) { 
				cylz(diam,pavht, pcross_shift-diam/2,0,0,pavseg);
				cylz(diam,pavht, start+diam/2,0,0,pavseg);
			}
		hull() {
			duply(-dev2+diam/2)
				duplx(200) //if diam 300->width 500
					cylz(diam,pavht, pcross_shift+pcross_wd+diam/2,0,0,pavseg);
			if (trian)
				cylz(150,pavht, dev_length,75,0,8);
		}
  }
}
//------------------------------------
module pavement (width, length, sep=false, recess = 0, width_recess = 2000) {
  module remove() { // recess for ramp
     if(recess)
       t(recess,-width-10, 1)
         ramp(width_recess);
  }
  if(width){
    color(color_pavement_border) {
      diff() {
        u(){
          cubey(length,150,pavht+2, length/2,-width,pavht/2-2); 
          if (sep)
            cubey(length,-150,pavht+2, length/2,0,pavht/2-2); 
        }
        remove();
      }  
    }  
    color(color_pavement)
      diff() {
        cubey(length,-width,pavht, length/2,0,pavht/2);    
        remove();  
      }
  }
} //pavement() 
//----------------------------------
//pavement island at the start (before pedestrian crossing)
module pav_start (pos,width,sidepos,extent=250) {
	dx = min(width, 600);
	color(color_pavement)
		t(pos-extent,sidepos-width/2) {
			hull()
				dmirrory() 
					cylz (dx, pavht, 0,(width-dx)/2);
			cubex (extent, width, pavht, 0,0,pavht/2); 
		}   
}

//-- 45 deg segments for crossing ----
module seg (width, radius, depth=10, intrad=true) {
// radius is internal radius by default	
// position is the segment AXIS	start if internal, but EXTERNAL for external radius
	addext = intrad?2*width:0;
	addint = intrad?0:-2*width;
	
	t(0,radius+(intrad?1:0)*width/2)
		diff() {
			cylz(2*radius+addext,depth, 0,0,0, 36);  
			//::
			cylz(2*radius+addint,40+depth, 0,0,-20, 36);  
			cubez(32000,50000,40+depth, 16000,0,-20); 
			rotz(-45)
				cubez(32000,50000,40+depth, -16000,0,-20); 
		}  
}

//==================================
module crossing () {
//	a=vY; b=vA;
	for(a=[0:1],b=[0:1]) {
		disp_br(paxis(a),pbranch(a,b))	// perpendicular !!
			rotz(Wang[a][b])
				if (Wcycle_wd(a,b,vright)) 
					bikeway_cross(a,b); 
	} // for
	
//-- modules ------------------------
module bikeway_cross (a,b) // a(xis), b(ranch) 	
	{
/*design basis
- within the crossing, the way width is the extended width, corner radiuses are the maximum of inlet and outlet corners. The inlet width increase is done by shift the normal width bent	
- The internal radius is based upon main radius but could be increased to have a more round crossing, at the cost of motorised vehicles space reduction. This will give a more 'roundabout' look.
*/
		ap = paxis(a);
		bp = pbranch(a,b);	
		usewd = Wusewidth(a,b)+straight_decrease;
		//echo(usewd=usewd,a=a,b=b);
		usewdp = Wusewidth(ap,bp)+straight_decrease;
		total = totwidth[a][b];
		ptotal = perpwidth[a][b];
		dist = total/2-Wpavement[a][b][vright];
		way_wd = Wcycle_wd(a,b,vright);
		// bikeway enlargement in road crossing
    fenlarg = cycle_wd_extent_crossing; 
    enlarg = fenlarg/2;
		way_tot = way_wd+fenlarg;
		
		double = Wcycle_double[a][b][vright];
		priority = Wpriority[a];
		pos1= cy_corner1[a][b][0];
		pos2= cy_corner1[ap][bp][1];
		// side shift if inequal pavement
		//??? next shall take into account de deviation
		wshift = Waxis(ap,bp);
		devp = isdev(ap,bp);
	//	of = off_axis(ap,bp);
	//	echo(devp=devp, of=of, wshift=wshift);
		signal = Wroad_start[ap][bp][vleft]-Wpark_lane[ap][bp][vleft]-Wcycle_lane[ap][bp][vleft]-Waxis_shift(ap,bp,vleft);
		
		signal2 =Wroad_start[ap][bp][vright]-Wpark_lane[ap][bp][vright]-Wcycle_lane[ap][bp][vright]-Waxis_shift(ap,bp,vright);
		// radius max from both corners	
		radius1 = cy_radius1[a][b];
		radius2 = cy_radius1[ap][bp];
		radius = (radius1+radius2)/2;
    rad_mean = radius+way_tot/2+rad_increase; 
		rad_ext = rad_mean+way_tot/2;
		//bikeway tangenting points
		ct1x = pos1-radius1*0.707;
		ct1y = cy_corner1[a][b][1]-radius1*0.707;
		ct2x = pos2-radius2*0.707;
		ct2y = cy_corner1[ap][bp][0]-radius2*0.707;
		//----------
		b1x = usewdp/2+rad_ext*0.707; 
		b1xs = wshift+b1x;
		b2xs = b1x-wshift;
		
		diffx1 = ct1x-b1xs;
		diffx2 = ct2x-b2xs;
		//echo(rad_ext=rad_ext,ct1x =ct1x,ct1y =ct1y, radius1=radius1);
		border1=ct1y+diffx1+rad_ext*0.293;
		border2=ct2y+diffx2+rad_ext*0.293;
		border = min(border1,border2);
	
//echo(border1=border1,border1x=border1x,border2=border2,border2x=border2x);	
		
		xshift = border1-border2;
		// real difference after shifting
		diffx1r = xshift>0?diffx1-abs(xshift):diffx1;
		diffx2r = xshift>0?diffx2:diffx2-abs(xshift);
//echo(xshift=xshift,diffx1r=diffx1r,diffx2r=diffx2r);
		
		//straight segment lengthened by assymetry
		lgstrseg = usewdp+abs(xshift);
		strshift = wshift+xshift/2;
		b1y = border-rad_ext*0.293;
		*blue() {
			cylz (200,2000,ct1x,ct1y);
			cylz (200,2000,-ct2x,ct2y);
		}	
		//cylz (200,2000,b1x,b1y);
	//echo(border=border, xshift=xshift);
  //echo(usewd=usewd,usewdp=usewdp, wshift=wshift);
	  //--------------------------------
    if (priority && disp_road)
      color(color_cycle) {
					//bends
				 t(strshift) {
					 dmirrorx() 
					  t(lgstrseg/2,border,8)
							mirrorx() mirrory() 
								seg(way_tot, rad_ext, 10, false);
					 // middle straights  
					t(0,border-way_tot/2)
						cubez(lgstrseg,way_tot,20);
				  }
				 //right seg 
				  t(pos1,total/2-Wpavement[a][b][vright]-way_wd/2,8) 
					  duplx(-fenlarg*1.414)
					    seg(way_wd, radius1,10);
					//left seg 
				  t(-pos2,total/2-Wpavement[a][b?0:1][vleft]-way_wd/2,8) 
					  duplx(fenlarg*1.414)
					    mirrorx() seg(way_wd, radius2,10);
					//bias right
					if (diffx1r>0)
						t(ct1x,ct1y)		
							rotz(-45)
								cubex(-diffx1r*1.414,way_tot,20, 0,-way_tot/2,10);
				 //bias left
					if (diffx2r>0)
						t(-ct2x,ct2y)		
							rotz(45)
								cubex(diffx2r*1.414,way_tot,20, 0,-way_tot/2,10);
					
		//== turns in case of double direction path on perpendicular axis == 
				pdoublel = Wcycle_double[ap][bp][vleft];
				pdoubler = Wcycle_double[ap][bp][vright];
				pposr = -Wcycle_pos2(ap,bp,vright)+Wcycle_wd(ap,bp,vright);
				pposl = Wcycle_pos2(ap,bp,vleft)-Wcycle_wd(ap,bp,vleft);
				if(pdoubler)  //???
				  t(pposr, border) 
						turn(way_wd);	
				if(pdoublel) 
				  t(pposl, border) 
						turn(way_wd, vleft);	
      } // cycle way color
   //-- cycle lane markings --------  
		white()  {
      // bends
		t(strshift)	
			dmirrorx() 		
				t(lgstrseg/2,border-way_tot/2,5)
					mirrorx() mirrory() 
						diff() {
							seg(way_tot+cycle_cross_line*2, rad_mean-way_tot/2-cycle_cross_line);
							t(0,0,-10)
								seg(way_tot, rad_mean-way_tot/2,30);
						}
	//echo (way_tot=way_tot, rad_mean=rad_mean);
			
      //---------------
			//right seg 
				  t(pos1,total/2-Wpavement[a][b][vright]-way_wd/2,5) 
					  diff() {
							duplx(-fenlarg*1.414) 
						seg(way_wd+cycle_cross_line*2, radius1-cycle_cross_line);
					    duplx(-fenlarg*1.414)
								seg(way_wd, radius1,30);
						}	
					//left seg 
				  t(-pos2,total/2-Wpavement[a][b?0:1][vleft]-way_wd/2,5) 
						mirrorx()
						diff() {
							duplx(-fenlarg*1.414)
								seg(way_wd+cycle_cross_line*2, radius2-cycle_cross_line,10);
							duplx(-fenlarg*1.414)
								seg(way_wd, radius2,30);
						}	
			
	  if (double)
			t(usewdp/2,border-way_tot/2,15)
        mirrorx() mirrory()
					seg(cycle_cent_line, radius+way_wd/2-enlarg);		
		//} //dmirrorx()
	//*	line between lanes ???		
//---------------------------------
      // straights lines
      t(strshift,border-way_tot/2)  {
        dmirrory()
					t(-lgstrseg/2,way_wd/2+enlarg)
			    line2(cycle_cross_line,0,lgstrseg,1,1000,500,10);	
			 // mark separator line ???
        if(double)
					t(-usewdp/2)
						line2(cycle_cent_line,0,usewdp,0,1000,0,55);
        // bike symbols  - not ok for double direction ??? 
		    if (double) {
					t(0,-way_wd/4-enlarg/2)
						mirrorx() bike(fill=true);
					t(0, way_wd/4+enlarg/2)
						bike(fill=true);
				}
			  else		
					bike(fill=true);
      } 
    } // white
		//------------------------------	
    // priority triangle marking 
    t(-Waxis_shift(ap,bp,vright)-devp,border-way_tot/2) {
      teeth(-way_tot/2-cycle_cross_line-cycle_triangle_dist, signal, false);
        if(priority)
          teeth(way_tot/2+cycle_cross_line+cycle_triangle_dist, -signal2, true);
      }  
  } // bikeway_cross() 
//---------------------------------
// next module for turns between bike ways required when double path	
module turn (width, side=vright, radius=0) {
  rad = radius?radius:1.3*width;
	mirrorx(!side)
		t(-rad+width/2,rad-width/2)
			diff() {
				cylz (rad*2+width,25, 0,0,-5);
				cylz (rad*2-width, 100, 0,0,-10);
				cubex (-20000,20000,80);
				cubey (20000,20000,90);
			}	
}	
	
	
} //crossing()

//------------------------------
  //Priority triangles on bike way - along X line
module teeth (pos, length, mirr=false) {
	plength = abs(length);
	nb = floor((plength+500)/cycle_triangle_sp);
	white() 
		mirrorx(!right_drive)
			mirrorx(length<0)
				duplx(cycle_triangle_sp, nb-1)
					t(0,pos)
						mirrory(mirr)
							// projection()
							linear_extrude(height=5)
							polygon([[0,0],[cycle_triangle_wd,0],[cycle_triangle_wd/2,-cycle_triangle_lg]]);
}//teeth()

//-- road pedestrian crossing -------
module disp_pedcross () {
	for(axis=[0:1],branch=[0:1])
		rotroad(axis,branch)
			ped_crossing(axis,branch);
	 //-- modules ---------------------
	module ped_crossing (axis,branch) {
//decho("ped_crossing:pos,start,rstart,width,length, notcar_lane, rd_shift,  light_dist",pos,start,rstart,width,length, notcar_lane, rd_shift, light_dist);		
		road = perpwidth[axis][branch]/2;
		notcar_lane = Wpark_lane[axis][branch][vright]+Wcycle_lane[axis][branch][vright];
		start = Wpav_start[axis][branch][vright];
		rstart = Wroad_start[axis][branch][vright];
		rd_shift = Waxis_shift(axis,branch,vright);	
	  pedcross_shift= Wpedcross_shift[axis][branch];
		width = Wpedcross_wd[axis][branch];
		length = Wpav_start[axis][branch][vright]+Wpav_start[axis][branch][vleft];	
		dev = isdev(axis, branch);
		pos = road+pedcross_shift;
		white() {
			if (width) { //if pedestrian cross
				t(pos,start)
					rotz(-90) {
						if (pedcross_zebra) //is zebra type 
							line2(width,0,length,1,2*ped_zebra_line,ped_zebra_line,34); 
						else 
							duply (width-pedcross_side_line)
								line2(pedcross_side_line,0,length,1,1000,ped_zebra_line,34); 
					}
			//dashed stop line ???
				stpos = pedcross_shift+width+stop_line;	
				devstop = dev*(1-stpos/dev_length);		
				diff() {
					t(road+stpos,rstart-notcar_lane+devstop)
						rotz(-90)
							line2(stop_line_thk,0,length,1,stop_line_lg,stop_line_sp,12); 
				 //:::::
				 cubey (1000,-30000,60,  pos+width+stop_line+250,rd_shift+devstop,-10);
				}  
			} // ped cross
		}// white  
		// traffic light
		// Check pavement width with traffic light ??
		lightsp = spacerk(axis,branch,vright);
		//echo (lightsp=lightsp);
		lpos = lightsp>=600?min(light_pole_dist,lightsp/2):light_pole_dist;
		
	//Light position on pavement
		pavpos =  totwidth[axis][branch]/2-Wpavement[axis][branch][vright]+lpos;
	// light position between bikeway and road	
		spacepos = totwidth[axis][branch]/2-Wpavement[axis][branch][vright]-Wcycle_wd(axis,branch,vright)-lightsp+lpos+150;
	// final light position
		light_ypos = lightsp>=600?spacepos:pavpos;
		//light_ypos = light_pole_dist+rstart-Wpark_lane[axis][branch][vright]+dev;
		tr_pos = light_after_crossing? pos-250: pos+width+250;
		if (traffic_light&&disp_road) // ??
			t(tr_pos,light_ypos) {
				side_traffic_light();
				color (color_pavement)
				  cylz (600, pavht);
			}	
  } //ped_crossing()
} //disp_pedcross() 

//-----------------------------------
module disp_lanes () {
	  // lanes separation, including central pavement
	for(axis=[0:1],branch=[0:1]) {
		rotroad(axis,branch) {
			dev = isdev(axis,branch); // global deviation (right side)
			road = perpwidth[axis][branch]/2;
			pcross_shift = Wpedcross_shift[axis][branch];
			pcross_wd = Wpedcross_wd[axis][branch];		
			Wlane_sep(road,pcross_shift,pcross_wd, Wmain_start[axis][branch], Wnb_lanes[axis][branch], Wcentral[axis][branch], Wlane_wd2(axis,branch), dev);
			// park and cycle lanes
			for(side = [0:1]) {
				cydev = iscycledev(axis,branch,side);
				deviate = cydev?cydev:side?-dev:dev;
				
				pk_lane = Wpark_lane[axis][branch][side];
				rstart = Wroad_start[axis][branch][side];
				cy_lane = Wcycle_lane[axis][branch][side];
		
				dev2 = Wcycle_lane[axis][branch][side]?Wpark_lane[axis][branch][side]:0;
				dlength = dev?dev_length:cydev_length;
				
				mirrory(side) {
					//-- Parking lanes ---------
					t(road, rstart)
						dpark_lane(road,pk_lane,axis,branch,side, deviate, dev);
					//-- Cycle lanes -----------
					if(cy_lane) //there's cycle lane
						t(road, rstart-pk_lane)
							dcycle_lane(road,cy_lane,pcross_shift,pcross_wd,side, pk_lane,dlength, dev2, dev);
				}
			}
		}	
	}		
  //-- modules ----------------------
	// parking lane draft
	module dpark_lane (road,width,axis,branch, side, deviate=0, dev2=0) {
		pcross_shift = Wpedcross_shift[axis][branch];
		pcross_wd = Wpedcross_wd[axis][branch];
		//dev = isdev(axis,branch);		
		dlength = dev2!=0?dev_length:cydev_length;
		dev = deviate;
		pos = road+pcross_shift+pcross_wd;
    pkstart = dev!=0?(dlength-pcross_shift-pcross_wd):(pcross_wd)?(!side)?park_protect:500:2500;
    safelg = (pkstart==500)?500:(pcross_wd)?park_protect:2500;
    ang = (pkstart==500)?0:(pcross_wd)?60:50;
    red = (pcross_wd)?-1400:-500;
    red2 = -1200;
		nbk = floor((road_length-pkstart-pos)/park_space);
		spacex = deviate?0:500;
		wdend = width-dev*(1-(pcross_shift+pcross_wd)/dlength);
		//echo(width=width, wdend=wdend, sidepole=sidepole);
		nb_poles = floor((pkstart-200)/2500);
	  sidepole = nb_poles>1?(width-wdend)*0.5/(nb_poles-1):0;	
		//-----------------------------------
		if(width){ // park lane exists
			// dashed line
			//echo(axis=axis, branch=branch, side=side,deviate=deviate);
			white(){
				t(0,-width) { //--
					line2(100,pkstart+pcross_shift+pcross_wd,dlength,1,1000,spacex,10, deviate);
					line2(100,dlength,road_length-road,1,1000,500,10);
				}	
			}	
			t(pcross_shift+pcross_wd) {
				white(){
				// place separations
					duplx(park_space, nbk) //--
						cubex(100,width,10, pkstart,-width/2);
					if (!parking_island_concrete) {	
						diff() {
							safe_frame();
							safe_frame(300);
						}
						intersection() {
							safe_frame();
							duplx (500,42)
								t(-width/1.6) rotz(45)
									cubez (100,width*1.5,10, 0,-width/1.6,-5);  
							
						}  
					}
			  }// white
				if (parking_island_concrete) 
					color (color_pavement) 
						hull() {
							safe_frame();
							safe_frame(200);
						}
				else {	
					// protection poles
					for (i=[0:nb_poles])
						white()
							cylz(150,800,pkstart-2500*i,-width/2+sidepole*i,0,8); 
				/*	if (dev==0) {
						white() {
							cylz(150,800,safelg-100,-width/2); 
							if(pkstart!=500)   
								cylz(150,800,safelg/2,-width/2); 
						}
						gray() { // protection pole rings
							cylz(152,120, safelg-100,-width/2,600); 
							if (pkstart!=500)   
								cylz(152,120, safelg/2,-width/2,600); 
						}
					} */
				}	
			} 
	  }	
	//-- no parking	zone on 5m (by law)-
    module safe_frame (dcl=0) {
			ctr = parking_island_concrete?300:0;
			ht = 	parking_island_concrete?pavht+dcl/3:20+dcl/3;
			if(dev!=0) { //triangle for deviation
				diff() {
					hull() {
						endwd = min(-10,-width+dev*(1-(pcross_shift+pcross_wd)/dlength)+2*dcl);
						//echo(endwd=endwd); 
						cubey(1,endwd,ht,
							2*dcl,-dcl,ht/2-5);
						cubey(1,-width+2*dcl,ht,dlength-pcross_shift-pcross_wd-dcl,-dcl,ht/2-5);
					}
					t(dlength-pcross_shift-pcross_wd+100,red2,-20) 
						rotz (-65)
							cubey(2000,-park_protect, 600, 800-dcl);
				}	
			}
			else //protected area
				diff() {
					cubex(safelg-dcl,width-dcl-ctr,ht, dcl/2,-width/2+150-ctr/2,ht/2-5);
					t(0,red,-20) 
						rotz(ang)
							cubey(2000,-park_protect,600, -1000+dcl/1.6);
					if(safelg> 4000) // long place
						t(safelg,red2,-20) 
							rotz (-65)
								cubey(2000,-park_protect,600, 1000-dcl/1.6);
				}
    } // safe_frame()	
  } //dpark_lane	
	//-------------------------------
	module dcycle_lane (road, width, pcross_shift, pcross_wd=2500, side = vright, park_lane=0, dlength, dev2, dev) {
		pos = road+pcross_shift+pcross_wd;
    pkstart = ((pcross_wd)?(!side)?4900:500:500)+pcross_shift+pcross_wd;
		rl = road_length-road;
		if (disp_road)
			color (color_cycle)
				line2(width-cycle_lane_line,-500,dlength,-1,10,0,5,dev2);
    white() {//  line
			duply(-width) {
				line2(cycle_lane_line,0,dlength,1,10,0,10,dev2);
				line2(cycle_lane_line,dlength,rl,1,10,0,10);
			}	
			t(0,-width)
				// line if cycle deviation only
				if(dlength==cydev_length)
					line2(cycle_lane_line,0,dlength,1,10,0,10,0);
				else 
					line2(cycle_lane_line,0,dlength,1,10,0,10,(side?-1:1)*dev);
      if (park_lane) {
				duply (-500)
					line2(100,dlength, rl,1,10,0,10);
				t(dlength) 
					duplx(1000, floor((rl-dlength)/1000)-1)
						rotz(55) 
							cubey(100,-800,10);
      }  
    } 
  }
  //--lanes separation w/central pavement
	module Wlane_sep (road,pcross_shift,pcross_wd, mstart, lane, central, lane_wd, deviate=0) {
		pos = road + pcross_shift;
    st1 = stop_line;
    st2 = 0;  
		rl = road_length-road;
		ang = atan(-deviate/dev_length);
		lstart1 = pcross_shift+pcross_wd+st1;
		lstart2 = pcross_shift+pcross_wd+st2;
		//-- lines ----------------------
    white() {
			// right
      if (lane[0]>1)
        for(i= [1:lane[0]-1]) 
					t(road, mstart[0]-lane_wd*i) {
						line2(road_sep_line,lstart1,dev_length,0,10,0,5, deviate);
						line2(road_sep_line,dev_length,rl,0,10,0,5, 0);
				  }
			// left	
      if (lane[1]>1) {
        for(i= [1:lane[1]-1]) 
					t(road, -mstart[1]+lane_wd*i) {
						line2(road_sep_line,lstart2,dev_length,0,10,0,5,deviate);
						line2(road_sep_line,dev_length,rl,0,10,0,5,0);
					}
			}		
			else if (deviate!=0)
				t(road, -mstart[1]) 
						line2(road_cent_line,lstart2,dev_length,0,10,0,5,deviate);
				
    } 
		//-- central pavement -----------
		coord = mstart[0]-lane[0]*lane_wd;
    if (central) {
      //coord = -mstart2+lane2*lane_wd+central;
			t(road+dev_length, coord) {
        pavement(central,rl-dev_length,true);
				rotz(ang)
					mirrorx() {
						pavement(central,dev_length-pcross_shift-pcross_wd,true);
						t(dev_length-pcross_shift)
						pavement(central,800);
					}	
			}
    } 
    else { // central line
      white() 
				t(road, -mstart[1]+lane_wd*lane[1]) {
					line2(road_cent_line,lstart2,dev_length, 0, 10,0,5,deviate);
					line2(road_cent_line,dev_length,rl, 0, 10,0,5);
				}	
		}
  }
} //disp_lanes()

module disp_islands (){// cycling way islands
//	axis=0;	branch=0;
  for(axis=[0:1],branch=[0:1])
	  rotz(Wang[axis][branch]) 
			island(axis,branch);
}

//-- some legacy here which shall be reviewed --
module island (axis,branch) {
	cydouble = Wcycle_double[axis][branch][vright];
	axisp = paxis(axis);
	prevbranch = prevbranch(axis, branch);
	branchp = pbranch(axis,branch);
	borderx = cr_border_r(axis,branch);
	bordery = cr_border_r(axisp,branchp);
	wayr = Wcycle_wd(axis,branch,vright);
	waypl = Wcycle_wd(axisp,branchp,vleft);
	wayprev = Wcycle_wd(axisp,prevbranch,vright);
	dblprev = Wcycle_double[axisp][prevbranch][vright];
	//way stop line length
	linelg = (wayr+cycle_wd_extent_crossing+400)/(cydouble?2:1)+450; 
	dev = isdev(axis,branch);	
	
  xil2 = Wmain_start[axisp][branchp][vleft]-ispartdev(axisp,branchp,bordery);
	
  yil2 = cr_border_r(axisp,branchp)-wayr-cycle_wd_extent_crossing-island_pos2[axis][branch];

	xil1 =borderx-wayprev-cycle_wd_extent_crossing-island_pos1[axis][branch];
	
	border1 = (Walley[axis][branch][vright]?Walley_pavement[axis][branch][vright]:0)+Wpark_lane[axis][branch][vright]-dev;
	border1r = max (border1-500,100);
	
	yil1 = totwidth[axis][branch]/2-Wpavement[axis][branch][vright]-wayr
-border1r;

// bike traffic light AND stop line priority logic handled within module
// concrete block to pedestrian 
	lighty = bordery+300;
	extent = totwidth[axis][branch]/2+Wpedcross_shift[paxis(axis)][pbranch(axis,branch)]-lighty;

	if(Wcycle_wd(axis,branch,vright))
		t(xil2+250,lighty)
			bikelight(-20,150,-83,linelg,axis, extent);

	if (dblprev) 
		t(xil1-200-dbl_light_adj[axis][branch],yil1+150)
			rotz(90)
				bikelight(0,150,-90,wayprev/2+600,axis,0);

//blue() cylz (200,2000,borderx,0);
//green() cylz (200,2000,0,bordery);
	//-- Island ---------------------
	xext = borderx-Wmain_start[axisp][branchp][vleft]-radius_clearance+isdev(axisp,branchp);
	yext = bordery-Wmain_start[axis][branch][vright]-radius_clearance-dev;
 //Bias on island only if roundabout
 quart_bias=round_int_diam?round_bias*0.707:0; 	
	//-- islands ---------
  if (!(t_cross&&branch==vB)&&Wcycle_wd(axis,branch,vright)) {
		//Only truck pavement if sufficient room ??
		istruckpav = (xext+yext)>16000&&!quart_bias;
		pavcarht = istruckpav?pavht/2:pavht;
		color(color_pavement_border)
			if(istruckpav) //truck island
				diff() {
					t(borderx,bordery) rotz(180)
						quart_shape(truck_radius,xext,yext,xext/3,pavht,0);
					//:::::::::
					cutcorner(axis,branch);
					cut_diag();
				}
		color(color_pavement)
			diff(){ // car island
				t(borderx,bordery) rotz(180)
					quart_shape(car_radius,xext,yext,xext/2.5,pavcarht,diag=quart_bias);
				//:::::::::
				cutcorner(axis,branch);
				if (quart_bias) {
					// cut internal cylinder
					cylz(d_roundline,500,0,0,-100);
					//bias cut pushed 500 mm due to round shape
					cut_diag(500);
				}	
				else // cut diagonally
					cut_diag();
			}	
	// Redraft the road angle for proper diagonal, only if there is perpendicular bikeway, are cut along island border	
		xcut = borderx-xext;
		ycut = bordery-yext;	
		if(Wcycle_wd(paxis(axis),prevbranch(axis,branch),vright))
			color(color_cycle)
				diff() {
					cutcorner(axis,branch,2,15,false);		
					//::::::::::::::::
					cubex (-10000,10000,100,xcut,bordery,-10);
					cubey (10000,-10000,100,borderx,ycut,-10);
				}	
	}	
	// cut diagonally to remove what expand over the way
	module cut_diag (dec=0){
		t(corner1[axis][branch][0]-radius1[axis][branch]+dec,corner1[axis][branch][1]-radius1[axis][branch]+dec)  
				rotz (-45) 
				  cubez (24000,4000,500, 0,2000,-100);
	}	
}//Island()

module quart_shape (radius,wdx,wdy, way, ht=pavht, extent=-1500, diag=0) {
	exty = wdy-radius+extent-diag;
	extx = wdx-radius+extent-diag;
	cutx = radius>(wdx+extent)?radius-wdx-extent:0;
	cuty= radius>(wdy+extent)?radius-wdy-extent:0;
	//cylz (150,2000,wdx-radius,wdy-radius);
	tslz(4) {
			t(wdx-radius-diag, wdy-radius) 
				diff() {
					cylz(radius*2,ht);
					cylz((radius-way)*2,ht+100,0,0,-50);
					rotz(diag?45:0) cubey(radius*2+200,-radius*2, ht+150, 0,cuty,ht/2-50);
					cubex(-radius*2,radius*2+200, ht+150, cutx,0,ht/2-50);
				}	
			if (diag)	{
				t(wdx-radius, wdy-radius-diag) 
					diff() {
						cylz(radius*2,ht);
						cylz((radius-way)*2,ht+100,0,0,-50);
						cubey(radius*2+200,-radius*2, ht+150, 0,cuty,ht/2-50);
						rotz(-45) cubex(-radius*2,radius*2+200, ht+150, cutx,0,ht/2-50);
					}		
				hull() {
					t(wdx-radius-diag, wdy-radius)				rotz(45) cubez(way,10, ht, radius-way/2,cuty,0);
						
					t(wdx-radius, wdy-radius-diag)
						rotz(-45) cubez(10,way, ht, cutx,radius-way/2,0);
				}
			}	
			if(!cuty)	
				cubez(way,exty,ht, wdx-way/2,
		exty/2-extent);
			if(!cutx)	
				cubez(extx,way,ht, extx/2-extent,wdy-way/2);
	}			
}

module bikelight (angline=-25,stopline=100, linang=0, linelength=1000, axis=vX, extent) {
	if(traffic_light) {
		rotz(angline) 
			side_traffic_light(1650,90,90,90,"bike");
		orange()  
			diff() {
				cylz (250,800, 0,0,300);  
				cylz (240,1500,0,0,-10);   
			}
			color(color_pavement) 
				hull() {
					cylz(500,pavht, 0,0,0,16);
					cubey (500,extent,pavht, 0,0,pavht/2);
				}	
		}
		// stop line 
		noprio = road_priority==0?false:axis?(road_priority==2?false:true):(road_priority==1?false:true);
		//no marking line if there is priority
		if(traffic_light || noprio)
			white() // bikeway stop line
				t(-100, stopline)
					rotz(linang) {
						line2(150,100,linelength,-1,1000,0,30);
						// shark teeth if no priority
						if (!traffic_light)
							t(500,0,30) 
								teeth(150,linelength-500, true);
					}	
} //bikelight

module pav_corner (x,y) {
  r = max(x,y)+corner_offset;
  //echo (x=x,y=y,cut=cut);
  gray() cylz(20,1000, 0,0,0,6);
  color(color_pavement) {
    diff() {
      cylz(2*r,pavht, -(y-r),-(x-r),0,32);
      cubey(3*r,3*r,600, -y+r,-x+r,-100);
      cubex(3*r,3*r,600, -y+r,-x+r,-100);
      // cut angle
      cubez(6000,6000,600,
        3000,3000,-100);
    }  
  }  
}

// Ramp for recess in the pavement for wheelchairs. too steep, adjust depending the pavement width ?? low priority
module ramp (width = 2000) {
  r(2.5)
    hull() {
      cubey (width,-10, 200, 0,30,140);  
			r(-2.5)
				cubey (width,-1200, 200, 0,30,140);  
			cubey (1000,10, 200, 0,3500,118);  
      cubey (width+3000,1200, 2, 0,-10,200);
			r(-2.5)
			  cubey (width+3000,-1200, 2, 0,-10,200);
			cubey (width+5000,10, 10, 0,3000,200); 
    }  
}

//-- Roundabout --------------------
module disp_roundabout() {
	if (round_int_diam) {
		color(color_pavement)
			hull() {
				cylz (round_int_diam-500,pavht);	
				cylz (round_int_diam,pavht/2);	
			}
	//the below modules assume that the road center is in the middle, which is not a correct hypothesis. ???		
		circline(d_roundline);	
		circline(d_roundline,true);	
		white()	
		for(a=[0:1],b=[0:1])
			rotroad(a,b) {
				coord = Wmain_start[a][b][vright]-Wnb_lanes[a][b][vright]*Wlane_wd2(a,b)-Wcentral[a][b]/2+isdev(a,b);
				t(0,coord)
					line2(road_cent_line,d_roundline/2,cr_border_r(a,b)-Wcycle_wd(paxis(a),prevbranch(a,b),vright)-cycle_wd_extent_crossing,0,10,0,5,0);
			}	
	}	
}
  
//-- Ground markings ----------------
module disp_arrows () {
	for(axis=[0:1],branch=[0:1])
		rotroad(axis,branch) {
			nbl = Wnb_lanes[axis][branch][vright];
			if(nbl) 
				for(i=[0:nbl-1]){
					road = perpwidth[axis][branch]/2;
					dev = isdev(axis,branch);
					ang = atan(-dev/dev_length);
					xa = Wpedcross_shift[axis][branch]+ Wpedcross_wd[axis][branch] + 6500;
					ya = Wmain_start[axis][branch][vright]-Wlane_wd2(axis,branch)*(i+0.5);
					tp = Wlane_arrows[axis][branch][i];
					t(road+dev_length)
						rotz (ang) 
							t(24000-dev_length) darr(-xa,ya,tp);
					darr(road+xa+20000,ya,tp);
				}	
		}	
	//----------------------
	module darr (x,y, type, nb=1, sp=20000) {
	// fr translation	
		tp = type=="tout droit"?"straight":
		type=="vers droite"?"right":type=="tout droit et droite"?"straight right":type;		
		white() 
			for(i=[1:nb])
				t(x+sp*(i-1)+1500,y) 
					arrow(tp); // arrow native size in mm
  }		
}

//-- Bike signs --------------------
module disp_bike_signs () {
	for(axis=[0:1],branch=[0:1],side=[0:1])
		rotroad(axis,branch) {
			cylane = Wcycle_lane[axis][branch][side];
			dev = cylane?Wpark_lane[axis][branch][side]:Wpavdev[axis][branch][side];
			ccpos =  cylane? Wcycle_pos2(axis,branch,side):Wcycle_pos2(axis,branch,side)-dev;
			ccwd = Wcycle_wd(axis,branch,side);
			maindev = isdev(axis,branch);
			dlength = cylane?(maindev?dev_length:cydev_length):cydev_length;
			road = cylane?perpwidth[axis][branch]/2:cy_corner1[axis][branch][0];
			dist = Wpedcross_wd[axis][branch]+
	Wpedcross_shift[axis][branch]+2000;
			pos = perpwidth[axis][branch]/2+Wpedcross_wd[axis][branch]+
	Wpedcross_shift[axis][branch]+2000;
			cycledouble = Wcycle_double[axis][branch][side];
			shift = (Wpark_lane[axis][branch][side]&&cylane)?250:0;
			start1 =ccpos-ccwd/2;
			start2 =ccpos-ccwd/2-shift; // shifted if near parking
    if (ccwd){ // there is a cycle path
			// branch A, right side 
				mirrory(side)
				  if (cycledouble) {
						dspbike (road, dev, dlength, dist, side, start1+ccwd/4, start1+ccwd/4);
						dspbike (road, dev, dlength, dist, !side, start1-ccwd/4, start1-ccwd/4);
					}
					else 	
						dspbike (road, dev, dlength, dist, side, start1, start2);
      }   
  } // main loop 
	module dspbike (road, dev, dlength, dist, direct=true, start1, start2) {
		// display nearby pedestrian, could be deviated
		 ang = atan(-dev/dlength);
		 t(road+dlength, start1)
		   rotz(ang)
		     t(-dlength+dist)
		       mirrorx(direct) 
							bike(fill=true);
		// display on distant lane
		 t(road+max(dlength+2000,22000), start2)
			 mirrorx(direct) 
					bike(fill=true);
	} //dspbike
} //disp_bikes_signs

//== VEHICLES =====================
//4 vehicles MODELS, their color
v_color = ["","red","blue","lightblue","Yellow"];
//4 vehicles MODELS, their type
v_type = [0,1,1,2,3];

module disp_vehicles () {
	for (i=[0:3]) {
		disp_vh (v_type[vh_type[i]],v_color[vh_type[i]],vh_X[i],vh_Y[i],vh_ang[i], vh_acc[i]); 
	}	
}
//-- display one vehicle --
module disp_vh (type, vcolor, x,y,ang, acc) {
//echo("type, vcolor, x,y,ang, acc", type, vcolor, x,y,ang, acc);	
	//type: 0:nothing, 1:car, 2:bus, 3:bicyclist
	linang= acc==1?1:acc==2?90:0;
	arrow= acc==3?1:0;	
	view = acc==4?1:0;		
	//parameters for each TYPE of vehicle
	//0:_, 1:arrow_dist, 2:view_pos, 3:view_shift, 4:view_ht, 5:view_angle]  
	v_acc_param =	[[],
		[0,2500,200,450,1050,-33],//car
		[0,6000,4400,750,2000,-33],//bus
		[0,1500,-20,0,1680,26] //bicyclist
	];	

	t(x*cfu,y*cfu) rotz(ang){ 
    if (type==1) 
		  car(vcolor,linang, ang); 
	  else if(type==2) {
			orange()
				import("Bus_body.stl");
			color(glass_color)
				import("Bus_glasses.stl");
			black()
				import("Bus_tires.stl");
		}
			/*color(vcolor)
				t(0,1350,-30) 
						scale(1560) 
							import("Bus_by_Anderson_Rondon.stl"); */
		else if(type==3) {
			color([0.15,0.15,0.15])
				import("Bicycle.stl"); 
			color("greenyellow")
				import("Cyclist_body.stl"); 
			color ("peachpuff")
				import("Cyclist_head.stl"); 
		}
/*		  color(vcolor)	
				rotz(90)
						import("Bicyclist_by_Digson.stl"); */
				/*/ Check dimensions
					cyly (-200,1000, 0,100,350);
					cyly (-100,1750, 0,100,350);
					cylz (100,1820);cylx 
					(740,40,0,0,370); //*/
		if(arrow&&type)
			demo_arrow(v_acc_param[type][1]);
		
		if(view&&type)
			t(v_acc_param[type][2],v_acc_param[type][3], v_acc_param[type][4])
		    demo_sight(v_acc_param[type][5],clr="lightgreen");
  } 
}
//-- Primitive car model(length:4.2m)
module car(clrcar = "red", linang=0, ang) {
	dwheel =600;
	//line showing the back car end
		t(-2100,800)
			if (linang)//shut view at 0
				rotz(-ang+linang)
					color ("lightgreen") 
						cubez (6000,120,30);
	//wheels
	black() 
		dmirrorx() dmirrory() 
			cyly(dwheel,220, 1200,550,dwheel/2); 	
	//car
	color(clrcar) 
		diff() {
			hull() {
				cubez(4200,1620,200, 0,0,135);
				cubez(4000,1580,200, -80,0,135+380);
				cubez(2300,1580,200, -150,0,135+500);
			}
			dmirrorx() 
				cyly(-dwheel-100,2200, 1200,0,dwheel/2); 	
		}
	//roof	
	color(clrcar) 
		cubez (1500,1400,10, -280,0,1350);	
	//glass	
	color(glass_color)
		hull() {
			cubez(2300,1580,2, -150,0,830);
			cubez(1500,1400,2, -280,0,1350);
		}
}
//-- Display arrow in front of vehicle
module demo_arrow (pos=2500) {
	ht = 40;
	color ("orange") {
		cubex(1000,100,ht, pos,0,ht/2);
			hull() {
				cubex (10,340,ht,pos+1000,0,ht/2);
				cubex (600,20,ht,pos+1000,0,ht/2);
			}
	}
}
//-- Show viewing angle ---------
module demo_sight(ang,clr = "lightgreen") {
		color ("orange")
			rotz (ang)
				cubex (10000,50,100);
		color (clr) {
			rotz(ang-60)
			  cubex (5000,50,100);
			rotz(ang+60)
			  cubex (5000,50,100);
		}	
}

//== display text ================
module disp_text () {
	copyright = ["Application: Protected crossing","Copyright Pierre ROUZEAU 2018","License: GPL v3, documentation: CC BY-SA 4.0","https://github.com/PRouzeau/Protected-crossing"];
	tXA = totwidth[vX][vA]/2;
	tXB = totwidth[vX][vB]/2;
	tYA = totwidth[vY][vA]/2;
	tYB = totwidth[vY][vB]/2;
	rpt = 20000;
	rl = road_length+2000;
	module dpt (x,y,txt) {
		t(x,y)
			mirrorx(!right_drive) 
				scale([1,2,1]) text(text=txt, size=800, halign = "center", valign = "center");
	}
// We shall extrude text for projection, as 2D text kills the projection process (?)
	if (Projection)
		linear_extrude(10) txt();
	else
	  txt();
	module txt() 	 {
		// User text
		t(tYA+4000,tXA+20000) 
			multiLine(usertxt);
		// Author & date
		t(tYA+3200,tXA+3800) 
			multiLine(designtxt,750, 25000,true);
		// Specification text
		t(tYA+3500,-tXA-4000) 
			multiLine(spectxt);
	  // Copyright		
		t(-26000-tYA,tXB+8000)
			multiLine(copyright,750);
		// Tags
		
		dpt(-tYA-15000, tXB+1200,"l(eft)");
		dpt(-tYB-15000, -tXB-1200,"r(ight)");
		  
		duplx(-rpt) dpt(rl, 0,"X - A ");
		duplx(rpt) dpt(-rl, 0,"X - B ");
		
		dpt(-tYA-1500,tXB+15000,"r(ight)");
		
		if (!t_cross) {
			dpt(-tYB-1500,-tXB-15000,"l(eft)");
			dpt(tYB+1500,-tXA-15000,"r(ight)");
		}  
		duply(-rpt) dpt(0,rl,"Y - A");
		if (!t_cross)
			duply(rpt) dpt(0,-rl,"Y - B");
			
		t(tYA+1500,tXA+1200) {
			dpt(0,0,"C1");
		  dpt(13500,0,"XAr");
			dpt(17000,0,"r(ight)");
			dpt(0,9000,"YAl");
			dpt(0,12000,"l(eft)");
		}	
		t(-tYA-1500,tXB+1200) {
			dpt(0,0,"C2");
		  dpt(-10000,0,"XBl");
			dpt(0,9000,"YAr");
		}	
 		t(-tYB-1500,-tXB-1200) {
			dpt(0,0,"C3");
		  dpt(-10000,0,"XBr");
			if (!t_cross)
				dpt(0,-9000,"YBl");
		}	
		t(tYB+1500,-tXA-1200) {
			dpt(0,0,"C4");
		  dpt(13500,0,"XAl");
			dpt(17000, 0,"l(eft)");
			if (!t_cross)
				dpt(0,-9000,"YBr"); 
		}	
	}
}
//=================================
module check () {
	naxis = ["X","Y"];
	nbranch = ["A","B"];
nside = [" droite"," gauche"];	
function typeway(axis,branch, side) =	str("Voie ",naxis[axis],",branche ",nbranch[branch],nside[side]);
	//-----------------------
	if(disp_road){// no message when projecting 
		msgway = str(
 		"Avertissements",
			c_way(vX,vA,vright),
			c_way(vX,vA,vleft),
			c_way(vX,vB,vright),
			c_way(vX,vB,vleft),
			c_way(vY,vA,vright),
			c_way(vY,vA,vleft),
			c_way(vY,vB,vright),
			c_way(vY,vB,vleft),
			c_1lane_sep (vX,vA),
			c_1lane_sep (vX,vB),
			c_1lane_sep (vY,vA),
			c_1lane_sep (vY,vB),
			c_ped_light()
		);
	//Split string in a vector
	tabmsg = split(msgway,"\n");
	//eliminate empty elements	
	tabmsg2 = [for(x = tabmsg) if (x!="") x];
	//add newline at end of each element for echo line change	and flatten string vector
	newmsg = 	catstr([for(x=tabmsg2) str(x,"\n")]);
	// output on console
	echo(newmsg);
	// output on the drawing
	red() 	
		t(-26000-totwidth[vY][vA]/2,-totwidth[vX][vB]/2-3500)
			multiLine(tabmsg2,900);

 /* if (traffic_light && (XA_pedcross_wd==0 || (YA_pedcross_wd==0)))  
    techo(wr_light_pcross_wd); */
  }//if disp_road
	
	//== Warning messages functions ==
	function c_ped_light() = traffic_light && (!XA_pedcross_wd || !YA_pedcross_wd) ?
	wr_light_pcross_wd:"";
	
	function c_way (a,b,s) = 
		str(c_path_wd1(a,b,s),"\n",c_path_wd2(a,b,s),"\n",c_lane_wd(a,b,s),"\n",c_pavalley(a,b,s),"\n"
	);
	
	//-- check cycle path width ------
	function c_path_wd1(a,b,s) = 
	Walley[a][b][s]&&Wcycle_path[a][b][s]&&Walley[a][b][s]<2000&&!Wcycle_double[a][b][s]?
	str(wr_path_width, Walley[a][b][s]/cfu,"m ,", typeway(a,b,s),"\n."):
	"";
	function c_path_wd2(a,b,s) = 
	Walley[a][b][s]&&Wcycle_path[a][b][s]&&Walley[a][b][s]<2500&&Wcycle_double[a][b][s]?
	str(wr_path_width, Walley[a][b][s]/cfu,"m ,", typeway(a,b,s),"\n."):
	"";
//-- Check cycle lane width ------
 // ruled width is INSIDE marking
	function c_lane_wd (a,b,s) = 
	Wcycle_lane[a][b][s]?
	(	Wpark_lane[a][b][s]?
	((Wcycle_lane[a][b][s]-cycle_lane_line)<1750?str(wr_lane_park_width, (Wcycle_lane[a][b][s]-cycle_lane_line)/cfu,"m ,",typeway(a,b,s),"\n."):"")
	:
	((Wcycle_lane[a][b][s]-cycle_lane_line)<1500?str(wr_lane_width, (Wcycle_lane[a][b][s]-cycle_lane_line)/cfu,"m ,",typeway(a,b,s),"\n."):"")
	):"";
	
	function c_pavalley (a,b,s) = 
	  Wcycle_path[a][b][s]&&Walley[a][b][s]&&Wpark_lane[a][b][s]?real_alley_pav[a][b][s]<600?str(er_pavalleypark, real_alley_pav[a][b][b]/cfu," m, ", typeway(a,b,s),"\n."):"":"";
		
	function c_1lane_sep (a,b) = 	 Wcentral[a][b]&&Wnb_lanes[a][b][vleft]<2&&!round_int_diam?str(er_1lane_sep, typeway(a,b,vleft),"\n.\n"):"";

} //check()
//== Warnings =====================
wr_path_width = "* La largeur minimale recommandée\n pour une piste cyclable unidirectionnelle\n est de 2m, avec une préférence pour 2.5m. Largeur actuelle:";
//---------------
wr_2path_width = "* La largeur minimale recommandée pour une piste cyclable a double sens est de 2.5m, avec une préférence pour 3m. Largeur actuelle:";
//-----------------
wr_lane_width_fr = "* La largeur minimale recommandée pour une bande cyclable est de 1.5m à l'INTERIEUR du marquage (250mm), avec une préférence pour 2m. Largeur actuelle:";
//--------------------
wr_lane_park_width = "* La largeur minimale recommandée pour une bande cyclable le long d'une file de stationnement est de 1.75m à l'INTERIEUR du marquage (250mm), avec une préférence pour 2m. Largeur actuelle:";
//---------------------------------
wr_light_ped_crossing = "* Lorqu'il y a des feux rouges, il y a généralement des passages piétons.";
//---------------------------------
//== ERRORS =======================
// a mettre en oeuvre
er_1lane_sep = "Erreur!: vous ne pouvez pas mettre de\n séparateur central béton quand il\n n'y  a qu'une seule voie, ceci empêche\n les bus et les camions de tourner:\n";

er_pavalleypark = "Erreur!: quand une voie de parking est\n située a coté d'un trottoir de séparation\n d'une allée, ce trottoir doit être\n suffisamment large pour un chargement/\ndéchargement correct des voitures et\n pour la protection des usagers de l'allée.\n Largeur actuelle du trottoir:\n";

//== end of Warnings ==============
//-- Information text -------------
module techo (var1, var2="",var3="", var4="",var5="",var6="", var7="",var8="") {
  if (inf_text) {
    txt = str(var1,var2,var3,var4,var5,var6,var7,var8);
    echo(txt);
  }  
}

//-- Debugging --------------------
module decho(var1, var2="",var3="", var4="",var5="",var6="", var7="",var8="") {
  if (debug) 
    echo("Debug:",var1,var2,var3,var4,var5,var6,var7,var8);
}

//== utilities ====================
//-- Draw a straight line, dotted or not, horizontal, with optional deviation (angled) --

//Round by 100 and divide by 1000 (cfu=1000) mm->m
function round100 (x) = round(x/10)/100;	

// implement negative lengths ??
module line2 (width=100,start, length, pos=0, interval=1000, space=0, ht=10, deviate=0) {
	ang = atan (deviate/length);
	lgt = length/cos(ang);
	startr = start/cos(ang);
	nb = max(0,floor((lgt-startr)/interval));
	//mmm shall correct library duplx /duply when numbers are negative ???
	t(0,deviate)
		rotz(-ang)
			if(space) {
				diff() {
					duplx(interval, nb)
						cubex(interval-space,width,ht, startr,pos*width/2,ht/2+1);
				
					cubex (2*interval,width+20,ht+50, lgt,pos*width/2,ht/2-10);  
				}	
			}	
			else 	
				cubex(lgt-startr,width,ht, startr,pos*width/2,ht/2+1);
}

//-- Draw dotted line or triangles
//   on a given diameter --
module circline (dline=24000, triang=false) {
	wdline = 250;
	segl = 500;
	nbsg = floor (dline*3.1415926/(segl*2));	
	ags = 360/nbsg;	
	white()
		for (i=[0:floor(nbsg/8)]) 
			for (j=[0:4]) 
			if (triang) {
				rotz(i*ags+j*90) 
					tria();
				rotz((i+0.5)*ags+j*90) 
					tria();
			}				
			else 	
				rotz(-i*ags+j*90) 
					cubex (wdline,segl,10, dline/2,-segl/2,7);
		module tria()	{
			t(dline/2) 
				linear_extrude(height=10)
					polygon([[700,0],[0,200],[0,-200]]);
		}
}

//Printing multiples lines in a vector
module multiLine (lines, size=1000, wdtxt=25000, always=false){
	//mirroring text if left drive 
	mirrorx(!right_drive) 
  t(!right_drive?-wdtxt:0)	
		if(Disp_text||always)
			union(){
				for(i=[0:len(lines)-1])
					translate([0 , -i *size*1.5*(i?1:1.2), 0 ])  text(lines[i], size*(i?1:1.2));
			}
}

//Flattening a vector of strings
function catstr(list, c = 0) = 
	c < len(list) - 1 ? 
	str(list[c], catstr(list, c + 1)) 
	:list[c];

//following function from library of Nathanaël Jourdane - license CC-BY
//split a string according a separator
function split(str, sep=" ", i=0, word="", v=[]) =
	i == len(str) ? concat(v, word) :
	str[i] == sep ? split(str, sep, i+1, "", concat(v, word)) :
	split(str, sep, i+1, str(word, str[i]), v);

//Display my Signature (PRZ)
module disp_signature(sc=50) {
	ht=round_int_diam?300:50;
	clr = round_int_diam?"green":"lightgreen";
	color(clr)
	scale([sc,sc,1])
	  linear_extrude(height = ht, center = false, convexity = 10)
	t(-10,-10,0)
   import(file="signature_PRZ_cut.dxf");
}
