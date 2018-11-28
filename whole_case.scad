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

// snap-in panel side extension
extens = 6;

// mounting pillars for atmega
mount_outer  = 6;
mount_inner  = 2.8;
mount_height = 6;

// dimensions of the USB hole
usb_w = 14;
usb_h = 13;

mega_x = 5;
mega_y = 4;
usb_x = mega_x + 6;
usb_y = 3*wall + mount_height + 2.5 - 1; // 2.5 is board width, 1 mm is the margin

fan_mnt_hole = 3;

// we need less, but we're leving room for the fit inserts
cable_x_rad = 14;
cable_y_rad = 9;
cable_m_rad = 12;

cable_out_h = 49;
cable_out_top_x = width - cable_x_rad + 3 * wall;
cable_out_side_left_z = 55;
cable_out_side_right_z = 44;

mount_bottom_offset = 25+profile;
mount_top_offset = height-10;

// top duct width/height
top_duct_x = 2 * wall; 
top_duct_y = 2*wall + mount_height + usb_h + wall * 3;
top_duct_width = cable_out_top_x - cable_x_rad / 2 - top_duct_x - 2*wall;
top_duct_height = depth - top_duct_y;

// snap-in notch
snap_len = 10;
snap_width = 8;
snap_notch = 3;
snap_offset = 25;

// snap-in holes for panel mounts
snap_bottom_y = 10;
snap_top_y    = depth - 15;
snap_bottom_z = 20;
snap_top_z    = height -30;
snap_hook_height = 10;
snap_base_height = 15; // base to side panels hole-peg mount
snap_dt = 0.6;
snap_hook_notch = 1;
snap_hook_extens = 1.6*snap_hook_notch;
snap_spring_slot_h = 0.8;
snap_spring_slot_extens = 20;
snap_hook_left = 10;
snap_hook_right = width - 10 - snap_hook_height;

// ------------------------------------------------------------------------------------
boxDemo();
// ------------------------------------------------------------------------------------

// lid();
// megaMountHoles();
// cableGuards(false);

module boxDemo() {
    base();
    top_panel();
    bottom_panel();
    right_panel();
    left_panel();
    translate([0,depth+2.2*wall,0]) lid();
    cableGuards(true);
}

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
        translate([rad - 2*narrowing,0,+wall]) cube([2*wall+3*narrowing,narrowing,4*wall+3*delta],center=true);
    }
}

module fanMount(rad, delt) {
    span = 50;
    ox = width / 2 - span / 2 + wall; oy = height-span-30; 
    translate([ox,wall+delt,oy]) rotate([90,0,0]) cylinder(d=rad,h=wall+2*delt);
    translate([ox+span,wall+delt,oy]) rotate([90,0,0]) cylinder(d=rad,h=wall+2*delt);
    translate([ox+span,wall+delt,oy+span]) rotate([90,0,0]) cylinder(d=rad,h=wall+2*delt);
    translate([ox,wall+delt,oy+span]) rotate([90,0,0]) cylinder(d=rad,h=wall+2*delt);
}

// lid snap-in mount
module lidSnapIn() {
    translate([-lip,-snap_len/2,0]) cube([wall,snap_len,snap_width], center=true);
    translate([-lip-wall/2+snap_notch/2,-snap_len,-snap_width/2]) cylinder(d=snap_notch, h=snap_width);
}

// hole for the lid snap-in mount
module lidSnapHole() {
    translate([-delta,-snap_len + snap_notch/2 + 3*lip,-snap_width/2-lip]) cube([wall+2*delta, snap_notch, snap_width+2*lip]);
}

// TODO: mounting holes. Add mounting cylinders, then diff out the mounting holes.
module lid() {
    difference() {
        union() {
            difference() {
                translate([-extens,0,0]) cube([width+2*wall+2*extens,wall,height+2*wall]);
                for (x = [4*wall : 2*wall : height-2*wall]) {
                    translate([3*wall,-delta,x]) cube([width-4*wall,wall+2*delta,wall]);
                }
            }

            // 4 mounting holes
            fanMount(fan_mnt_hole + 3, 0);
            
            // snap-in mounts
            translate([wall+3*lip,0,snap_offset+wall]) rotate([0,180,0]) lidSnapIn();
            translate([wall+3*lip,0,height-snap_offset+wall]) rotate([0,180,0]) lidSnapIn();
            translate([width+wall-3*lip,0,snap_offset+wall]) lidSnapIn();
            translate([width+wall-3*lip,0,height-snap_offset+wall]) lidSnapIn();
        }
        
        fanMount(fan_mnt_hole, delta);
    }
}

