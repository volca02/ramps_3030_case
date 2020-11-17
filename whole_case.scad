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

$fn=60;
profile = 30;
width = 70 + 20 + 2*2;
height = 120 + 2*2;
// depth = 55 + 13 + 2*3;
wall = 1.5;

pillar_d = 2;

// we need less, but we're leving room for the fit inserts
cable_x_d = 9.2;
cable_y_rad = 9;
cable_m_rad = 12;

cable_out_h = 49;
cable_out_bottom_h = 29 + 5;
cable_out_side_left_z = 75;
cable_out_side_right_z = 44;
cable_out_left_d = 22;

depth = cable_out_h + 12.6; //- cable_y_rad;
lid_depth = 14;

base_depth = 2*wall;

// tolerance agains Z-fighting
delta = 0.01;

// cable guard snap-in lip
lip = 0.3;

// mounting pillars for atmega
mount_outer  = 8;
mount_inner  = 3.5;
mount_height = 5;
mount_depth  = 1;

// dimensions of the USB hole
usb_w = 14;
usb_h = 13;

mega_x = 5 + 8;
mega_y = 0;
usb_x = mega_x + 6;
usb_y = base_depth + mount_height + 2.5 - 1; // 2.5 is board width, 1 mm is the margin

fan_mnt_hole = 4.1;

screw_d = 3.1;
screw_head_d = 6;

pillar_screw_d = 3.5;
pillar_h = depth - base_depth - 2.7;
pillar_left_h = depth - base_depth;
pillar_off = pillar_d;

// nut trap
nut_trap_h = 2.8;
nut_trap_w = 5.5;
nut_trap_off = 2.9; // depth of the nut trap

mount_bottom_offset = 25+profile;
mount_top_offset = height-10;

// top duct width/height
top_duct_x = 5 * wall;
top_duct_y = 2*wall + mount_height + usb_h + wall * 3;
top_duct_width  = width - 43;
top_duct_height = depth - top_duct_y - 4 * wall;

bottom_slot_h = 18+delta;

// ziptie mounts
// various input power etc...
ziptie1_h = 20;
ziptie1_z = 22;

// Extruder cable
ziptie2_h = 38;
ziptie2_z = height - 25;

hinge_d = 8;
hinge_h = 5;
hinge_in_h = 4.5;
hinge_in_off = (hinge_h - hinge_in_h)/2;
hinge_in_d = 1.9;
hinge_offset = 4;

// lid poles
lid_pole_h = 3.1;
lid_pole_d = 2.7;

// rotate([-90,0,0]) fan_lid();
box_demo();

// bed_cable_leadout();
//bed_cable_cover();

/* TO TEST PRINT:
   * Hinge for the filament insertion clearance and spacing/fit of both pars
   * closing mechanism once implemented
   * cable covers bottom/top to test nut insertion, screw fit and cable tightness
   * bottom part for the screw mount offsets AND depths
*/

/* TO RESOLVE:

 * bottom part needs repositioning of some of the mount pillars
 * PCB mount needs screw depths tuned
 * X cable leadout needs to be done. simple hole won't hold the cable. Maybe a hook shaped hole would

 */

module box_demo() {
    solid_box();

    translate([ width - wall - delta, cable_out_h, cable_out_side_left_z ]) bed_cable_cover();
    translate([0,0,height - wall]) top_cable_cover();
    hoffx = hinge_offset-wall;
    hoffy = -0;
    /*
    translate([0,depth,0]) translate([-hoffx,-hoffy,0]) rotate([0,0,90*(1+sin(360*$t))]) translate([hoffx,hoffy,0]) fan_lid();
        */
    translate([0,depth+0.1,0]) translate([-hoffx,-hoffy,0]) rotate([0,0,0]) translate([hoffx,hoffy,0]) fan_lid();
}


module support(h,d=wall) {
    cube([support_w, h, d]);
}

module supports() {
    // bottom slot supports
    translate([10, 2*wall + 55 - 12, 0]) {
        for(x=[support_sp:support_sp:width - 2*10 + 2*wall]) translate([x,0,0]) support(h=bottom_slot_h);
    }
}

