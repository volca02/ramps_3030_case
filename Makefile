%.stl: %.scad
	openscad -o $@ $<

all: bed_cable_clip.stl extruder_cable_clip.stl body.stl lid.stl whole_case.stl

# phony rules describing dependencies
bed_cable_clip.stl: bed_cable_clip.scad whole_case.scad
extruder_cable_clip.stl: extruder_cable_clip.scad whole_case.scad
body.stl: body.scad whole_case.scad
lid.stl: lid.scad whole_case.scad

clean:
	-rm *.stl
