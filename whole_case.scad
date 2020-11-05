// Modified from PSU mount by kumekay
// use these modules to produce the shapes
//
// left_panel
// right_panel
// top_panel
// bottom_panel
// base
// lid
//
// all modules are oriented as they go together (not in printable orientation)

$fs=0.01;
profile = 30;
width = 70 + 20 + 2*2;
depth = 55 + 13 + 2*3;
height = 120 + 2*2;
wall = 1.5;

base_depth = 2*wall;

// tolerance agains Z-fighting
delta = 0.01;

// cable guard snap-in lip
lip = 0.3;

// mounting pillars for atmega
mount_outer  = 8;
mount_inner  = 3.5;
mount_height = 5;

// dimensions of the USB hole
usb_w = 14;
usb_h = 13;

mega_x = 5 + 8;
mega_y = 0;
usb_x = mega_x + 6;
usb_y = 3*wall + mount_height + 2.5 - 1; // 2.5 is board width, 1 mm is the margin

fan_mnt_hole = 4.1;

// we need less, but we're leving room for the fit inserts
cable_x_rad = 14;
cable_y_rad = 9;
cable_m_rad = 12;

pillar_screw_d = 3.5;
pillar_d = pillar_screw_d + 2*wall;
pillar_h = depth - base_depth;
pillar_off = 2.5*wall;

cable_out_h = 49;
cable_out_bottom_h = 29 + 5;
cable_out_top_x = width - pillar_d - cable_x_rad + 3 * wall;
cable_out_bottom_x = cable_out_top_x;
cable_out_side_left_z = 55;
cable_out_side_right_z = 44;

mount_bottom_offset = 25+profile;
mount_top_offset = height-10;

// top duct width/height
top_duct_x = 4 * wall;
top_duct_y = 2*wall + mount_height + usb_h + wall * 3;
top_duct_width = cable_out_top_x - cable_x_rad / 2 - top_duct_x - 2*wall;
top_duct_height = depth - top_duct_y - 2 * wall;

bottom_slot_h = 14+delta;

// support every centimeter
support_sp = 10;
support_w = 0.4;

// rotate([-90,0,0]) fan_lid();
box_demo();

module support(h,d=wall) {
    #cube([support_w,h,d]);
}

module supports() {
    // bottom slot supports
    translate([10, 2*wall + 55 - 12, 0]) {
        for(x=[support_sp:support_sp:width - 2*10 + 2*wall]) translate([x,0,0]) support(h=bottom_slot_h);
    }
}

module box_demo() {
    solid_box();
    supports();
    //fan_lid();
    //cable_guards(true);
}

module chamfers() {
    ch_d = 4;
    w2 = 2*wall;
    rotate([ 0, 45, 0 ]) translate([ 0, depth / 2, 0 ])
            cube([ ch_d, depth + 8 * wall, ch_d ], center = true);
    translate([ width, 0, 0 ]) rotate([ 0, 45, 0 ])
            translate([ 0, depth / 2, 0 ])
                    cube([ ch_d, depth + 8 * wall, ch_d ], center = true);
    translate([ 0, 0, height ]) rotate([ 0, 45, 0 ])
            translate([ 0, depth / 2, 0 ])
                    cube([ ch_d, depth + 8 * wall, ch_d ], center = true);
    translate([ width, 0, height ]) rotate([ 0, 45, 0 ])
            translate([ 0, depth / 2, 0 ])
                    cube([ ch_d, depth + 8 * wall, ch_d ], center = true);
}

module solid_box() {
    difference() {
        union() {
            base();
            top_panel();
            bottom_panel();
            right_panel();
            left_panel();
            pillars();
        }

        // minus the chamfers
        chamfers();
    }
}

module pillar(d=pillar_d,h=pillar_h) {
    rotate([-90,0,0]) difference() {
        cylinder(h=h, d=d);
        cylinder(h=h + delta, d=pillar_screw_d);
    }
}

// screw-in pillars for the lid
module pillars() {
    pd2 = pillar_off;

    translate([0,base_depth,0]) {
        translate([pd2,0,pd2]) pillar();
        translate([width - pd2,0,pd2]) pillar();
        translate([pd2,0,height  - pd2]) pillar();
        translate([width - pd2,0,height - pd2]) pillar();
    }
}

