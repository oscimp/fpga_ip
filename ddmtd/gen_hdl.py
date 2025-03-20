#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys

from amaranth_boards.redpitaya_125_14 import RedPitaya14Platform

from src.ddmtd import DDMTD

if __name__ == "__main__":
    gateware = RedPitaya14Platform().build(
        DDMTD(),
        do_program=False,
        do_build=False,
        build_dir='./hdl')
    gateware.execute_local('./hdl', run_script=False)
