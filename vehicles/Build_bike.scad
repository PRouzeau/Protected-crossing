// Protected crossing design
// Copyright 2018 Pierre ROUZEAU AKA PRZ
// Program license GPL v3
// documentation licence cc BY-SA 4.0 and GFDL 1.2
include <../Z_library.scad>

part=0;

if (part==1)
	bike();
else if (part==2)
	body();
else if (part==3)
	head();
else {
	color([0.15,0.15,0.15]) bike();
	green()red() body();
	color ("peachpuff") head();
}

*t(-20,-20,40)
	rotz(90)
		import("Bicyclist_by_Digson.stl"); 


module head () {
	t(-110,0,1675) {
		scale ([1,0.9,1.2])
			sphere (110, $fn=24);
		//neck
		cylz (120,230,-30,0,-200,16); 

		//nose
		hull() {
			cylz (20,10,98,0,-1, 6); 
			duplx (-20) 
				cylz (30,10,110,0,-55, 6); 
		}
	}	
	//hands
	dmirrory()
	  t(370,230,1100) {
			r(-60,40,-10)
	    scale ([0.5,0.7,0.3])
				hull() 
					duplx (140)
						sphere (65, $fn=12);
	  }	
	// origin
	cylz (12,12,0,0,0,6);	
}
		
module tire (dt=700, db=44, sp=1020) {
	tslz(dt/2) {
		r(90) rotate_extrude($fn=24)
      t(dt/2-db/2) {
        circle(db/2, $fn=10);
				t(-30)
					square([20,28], center=true);
			}	
		cyly (-20,140,0,0,0, 12);
		cyly (-90,70,0,0,0, 16);
	}	
}
module bike (tdia = 720, lgext=20) {backw = -390;				 
duplx (1100+lgext)				 
  t(backw)
	  tire(tdia);	
	//chain
	hull() {
		cyly (90,10, backw,-50,tdia/2,16);
		cyly (220,10, 40,-50,300,16);
	}	
	//saddle
	hull() {
		dmirrory()
		  cylz (80,40, -220,80,900,8);
		cylz (40,30, -30,0,900,8);
	} 
	//back struct
	dmirrory() {
		t(backw,-60,tdia/2) {
			pipe (0,0,82,20,-310)
				r(20) pipe (0,0,0,20,-140);	
			pipe (0,0,138,20,-310)
				r(20) pipe (0,0,0,20,-150);	
			//baggage support
			pipe (0,0,196,16,-420);	
		}
		//baggage support
		t(backw-250,-75,tdia+45) {
			pipe (0,0,90,16,-410)
				r(28) pipe (0,0,0,16,-140);	
		}	
	}
	//baggage support
	duplx (-133,3)
		t(backw+150,0,tdia+45)
			rotz(90)
				pipe (0,0,90,-16,150);
	
	// pedal unit
	pdang = -50;
	t (40,0,300)
		r(90, -pdang)
			pipe(0,0,0, -45,140) {
			  pipe(0,0,-90, 22,180)
				  r(pdang+10)
						hull() dmirrorz() tslz(30)
							pipe(0,0,90, 22,90);	
				tslz(-140)
				  pipe(0,0,90, 22,170)
						r(-pdang-40) // left pedal
						hull() dmirrorz() tslz(30)
							pipe(0,0,90, 22,90);	;	
			}	
	//frame
	pipe (40,300,17, 34,650);	
	pipe (40,300,-46, 34,680+lgext*1.2);	
	pipe (-15,480,-51, 34,660+lgext*1.2);
// direction	
	pipe (540+lgext,740,17, 48,200);
	pipe (540+lgext,740,17, 34,390,-40)
	  r(90,80)
			pipe (0,0,0, -25,360) {
				tslz(-360)
					r(-60) 
						pipe (0,0,0, 30,-130);
				r(60) 
						pipe (0,0,0, 30,130);
			}	
	hull() 		
		dmirrory()		
			t(540+lgext,50,740) 
				r(0,-17)
					cylz (34,25,0,0,-40,8);	
  dmirrory()
		t(6,50, -20) 
			pipe (540+lgext,740,17, 30,-300)
			  pipe (0,0,29, 24,-120);
	
	//light
	t(600,0,880)		
		hull() {		
			cylx(80,-20,0,0,0, 12);
			cylx(40,-50,0,0,0, 12);
		}		
}	

module pipe (x,z, ang, dia, length, dcl=0){
	t(x,0,z) {
		r(0,-ang){
			cylz (dia,length,0,0,dcl,8);
			tslz (dia<0?length/2:length+dcl) 
				children();
		}	
	}	
} 


module dseg (di1,di2,di3,lg1,lg2,ang) {
	segment (di1,di2,lg1,0);
	t(lg1) 
		r(0,ang) {
	    segment (di2-8,di3,lg2,0);
			t(lg2) 
				children();
		}	
}

module segment (di1,di2,lg,wd1,wd2) {
  hull() {
		dmirrory(wd1)  {
			t(0,wd1/2) sphere (di1/2, $fn=12);
			t(lg,wd2/2) 
				sphere (di2/2, $fn=12);
		}	
	}	
}	


module body () {
	t(-180,0,1020) {
		//body
		r(0,-85) 
			segment(200,160,450,155,245);
		//leg right
		t(0,-80)
		  r(-2,50,-8)
		  dseg(188,140,110, 405,420,44)
				r(5,-85,-8)foot();
		//leg left
		t(0,80)
		  r(2,17,8)
		  dseg(186,140,110, 405,420,116)
				r(-5,-90,8)foot();
	//arms
	dmirrory()  
		t(40,150,456)
	    r(25,47,16)
				dseg(140,110,90, 300,300,-23);
	//hat
	t(70,0,740)
		hull() {
			cylz(240,10, 0,0,0, 12); 	
			cylz(100,10,0,0,40, 12); 	
			cubez (10,160,10, 150,0,-30);
		}
	}	
	module foot() {
		tslz (-100)
			hull() {
				cylz (80,80, 0,0,0, 8);
				cylz (80,60, 100,0,0, 8);
				cylz (60,35, 180,0,0, 8);
			}
	}
	// origin
	cylz (10,10,0,0,0,6);
}	