// note - remove the transforms before printing
module cableGuards(demo) {
    if (demo) {
        translate([cable_out_top_x, cable_out_h, height+wall]) cableGuard(cable_x_rad);
        translate([width+wall, cable_out_h, cable_out_side_left_z]) rotate([0,90,0]) cableGuard(cable_y_rad);
        translate([wall, cable_out_h, cable_out_side_right_z]) rotate([180,90,0]) cableGuard(cable_m_rad);
    } else {
        translate([0,0,3*wall]) rotate([180,0,0]) cableGuard(cable_x_rad);
        translate([cable_x_rad * 2,0,3*wall]) rotate([180,0,0]) cableGuard(cable_y_rad);
        translate([-cable_x_rad * 2,0,3*wall]) rotate([180,0,0]) cableGuard(cable_m_rad);
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
        %translate([38,-5,2.5]) cube([9,15.0,11]);
        
        // ramps board
        %translate([0,-2,2.5+13]) cube([53.3,106.6,2]);
        
        // ramps board top mounted sockets
        %translate([24,-2+5,2.5+13+2.5]) cube([25,8,20]);
        %translate([4,-2+5,2.5+13+2.5]) cube([18,8,15]);
        
        // smart ctl daughterboard
        %translate([0,101.6-6,2.5+26]) cube([53.3,15,2]);
        // two duponts for smart ctrl on daughterboard
        %translate([10,101.6,2.5+26]) cube([16,8,14]);
        %translate([30,101.6,2.5+26]) cube([16,8,14]);
    }
}

module body() {
    cube([width,/*depth+*/3*wall,height]);
}

// top bottom snap holes
module topbottom_snap_holes() {
    translate([-snap_dt/2,snap_bottom_y,-delta]) cube([wall+snap_dt,snap_hook_height+snap_dt, wall+2*delta]);
    translate([-snap_dt/2,snap_top_y,-delta]) cube([wall+snap_dt,snap_hook_height+snap_dt, wall+2*delta]);
    translate([width+wall-snap_dt/2,snap_bottom_y,-delta]) cube([wall+snap_dt,snap_hook_height+snap_dt, wall+2*delta]);
    translate([width+wall-snap_dt/2,snap_top_y,-delta]) cube([wall+snap_dt,snap_hook_height+snap_dt, wall+2*delta]);
    
    translate([wall+snap_hook_left-snap_dt/2,-snap_dt/2,-delta]) cube([snap_hook_height+snap_dt, 2*wall + snap_dt, wall+2*delta]);
    translate([wall+snap_hook_right-snap_dt/2,-snap_dt/2,-delta]) cube([snap_hook_height+snap_dt, 2*wall + snap_dt, wall+2*delta]);
}

// side snap holes
module side_snap_holes() {
    translate([-delta,-snap_dt/2,snap_top_z-snap_dt/2]) cube([wall+2*delta, 2*wall+snap_dt, snap_base_height + snap_dt]);
    translate([-delta,-snap_dt/2,snap_bottom_z-snap_dt/12]) cube([wall+2*delta, 2*wall+snap_dt, snap_base_height + snap_dt]);
}

// excess material to remove to make a rounded corner
module rounded_corner(dia,w) {
    translate([-dia/2,-dia/2,0]) difference() {
        translate([0,0,delta/2]) cube([dia/2,dia/2,w]);
        cylinder(d=dia,h=w+delta);
    }
}

// these are on the left and right panel, top and bottom side. They snap into the holes in top/bottom panels
// we cut a slot in the one closer to the base in them later
module snap_peg(h, bottom_peg) {
    translate([0,0,-snap_hook_extens]) union() {
        if (bottom_peg) {
            cube([wall, h,wall + snap_hook_extens]);
            translate([0, 0, snap_hook_notch/2]) rotate([0,90,0]) cylinder(d=snap_hook_notch,h=wall);
        } else {
            difference() {
                cube([wall, h,wall + snap_hook_extens]);
                rotate([90,180,90]) rounded_corner(2*snap_hook_notch, wall);
            }
        }
        
        translate([0, h, snap_hook_notch/2]) rotate([0,90,0]) cylinder(d=snap_hook_notch,h=wall);
    }
}
module snap_pegs() {
    // top one has no slot in it cut, so it has to pass through with the peg
    translate([0,snap_top_y + snap_hook_notch,0]) snap_peg(snap_hook_height, true);
    // bottom one will be springy
    translate([0,snap_bottom_y,0]) snap_peg(snap_hook_height - snap_hook_notch, true);
}

// we don't place the spring slot near the edge enough to have thin enough wall for a spring, so we make two holes to make it springy
module snap_spring_slot() {
    translate([-delta,snap_top_y + snap_hook_height/2, - snap_hook_extens - delta]) cube([wall+2*delta, snap_spring_slot_h, snap_spring_slot_extens]);
    translate([-delta,snap_top_y + snap_hook_height + snap_spring_slot_h, - snap_hook_extens + snap_hook_notch]) cube([wall+2*delta, snap_spring_slot_h, snap_spring_slot_extens - snap_hook_notch]);
}

module top_panel() {
    translate([0,0,height+wall]) difference() {
        translate([-extens,-extens,0]) cube([width+2*wall+2*extens,depth+2*wall+extens,wall]);

        // through hole for X axis cable
        translate([cable_out_top_x, cable_out_h,-delta]) cylinder(d=cable_x_rad, h=wall+2*delta);

        // through hole for USB
        translate([usb_x, usb_y,-delta]) cube([usb_w,usb_h,wall*2+2*delta]);

        // air duct out on top
        for (h = [0:wall*2:top_duct_height]) {
            for (w = [0:wall*2:top_duct_width]) {
                translate([top_duct_x + w, top_duct_y + h, - delta/2]) cube([wall*1.2,wall*1.2,wall+delta]);
            }
        }
        
        topbottom_snap_holes();
    }
}

