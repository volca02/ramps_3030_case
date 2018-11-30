include <whole_case.scad>

// should be symmetrical, but we might introduce a cable guide into this piece as well
// and we want topside to be the outer side
 translate([0,0,wall]) rotate([180,0,0]) bottom_panel();