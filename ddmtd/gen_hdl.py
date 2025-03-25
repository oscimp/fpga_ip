#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys

from amaranth_boards.redpitaya_125_14 import RedPitaya14Platform
from amaranth.build import Resource, Pins, Attrs
import amaranth

from src.ddmtd import DDMTD

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'output_name', help='Output verilog file')
    parser.add_argument(
        '--conf_file', default='conf.json')
    return parser.parse_args()


def main():
    args = parse_args()
    conf = eval(open(args.conf_file, 'r').read())
    top = DDMTD(**conf)
    platform = RedPitaya14Platform()
    with open(f'{args.output_name}.v', 'w') as f:
        f.write(amaranth.back.verilog.convert(
            top, platform=platform, ports=top.ports()))

if __name__ == '__main__':
    main()