module bottom_panel() {
    difference() {
        translate([-extens,-extens,0]) cube([width+2*wall+2*extens,depth+2*wall+extens,wall]);
        // ============== bottom panel ===============
        // control box cables + power - in
        translate([10, 2*wall + depth - 12, -delta]) cube([width - 2*10 + 2*wall,12+delta,wall+2*delta]);
        
        // mount holes for snap-in extensions
        topbottom_snap_holes();
    }
}

module right_panel() {
    translate([0,0,wall])  difference() {
        union() {
            difference() {
                translate([0,-extens,0]) cube([wall,depth+2*wall+extens,height]);
                translate([wall,depth,snap_offset]) rotate([0,180,0]) lidSnapHole();
                translate([wall,depth,height-snap_offset]) rotate([0,180,0]) lidSnapHole();
                // through hole for the X motor
                translate([-delta, cable_out_h, cable_out_side_right_z]) rotate([0,90,0]) cylinder(d=cable_m_rad, h=wall+2*delta);
                
                // slide - in holes where the 3030 mount is
                translate([-delta,-extens-delta,mount_bottom_offset -profile - wall - snap_dt/2]) cube([wall+2*delta, extens + 2*wall, profile + snap_dt]);
                translate([-delta,-extens-delta,mount_top_offset    -profile - wall - snap_dt/2]) cube([wall+2*delta, extens + 2*wall, profile + snap_dt]);
                
                
            }
            
            translate([0,0,-wall]) snap_pegs();
            translate([wall,0,height+snap_hook_extens]) rotate([0,180,0]) snap_pegs();
        }
        
        // 2 spring slots
        translate([0,0,-wall]) snap_spring_slot();
        translate([wall,0,height+snap_hook_extens]) rotate([0,180,0]) snap_spring_slot();
    }
}

module left_panel() {
    translate([width+wall,0,wall]) difference() {
        union() {
            difference() {
                translate([0,-extens,0]) cube([wall,depth+2*wall+extens,height]);
                translate([0,depth,snap_offset]) lidSnapHole();
                translate([0,depth,height-snap_offset]) lidSnapHole();
                // through hole for the Y carriage cable
                translate([- delta, cable_out_h, cable_out_side_left_z]) rotate([0,90,0]) cylinder(d=cable_y_rad, h=wall+2*delta);
                
                // mount holes - on left it slides onto two long guide rectangles
                side_snap_holes();
        
            }
            translate([0,0,-wall]) snap_pegs();
            translate([wall,0,height+snap_hook_extens]) rotate([0,180,0]) snap_pegs();
        }
        
        // 2 spring slots
        translate([0,0,-wall]) snap_spring_slot();
        translate([wall,0,height+snap_hook_extens]) rotate([0,180,0]) snap_spring_slot();
    }
}

module base() {
    union() {
        difference() {
            union() {
                
                translate([wall+snap_dt,0,wall]) body();

                translate([-10,0, mount_bottom_offset]) rotate([0,90,90]) mount3030();
                translate([-10,0, mount_top_offset]) rotate([0,90,90]) mount3030();
                
                // these rise the walls for holding the panel on both sides
                translate([0,3,mount_bottom_offset - profile])rotate([0,0,45]) cube([2*wall,2*wall,profile]);
                translate([0,3,mount_top_offset - profile])rotate([0,0,45]) cube([2*wall,2*wall,profile]);
                
                // panel guide pegs on the left side
                translate([width+wall,0,snap_top_z + wall]) cube([wall, 2*wall, snap_base_height]);
                translate([width+wall,0,snap_bottom_z + wall]) cube([wall, 2*wall, snap_base_height]);

                // top/bottom panel guides
                // top
                translate([wall+snap_hook_left,0,height+wall]) cube([snap_hook_height,2*wall,wall]);
                translate([wall+snap_hook_right,0,height+wall]) cube([snap_hook_height,2*wall,wall]);
                // bottom
                translate([wall+snap_hook_left,0,0]) cube([snap_hook_height,2*wall,wall]);
                translate([wall+snap_hook_right,0,0]) cube([snap_hook_height,2*wall,wall]);
            }
            
            // right panel guides + tolerance
            // bottom mount
            translate([0,2*wall-snap_dt/2,mount_bottom_offset-profile-delta]) cube([wall+snap_dt,3*wall+snap_dt,profile+2*delta]);
            // top mount
            translate([0,2*wall-snap_dt/2,mount_top_offset-profile-delta]) cube([wall+snap_dt,3*wall+snap_dt,profile+2*delta]);
        }
        
        // pillars for the arduino (china clone)
        translate([mega_x, 3*wall-0.01, height-101.6+mega_y-8]) rotate([90,180,180]) megaMountHoles();
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
        translate([15,15,-0.5])rotate([0,0,90])cylinder(h = 7, d = 6.2, $fn=100);
    }
}
