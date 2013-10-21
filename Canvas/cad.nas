var cad_canvas = canvas.new({
  "name": "cad-instrument",   # The name is optional but allow for easier identification
  "size": [512, 512],   # Size of the underlying texture (should be a power of 2, required)
  "view": [339, 263],  # Virtual resolution (Defines the coordinate system of the canvas
                        # which will be stretched the size of the texture, required)
  "mipmapping": 0       # Enable mipmapping (optional)
});

canvas.parsesvg(cad, "Aircraft/EC-135/Canvas/cad.svg", {'font-mapper': font_mapper});

# Place it on all objects called cad (maybe use the texture identifier later)
cad_canvas.addPlacement({"node": "cad"});


# creating groups to keep the canvas organized
var group = cad_canvas.createGroup();
var group_top = cad_canvas.createGroup();
var group_bottom = cad_canvas.createGroup();

var group_topleft = cad_canvas.createGroup();
var group_topmid = cad_canvas.createGroup();
var group_topright = cad_canvas.createGroup();

var group_bottomleft = cad_canvas.createGroup();
var group_bottomright = cad_canvas.createGroup();

# create all textfield for the CAD instrument
# Engine Oil Pressure
var text = group.createChild("text", "eng-oil-pressure")
                .setTranslation(40, 20)      # The origin is in the top left corner
                .setAlignment("left-center") # All values from osgText are supported (see $FG_ROOT/Docs/README.osgtext)
                .setFont("LiberationFonts/LiberationSans-Regular.ttf") # Search for appropriate font. Fonts are loaded either from $AIRCRAFT_DIR/Fonts or $FG_DATA/Fonts
                .setFontSize(14, 1.2)        # Set fontsize and optionally character aspect ratio
                .setColor(1,1,0)             # yellow
                .setText("ENG OIL P");
# ...
text.hide();
# ...
text.setText("Hello!").show();
