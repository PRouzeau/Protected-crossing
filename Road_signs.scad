// Road signs for road crossing design
//(c) 2018 Pierre ROUZEAU AKA PRZ
// Program license GPL 3.0
// Documentation and symbols licence cc BY-SA 3 and GFDL 1.2
// All bike symbols are original design
// Arrows according french standards

/*bike symbol test 
 include <Utilities\Z_library.scad>
 rotz (-90) bike (2000, ana = 1);
// rotz (-90) bike2 (2000, ana = 1);
// rotz (-90) bike_light (diam=2000, ana = 1, link=true);
//r(-90,-90) traffic_light_block ("brown", 90, "bike");
// rotz (-90) naked_bike (1000);
// rotz (-90) naked_bike2 (1000);
//*/
//== road signs ====================

//-- Ground marking ----------------
// arrows dimensions per french regulation
// last  arrow end at 1.5m from stop line
// space between arrows is minimum 20m
//3 arrows normally, 2 arrow ok in urban area
module arrow (type="straight") {
  // right arrow dimensions
  awd = 150; // line width
  awd2 = 500; // bias line width
  alg = 2600; // line length
  awa = 2000; // arrow base
  aalg = 350; // arrow length
  apos = 500; // arrow pos right of straight line
  bias = 650; // bias on bias line
  // straight arrow dimensions
  algs = 2000; // line length
  aswd = 700; // arrow base
  aalgs = 2000; // arrrow length
  
  ht = 35; // marking height
  
  module right_arrow () {
     // bias line
      t(-alg)
        hull() {
          cubex(awd2,2,ht, 0,1-awd/2,ht/2+1);
          cubex(awd2,2,ht, -bias,-1+awd/2+apos,ht/2+1);
        }  
      // arrow  
      t(-alg-bias+awd2/2,apos+awd/2)
        hull() {
          cubez (awa,2,ht); 
          cylz(2,ht, 0, aalg); 
        }  
  }
  
  if (type=="right") 
    // arrow is not centered on straight line 
    t(algs+aalgs,-awd/2-apos/2) {
      // straight line
      cubex(-alg,awd,ht, 0,0,ht/2+1);
      right_arrow();
    }
  else if (type=="straight"||type=="straight right")  { // reference is arrow end
    // straight line
    cubex(algs,awd,ht, aalgs,0,ht/2+1);
    // arrow
    hull() {
      cubez (2,aswd,ht, aalgs,0,1);
      cylz (2,ht, 0,0,1);    
    }
  }  
  if (type=="straight right")
    t(1500+algs+aalgs) right_arrow();
}

// traffic lights with cyclist 
module bike_light (clr="red",diaml=90, ht=12, link= false) {
  wdiam = diaml/2.8;
  black() 
    t(diaml/25)
      naked_bike(wdiam);
  color(clr) cylz(diaml,10);
}

// bike symbol, while it looks quite standard, it is a modified version with more vertical cyclist back, more 'urban cyclist' style.
module bike (diam=380, ht=35, ana=2, fill=false) {
  d10 = diam/10;
  d8 = diam/8;
  d6 = diam/6;
  d4 = diam/4;
  d3 = diam/3.3;
  d2 = diam/2;
  d25 = diam/2.5;
  wbase2 = diam/1.3;
white() t(diam*0.3)  scale ([ana,1,1]) { 
  // wheels
  dmirrory() 
    diff() {
      cylz(diam,ht, 0,wbase2,2);
      if (!fill) {
        cylz(diam*0.75,ht+20, 0,wbase2,-10);    cubez(diam,diam*0.05,ht+20, -diam/2,diam/1.4,-10);
        t(0,wbase2)  
          dmirrory()   
          rotz (60)
            cubez(diam,diam*0.05,ht+20, diam/2,0,-10); 
      }
    }  
  t (0,0) {  
    // leg
    hull() {
      cylz (d8,ht, diam*0.24,-diam*0.12);  
      cylz (d6,ht,-diam*0.24,-diam*0.14);  
    }  
    // top leg  
    hull() {
      cylz (d6,ht,-diam*0.24,-diam*0.14);  
      cylz (d6,ht, -diam*0.58, -diam*0.34); 
    }
    
    // leg bent
    hull() {
      cylz (d8,ht, -diam*0.05,diam*0.1);  
      cylz (d6,ht,-diam*0.46,diam*0.12);  
    }  
    // top leg bent 
    hull() {
      cylz (d6,ht, -diam*0.46, diam*0.12);    
      cylz (d6,ht, -diam*0.6, -d25+d10); 
    }
    
    
    // body
    hull() {
      cylz (d3,ht, -diam*0.65, -d25+d10);
      cylz (d3,ht, -diam*1.15, -d3+d10);
    }
    // top arm
    hull() {
      cylz (d8,ht, -diam*1.2, -d4+d10);
      cylz (d8,ht, -diam*0.9, d10);
    }
    // arm
    hull() {
      cylz(d8,ht, -diam*0.9,d10);
      cylz(d8,ht, -diam*0.8,d4+d10);
    }  
    //head
    cylz(d3,ht,  -diam*1.52,-d4+d10);
  }
 } 
}

