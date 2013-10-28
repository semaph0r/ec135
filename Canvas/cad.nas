#
# CAD display implementation for EC 135
# @author Patrik Schmidt / semaph0r
#


var cad_canvas = {};
var cad_display = {};

# class definition for all warnings 
var warnings = {
  new: func() {
    var member = { parents : [warnings] };
    var canvasRef = {};
    var text = "";
    var order = -1;
    return member
  },
  show: func() {
    me.canvasRef.show();
  },
  hide: func() {
    me.canvasRef.hide();
  }
};

# init testing properties
setprop("/systems/cad/warnings/eng1-fail", 0);
setprop("/systems/cad/warnings/eng2-fail", 0);
setprop("/systems/electrical/inverter1", 0);
setprop("/systems/electrical/inverter2", 0);
setprop("/systems/cad/warnings/xmsn1-oil-press", 0);
setprop("/systems/cad/warnings/xmsn2-oil-press", 0);
setprop("/systems/cad/warnings/eng1-oil-press", 0);
setprop("/systems/cad/warnings/eng2-oil-press", 0);
setprop("/systems/cad/warnings/eng1-fuel-press", 0);
setprop("/systems/cad/warnings/eng2-fuel-press", 0);


# message lists which hold the current advisories displayed in the different areas
var messageListLeft = [];
var messageListCenter = [];
var messageListRight = [];

# variables for holding all the advisories and warnings
var pager = { parents : [warnings], text: "1 OF 2", order: 1};
var aux1FuelText = { parents : [warnings], text: "999", order: 0};
var aux1FuelIndicator = {};
var mainFuelText = { parents : [warnings], text: "999", order: 0};
var mainFuelIndicator = {};
var aux2FuelText = { parents : [warnings], text: "999", order: 0};
var aux2FuelIndicator = {};
var eng1Fail = { parents : [warnings], text: "ENG FAIL", order: 1 };
var eng2Fail = { parents : [warnings], text: "ENG FAIL", order: 1 };
var xmsn1OilPress = {};
var xmsn2OilPress = {};
var eng1FuelPress = {};
var eng2FuelPress = {};
var eng1OilPress = {};
var eng2OilPress = {};
var inverter1 = {};
var inverter2 = {};
var fuelWeight = {};
var leftBarTop = {};
var leftBarBottom = {};
var rightBarTop = {};
var rightBarBottom = {};

# fuel properties
var mainFuel = {};
var supplyFuel = {};
var initialMainFuel = {}; 
var initialSupplyFuel = {}; 
var normalizedMainFuel = 0;
var normalizedSupplyFuel = 0;
var leftFuelLevel = {};
var mainFuelLevel = {};
var rightFuelLevel = {};

