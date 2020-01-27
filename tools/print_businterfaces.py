#!/usr/bin/python3
import sys

from ipyxact.ipyxact import Component
# need package color
import color

def get_modelParameters(parameters):
    print(color.blue("\nParameters:"))
    print(color.blue("-----------"))
    for parameter in parameters.parameter:
        print("name: "+ color.red('{}'.format(parameter.name)))
        if parameter.displayName == "":
            print('  name          : '+color.green('{}'.format(parameter.name)))
        else:
            print('  display name  : '+color.green('{}'.format(parameter.displayName)))
        print('  default value : ' + color.green('{}'.format(parameter.value)))

def get_businterfaces(busInterfaces, quiet=True):
    ifs = []
    print()
    print(color.blue("Interfaces:"))
    print(color.blue("-----------"))
    for busInterface in busInterfaces.busInterface:
        print('name: ' + color.red(busInterface.name))
        print('  type      : ' + color.green(busInterface.busType.name))
        print('  direction : ', end='')
        if busInterface.slave is not None:
            print(color.green("in"))
        elif busInterface.master is not None:
            print(color.green("out"))
        else:
            print(color.green("unknown"))
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
    print(color.blue('component:'))
    print(color.blue('----------'))
    print('name        : ' + color.green('{}'.format(component.name)))
    print('VLNV        : ' + color.green('{}:{}:{}:{}'.format(component.vendor,
                                        component.library,
                                        component.name,
                                        component.version)))
    print('description : ' + color.green('{}'.format(component.description)))

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
    print(color.blue("Ports:"))
    print(color.blue("------"))
    for port in (port for port in component.model.ports.port if port.name in port_alone):
        print("name: " + color.red(port.name))
        print("  direction : " + color.green(port.wire.direction))
        if port.wire.wireTypeDefs is not None:
            for wtd in port.wire.wireTypeDefs.wireTypeDef:
                print("  type      : " + color.green(wtd.typeName))
    print()

    f.close()
