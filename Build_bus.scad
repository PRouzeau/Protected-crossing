// Protected crossing design
// Copyright 2018 Pierre ROUZEAU AKA PRZ
// Program license GPL v3
// documentation licence cc BY-SA 4.0 and GFDL 1.2
include <Z_library.scad>

part=0;

//Front wheel x position
xfrontw= 3280;
//Bus length
length = 12000;
//Bus width
width = 2530;
//Main bus height
busht=3000;
//Wheel base
wheelbase = 5900;
//Front cantilever
frontcant = 2800; 
//Height of median line
midht = 1350;
//ground clearance
groundclear = 250;

if (part==1)
	bus();
else if (part==2)
	glass();
else if (part==3)
	tires();
else {
	color(glass_color) glass();
	red() bus();
	black() tires();
}

glass_color = [128,128,128,180]/256;

//Back cantilever - unused
backcant = length-wheelbase-frontcant;

*t(0,1380,-30) 
						scale(1595) 
							import("Bus_by_Anderson_Rondon.stl");

module bus () {
	sphd = 300;
	sphr = sphd/2;
	diff() {
		hull() {
			// bus bottom
			duplx(-length+1500) 
				bcyl(xfrontw+frontcant-sphr-100,sphr+groundclear);
			duplx(-length+sphd) 
				bcyl(xfrontw+frontcant-sphr,sphr+520);
			duplx(-length+sphd) 
				bcyl(xfrontw+frontcant-sphr,midht);
			duplx(-length+sphd+300) 
				bcyl(xfrontw+frontcant-sphr-300,busht-sphr,80);
		}
		//:::  Remove wheel place
		duplx (-wheelbase)
		  hull()
				t(xfrontw,0,500) 
					dmirrorx() dmirrorz()
						cyly (-600,3000, 270,0,260, 16);
  }
	module bcyl(x,z, mw=0) {
	  wdx = width/2-sphr;
		dmirrory()
			t(x,wdx-mw,z)
				sphere(sphr, $fn=12);
	}	
}	
//size control
//blue() cyly (-300,2550, 0,0,1500);
//blue() cylx (300,12020, -5920,0,1300);

module glass (){
	//front glass
	t(xfrontw+frontcant-20,0,1450)
	  r(0,-11.5)
			cubez(20,2100,1150);	
	//back glass
	t(xfrontw+frontcant-length+5,0,1670)
		cubez(20,2100,800);
	//door glasses
	duplx (-wheelbase)
	t(xfrontw+frontcant-950,-width/2+5,350)
		duplx(-600) {
			cubez(550,20,1100);
			tslz (1100)
			  r(-3.5)
			    cubez(550,20,1000);
		}	
	//side glasses	
	dmirrory() {
		t(xfrontw+frontcant-1900,-width/2-10,1450)
					r(-3.5)
						cubex(-wheelbase+1300,20,1000,0,10,500);	
		t(xfrontw+frontcant-1900-wheelbase,-width/2-10,1450)
			r(-3.5)
				cubex(-length+wheelbase+2200,20,1000,0,10,500);	
	}	
	//driver glass
	t(xfrontw+frontcant-1750,width/2+10,1450)
	  diff() {        
		  r(3.5)
				cubex(1450,20,1000,0,10,500);	
			r(0,-11)
				cubex(400,400,1600, 1480,10,500);
		}	
	//side front glass
	t(xfrontw+frontcant-1350+750,-width/2-10,1450)
	  diff() {        
		  r(-3.5)
				cubex(300,20,1000,0,10,500);	
			r(0,-11)
				cubex(800,400,1600, 340,10,500);
		}	
	//middle glass, driver side
		t(xfrontw+frontcant-1900-wheelbase,width/2+10,1450)
			r(-3.5)
				cubex(1100,20,1000,100,10,500);	
} 

module tires() {
	tirede = 1040;
	duplx(-wheelbase) 
	  cyly (-tirede,2370, xfrontw,0,tirede/2-35, 24);
}