module bike2 (diam=35, ht=12, ana=1, fill=false, link=false) {
  d12 = diam/11.5;
  d8 = diam/8;
  d6 = diam/6;
  d4 = diam/4;
  d3 = diam/3.5;
  d2 = diam/2;
 // link=true;
 // fill=true;
  module ped () { 
    cylz (d12,ht,  d8,-diam*0.1);
  }

t(diam*0.3)  
 scale ([ana,1,1]) {  
  dmirrory() 
    diff() { // wheels
      cylz(diam,ht, 0,diam/1.4);
      if (!fill) {
        cylz(diam*0.75,ht+10, 0,diam/1.4,-2);
        if (!link) {
          cubez(diam,diam*0.05,ht+20, -diam/2,diam/1.4,-10);
        t(0,diam/1.4)  
          dmirrory()   
          rotz (60)
            cubez(diam,diam*0.05,ht+20, diam/2,0,-10); 
        }  
      }  
    }  
  hull() { // bottom leg
    cylz (d6,ht,  d8,-diam*0.05);  
    cylz (d6,ht, -diam*.38,d12);  
  }  
  hull() { // top leg
    cylz (d6,ht, -diam*.38, d12);    
    cylz (d6,ht, -diam*0.60, -diam*0.29); 
  }
  t(0,diam*0.1) {
  // body
  hull() {
    cylz (d3,ht, -diam*0.65, -diam*.36);
    cylz (d3,ht, -diam*1.08, -diam*0.24);
  }
  hull() { // top arm
    cylz (d8,ht, -diam*1.12, -diam*0.18);
    cylz (d8,ht, -diam*0.85);
  }
  hull() { // arm horiz
    cylz(d8,ht, -diam*0.85);
    cylz(d8,ht, -diam*0.75, d4);
  }  
  //head
    cylz(d3,ht, (link)?-diam*1.4:-diam*1.42, -d6);
  } // move right
  
  if (link) {
    hull() { //ar wheel horiz
      cylz (d12,ht,  0,-diam/1.4);  
      ped();  
    }
    hull() { // ar wheel diag
      cylz(d12,ht,  0,-diam/1.4);  
      cylz(d12,ht, -diam*0.38,-diam*0.25); 
    }
    hull() { // saddle bar
      cylz(d12,ht, -diam*0.5,-diam*0.26); 
      ped();  
    }
    hull() { // saddle
      duply (-diam*0.22)
        cylz(d12,ht, -diam*0.52,-diam*0.16); 
    }
    hull() { // diag
      ped();  
      cylz (d12,ht,  -diam*0.58,diam*0.44);  
    }
    hull() { // direction
      cylz (d12,ht, -diam*0.75,diam*0.35);  
      cylz (d12,ht, 0,diam/1.4);
    }
    hull() { // direction
      cylz (d8,ht, -diam*0.61,diam*0.42);  
      cylz (d8,ht, -diam*0.41,diam*0.52);
    }
    hull() {  //head
      cylz(d8,ht, -diam*1.45, -diam*0.07);
      cylz(d8,ht, -diam*1.2, -d8);
    }
  }
 } 
  
}

module naked_bike (wdiam=35, ht=12) {
  frame_thk = wdiam/12.5;
  d12 = wdiam/12.5;
  d8 = wdiam/8;
  d6 = wdiam/6;
  d5 = wdiam/5;
  d4 = wdiam/4;
  wbase2 = wdiam/1.35;
  module ped() {
    cylz (frame_thk,ht, wdiam*0.2,-wdiam*0.12);
  }
  dmirrory() 
    diff() { // wheels
      cylz(wdiam,ht, 0,wbase2);
      cylz(wdiam*0.78,ht+10, 0,wbase2,-2);
  } 
  hull() { //ar wheel horiz
    cylz (frame_thk,ht, 0,-wbase2);  
    ped();    
  }
  hull() { // ar wheel diag
    cylz (frame_thk,ht, 0,-wbase2);  
    cylz (frame_thk,ht, -wdiam*0.35,-wdiam*0.27); 
  }
  hull() { // reinf
    cylz (frame_thk,ht, -wdiam*.10,-wdiam*0.17);
    cylz (frame_thk,ht, -wdiam*.17,wdiam*0.14);
  }
  hull() { //av diag
    cylz(frame_thk,ht, -wdiam*0.57,wdiam*0.44);  
    ped();   
  }
  hull() { //saddle bar
    cylz(frame_thk,ht, -wdiam*0.57,-wdiam*0.3);  
    ped();  
  }
  hull() { //saddle
    duply(-d5) 
      cylz(frame_thk,ht, -wdiam*0.6,-wdiam*0.22);  
  }
  hull() { // direction
    cylz(frame_thk,ht, -wdiam*0.82,d5*2);  
    cylz(frame_thk,ht, 0,wbase2);
  }
  hull() { // direction bearing
    cylz(d8,ht, -wdiam*0.64,wdiam*0.47);  
    cylz(d8,ht, -wdiam*0.41,wdiam*0.56);
  }
  hull() { // handlebar
    duply(-d6)
      cylz(frame_thk,ht, -wdiam*0.82,d5*2); 
    //cylz (d12,ht, 0,wdiam/1.4);
  }
}

