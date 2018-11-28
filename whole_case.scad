// Modified from PSU mount by kumekay
$fs=0.01;
profile = 30;
width = 70;
depth = 55;
height = 120;
wall = 2;

// tolerance agains Z-fighting
delta = 0.01;

// cable guard snap-in lip
lip = 0.3;

// mounting pillars for atmega
mount_outer  = 6;
mount_inner  = 2.8;
mount_height = 9;

usb_w = 14;
usb_h = 13;

mega_x = 10;
mega_y = 4;
usb_x = mega_x + 6;
usb_y = wall + mount_height + 2.5 - 1; // 2.5 is board width, 1 mm is the margin

fan_mnt_hole = 3;

// we need less, but we're leving room for the fit inserts
cable_x_rad = 14;
cable_y_rad = 8;

cable_out_h = 45;
cable_out_top_x = width - cable_x_rad + wall;
cable_out_side_left_z = 48;
cable_out_side_right_z = 38;

// top duct width/height
top_duct_x = 2 * wall; 
top_duct_y = wall + mount_height + usb_h + wall * 3;
top_duct_width = cable_out_top_x - cable_x_rad / 2 - top_duct_x - 2*wall;
top_duct_height = depth - top_duct_y;

rampsBox();
%translate([0,depth+2*wall,0]) lid();
cableGuards(true);

// megaMountHoles();
// cableGuards(false);

module cableGuard(rad) {
    difference() {
        union() {
            translate([0,0,-wall]) cylinder(d=rad,h=4*wall);
            translate([0,0,wall]) cylinder(d=rad+2*wall,h=2*wall);
            translate([0,0,-wall]) cylinder(d=rad+lip,h=0.8*wall);
        }
        
        // inner hole, a mil narrower
        narrowing = 2;
        
        translate([0,0,-wall-delta]) cylinder(d=rad - narrowing, h = 4*wall+2*delta);
        
        // split slot to make it forceable
        translate([rad - 2*narrowing,0,+wall]) cube([2*wall+narrowing,narrowing,4*wall+3*delta],center=true);
    }
}

// todo: move transform outta here
module lidBase(delta) {
    cube([width+2*wall,wall,height+2*wall]);
}

module fanMount(rad) {
    // TODO: propper fan span (choose fan)
    span = 50;
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
                    translate([3*wall,-delta,x]) cube([width-4*wall,wall+2*delta,wall]);
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
        translate([cable_out_top_x, cable_out_h, height+wall]) cableGuard(cable_x_rad);
        translate([width+wall, cable_out_h, cable_out_side_left_z]) rotate([0,90,0]) cableGuard(cable_y_rad);
        translate([wall, cable_out_h, cable_out_side_right_z]) rotate([180,90,0]) cableGuard(cable_y_rad);
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
    // origin is corner of the PCB, up closest to USB port
    
    translate([0,-101.6,mount_height]) union() {
        translate([2.5,15,-mount_height]) mountHole();
        translate([2.5,90,-mount_height]) mountHole();
        translate([49.54,13.5,-mount_height]) mountHole();
        translate([49.5,96.5,-mount_height]) mountHole();

        // mega
        %cube([53.3,101.6,2]);
        // USB 
        %translate([7,-8,2.5]) cube([12.2,16.1,10.7]);
        
        // ramps board
        %translate([0,-2,2.5+13]) cube([53.3,106.6,2]);
        
        // smart ctl daughterboard
        %translate([0,101.6-6,2.5+26]) cube([53.3,15,2]);
        // two duponts for smart ctrl on daughterboard
        %translate([10,101.6,2.5+26]) cube([16,8,14]);
        %translate([30,101.6,2.5+26]) cube([16,8,14]);
    }
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
            
            translate([wall,wall,wall])cube([width,depth+wall+delta,height]);
            
            // through hole for USB
            translate([usb_x, usb_y, height-delta]) cube([usb_w,usb_h,wall*2+2*delta]);
            
            // through hole for X axis cable
            translate([cable_out_top_x, cable_out_h, height+wall-delta]) cylinder(d=cable_x_rad, h=wall+2*delta);

            // through hole for the Y carriage cable
            translate([width+wall - delta, cable_out_h, cable_out_side_left_z]) rotate([0,90,0]) cylinder(d=cable_y_rad, h=wall+2*delta);
            
            // through hole for the X motor
            translate([-delta, cable_out_h, cable_out_side_right_z]) rotate([0,90,0]) cylinder(d=cable_y_rad, h=wall+2*delta);

            // control box cables + power - in
            translate([10, wall + mount_height + 25, -delta]) cube([width - 2*10 + 2*wall,12,wall+2*delta]);

            // air duct out on top
            union() {
                for (h = [0:wall*2:top_duct_height]) {
                    for (w = [0:wall*2:top_duct_width]) {
                        translate([top_duct_x + w, top_duct_y + h, height + wall - delta/2]) cube([wall*1.2,wall*1.2,wall+delta]);
                    }
               }
                
            }
        }    
  
        translate([mega_x, wall-0.01, height-101.6+mega_y-8]) rotate([90,180,180]) megaMountHoles();            
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
