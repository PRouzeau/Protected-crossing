PROTECTED CROSSING DESIGN
Road protected crossing design, 'the dutch way', as built in the Netherlands from nearly fifty years.

Please note that an help more complete than what is written below and much more practical is available:
*On Internet at  http://rouzeau.net/pcross
*Or directly in the help directory by running the 'index.htm' file. This is direct with Firefox or Edge but Chrome refuse to execute local Javascript files and you will need to use a local web server or to create a new shortcut with the parameter "--allow-file-access-from-files".

For state of the art explanation, have a look here:
	https://bicycledutch.wordpress.com/2011/04/07/state-of-the-art-bikeway-design-or-is-it/

Why this application?
This application was elaborated to try to influence urban designers about bicycling infrastructure, as in my country (France), cycling infrastructure is often poorly designed, especially at road crossing, which ruins the interest of all the cycling infrastructure and is unsafe.
 I have been a bicycle commuter in France for a few years (in harsh environment) and while very efficient compared to any other transport, I found it somewhat difficult.
 I have limited experience of bicycling in the Netherlands as a tourist, and this is really another world, but when using it, you don't quite realize the amount of work and details which make the infrastructure efficient and safe.
 I also added to the program other stuff unrelated to cycling uncommon in France, derived from the impressive work done by Jacques Robin on safety:http://www.securite-routiere-plus.com/
 (that is in french)
 Examples are for relatively space constrained roads, as this is what is common where I live and you have to deal with. Most existing bicycle lanes does not comply with the required minimum and most of the cycling infrastructure is an afterthought, and planners think that could be done only using paint! There is much road ahead...
If available footprint is sufficient, protected crossing are not the best solution, which is the 'dutch roundabout':https://bicycledutch.wordpress.com/2015/10/13/explaining-the-dutch-roundabout-abroad/. 
You can design a roundabout with this application, just define an internal diameter and you are done.
 
Usage:  
In its current form, this application is limited to perpendicular roads, aligned, with bikeways and parking lanes also aligned but car lanes could be adapted. There are so many possible combinations that it is difficult to design a program really usable for all the variety you can find. It shall be regarded primarily as an educational tool.
All car lanes within a road segment shall have the same width (yet).

This application need to have prealably installed OpenSCAD (a free parametric 3D modeler), see here:
* http://www.openscad.org/downloads.html#snapshots
Only snapshot versions of OpenScad works with Customizer, use the last version (yet 1 June 2018)
*The complete path of the directory where you install this application (Protected crossing or any other) shall only use ASCII characters, without spaces, accented letters, any diacritic, umlaut or other character set.
You NEED to validate Customizer:
*In [Edit] menu, select [Preferences] then open tab [Features], tick [Customizer], then close the window when tick is shown.
*In [View] menu, you shall now have an option [Hide customizer], than you shall untick
*In same [View] menu, you may want to hide the programming editor with ticking [Hide editor].
*Interface use local language (as configured on your machine) by default. To deactivate: menu [Edit][Preferences] tab [Advanced], untick the option (in the bottom) [Enable user interface localization (requires restart of openSCAD)]. 
*After program loading, Customizer is not activated, you need first to do a preview, either with [F5] key or by clicking the first icon below the view.
*In Customizer screen, on first line, select [Description only], which will give a much cleaner interface. 
*In the application 'protected crossing', by default each preview reposition the view at its original position, which is pretty boring, so you shall first deactivate this imposed position in [Camera] tab, by unticking [Dictate the camera position].
 
When happy with a design, customizer can record it in a dataset, use the button [+] to create a new dataset then [save preset] to save further modifications, which can be recalled by selecting a dataset in the dropdown menu. NOTHING is saved automatically.
If you don't see the examples in the dataset pull-down menu, come back to the note about the directory character sets.

Note that for variables with spinboxes (small box with top/down arrows), when you click in the value box, you can then use the mouse scroll wheel to modify the value. 

Yet (August 2018) there is some trouble with automated recalculation when updating data, you can untick [Automatic preview], then force recalculation with [F5] key.
 
Note a few conventions
* 0 neutralise equipment
* n number give value
 
Tagging:
 Road X is left-right 
 Road Y is south-north 
 For each road there is two branches, A and B, but there can be common parameters (see below) 
 
Right and left are considered for each branch when running TO the crossroad (but FROM the crossroad for left hand drive)

Dimensions are in m(eters), except for ground marking where they are in mm. 
 
After that, you are free to modify any variable to adjust your road crossing. Remember that nothing is saved till you record a dataset 
  
