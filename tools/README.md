# Tools:

## print_businterfaces.py
Tools to display IP (component.xml) parameters:
- VLNV
- parameters availables with default value
- interfaces
- ports

### Dependencies
- ipyxact https://github.com/trabucayre/ipyxact fork
  - `git clone https://github.com/trabucayre/ipyxact.git`
  - `cd ipyxact`
  - `python3 setup.py install --user`
- python3 colored package
  - `sudo apt-get install python3-colored` or
  - `pip3 install colored --user`

### How to use
```bash
print_businterfaces.py /somewhere/fpga_ip/IPdirectory
```
IPdirectory is the root directory of an IP (where component.xml is stored).