module hinge(x=0,y=15,o=0,hh=hinge_h,c=3,dp=0) {
    for(h=[0:1:c-1]) translate([0,0,h*2*hinge_h + o]) difference() {
            hull() {
                cylinder(d=hinge_d+dp,h=hh);
                translate([x,y,0]) cylinder(d=0.1,h=hh);
            }

            translate([0,0,-delta]) cylinder(d=hinge_in_d,h=hinge_h+2*delta);
    }
}

module box_hinges(sp=0,dp=0) {
    // hinges
    translate([ -2.6, depth, hinge_offset + hinge_h ])
            hinge(x = 4, y = -10, hh = hinge_in_h + sp, o = hinge_in_off - sp/2, c = 2, dp=dp);
    translate([ -2.6, depth, height - hinge_offset - 4 * hinge_h ])
            hinge(x = 4, y = -10, hh = hinge_in_h + sp, o = hinge_in_off - sp/2, c = 2, dp=dp);
}

module lid_hinges(sp=0,dp=0) {
    // hinges
    translate([ -2.6, 0, hinge_offset ])
            hinge(x = 7.8, y = 11.5, hh = hinge_h + sp, o = -sp / 2, dp = dp);
    translate([ -2.6, 0, height - hinge_offset - 5 * hinge_h ])
            hinge(x = 7.8, y = 11.5, hh = hinge_h + sp, o = -sp / 2, dp = dp);
}

module hook() {
    d_latch = 3;
    d_eff   = 5;

    difference() {
        translate([-14+d_latch/2,-0.3,0]) linear_extrude(height=10, convexity = 10) {
            union() {
                difference() {
                    hull() {
                        circle(d=d_eff);
                        translate([15,0]) circle(d=d_eff);
                    }

                    // we only leave the negative part...
                    translate([-15,0]) square([40,d_eff]);
                }

                // hook itself
                translate([(d_latch-d_eff)/2,0]) circle(d=d_latch);

                // a slight slope to ease printing
                translate([(d_latch-d_eff)/2+d_latch/2,0]) polygon([[0,0],[0.25,0],[-0.25,0.5]]);

                // mounting part
                translate([15,0]) hull() {
                    circle(d=d_eff);
                    translate([9,7]) circle(d=1);
                }
            }
        }

        // chamfers
        translate([-30,-3,-3]) rotate([45,0,0]) cube([40,3,3]);
        translate([-30,-3,10-1.3]) rotate([45,0,0]) cube([40,3,3]);
    }
}

module chamfers() {
    ch_d = 3;
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

// stolen from prusa MK3S Einsy base source code
// it's a wall mounted ziptie based cable organization thing
module ziptie_mount() {
    rotate([0,180,0]) rotate([-90,0,0])
    difference() {
        translate([ 0,  0, -2 ]) cube([ 5, 8, 10 ]);
        translate([ 0, -1, -3 ]) rotate([ 0,  45, 0 ]) cube([ 5, 10, 8 ]);
        translate([ 5, -1,  6 ]) rotate([ 0, -60, 0 ]) cube([ 5, 10, 8 ]);

        union() {
            translate([ 1.5, 2.5, 3.5 ]) cube([ 2  , 3, 10 ]);
            translate([ 3  , 2.5, 2   ]) cube([ 5.5, 3,  2 ]);
            translate([ 2  , 2.5, 6.5 ]) cube([ 5  , 3,  3 ]);

            difference() {
                translate([ 3, 5.5, 3.5 ]) rotate([ 90, 0, 0 ])
                    cylinder(h = 3, r = 1.5, $fn = 30);
                translate([ 3.5, 1.5, 4 ]) cube([ 5, 5, 3 ]);
            }

            difference() {
                translate([ 4, 5.5, 4.5 ]) rotate([ 90, 0, 0 ])
                    cylinder(h = 3, r = 1, $fn = 30);
                translate([ 4, 5.5, 4.5 ]) rotate([ 90, 0, 0 ])
                    cylinder(h = 3, r = 0.5, $fn = 30);
                translate([ 3.5, 1.5, 4.5 ]) cube([ 5, 5, 3 ]);
                translate([ 4., 1.5, 4 ]) cube([ 5, 5, 3 ]);
            }
        }
    }
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
/*        cylinder(h=h, d=d);
        cylinder(h=h + delta, d=pillar_screw_d);*/
        translate([0,0,h/2]) cube([d,d,h], center=true);
    }
}

