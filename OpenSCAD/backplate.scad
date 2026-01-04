// --- PARAMETERS ---
// NOTE: All units are in mm
TILE_HEIGHT = 120;          // Interior height of each square tile
TILE_WIDTH = 100;           // Interior width of each square tile

backplate_thickness = 15;   // Thickness of backplate
wall_thickness = 15;        // Thickness of frame walls
wall_depth = 100;

div_peg_radius = 3;             // Radius of the divider pegs holes/pegs
div_height = 30;
div_peg_offset_x = (wall_thickness - 2 * div_peg_radius);           // Distance of divider pegs from the (left, right) edges
div_peg_distance = 10;          // Distance between divider peg pairs on tile
div_peg_offset_y = div_height/2 - div_peg_distance;          // Distance of divider pegs from the (top, bottom) edges


wall_peg_radius = 3;             // Radius of the wall pegs
wall_peg_offset_x = (wall_thickness - 2 * wall_peg_radius);           // Distance of wall pegs from the (left, right) edges
wall_peg_offset_y = 12;          // Distance of wall pegs from the (top, bottom) edges
wall_peg_distance = 55;          // Distance between wall peg pairs on tile

joint_width = 15;           // Width of the interlocking dovetail
joint_depth = 10;           // Depth of the interlocking joint
tolerance = 0.2;            // Tolerance for printing

/* [Piece Selector] */
// Options: "center", "top_left", "top_mid", "top_right", "mid_left", "mid_right", "bot_left", "bot_mid", "bot_right"
// Order of options below is IMPORTANT
// Note: This generates all the modular pieces for the mug shelf. There should be no need to modify the tile options matrix as all parts with exception of corners are designed to be infinitely tile-able to fit the desired dimension requirements.
TILE_OPTIONS = ["top_left", "top_mid", "top_right", 
                "mid_left", "center", "mid_right", 
                "bot_left", "bot_mid", "bot_right"];
tile_type = "bot_right";
tile_index = search([tile_type], TILE_OPTIONS);

module dovetail_male(is_socket = false) {
    t_adj = is_socket ? tolerance : 0;
    linear_extrude(backplate_thickness + (is_socket ? 2 : 0))
    polygon([
            [0, -t_adj], 
            [joint_depth + t_adj, -joint_width/4 - t_adj], 
            [joint_depth + t_adj, joint_width*1.25 + t_adj], 
            [0, joint_width + t_adj]]);
}

module tile_generator() {
    // Adjust tile dimensions depending on option to keep interior space consistent
    // Increase height for top and bottom rows, NOTE: top row should be the largest as it contains both a top and bottom wall
    tile_height = TILE_HEIGHT + (tile_index[0] < 3 ? 2 : 1) * wall_thickness;
    // Increase width for leftmost and rightmost columns
    tile_width = TILE_WIDTH + (tile_index[0] % 3 == 2 ? 2 : 1) * wall_thickness;
    