module fan_mount(rad, delt) {
    span = 70;
    ox = width / 2 - span / 2; oy = height-span-25;
    w2=2*wall;

    translate([ox,w2+delt,oy]) rotate([90,0,0]) cylinder(d=rad,h=w2+2*delt);
    translate([ox+span,w2+delt,oy]) rotate([90,0,0]) cylinder(d=rad,h=w2+2*delt);
    translate([ox+span,w2+delt,oy+span]) rotate([90,0,0]) cylinder(d=rad,h=w2+2*delt);
    translate([ox,w2+delt,oy+span]) rotate([90,0,0]) cylinder(d=rad,h=w2+2*delt);
}

module lid_mount(rad, delt) {
    pd2 = pillar_d/2;
    w2 = 2*wall;
    h = 2*wall;

    translate([pd2,0,pd2]) rotate([-90,0,0]) cylinder(d=rad,h=h+delt);
    translate([width - pd2,0,pd2]) rotate([-90,0,0]) cylinder(d=rad,h=h+delt);
    translate([pd2,0,height - pd2]) rotate([-90,0,0]) cylinder(d=rad,h=h+delt);
    translate([width - pd2,0,height - pd2]) rotate([-90,0,0]) cylinder(d=rad,h=h+delt);
}

module frame(w, h, t, d) {
    t2 = t / 2;
    union() {
        translate([0,-d,0]) cube([w + t, d, t]);
        translate([0,-d,h]) cube([w + t, d, t]);
        translate([0,-d,0]) cube([t, d, h]);
        translate([0+w,-d,0]) cube([t, d, h]);
    }
}

// simplified cover that only mounts a bigger 80 mm fan
module fan_lid() {
    translate([0,depth,0]) difference() {
        union() {
            cube([width,2*wall,height]);

            // 4 fan mounting holes
            fan_mount(fan_mnt_hole + 8, 0);

            // 4 lid mounting holes
            translate([0,0,0]) lid_mount(pillar_d, 0);
        }

        // text
        translate([width/2-28,2*wall,height+37]) rotate([-90,0,0]) rotate([0,180,0]) {
            translate([-67,51,0.6]) rotate([180,0,0]) linear_extrude(height = 2)
            { text("DERIVATIVE",font = "helvetica:style=Bold", size=5); }
            translate([-26,51,0.6]) rotate([180,0,0]) linear_extrude(height = 2)
            { text("VOLCA",font = "helvetica:style=Bold", size=8); }
            translate( [ -66 , 42.5 , -0.4 ] )  cube( [ 38 , 1.6 , 1 ] );
        }

        // fan hole
        span = 70;
        ox = width / 2 - span / 2; oy = height-span-25;
        translate([ox + span/2,-wall-delta,oy+span/2]) rotate([-90,0,0]) cylinder(d=75,h=4*wall+2*delta,$fn=100);

        fan_mount(fan_mnt_hole, delta);
        lid_mount(pillar_screw_d, delta);

        chamfers();
    }
}

module cable_guard(rad) {
    difference() {
        union() {
            translate([0,0,-2*wall]) cylinder(d=rad,h=4*wall);
            translate([0,0,0]) cylinder(d=rad+2*wall,h=2*wall);
            translate([0,0,-2*wall]) cylinder(d=rad+lip,h=0.8*wall);
        }

        // inner hole, a mil narrower
        narrowing = 2;

        translate([0,0,-wall-delta]) cylinder(d=rad - narrowing, h = 4*wall+2*delta);

        // split slot to make it forceable
        translate([rad - 2*narrowing,0,+wall]) cube([2*wall+3*narrowing,narrowing,4*wall+3*delta],center=true);
    }
}