# variables which indicates the current display state
var paged = {};
var flashOn = 1;

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
    };

    canvas.parsesvg(cad, "Aircraft/ec135/Canvas/cad.svg", {'font-mapper' : font_mapper});

    paged = 0;

    # hack to align canvas properly inside cad display area
    cad.updateCenter();
    cad.setRotation(180*D2R);
    cad.setTranslation(0, -65);

    # obtain handle for all svg elements
    pager = cad.getElementById("pager");
    aux1FuelText = cad.getElementById("aux1-fuel-text");
    aux2FuelText = cad.getElementById("aux2-fuel-text");
    mainFuelText = cad.getElementById("main-fuel-text");
    eng1Fail.canvasRef = cad.getElementById("eng1-fail");
    eng2Fail = cad.getElementById("eng2-fail");
    xmsn1OilPress = cad.getElementById("xmsn1-oil-press");
    xmsn2OilPress = cad.getElementById("xmsn2-oil-press");
    eng1FuelPress = cad.getElementById("eng1-fuel-press");
    eng2FuelPress = cad.getElementById("eng2-fuel-press");
    eng1OilPress = cad.getElementById("eng1-oil-press");
    eng2OilPress = cad.getElementById("eng2-oil-press");
    inverter1 = cad.getElementById("inverter1");
    inverter2 = cad.getElementById("inverter2");
    leftFuelLevel = cad.getElementById("leftFuelLevel");
    mainFuelLevel = cad.getElementById("mainFuelLevel");
    rightFuelLevel = cad.getElementById("rightFuelLevel");
    leftBarTop = cad.getElementById("leftBarTop");
    leftBarBottom = cad.getElementById("leftBarBottom");
    rightBarTop = cad.getElementById("rightBarTop");
    rightBarBottom = cad.getElementById("rightBarBottom");

    inverter1.hide();
    inverter2.hide();

    #TODO: add all warnings/advisories, especially for center area

    initialMainFuel = convertGalToKg(getprop("/consumables/fuel/tank[0]/level-gal_us"));
    initialSupplyFuel = convertGalToKg(getprop("/consumables/fuel/tank[1]/level-gal_us"));

    # define clip area for fuel level indicator
    leftFuelLevel.set("clip", "rect(121, 95, 166, 175)");

    print("CAD initialized");

    return member;
  },
  update: func()
  {
    print("called canvas update");

    if(getprop("systems/cad/warnings/eng1-fail")){
      append(messageListLeft, eng1Fail);
      eng1Fail.show();
    }else {
      eng1Fail.hide();
    }

    if(getprop("systems/cad/warnings/eng2-fail")){
      append(messageListRight, eng2Fail);
      eng2Fail.show();
    }else {
      eng2Fail.hide();
    }

    if(getprop("systems/cad/warnings/xmsn1-oil-press")){
      append(messageListLeft, xmsn1OilPress);
      xmsn1OilPress.show();
    }else {
      xmsn1OilPress.hide();
    }

    if(getprop("systems/cad/warnings/xmsn2-oil-press")){
      append(messageListRight, xmsn2OilPress);
      xmsn2OilPress.show();
    }else {
      xmsn2OilPress.hide();
    }

    if(getprop("systems/cad/warnings/eng1-oil-press")){
      append(messageListLeft, eng1-oil-press);
    }

    if(getprop("systems/cad/warnings/eng2-oil-press")){
      append(messageListRight, eng2-oil-press);
    }

    if(getprop("systems/electrical/inverter1")){
      append(messageListLeft, inverter1);
      inverter1.show();
    } else {
      inverter1.hide();
    }

    if(getprop("systems/electrical/inverter2")){
      append(messageListRight, inverter2);
      inverter2.show();
    } else {
      inverter2.hide();
    }

    # directly converted lbs to kg
    mainFuel = getprop("/consumables/fuel/tank[0]/level-gal_us");
    mainFuel = convertGalToKg(mainFuel);

    mainFuelText.setText(sprintf("%3.0f", mainFuel));

    supplyFuel = getprop("/consumables/fuel/tank[1]/level-gal_us");
    supplyFuel = convertGalToKg(supplyFuel)/2;
    
    aux1FuelText.setText(sprintf("%3.0f", supplyFuel));
    aux2FuelText.setText(sprintf("%3.0f", supplyFuel));

    normalizedMainFuel = mainFuel/initialMainFuel;
    normalizedSupplyFuel = supplyFuel/initialSupplyFuel;

    # sort messages to appear in their relative order
    #sort(messageListLeft, sortMessages);
    #sort(messageListCenter, sortMessages);
    #sort(messageListRight, sortMessages);

    # render all messages to columns
    #displayMessageList(messageListLeft, messageListRight);

    toggleSignalBar(flashOn);
    

    settimer(func me.update(), 0.50);
  }

};

# initialize cad canvas after fdm is ready
setlistener("sim/signals/fdm-initialized", func(){
  cad_display = canvas.new({
  "name": "cad",
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

# converts the fuel weight from us gallon to kilogramm
var convertGalToKg = func(gal_us) {
  var value = gal_us*3.78; 
  return value; # returns the fuel weight in kg
}

# toggles the state of the flashing signal bar
var toggleSignalBar = func(flag) {
  if(flag) {
    leftBarTop.show();
    leftBarBottom.show();
    rightBarTop.show();
    rightBarBottom.show();
    flashOn = 0;
  }
  else {
    leftBarTop.hide();
    leftBarBottom.hide();
    rightBarTop.hide();
    rightBarBottom.hide();
    flashOn = 1;
  }
}

# sort func to ensure proper ordering of the warnings (should be stable)
var sortMessages = func(message1, message2) {
  if(message1.order < message2.order)
    return -1;
  elsif(message1.order > message2.order)
    return 1;
  else
    return 0;
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