    difference () {
        union(){
            cube([tile_width, tile_height, backplate_thickness]);
            // Add Male Joints (Left and Bottom for logic)
            // Left joint (mid, right)
            if (tile_index[0] % 3 > 0) {
                 translate([0, tile_height/2 + joint_width/2, 0]) rotate([0,0,180]) dovetail_male();
            }
            
            // Bottom joint (top, mid)
            if (tile_index[0] < 6) {    
                 // Bottom
                 translate([tile_width/2 - joint_width/2, 0, 0]) rotate([0,0,-90]) dovetail_male();
            }
        }
        
        // Subtract Female Joints (Right and Top for logic)
        // Right joint (left, mid)
        if (tile_index[0] % 3 < 2) {
                 translate([tile_width + tolerance, tile_height/2 + joint_width/2, -1]) rotate([0,0,180]) dovetail_male(true);
        }
        
        // Troubleshooting hole distances
        // Divider bottom
        //translate([0, wall_thickness, 0]) cube([wall_thickness, div_height, backplate_thickness + 2]);
        // Divider top
        //translate([0, tile_height - div_height - (tile_index[0] < 3 ? 1 : 0) * wall_thickness, 0]) cube([wall_thickness, div_height, backplate_thickness + 2]);
        // Wall bottom
        //cube([tile_width, wall_thickness, backplate_thickness + 2]);
        // Wall top
        //translate([0, tile_height - (tile_index[0] < 3 ? 1 : 0) * wall_thickness, 0]) cube([tile_width, wall_thickness, backplate_thickness + 2]);
        // Wall left
        //cube([wall_thickness, tile_height, backplate_thickness + 2]);
        // Interior
        //translate([wall_thickness, wall_thickness, 0]) cube([TILE_WIDTH, TILE_HEIGHT, backplate_thickness + 2]);
        
        // Top joint (mid, bottom)
        if (tile_index[0] > 2) {
                 translate([tile_width/2 - joint_width/2, tile_height + tolerance, -1]) rotate([0,0,-90]) dovetail_male(true);
        }
        
        // Subtract Pegholes
        // Frame Top (top) we swap the offset x and y values here
        if (tile_index[0] < 3) {
            // (tile_index[0] % 3) -> [0,1,2] shift the whole thing down by -1, then we can apply adjustment for additional wall thickness while keeping pegs centered
            translate([tile_width/2 - wall_peg_distance/2 - (((tile_index[0] % 3) - 1) * wall_thickness)/2, tile_height - wall_peg_offset_x + wall_peg_radius, -1]) cylinder(r=wall_peg_radius, h=backplate_thickness+2, $fn=32);
            translate([tile_width/2 + wall_peg_distance/2 - (((tile_index[0] % 3) - 1) * wall_thickness)/2, tile_height - wall_peg_offset_x + wall_peg_radius, -1]) cylinder(r=wall_peg_radius, h=backplate_thickness+2, $fn=32);
        }
        // Frame Left (left)
        if (tile_index[0] % 3 == 0) {
            translate([wall_peg_offset_x - wall_peg_radius, tile_height/2 + wall_peg_distance/2 - wall_peg_radius, -1]) cylinder(r=div_peg_radius, h=backplate_thickness+2, $fn=32);
            translate([wall_peg_offset_x - wall_peg_radius, tile_height/2 - wall_peg_distance/2 + wall_peg_radius, -1]) cylinder(r=div_peg_radius, h=backplate_thickness+2, $fn=32);
        }
        // Frame Right (right)
        if (tile_index[0] % 3 == 2) {
            translate([tile_width - wall_peg_offset_x + wall_peg_radius, tile_height/2 + wall_peg_distance/2 - wall_peg_radius, -1]) cylinder(r=div_peg_radius, h=backplate_thickness+2, $fn=32);
            translate([tile_width - wall_peg_offset_x + wall_peg_radius, tile_height/2 - wall_peg_distance/2 + wall_peg_radius, -1]) cylinder(r=div_peg_radius, h=backplate_thickness+2, $fn=32);
        }
        // Frame Bottom (all tiles) we swap the offset x and y values here
        translate([tile_width/2 - wall_peg_distance/2 - (((tile_index[0] % 3) - 1) * wall_thickness)/2, wall_peg_offset_x - wall_peg_radius, -1]) cylinder(r=wall_peg_radius, h=backplate_thickness+2, $fn=32);
        translate([tile_width/2 + wall_peg_distance/2 - (((tile_index[0] % 3) - 1) * wall_thickness)/2, wall_peg_offset_x - wall_peg_radius, -1]) cylinder(r=wall_peg_radius, h=backplate_thickness+2, $fn=32);
        // Dividers (mid, right)
        if (tile_index[0] % 3 > 0) {
            // (floor(tile_index[0] / 3)) -> [0,1,2] shift the whole thing down by -1, then we can apply adjustment for additional wall thickness while keeping pegs centered
            // Top pair
            translate([div_peg_offset_x - div_peg_radius, tile_height - div_peg_offset_y - div_peg_radius - (tile_index[0] < 3 ? 2 : 0) * wall_thickness/2, -1]) cylinder(r=div_peg_radius, h=backplate_thickness+2, $fn=32);
            translate([div_peg_offset_x - div_peg_radius, tile_height - div_peg_offset_y - div_peg_distance - div_peg_radius - (tile_index[0] < 3 ? 2 : 0) * wall_thickness/2, -1]) cylinder(r=div_peg_radius, h=backplate_thickness+2, $fn=32);
            
            // Bottom pair
            translate([div_peg_offset_x - div_peg_radius, div_peg_offset_y + div_peg_radius + 
            wall_thickness, -1]) cylinder(r=div_peg_radius, h=backplate_thickness+2, $fn=32);
            translate([div_peg_offset_x - div_peg_radius, div_peg_offset_y + div_peg_distance + div_peg_radius + wall_thickness, -1]) cylinder(r=div_peg_radius, h=backplate_thickness+2, $fn=32);
        }
    }
}

tile_generator();
