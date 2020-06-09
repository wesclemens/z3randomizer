import os
import subprocess
import sys
import typing
import functools
import hashlib

from asar import init as asar_init, close as asar_close, patch as asar_patch, geterrors as asar_errors
from yaml import load, dump

JAP10HASH = '03a63945398191337e896e5771f77173'

try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader

import xml.etree.ElementTree as ET

def int16_as_bytes(value):
    value = value & 0xFFFF
    return [value & 0xFF, (value >> 8) & 0xFF]


def int32_as_bytes(value):
    value = value & 0xFFFFFFFF
    return [value & 0xFF, (value >> 8) & 0xFF, (value >> 16) & 0xFF, (value >> 24) & 0xFF]



def is_bundled():
    return getattr(sys, 'frozen', False)

def local_path(path):
    if local_path.cached_path:
        return os.path.join(local_path.cached_path, path)

    elif is_bundled():
        if hasattr(sys, "_MEIPASS"):
            # we are running in a PyInstaller bundle
            local_path.cached_path = sys._MEIPASS  # pylint: disable=protected-access,no-member
        else:
            # cx_Freeze
            local_path.cached_path = os.path.dirname(os.path.abspath(sys.argv[0]))
    else:
        # we are running in a normal Python environment
        import __main__
        local_path.cached_path = os.path.dirname(os.path.abspath(__main__.__file__))

    return os.path.join(local_path.cached_path, path)

local_path.cached_path = None



def make_new_base2current(old_rom_data, new_rom_data):
    from collections import OrderedDict
    import json
    # extend to 2 mb
    old_rom_data.extend(bytearray([0x00]) * (2097152 - len(old_rom_data)))

    out_data = OrderedDict()
    for idx, old in enumerate(old_rom_data):
        new = new_rom_data[idx]
        if old != new:
            out_data[idx] = [int(new)]
    for offset in reversed(list(out_data.keys())):
        if offset - 1 in out_data:
            out_data[offset-1].extend(out_data.pop(offset))
    with open('../base2current.json', 'wt') as outfile:
        json.dump([{key: value} for key, value in out_data.items()], outfile, separators=(",", ":"))

    basemd5 = hashlib.md5()
    basemd5.update(new_rom_data)
    return "New Rom Hash: " + basemd5.hexdigest()


if __name__ == '__main__':
    try:
        asar_init()
        print("Asar DLL initialized")
        
        print("Opening Base rom")
        with open('../alttp.sfc', 'rb') as stream:
            old_rom_data = bytearray(stream.read())
            
        if len(old_rom_data) % 0x400 == 0x200:
            old_rom_data = old_rom_data[0x200:]
            
        basemd5 = hashlib.md5()
        basemd5.update(old_rom_data)
        if JAP10HASH != basemd5.hexdigest():
            raise Exception("Base rom is not 'Zelda no Densetsu - Kamigami no Triforce (J) (V1.0)'")
            
        print("Patching Base Rom")
        result, new_rom_data = asar_patch('LTTP_RND_GeneralBugfixes.asm', old_rom_data)
        
        if result:
            with open('../working.sfc', 'wb') as stream:
                stream.write(new_rom_data)
            print("Success\n")
            print(make_new_base2current(old_rom_data, new_rom_data))        
        else:
            errors = asar_errors()
            print("\nErrors: " + str(len(errors)))
            for error in errors:
                print (error)
        
        asar_close()
    except:
        import traceback
        traceback.print_exc()
    
    input("Press enter to close")

