// EXPERIMENTAL: DO NOT PRINT UNLESS YOU ARE HAPPY TO WASTE PLASTIC
// EXPERIMENTAL: DO NOT PRINT UNLESS YOU ARE HAPPY TO WASTE PLASTIC
// EXPERIMENTAL: DO NOT PRINT UNLESS YOU ARE HAPPY TO WASTE PLASTIC
// EXPERIMENTAL: DO NOT PRINT UNLESS YOU ARE HAPPY TO WASTE PLASTIC

include <config.scad>;
use <metric-cerberus.scad>;
to_print = 1;
layer_height = .25; // to add a layer of bridging support to the bearing holes
roller_diameter = 13.3; // on flat part
roller_width = 11;

if (0) {
  translate([0,19.5,2]) #vert_carriage_for_623_dual_bearing_roller();
}

module vert_carriage(extrusion_width = 40, spacing = 2.5, curvature = 8)
{
  width = extrusion_width+10;
  height = width;
  depth = 25;
  hole_offset = extrusion_width/2+5;
  vert_hole_offset = height;
  cut_width = extrusion_width+spacing;
  center_width = 4.5;
  adjustment_slit_width = 1.5;
  end_stop_block_width = 25;
  end_stop_screw_hole_diameter = 0; // 3.5mm (m4 tap) or 0 (no hole)
  end_stop_block = 0;
  bearing_support_rad = 5;
  hull_offset = curvature-bearing_support_rad;
  idler_gap = 3;

  difference() {

    union() {
      // main body
      hull() {
        translate([width/2-hull_offset, 0, -1*height/2])
          rotate([90,0,0]) cylinder(r=curvature, h = depth, center = true);
        translate([width/2-hull_offset, 0, 1*height/2])
          rotate([90,0,0]) cylinder(r=curvature, h = depth, center = true);
        translate([-10, 0, -1*height/3])
          rotate([90,0,0]) cylinder(r=curvature, h = depth, center = true);
        translate([-10, 0, 1*height/2])
          rotate([90,0,0]) cylinder(r=curvature, h = depth, center = true);
      }
      // body idler
      difference() {
        hull() {
          translate([-width/2+hull_offset, 0, -1*height/4])
            rotate([90,0,0]) cylinder(r=curvature, h = depth, center = true);
          translate([-width/2+hull_offset, 0, 1*height/4])
            rotate([90,0,0]) cylinder(r=curvature, h = depth, center = true);
        }
        // cut out idler's body
        translate([-10-curvature-idler_gap,-depth,-height]) cube([width,depth,2*height]);
      }

      // bearing supports
      for (t = [[-1*hole_offset, 0, 0],
                [hole_offset, vert_hole_offset*.5, 0],
                [hole_offset, vert_hole_offset*-.5, 0]]) {
        translate([0, 1, 0])
        rotate([90, 0, 0])
          translate(t) cylinder(r = bearing_support_rad, h = depth, center = true);

        // roller
        translate([0, 1.5+(roller_width+depth)/2, 0]) {
          rotate([90, 0, 0]) {
            translate(t) {
              %cylinder(r = roller_diameter/2,
                h = roller_width, center = true);
            }
          }
        }
      }
    }

    // cut out middle
    hull() {
      for (t = [[width/2-12, 0, 15], [-10+3/2, 0, 15],
                [width/2-12, 0, -22], [-10+3/2, 0, -16.5]]) {
        translate(t)
          rotate([90, 0, 0]) cylinder(r=3, h=depth+10, center = true);
      }
    }
    // cut out idler's features
    translate([-10-curvature-idler_gap,-depth,-height]) cube([idler_gap,depth,2*height]);

    // idler screws
    for (t = [
        [0,-2-4,-1*height/4+3/2],
        [0,-2-4,1*height/4-3/2],
      ]) {

      translate(t) rotate([0,-90,0]) {
        cylinder(r=3/2, h=width, $fn=10);
        cylinder(r=(6.01+1)/2, h=10+3/2+2.15, $fn=6);
      }
    }

    // filament/bracket screw
    translate([0, 0, height/2+3]) rotate([90,0,0])
        cylinder(r=3/2, h = depth+2, center = true, $fn=10);


    // clear middle
    translate([0, 16, 0]) cube([20, 20, height*2], center = true);

    // clear middle bottom
    translate([0, 18, -14])
      cube([20, extrusion_width, height], center = true);

    // clear extrusion curves
    for (x=[
      [
        [extrusion_width/2-4+spacing,12+10,0],
        [center_width/2+4,12+10,0],
        [extrusion_width/2-4+spacing,12-10,0],
        [center_width/2+4,12-10,0],
      ],
      [
        [-extrusion_width/2+4-spacing,12+10,height+curvature],
        [-center_width/2-4,12-10,height+curvature],
        [-extrusion_width/2+4-spacing,12-10,height+curvature],
        [-center_width/2-4,12+10,height+curvature],
      ],
      [
        [-extrusion_width/2+4-spacing,12+10,-height+curvature],
        [-center_width/2-4,12-10,-height+curvature],
        [-extrusion_width/2+4-spacing,12-10,-height+curvature],
        [-center_width/2-4,12+10,-height+curvature],
      ],
    ]) {
      hull() {
        for (y=x) {
          translate(y)
            cylinder(r=4, h = height*2, center = true);
        }
      }
    }

    // bearing holes
    for (t = [[-1*hole_offset, layer_height+3, 0 ],
              [hole_offset, layer_height+3, vert_hole_offset*.5],
              [hole_offset, layer_height+3, vert_hole_offset*-.5]]) {
      translate(t) rotate([90, 0, 0])
        cylinder(r = 3/2, h = depth, center = true, $fn = 10);
    }

    // bearing holes sink heads
    for (t = [[-1*hole_offset, -depth/2+1.49, 0],
              [hole_offset, -depth/2+1.49, vert_hole_offset*.5],
              [hole_offset, -depth/2+1.49, vert_hole_offset*-.5]]) {
      translate(t) rotate([90, 0, 0])
        cylinder(r = 3, h = 3, center = true, $fn = 10);
    }

    // mounting holes for carriage bracket
    // spacing is middle then 10 across and 5 down for each hole
    for (t = [[-10, 0, height/2-2],
              [10, 0, height/2-2]]) {
      translate(t) rotate([90,0,0]) {
        translate([0,0,8])
          cylinder(r=3.1/2, h = 10, center = true, $fn=10);

        // m3 nut trap
        cylinder(r=(6.01+1)/2, h = depth/2-5, $fn=6);
      }
    }
  }
}

// rotate to print
rotate([to_print ? 90 : 0, 0, 0]) {

  // the part
  vert_carriage();

  // extrusion
  %translate([0,19.5,-40]) extrusion4040(h=80);

  //testfit carriage bracket
  //include <carriage-bracket.scad>;
}

