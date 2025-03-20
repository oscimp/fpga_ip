#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys

from amaranth_boards.redpitaya_125_14 import RedPitaya14Platform
import amaranth

from src.ddmtd import DDMTD

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'output_file', help='Output verilog file')
    return parser.parse_args()


def main():
    args = parse_args()
    top = DDMTD()
    platform = RedPitaya14Platform()
    with open(args.output_file, 'w') as f:
        f.write(amaranth.back.verilog.convert(
            top, platform=platform, ports=top.ports()))

if __name__ == '__main__':
    main()