// screw-in pillars for the lid
module pillars() {
    pd2 = pillar_off;

    translate([0,base_depth,0]) {
        translate([pd2,0,pd2]) pillar();
        translate([width - pd2,0,pd2]) pillar(h=pillar_left_h);
        translate([pd2,0,height  - pd2]) pillar();
        translate([width - pd2,0,height - pd2]) pillar(h=pillar_left_h);
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

module lid_shape() {
    slope = lid_depth/2;
    polygon([[0,0],[width,0],[width-slope,lid_depth], [slope,lid_depth]]);
}

module lid_cutout() {
    wl    = 2*wall;
    slope = lid_depth/2;
    polygon([[wl,-delta],[width-wl,-delta],[width-slope,lid_depth-wl], [slope,lid_depth-wl]]);
}

// simplified cover that only mounts a bigger 80 mm fan
module fan_lid() {
    difference() {
        union() {
            difference() {
                linear_extrude(height = height) lid_shape();

                translate([ 0, 0, 2 * wall ])
                    linear_extrude(height = height - 4 * wall) lid_cutout();

                // text
                translate([ width / 2 - 36, lid_depth, height + 37 ])
                    rotate([ -90, 0, 0 ]) rotate([ 0, 180, 0 ])
                {
                    translate([ -66, 45.0, -0.4 ]) cube([ 11.5, 1.6, 1 ]);
                    translate([ -66, 47.25, -0.4 ]) cube([ 11.5, 1.6, 1 ]);
                    translate([ -66, 49.5, -0.4 ]) cube([ 11.5, 1.6, 1 ]);
                    translate([ -51.75, 51, 0.6 ]) rotate([ 180, 0, 0 ])
                        linear_extrude(height = 2)
                    {
                        text("DERIVATIVE", font = "helvetica:style=Bold", size = 6);
                    }
                    translate([ -35, 153, 0.6 ]) rotate([ 180, 0, 0 ])
                        linear_extrude(height = 2)
                    {
                        text("VOLCA", font = "helvetica:style=Bold", size = 6.5);
                    }
                    translate([ -66, 146.75, -0.4 ]) cube([ 28.5, 1.6, 1 ]);
                    translate([ -66, 149.0, -0.4 ]) cube([ 28.5, 1.6, 1 ]);
                    translate([ -66, 151.25, -0.4 ]) cube([ 28.5, 1.6, 1 ]);
                }

                // cosmetics
                translate([ 0, lid_depth, -3.1 ]) rotate([ 45, 0, 0 ])
                    cube([ width, 4, 4 ]);
                translate([ 0, lid_depth, height - 2.8 ]) rotate([ 45, 0, 0 ])
                    cube([ width, 4, 4 ]);

                // todo: Cutout from the circular hole to the side to allow for fan
                // cable to go in cleanly todo: a well designed hinge mechanism. one
                // screw on each end of the lid todo: lid snap-in mechanism to hold
                // it closed (or a single screw system to hold it closed)

                // fan holes
                span = 70;
                ox = width / 2 - span / 2;
                oy = height - span - 25;

                translate([ 0, lid_depth - 2 * wall, 0 ]) {
                    translate([ ox + span / 2, -delta, oy + span / 2 ])
                        rotate([ -90, 0, 0 ]) cylinder(
                                d = 75, h = 4 * wall + 2 * delta, $fn = 100);
                    fan_mount(fan_mnt_hole, delta);

                    // hole for the cable to go through
                    translate([ox+10, -delta, oy-7]) hull() {
                        rotate([-90,0,0]) cylinder(d=6,h=3*wall);
                        translate([0,0,20]) rotate([-90,0,0]) cylinder(d=6,h=3*wall);
                    }
                }

                chamfers();

                // hinges from the other side, to make space for them
                box_hinges(sp=hinge_in_off,dp=1);
            }

            // ziptie holder for the fan cable
            translate([40,lid_depth-2*wall+1.5,7]) rotate([90,0,90]) ziptie_mount();

            lid_hinges();

            // two hooks
            translate([width,0,10]) rotate([0,0,90]) hook();
            translate([width,0,height - 20]) rotate([0,0,90]) hook();

            // support material for lid poles
            translate([width-wall-3.3, 0, height-4.5]) cube([1.8,4,3]);
            translate([width-wall-3.3, 0, 1.5]) cube([1.8,4,3]);
        }

        translate([width-wall, delta, 0]) lid_poles();
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

// mounting pillar for atmega
module mount_pillar() {
    cylinder(d=mount_outer, h=mount_height);
}

module mount_hole() {
    translate([0,0,-mount_depth]) cylinder(d=mount_inner, h=mount_height+mount_depth);
}

module mega_mount_holes() {
    translate([0,-101.6,mount_height]) union() {
        translate([2.5,15,-mount_height]) mount_hole();
        translate([2.5,90,-mount_height]) mount_hole();
        translate([49.54,13.5,-mount_height]) mount_hole();
        translate([49.5,96.5,-mount_height]) mount_hole();
    }
}

module mega_mount_pillars() {
    // origin is corner of the PCB, up closest to USB port

    translate([0,-101.6,mount_height]) union() {
        translate([2.5,15,-mount_height]) mount_pillar();
        translate([2.5,90,-mount_height]) mount_pillar();
        translate([49.54,13.5,-mount_height]) mount_pillar();
        translate([49.5,96.5,-mount_height]) mount_pillar();

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


module top_cable_leadout() {
    rotate([0,-90,0]) difference() {
        // base shape is a conical sided cylinder
        union() {
            cylinder(h=7,d1=22,d2=22-5,$fn=50);
            translate([0,0,-wall]) cylinder(h=wall,d=22,$fn=50);
            translate([0,0,-wall-7]) cylinder(h=7,d1=22-7,d2=22,$fn=50);
        }

        // only half of it is needed...
        translate([-12,0,-13]) cube([24,22,22]);

        // cable leadout for the heated bed is rotated so that it lifts the calbe
        rotate([0,-30,0]) translate([0,0,-25]) cylinder(d=6.5,h=40);

        xoff = 5.0;
        zoff = 3.5;
        sc_h = nut_trap_off - nut_trap_h/2 - 0.12;

        translate([xoff, 0,  zoff]) {
            rotate([90,0,0]) translate([0,0,-delta]) cylinder(d=screw_d,h = sc_h);
            nut_trap();
        }

        translate([-xoff, 0, -zoff-1.5]) {
            rotate([90,0,0]) translate([0,0,-delta]) #cylinder(d=screw_d,h=sc_h);
            nut_trap(180);
        }

        // internal support
    }
}

module top_cable_cover() {
    wls = 16;
    cx = width - 16;
    outd = cable_x_d+wls;
    difference() {
        union() {
            translate([cx, cable_out_h, -delta]) cylinder(d=outd,h=5+wall);
            translate([cx, cable_out_h, 5+wall]) cylinder(d1=outd,d2=outd-3,h=2);
            translate([cx, cable_out_h, -7]) cylinder(d2=outd,d1=outd-7,h=7);

            translate([cx - outd/2 + 0.5, cable_out_h, 0]) cube([outd - 1,25/2,wall]);
        }

        translate([cx-outd/2, -wls+cable_out_h, -8]) cube([outd,wls,19]);

        // excess material on the sides and top
        translate([cx - outd/2, cable_out_h, -5]) cube([0.5, 25/2, 20]);
        translate([cx + outd/2 - 0.5, cable_out_h, -5]) cube([0.5, 25/2, 20]);
        translate([cx-outd/2, cable_out_h+25/2, -8]) cube([outd,wls,19]);

        translate([cx, cable_out_h,-7]) {
            for(z=[5:1:12])
                translate([0,0,z - 0.005])
                    cylinder(d=cable_x_d - (0.5*(z%2)),h=1.01);

            translate([0,0,-delta]) cylinder(d = cable_x_d, h = 5 + delta);
            translate([0,0,-1-delta]) cylinder(d1 = cable_x_d + 4, d2 = cable_x_d, h = 4);
            translate([0,0,12]) union() {
                cylinder(d = cable_x_d, h = 4);
                translate([0,0,2]) cylinder(d1 = cable_x_d, d2=cable_x_d + 3, h = 4);
            }
        }

        sc_h_off = 4;
        translate([ cx, cable_out_h, -delta + screw_head_d / 2 + wall + 0.25 ])
                rotate([ -90, 0, 0 ]) translate([ 0, 0, -delta ])
        {
            for (x=[-8,8]) translate([x,0,0]) {
                    cylinder(d=screw_d,h=sc_h_off + delta);
                    translate([0,0,sc_h_off]) cylinder(d=screw_head_d, h=15);
                }
        }
    }
}

module top_panel() {
    wls = 16;
    cx = width - 16;
    outd = cable_x_d+wls;
    translate([0,0,height - wall]) union() {
        difference() {
            union() {
                cube([width, depth, wall]);

                // cable leadout for the print head
                translate([cx, cable_out_h, -delta + wall]) cylinder(d=outd,h=5);
                translate([cx, cable_out_h, -delta + wall + 5]) cylinder(d1=outd,d2=outd-3,h=2);
                translate([cx, cable_out_h, -7]) cylinder(d2=outd,d1=outd-7,h=7);

                // supports
                translate([ cx + 7, cable_out_h - outd / 2 - 3.2 - 7.5, -delta + wall ]) difference() {
                    rotate([ 0, -90, 0 ]) wedge(14, 14.56, 8.5);
                    translate([-14.5,10,7]) cube([15,14,10]);
                }

                translate([cx - 13/2, base_depth, -wall ]) cube([13,cable_out_h - outd/2, wall]);

                translate([cx - 6.5, cable_out_h - outd / 2 - 3.2 - 4.8, -wall ]) difference() {
                    rotate([ 0, 90, 0 ]) wedge(13, 14, 6.65);
                    translate([0,10,-15.5]) cube([13,14,10]);
                }

            }

            cxr = cable_x_d / 2;

            // whole upper half of the cable cover is removed to allow for screw-in cover
            translate([cx-outd/2, cable_out_h, -8]) cube([outd,wls,19]);
            translate([cx - outd/2, cable_out_h - 25/2, wall + delta]) cube([0.5, 25/2 + delta, 20]);
            translate([cx + outd/2 - 0.5, cable_out_h - 25/2, wall + delta]) cube([0.5, 25/2 + delta, 20]);


            // through hole for X axis cable
            translate([cx, cable_out_h,-8]) {
                translate([-cable_x_d/2,0,-wall/2]) cube([cable_x_d,cable_x_d + 2,6 + 7 + 2 * wall]);
                cylinder(d = cable_x_d, h = 2 * wall + 2 * delta + 6 + 7);
                cylinder(d1 = cable_x_d + 4, d2=cable_x_d, h = 4);
                translate([0,0,15]) cylinder(d1 = cable_x_d, d2=cable_x_d + 3, h = 4);
            }

            // screw holes in the leadout
            sc_h_off = 4;
            translate([cx, cable_out_h-sc_h_off, screw_head_d/2 + wall + 0.25]) rotate([-90,0,0]) {
                for (x=[-8,8]) translate([x,0,0]) {
                        translate([0,0,sc_h_off - nut_trap_h/2]) cylinder(d=screw_d,h=sc_h_off + delta);
                        translate([0,0,-sc_h_off/2]) cylinder(d=screw_d,h=sc_h_off/2);
                        translate([0,0,sc_h_off-delta]) rotate([90,0,0]) nut_trap();
                    }
            }

            // through hole for USB
            translate([usb_x, usb_y,-delta]) cube([usb_w,usb_h,wall*2+2*delta]);

            // air duct out on top
            for (h = [0:wall*2:top_duct_height]) {
                for (w = [0:wall*4:top_duct_width]) {
                    translate([top_duct_x + w, top_duct_y + h, - delta/2]) cube([wall*3.1,wall*1.2,wall+delta]);
                }
            }
        }
    }
}

module bottom_panel() {
    dx = 25;

    union() {
        difference() {
            cube([width,depth,wall]);

            // ============== bottom panel ===============
            // control box cables + power - in
            translate([ 6, 2 * wall + 41, -delta ]) cube(
                    [ width - 2 * 6 + 2 * wall, bottom_slot_h, wall + 2 * delta ]);
            translate([ width - dx - 2*wall, 2 * wall + 20, -delta ]) cube(
                    [ dx, 31, wall + 2 * delta ]);

        }

        translate([width - pillar_off/2 - dx - 2*wall,0,pillar_off]) pillar(h=40 + 2*wall);
    }
}

module right_panel() {
    union() {
        difference() {
            cube([wall,depth,height]);
            translate([0,depth,0]) lid_hinges(sp=hinge_in_off*2,dp=1);

            // cutout for X cable
            translate([-delta,50,55]) rotate([0,90,0]) hull() {
                cylinder(d=10,h=2*wall);
                translate([0,20,0]) cylinder(d=10,h=2*wall);
            }
        }

        box_hinges();

        // support structures for the hinges and overall integrity
        translate([wall, 0, hinge_offset + 7]) cube([2*wall,depth-2*wall,10]);
        translate([wall, 0, height - hinge_offset - 18]) cube([2*wall,depth-2*wall,10]);

        // ziptie mount for fan
        translate([3*wall-1.5,40,20]) rotate([0,180,0]) ziptie_mount();

        // ziptie mount for X cable
        translate([wall-1.5,40,75]) rotate([0,180,0]) ziptie_mount();

    }
}

// nut trap oriented in y plane
module nut_trap(rot=0) {
    trap_l = 8;
    // this makes the inscribed cylinder have the same side to side distance as specified in D
    // inscribed circle in the cylinder instead)
    coeff = 2/sqrt(3);

    translate([0, -nut_trap_off, 0]) rotate([0,rot,0]) union() {
        translate([0,0,trap_l/2]) cube([nut_trap_w, nut_trap_h, trap_l], center=true);
        translate([0,-nut_trap_h/2,0]) rotate([-90,0,0]) rotate([0,0,30]) cylinder(d=coeff*nut_trap_w, h=nut_trap_h,$fn=6);
    }
}

module bed_cable_cover() {
    rotate([0,-90,0]) difference() {
        // base shape is a conical sided cylinder
        union() {
            translate([0,0,-wall-7]) cylinder(h=7,d1=22-6,d2=22,$fn=50);
            translate([-10.5,0,-wall]) cube([21,12.5,7+wall]);
        }

        // only half of it is needed...
        translate([-12,-22,-13]) cube([24,22,22]);


        // cable leadout for the heated bed is rotated so that it lifts the calbe
        rotate([0,-30,0]) translate([0,0,-25]) {
            for(z=[20:1:27])
                translate([0,0,z - 0.005])
                    cylinder(d=6.5 - (0.5*(z%2)),h=1.01);

            // for edges we dont want the ribs
            cylinder(d=6.5,h=20);
            translate([0,0,28]) cylinder(d=6.5,h=15);
            translate([-1,0,14.2]) rotate([0,15,0]) cylinder(d2=6.5,d1=11.5,h=3);
        }

        xoff = 5.0;
        zoff = 3.5;
        sc_h_off = 3;

        translate([xoff+0.5, 0, zoff-0.25]) rotate([-90,0,0]) translate([0,0,-delta]) {
              cylinder(d=screw_d,h=sc_h_off + delta);
              translate([0,0,sc_h_off]) cylinder(d=screw_head_d, h=15);
        }

        translate([-xoff, 0, -zoff-1.4]) rotate([-90,0,0]) translate([0,0,-delta]) {
            cylinder(d=screw_d,h=sc_h_off + delta);
            translate([0,0,sc_h_off]) cylinder(d=screw_head_d, h=15);
        }
    }
}

module bed_cable_leadout() {
    rotate([0,-90,0]) difference() {
        // base shape is a conical sided cylinder
        union() {
            cylinder(h=7,d1=22,d2=22-3,$fn=50);
            translate([0,0,-wall]) cylinder(h=wall,d=22,$fn=50);
            translate([0,0,-wall-7]) cylinder(h=7,d1=22-6,d2=22,$fn=50);
        }

        // only half of it is needed...
        translate([-12,0,-13]) cube([24,22,22]);

        // cable leadout for the heated bed is rotated so that it lifts the calbe
        rotate([0,-30,0]) translate([0,0,-25]) union() {
            cylinder(d=6.5,h=40);
            translate([-1,0,14.2]) rotate([0,15,0]) cylinder(d2=6.5,d1=11.5,h=3);
        }


        xoff = 5.0;
        zoff = 3.5;
        sc_h = nut_trap_off - nut_trap_h/2 - 0.12;

        translate([xoff + 0.5, 0,  zoff - 0.25]) {
            rotate([90,0,0]) translate([0,0,-delta]) cylinder(d=screw_d,h = sc_h);
            nut_trap();
        }

        translate([-xoff, 0, -zoff-1.4]) {
            rotate([90,0,0]) translate([0,0,-delta]) #cylinder(d=screw_d,h=sc_h);
            nut_trap(150);
        }

        // internal support
    }
}

module lid_pole(md) {
    rotate([-90,0,0]) union() {
        cylinder(d1=lid_pole_d-md,d2=1,h=lid_pole_h-md);
        hull() {
            translate([-lid_pole_d/2,-lid_pole_d/2,-1]) cube([lid_pole_d,lid_pole_d,1]);
//            translate([0,0,-1]) cylinder(d=lid_pole_d,h=1);
            translate([1.5,0,-8]) cylinder(d=1,h=1);
        }
    }
}

module lid_poles(md=0) {
    union() {
        translate([-1.2,0,2.5]) lid_pole(md);
        translate([-1.2,0,height-2.5]) lid_pole(md);
    }
}

module wedge(w,h,t) {
    rotate([0,0,90]) linear_extrude(height=w) {
        polygon([[0,0],[h,0],[h,-t]]);
    }
}

module left_panel() {
    translate([ width - wall, 0, 0 ]) union() {
        difference() {
            union() {
                cube([ wall, depth, height ]);

                // support/structural pole
                translate([-wall, 0, cable_out_side_left_z - 11/2])
                        cube([ wall, cable_out_h - 6, 11 ]);

                // structural wedge
                translate([-wall, cable_out_h - 16, cable_out_side_left_z - 11/2]) difference() {
                        wedge(11, 9, -6);
                        translate([-6-10.5,1,-1]) cube([11,15,14]);
                }

                // outer structural wedge
                translate([wall,cable_out_h - 20, cable_out_side_left_z - 8.5/2])
                difference() {
                        wedge(8.5,15,8);
                        translate([7-2*delta,10,-1]) cube([11,15,13]);
                }

                // support for the top cable ziptie
                translate([-3*wall, 0, ziptie2_z])
                        cube([ 3*wall, depth, 8 ]);

                translate([-2*wall, 0, cable_out_side_left_z - 11 - 5])
                        cube([ 2*wall, depth, 5 ]);
                translate([-2*wall, 0, cable_out_side_left_z + 11])
                        cube([ 2*wall, depth, 5 ]);
            }

            // through hole for the Y carriage cable
            translate([-delta, cable_out_h, cable_out_side_left_z]) {
                translate([0,0, - cable_out_left_d/2]) cube([20,20,cable_out_left_d]);
                rotate([ 0, 90, 0 ])
                    cylinder(d = cable_out_left_d, h = wall + 2 * delta);
            }

            // hook holes
            translate([2.5, depth-13.8, 9]) rotate([0,0,90]) cylinder(d=4.5,h=12);
            translate([2.5, depth-13.8, height - 21]) rotate([0,0,90]) cylinder(d=4.5,h=12);
        }

        translate([ -delta, cable_out_h, cable_out_side_left_z ])
                bed_cable_leadout();

        translate([ 1.5, ziptie1_h, ziptie1_z ]) ziptie_mount();
        translate([ 1.5 - 3*wall, ziptie2_h, ziptie2_z ]) ziptie_mount();

        // these hold the lid in place when the hooks are snapped in place
        translate([-delta, depth, 0]) lid_poles(0.5);
    }
}

module base() {
    difference() {
        union() {
            translate([0/*+snap_dt*/,0,0]) cube([width, /*depth+*/base_depth, height]);

            translate([-10,0, mount_bottom_offset]) rotate([0,90,90]) mount3030();
            translate([-10,0, mount_top_offset]) rotate([0,90,90]) mount3030();

            // these rise the walls for holding the panel on both sides
            /*translate([0,3,mount_bottom_offset - profile])rotate([0,0,45]) cube([2*wall,2*wall,profile]);
              translate([0,3,mount_top_offset - profile])rotate([0,0,45]) cube([2*wall,2*wall,profile]);*/

            // pillars for the arduino (china clone)
            translate([mega_x, base_depth-0.01, height-101.6+mega_y-8]) rotate([90,180,180]) mega_mount_pillars();
        }

        translate([mega_x, base_depth-0.01, height-101.6+mega_y-8]) rotate([90,180,180]) mega_mount_holes();
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
