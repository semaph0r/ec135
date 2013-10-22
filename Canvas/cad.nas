#
# CAD display implementation for EC 135
# @author Patrik Schmidt 
#


var cad_canvas = {};
var cad_display = {};

var warnings = {
  new: func() {
    var member = { parents : [warnings] };
    var message = "";
    return member
  }
};

# init testing properties

setprop("/system/cad/warnings/eng1-fail", 0);
setprop("/system/cad/warnings/eng2-fail", 1);


# message lists which hold the current advisories displayed in the different areas
var messageListLeft = [];
var messageListCenter = [];
var messageListRight = [];

# variables for holding all the advisories and warnings
var pager = {};
var aux1FuelText = {};
var aux1FuelIndicator = {};
var mainFuelText = {};
var mainFuelIndicator = {};
var aux2FuelText = {};
var aux2FuelIndicator = {};
var eng1Fail = {};
var eng2Fail = {};
var xmsn1OilPress = {};
var xmsn2OilPress = {};
var eng1FuelPress = {};
var eng2FuelPress = {};
var eng1OilPress = {};
var eng2OilPress = {};
var inverter1 = {};
var inverter2 = {};
var fuelWeight = {};

# variables which indicates the current display state
var paged = {};

# Display class which manages all svg elements
var canvas_cad = {
  new: func (canvas_group)
  {
    var member = { parents : [canvas_cad] };
    var cad = canvas_group;
    var font_mapper = func(family, weight)
    {
      if( family == "Liberation Sans" and weight == "normal" )
        return "LiberationFonts/LiberationSans-Regular.ttf";
      #TODO: provide appropriate fonts
    };

    canvas.parsesvg(cad, "Aircraft/ec135/Canvas/cad.svg", {'font-mapper' : font_mapper});

    paged = 0;

    pager = cad.getElementById("pager");
    aux1FuelText = cad.getElementById("aux1-fuel-text");
    aux2FuelText = cad.getElementById("aux2-fuel-text");
    mainFuelText = cad.getElementById("main-fuel-text");
    eng1Fail = cad.getElementById("eng1-fail");
    eng2Fail = cad.getElementById("eng2-fail");
    xmsn1OilPress = cad.getElementById("xmsn1-oil-press");
    xmsn2OilPress = cad.getElementById("xmsn2-oil-press");
    eng1FuelPress = cad.getElementById("eng1-fuel-press");
    eng2FuelPress = cad.getElementById("eng2-fuel-press");
    eng1OilPress = cad.getElementById("eng1-oil-press");
    eng2OilPress = cad.getElementById("eng2-oil-press");
    inverter1 = cad.getElementById("inverter1");
    inverter2 = cad.getElementById("inverter2");

    #TODO: add all warnings/advisories, especially for center area

    pager.setText("Page 1 of 2");

    print("CAD initialized");

    return member;
  },
  update: func()
  {
    print("called canvas update");

    if(getprop("system/cad/warnings/eng1-fail" == 1)){
      append(messageListLeft, eng1Fail);
      eng1Fail.show();
      print("engine 1 failure");
    } 

    inverter1.show();
    inverter2.show();

    if(getprop("system/cad/warnings/eng2-fail"))
      append(messageListRight, eng2Fail);

    if(getprop("system/cad/warnings/xmsn1-oil-press"))
      append(messageListLeft, xmsn1OilPress);

    if(getprop("system/cad/warnings/xmsn2-oil-press"))
      append(messageListRight, xmsn2OilPress);

    if(getprop("system/cad/warnings/eng1-oil-press"))
      append(messageListLeft, eng1-oil-press);

    if(getprop("system/cad/warnings/eng2-oil-press"))
      append(messageListRight, eng2-oil-press);

    if(getprop("system/cad/warnings/inverter1"))
      append(messageListLeft, inverter1);

    if(getprop("system/cad/warnings/inverter2"))
      append(messageListRight, inverter2);

    # directly converted lbs to kg
    #aux1FuelText.setText(getprop("/consumables/fuel/tank[0]/level-lbs")/2.2046);
    #aux2FuelText.setText(getprop("/consumables/fuel/tank[2]/level-lbs")/2.2046);
    #MainFuelText.setText(getprop("/consumables/fuel/tank[1]/level-lbs")/2.2046);

    #displayMessageList(messageListLeft, messageListRight);

    settimer(func me.update(), 5.00);
  }

};


# initialize cad canvas after fdm is ready
setlistener("sim/signals/fdm-initialized", func(){
  cad_display = canvas.new({
  "name": "CAD",
  "size": [512, 512],
  "view": [512, 512],
  "mipmapping": 1
  });
  cad_display.addPlacement({"node": "cad"});
  var group = cad_display.createGroup();
  cad_canvas = canvas_cad.new(group);
  cad_canvas.update();
});

# --- helper functions ---

# calculates the total fuel weight of all three fuel tanks
var calcTotalFuelWeight = func() {
  var weight = getprop("/consumables/fuel/tank[0]/level-lbs") #aux1
             + getprop("/consumables/fuel/tank[2]/level-lbs") #aux2
             + getprop("/consumables/fuel/tank[1]/level-lbs");#main 
  wieght/2.2046;
  return weight;
}

# toggles the state of the flashing signal bar
var toggleSignalBar = func(barLeft, barRight) {
  if(barLeft.hidden())
    barLeft.show();
  else
    barLeft.hide();

  if(barRight.hidden())
    barRight.show();
  else
    barRight.hide();
}

# iterates all message lists and displays all entries in their designated area
var displayMessageList = func(list...) {
  
  # translation from the origin in the upper left corner
  var gTranslationX = 55;
  var gTranslationY = 93;
  foreach(elem; list){
  if(elem == "messageListLeft" and size(elem) != nil) {
    var messageListLeft = list[0];
    var translationX = gTranslationX;
    var translationY = gTranslationY;

    if(messageListLeft.size() < 6){
      paged = 1;
      #TODO: implement paging (building range list, ...)
    }
    foreach(elem; messageListLeft) {
      elem.setTranslation(translationX, translationY);
      elem.show();
      translationY += 20;
    }

  }elsif (elem == "messageListCenter" and size(elem) != nil) {
      var messageListCenter = list[1];
      var translationX = gTranslationX + 113;
      var translationY = gTranslationY;

      if(messageListLeft.size() < 6){
      paged = 1;
      #TODO: implement paging (building range list, ...)
    }
    foreach(elem; messageListLeft) {
      elem.setTranslation(translationX, translationY);
      elem.show();
      translationY += 20;
    }

  }else if (elem == "messageListRight" and size(elem) != nil){
    var messageListRight = list[2];
    var translationX = gTranslationX + 226;
    var translationY = gTranslationY;

    if(messageListLeft.size() < 6){
      paged = 1;
      #TODO: implement paging (building range list, ...)
    }
    foreach(elem; messageListLeft) {
      elem.setTranslation(translationX, translationY);
      elem.show();
      translationY += 20;
    }
  }
  }
}

# TODO: implement sort func for warnings/advisories