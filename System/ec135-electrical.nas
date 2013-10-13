##
# Procedural model of a Cessna 172S electrical system.  Includes a
# preliminary battery charge/discharge model and realistic ammeter
# gauge modeling.
#

##
# Initialize the electrical system
#

init_electrical = func {
    battery = BatteryClass.new();
    alternator = AlternatorClass.new();

    # set initial switch positions
    setprop("/systems/electric/master-bat", 0)

    # Request that the update function be called next frame
    settimer(update_electrical, 0);
    print("Electrical system initialized");
}


##
# Battery model class.
#

BatteryClass = {};

# TODO: provide correct values

BatteryClass.new = func {
    var obj = { parents : [BatteryClass],
                ideal_volts : 24.0,
                ideal_amps : 30.0,
                amp_hours : 12.75,
                charge_percent : 1.0,
                charge_amps : 7.0 };
    return obj;
}