// note - remove the transforms before printing
module cable_guards(demo) {
    if (demo) {
        translate([cable_out_top_x, cable_out_h, height]) cable_guard(cable_x_rad);
        translate([cable_out_bottom_x, cable_out_bottom_h, 0]) rotate([0,180,0]) cable_guard(cable_x_rad);
        translate([width, cable_out_h, cable_out_side_left_z ]) rotate([0,90,0]) cable_guard(cable_y_rad);
        translate([0, cable_out_h, cable_out_side_right_z]) rotate([180,90,0]) cable_guard(cable_m_rad);
    } else {
        translate([0,0,3*wall]) rotate([180,0,0]) cable_guard(cable_x_rad);
        translate([cable_x_rad * 4,0,3*wall]) rotate([180,0,0]) cable_guard(cable_x_rad);
        translate([cable_x_rad * 2,0,3*wall]) rotate([180,0,0]) cable_guard(cable_y_rad);
        translate([-cable_x_rad * 2,0,3*wall]) rotate([180,0,0]) cable_guard(cable_m_rad);
    }
}

// mounting pillar for atmega
module mount_hole() {
    difference() {
        cylinder(d=mount_outer, h=mount_height);
        cylinder(d=mount_inner, h=mount_height);
    }
}

module mega_mount_holes() {
    // origin is corner of the PCB, up closest to USB port

    translate([0,-101.6,mount_height]) union() {
        translate([2.5,15,-mount_height]) mount_hole();
        translate([2.5,90,-mount_height]) mount_hole();
        translate([49.54,13.5,-mount_height]) mount_hole();
        translate([49.5,96.5,-mount_height]) mount_hole();

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

module top_panel() {
    translate([0,0,height - wall]) difference() {
        cube([width,depth,wall]);

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
    }
}

module bottom_panel() {
    difference() {
        cube([width,depth,wall]);

        // through hole for X axis cable
        translate([cable_out_top_x, cable_out_bottom_h,-delta]) cylinder(d=cable_x_rad, h=wall+2*delta);

        // ============== bottom panel ===============
        // control box cables + power - in
        translate([10, 2*wall + 55 - 12, -delta]) cube([width - 2*10 + 2*wall,bottom_slot_h,wall+2*delta]);
    }
}

module right_panel() {
    difference() {
        cube([wall,depth,height]);
        // through hole for the X motor
        translate([-delta, cable_out_h, cable_out_side_right_z]) rotate([0,90,0]) cylinder(d=cable_m_rad, h=wall+2*delta);
    }
}

module left_panel() {
    translate([width - wall,0,0]) difference() {
                cube([wall,depth,height]);

                // through hole for the Y carriage cable
                translate([- delta, cable_out_h, cable_out_side_left_z]) rotate([0,90,0]) cylinder(d=cable_y_rad, h=wall+2*delta);
        }
}

module base() {
    union() {
        translate([0/*+snap_dt*/,0,0]) cube([width, /*depth+*/base_depth, height]);

        translate([-10,0, mount_bottom_offset]) rotate([0,90,90]) mount3030();
        translate([-10,0, mount_top_offset]) rotate([0,90,90]) mount3030();

        // these rise the walls for holding the panel on both sides
        /*translate([0,3,mount_bottom_offset - profile])rotate([0,0,45]) cube([2*wall,2*wall,profile]);
        translate([0,3,mount_top_offset - profile])rotate([0,0,45]) cube([2*wall,2*wall,profile]);*/

        // pillars for the arduino (china clone)
        translate([mega_x, 3*wall-0.01, height-101.6+mega_y-8]) rotate([90,180,180]) mega_mount_holes();
    }
}

module mount3030(profile = 30) {
    slot_width = 7.9;
    thickness = 6;
    deepness = 2;
    gap=10;

    difference() {
        union() {
            translate([0,-gap,0])cube([profile,profile+gap,thickness]);
            translate([0,(profile-slot_width)/2,0])cube([slot_width-deepness,slot_width,thickness+deepness]);
            translate([profile-slot_width+deepness,(profile-slot_width)/2,0])cube([slot_width-deepness,slot_width,thickness+deepness]);
            translate([profile-slot_width+deepness,(profile+slot_width)/2,thickness])rotate([90,0,0])cylinder(slot_width,deepness,deepness, $fn=100);
            translate([slot_width-deepness,(profile+slot_width)/2,thickness])rotate([90,0,0])cylinder(slot_width,deepness,deepness, $fn=100);
        }
            translate([15,15,-0.5])rotate([0,0,90])cylinder(h = 7, d = 6.2, $fn=100);
    }
}
