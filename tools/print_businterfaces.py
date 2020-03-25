#!/usr/bin/python3
import sys

from ipyxact.ipyxact import Component
# need package colored
import colored
from colored import stylize

def printRed(key, value):
    print(key + stylize(value, colored.fg("red")))
def printGreen(key, value):
    print(key + stylize(value, colored.fg("green")))
def printBlue(key, value):
    print(key + stylize(value, colored.fg("steel_blue_1a")))

def get_modelParameters(parameters):
    print(stylize("\nParameters:", colored.fg("blue")))
    print(stylize("-----------", colored.fg("blue")))
    for parameter in parameters.parameter:
        if parameter.name in ["C_S00_AXI_DATA_WIDTH", "C_S00_AXI_ADDR_WIDTH",
                         "C_M00_AXIS_TDATA_WIDTH", "Component_Name" ]:
            continue
        printRed("name: ", "{}".format(parameter.name))
        if parameter.displayName == "":
            printGreen('  name          : ', '{}'.format(parameter.name))
        else:
            printGreen('  display name  : ', '{}'.format(parameter.displayName))
        printGreen('  default value : ', '{}'.format(parameter.value))

def get_businterfaces(busInterfaces, quiet=True):
    ifs = []
    print()
    printBlue("", "Interfaces:")
    printBlue("", "-----------")
    for busInterface in busInterfaces.busInterface:
        printRed('name: ', busInterface.name)
        printGreen('  type      : ', busInterface.busType.name)
        print('  direction : ', end='')
        if busInterface.slave is not None:
            printGreen("", "in")
        elif busInterface.master is not None:
            printGreen("out")
        else:
            printGreen("unknown")
        if (quiet == False):
            _vendor  = busInterface.busType.vendor
            _library = busInterface.busType.library
            _name    = busInterface.busType.name
            _version = busInterface.busType.version
            print('  busType         : {}/{}/{}/{}'.format(_vendor,
                                                     _library,
                                                     _name,
                                                     _version))
            print('  abstractionType : {}/{}/{}/{}'.format(_vendor,
                                                     _library,
                                                     _name,
                                                     _version))
        if busInterface.portMaps and quiet == False:
            for portMap in busInterface.portMaps.portMap:
                if portMap.logicalPort.vector:
                    log_range = '[{}:{}]'.format(portMap.logicalPort.vector.left,
                                                 portMap.logicalPort.vector.right)
                else:
                    log_range = ''
                if portMap.physicalPort.vector:
                    phy_range = '[{}:{}]'.format(portMap.physicalPort.vector.left,
                                                 portMap.physicalPort.vector.right)
                else:
                    phy_range = ''

                print("  {}{}  => {}{}".format(portMap.logicalPort.name,
                                            log_range,
                                            portMap.physicalPort.name,
                                            phy_range))
    return ifs
    
if __name__ == "__main__":
    f = open(sys.argv[1]+"/component.xml")

    component = Component()
    component.load(f)
    printBlue("", 'component:')
    printBlue("", '----------')
    printGreen('name        : ', '{}'.format(component.name))
    printGreen('VLNV        : ', '{}:{}:{}:{}'.format(component.vendor,
                                                      component.library,
                                                      component.name,
                                                      component.version))
    printGreen('description : ', '{}'.format(component.description))

    if component.parameters is not None:
        get_modelParameters(component.parameters)

    list_port = []
    if component.model.ports is not None:
        list_port = [i.name for i in component.model.ports.port]

    list_if = []
    if component.busInterfaces is not None:
        list_if = [ii.physicalPort.name for i in component.busInterfaces.busInterface for ii in i.portMaps.portMap]
        get_businterfaces(component.busInterfaces)
    else:
        print("No bus interfaces found in file")

    port_alone = list(set(list_port) - set(list_if))

    print()
    printBlue("", "Ports:")
    printBlue("", "------")
    for port in (port for port in component.model.ports.port if port.name in port_alone):
        printRed("name: ", port.name)
        printGreen("  direction : ", port.wire.direction)
        if port.wire.wireTypeDefs is not None:
            for wtd in port.wire.wireTypeDefs.wireTypeDef:
                printGreen("  type      : ", wtd.typeName)
    print()

    f.close()
