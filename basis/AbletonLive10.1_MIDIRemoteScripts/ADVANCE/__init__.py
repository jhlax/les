# uncompyle6 version 3.4.1
# Python bytecode 2.7 (62211)
# Decompiled from: Python 2.7.16 (v2.7.16:413a49145e, Mar  2 2019, 14:32:10) 
# [GCC 4.2.1 Compatible Apple LLVM 6.0 (clang-600.0.57)]
# Embedded file name: /Users/versonator/Jenkins/live/output/mac_64_static/Release/python-bundle/MIDI Remote Scripts/ADVANCE/__init__.py
# Compiled at: 2019-04-09 19:23:44
from __future__ import absolute_import, print_function, unicode_literals
import _Framework.Capabilities as caps
from .Advance import Advance

def get_capabilities():
    return {caps.CONTROLLER_ID_KEY: caps.controller_id(vendor_id=2536, product_ids=[
                              46, 47, 48], model_name=[
                              'ADVANCE25', 'ADVANCE49', 'ADVANCE61']), 
       caps.PORTS_KEY: [
                      caps.inport(props=[caps.NOTES_CC, caps.SCRIPT, caps.REMOTE]),
                      caps.outport(props=[caps.NOTES_CC, caps.SCRIPT])]}


def create_instance(c_instance):
    return Advance(c_instance)