Ground signalling dimensions not all accessible in customizer (values set in 'Hidden' group) as it shall be imposed, however, you still can modify them in the program.
 
As a general philosophy, while there are many parameters, some things are not modifiable on purpose. This is a design decision because what initiated this program was the absolute lack of standardization and huge incoherences in existing road infrastructure in my country (France), and I got the idea that a program may help to improve the compliance with rules, being official rules, recommendations or simply good practice. In France, many infrastructures design points are only 'recommended' and not compulsory and that did open a wide door to poor design. The absence of stop line at pedestrian crossing is one of these problems, while it was recommended in Vienna convention in 1973, so more than fourty years ago. However nowadays we found a stop line to set a bike box, but it is not designed properly with way insufficient thicknesses to be well noticeable and there may be half of the drivers which does not comply, which should have driven to thorougly question the design.

Ground marking according french regulation (line size, arrows, etc.). May be compatible to international or European standards, I don't know...

X and Y roads are assumed to be of continuous width. So are pavement width.
    Central pavement separator are same width along one road, but may be repositioned according lanes distribution.

IMPORTANT NOTE: By exception, you can adjust lanes number of facing branch (B) in the parameters of branch A (to help create preselection lanes). There is a tab dedicated for lane count

There are really many options of design and they are not all covered in this program. So it may be sometimes used only for preliminary study or for training, which is a very important goal. 

You can do a projection by ticking the [projection] option in [Display] tab. Note this can be a long process depending your machine power. The advantage is that once projected, the image can be exported in vector dxf format, usable by any CAD program. This image will need cleanup.
 
Bases for dimensions:

*park_lane and cycle_lane width defined outside the external line, however the regulated minimum specified bike lane width is inside the line.
*cycle path width is measured between the pavements, and the marking lines are set outside at crossing
*stop line width (500 or 600mm) is compliant with vienna convention, even if not traditional in some countries (France)
*red color for cycle lanes and path is only required in the Netherlands, but this is by far the best solution and you may stay with it.
*Yet there is no solution for preselection lane at arrival in cross
*Cycle ways are enlarged of a fixed value (yet 250mm) inside the crossing compared to the road. Parameter  accessible in [Fine tuning] tab.
*Lanes are always deviated toward the center of the road by biting the parking lanes as this is what gives the best results for islands and also the largest space for motorised vehicles. You can forbid these deviations in [General] tab but the results are generally quite poor.
*A bike path deviation (to not be confused with main lanes deviation) 'eat' the pavement separating the bike path and the main road, so this pavement shall be widened accordingly.
*Islands are automatically positioned but their radius is adjustable. In large crossroads, the 'car island' is lowered and a 'truck' island is added.
*If there is at least two lanes on each side, a central separating island is automatically added. It width is established while reducing central lanes width to 2.7m. This lanes width reduction is also done if there is a central separating pavement. 

The general aspect of the bikeway is more 'round' that what you generally see. This gives more space for motorised vehicles and allow better placement of islands. This is more adapted to low footprint but is beneficial whatever the size. 

Note that for all examples, there was some tuning done in parameters available in [Fine tuning] tab.

KNOWN BUGS:
*Islands have problems if there is no bikeway on one side
*and a double direction cycle path on the side of the t branch (there shall not be traversing bikeways) 
*If there is an alley not used for cycle path and a cycle lane, all crossing is wrong
*If the alley is not dedicated to cycle path, there are some misplaced pavements.
*The roundabout ground marking assumes symetrical lanes layout, which is not necessarily the case, e.g. you can have two inlet for one outlet.
*Double direction path:
They have many problems and yet are not properly working. Parking lane shall be on the other side than the double direction bike path. Islands are lost, so yet this is non functional. Turns and ground marking are not handled well on double direction bike paths. Bikeway are not handled properly when there is a t cross.


QUESTIONABLE DESIGN
*Shall priority triangle be set on the lanes arriving to crossroad on a crossroad without priority nor traffic light, meaning have the bike alway priority (seems somewhat true in the Netherlands)
*Shall the bike traffic light be repeated at a higher position ? They are 90mm diameter according standard for small light, is that sufficient ? 

First issue on Github on 19 August 2018.
If this application drive some interest, I will elaborate a mode developed user manual.

Copyright Pierre ROUZEAU AKA PRZ
Program license GPL 3.0
documentation licence cc BY-SA and GFDL 1.2
This uses my OpenSCAD library, attached, but if curious you can find details here:
https://github.com/PRouzeau/OpenScad-Library
