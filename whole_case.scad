// Modified from PSU mount by kumekay
profile = 30;
width = 80;
depth = 65;
height = 130;
wall = 2;
// empty space between lid and the hole for it
delta = 0.2;

// mounting pillars for atmega
mount_outer  = 6;
mount_inner  = 2.3;
mount_height = 9;

usb_w = 14;
usb_h = 13;

mega_x = 17;

fan_mnt_hole = 3;

// we need less, but we're leving room for the fit inserts
cable_x_rad = 14;
cable_y_rad = 8;
cable_out_h = 55;
$fn=100;    

rampsBox();
translate([wall/2-delta,depth+wall,wall/2-delta]) lid();
cableGuards(true);

module cableGuard(rad) {
    difference() {
        union() {
            cylinder(d=rad,h=3*wall);
            translate([0,0,wall]) cylinder(d=rad+2*wall,h=2*wall);
        }
        
        // inner hole, a mil narrower
        narrowing = 2;
        
        cylinder(d=rad - narrowing, h = 3*wall);
        
        // split slot to make it forceable
        translate([rad/2 - narrowing,0,1.5*wall]) cube([3*wall+narrowing,narrowing,3*wall],center=true);
    }
}

// todo: move transform outta here
module lidBase(delta) {
    cube([width+wall+2*delta,wall,height+wall+2*delta]);
}

module fanMount(rad) {
    // TODO: propper fan span (choose fan)
    span = 60;
    ox = width / 2 - span / 2 + wall; oy = 30; 
    translate([ox,wall,oy]) rotate([90,0,0]) cylinder(d=rad,h=wall);
    translate([ox+span,wall,oy]) rotate([90,0,0]) cylinder(d=rad,h=wall);
    translate([ox+span,wall,oy+span]) rotate([90,0,0]) cylinder(d=rad,h=wall);
    translate([ox,wall,oy+span]) rotate([90,0,0]) cylinder(d=rad,h=wall);
}

// TODO: mounting holes. Add mounting cylinders, then diff out the mounting holes.
module lid() {
    difference() {
        union() {
            difference() {
                lidBase(0);
                for (x = [4*wall : 2*wall : height-2*wall]) {
                    translate([3*wall,0,x]) cube([width-4*wall,wall,wall]);
                }
            }
            
            // 4 mounting holes
            fanMount(fan_mnt_hole + 3);
        }
        
        fanMount(fan_mnt_hole);
    }
}

// note - remove the transforms before printing
module cableGuards(demo) {
    if (demo) {
        translate([68, cable_out_h, height+wall]) cableGuard(cable_x_rad);
        translate([width+wall, cable_out_h, 24]) rotate([0,90,0]) cableGuard(cable_y_rad);
        translate([wall, cable_out_h, 24]) rotate([180,90,0]) cableGuard(cable_y_rad);
    } else {
        translate([0,0,3*wall]) rotate([180,0,0]) cableGuard(cable_x_rad);
        translate([cable_x_rad * 2,0,3*wall]) rotate([180,0,0]) cableGuard(cable_y_rad);
        translate([-cable_x_rad * 2,0,3*wall]) rotate([180,0,0]) cableGuard(cable_y_rad);
    }
}

// mounting pillar for atmega
module mountHole() {
    difference() {
        cylinder(d=mount_outer, h=mount_height);
        cylinder(d=mount_inner, h=mount_height);
    }
}

module megaMountHoles() {
    mountHole();
    translate([81.28,0,0]) mountHole();
    translate([0,48.26,0]) mountHole();
    translate([74.93,48.26,0]) mountHole();
}

module body() {
    cube([width+2*wall,depth+2*wall,height+2*wall]);
}

module rampsBox() {
    union() {
        difference() {
            union() {    
                translate([-10,0,profile+25]) rotate([0,90,90]) mount3030();
                translate([-10,0,height]) rotate([0,90,90]) mount3030();
                body();
                translate([0,3,25])rotate([0,0,45])cube([2*wall,2*wall,profile]);
                translate([0,3,height-profile])rotate([0,0,45])cube([2*wall,2*wall,profile]);
            }
            
            translate([wall,wall,wall])cube([width,depth+wall,height]);
            
            // subtract lid Base
            translate([wall/2-delta,depth+wall,wall/2-delta]) lidBase(delta);
        
            // through hole for USB
            translate([mega_x+3, wall + mount_height + 1.5, height]) cube([usb_w,usb_h,wall*2]);
            
            // through hole for X axis cable
            translate([68, cable_out_h, height+wall]) cylinder(d=cable_x_rad, h=wall);

            // through hole for the Y carriage cable
            translate([width+wall, cable_out_h, 24]) rotate([0,90,0]) cylinder(d=cable_y_rad, h=wall);
            
            // through hole for the X motor
            translate([0, cable_out_h, 24]) rotate([0,90,0]) cylinder(d=cable_y_rad, h=wall);


            // control box cables + power - in
            translate([10, wall + mount_height + 25, 0]) cube([width - 2*10 + 2*wall,12,wall]);

            // air out on top
            union() {
                for (h = [0:wall*2:30]) {
                    for (w = [0:wall*2:50]) {
                        translate([wall * 2 + w, wall + mount_height + usb_h + wall * 3 + h, height + wall]) cube([wall*1.2,wall*1.2,wall]);
                    }
               }
                
            }
        }    
  
        translate([mega_x, wall+mount_height-0.01, height-24]) rotate([90,90,0]) megaMountHoles();            
    }         
}


module mount3030(profile = 30) {
    slot_width = 7.9;
    thickness = 6;
    deepness = 2;
    gap=20;
    
    difference(){
        union(){
        translate([0,-gap,0])cube([profile,profile+gap,thickness]);
        translate([0,(profile-slot_width)/2,0])cube([slot_width-deepness,slot_width,thickness+deepness]);
        translate([profile-slot_width+deepness,(profile-slot_width)/2,0])cube([slot_width-deepness,slot_width,thickness+deepness]);
        translate([profile-slot_width+deepness,(profile+slot_width)/2,thickness])rotate([90,0,0])cylinder(slot_width,deepness,deepness, $fn=100);
        translate([slot_width-deepness,(profile+slot_width)/2,thickness])rotate([90,0,0])cylinder(slot_width,deepness,deepness, $fn=100);
        }
        translate([15,15,-0.5])rotate([0,0,90])cylinder(h = 7, r1 = 3.1, r2 = 3.1, $fn=100);
    }
}