module naked_bike2 (wdiam=35, ht=12, link=false) {
  frame_thk = wdiam/12.5;
  d12 = wdiam/12.5;
  d8 = wdiam/8;
  d6 = wdiam/6;
  d5 = wdiam/5;
  d4 = wdiam/4;
  link=true;
  wbase2 = wdiam/1.35;
  module ped(dp=frame_thk) {
    cylz (dp,ht, wdiam*0.1,-wdiam*0.05);
  }
  dmirrory() // wheels
    cylz(wdiam,ht, 0,wbase2);
  ped(d5);    
  hull() { //pedals
    cylz (frame_thk,ht, -wdiam*0.05,wdiam*0.1);  
    cylz (frame_thk,ht, wdiam*0.25,-wdiam*0.2);  
  }
  hull() { //av diag
    cylz(frame_thk,ht, -wdiam*0.63,wdiam*0.45);  
    if(link) 
      cylz(frame_thk,ht, -wdiam*0.05,-wdiam*0.11);
    else   
      cylz(frame_thk,ht, -wdiam*0.18,-wdiam*0.15);
  }
  hull() { //saddle bar
    cylz(frame_thk,ht, -wdiam*0.65,-wdiam*0.35);
    if (link) 
      ped(); 
    else 
      cylz(frame_thk,ht, -wdiam*0.06,-wdiam*0.12);
  }
  hull() { //saddle
     cylz(d8,ht, -wdiam*0.65,-wdiam*0.46);  
     cylz(d12,ht, -wdiam*0.65,-wdiam*0.24);  
  }
  hull() { // direction
    cylz(frame_thk,ht, -wdiam*0.82,d5*2); 
    if(link) 
      cylz(d6,ht, 0,wbase2);
    else 
      cylz(d8,ht, -wdiam*0.55,wdiam*0.515);  
    
  }
  if (link) {
  *  hull() { // direction bearing
      cylz(d8,ht, -wdiam*0.7,wdiam*0.45); 
      cylz(d8,ht, -wdiam*0.54,wdiam*0.515);
    }
    hull() { // Back horiz
       cylz(frame_thk,ht, -wdiam*0.05,-wdiam*0.11);
     * cylz(frame_thk,ht, -wdiam*0.18,-wdiam*0.15);
      cylz(frame_thk,ht, 0,-wbase2);
    }  
  }  
  hull() { // handlebar
    duply(-d6)
      cylz(frame_thk,ht, -wdiam*0.82,d5*2); 
    //cylz (d12,ht, 0,wdiam/1.4);
  }
}


//-- Other road signs----------------------- 

//Traffic light as installed on the side of the road
//Light height is the elevation of the bottom light axis
module side_traffic_light (height=2650, diaml=traffic_light_diam, pole1=180, pole2=120, type="" ) {

  clrt = "brown"; // light block color
  clrp = "brown"; // pole color
  color (clrp) {
    cylz (pole2, height+2*diaml); // pole
    hull() {
      cylz (pole1, 1400); // pole
      cylz (pole2, 1460); // pole
    }  
  }  
  t(80,0,height) traffic_light_block (clrt, diaml, type);
}

module traffic_light_block (clrt, diaml, type) {
  vsp = diaml/6+10;  
  color (clrt) {
    cubez (100,20,diaml*2+vsp, -30,0,-diaml/2+vsp/2); 
    hull() 
      duplz(diaml*2+vsp*2)
        cylx(diaml*1.5,60);
    t(diaml/5) // lights
      // sun protect
      duplz (diaml+vsp,2)
        diff() {
          cylx(diaml*1.08,250);
          cylx(diaml,300,10);
          r(0,30)
             cubez (300,300,600, 235,0,-200);
        }
  } // light color
  lk=true;
  t(80) { 
    if (type=="bike")
      r(0,90)
        bike_light("green",diaml,link=lk);
    else
      color("green") cylx(diaml,12);
    tslz(diaml+vsp)
      if (type=="bike")
        r(0,90) 
          bike_light("orange",diaml,link=lk);
      else
        color ("orange") cylx(diaml,12);
    tslz(2*diaml+2*vsp) 
      if (type=="bike")
        r(0,90) 
          bike_light("red",diaml,link=lk);
      else color ("red") {
        cylx(diaml,12);
        hull() 
          dmirrorz() 
            cylx(30,10, -85,0,80); 
        hull() 
          dmirrory() 
            cylx(30,10, -85,80); 
      }  
  }  
}
