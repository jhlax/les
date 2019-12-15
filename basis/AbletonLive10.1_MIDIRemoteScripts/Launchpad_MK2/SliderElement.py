# uncompyle6 version 3.4.1
# Python bytecode 2.7 (62211)
# Decompiled from: Python 2.7.16 (v2.7.16:413a49145e, Mar  2 2019, 14:32:10) 
# [GCC 4.2.1 Compatible Apple LLVM 6.0 (clang-600.0.57)]
# Embedded file name: /Users/versonator/Jenkins/live/output/mac_64_static/Release/python-bundle/MIDI Remote Scripts/Launchpad_MK2/SliderElement.py
# Compiled at: 2019-04-09 19:23:44
from __future__ import absolute_import, print_function, unicode_literals
from _Framework.Dependency import depends
from _Framework.Skin import SkinColorMissingError
from _Framework.SliderElement import SliderElement as SliderElementBase
from . import consts

class SliderElement(SliderElementBase):

    @depends(skin=None)
    def __init__(self, msg_type, channel, identifier, skin=None, *a, **k):
        super(SliderElement, self).__init__(msg_type, channel, identifier, *a, **k)
        self._skin = skin
        self._index = 0
        self._type = 0
        self._color = 0

    def _get_index(self):
        return self._index

    def _set_index(self, index):
        self._index = index

    index = property(_get_index, _set_index)

    def _get_type(self):
        return self._type

    def _set_type(self, type):
        assert type in (consts.FADER_STANDARD_TYPE, consts.FADER_BIPOLAR_TYPE)
        self._type = type

    type = property(_get_type, _set_type)

    def _get_color(self):
        return self._color

    def _set_color(self, value):
        self._color = value

    color = property(_get_color, _set_color)

    def install_connections(self, install_translation, install_mapping, install_forwarding):
        super(SliderElement, self).install_connections(install_translation, install_mapping, install_forwarding)
        self._setup_fader()

    def _setup_fader(self):
        msg = consts.STANDARD_SYSEX_PREFIX + consts.FADER_SETUP_BYTE + (self.index,)
        param = self._parameter_to_map_to
        if param != None and param.is_enabled:
            p_range = param.max - param.min
            value = int(round((param.value - param.min) / p_range * 127))
            color_value = int(self._skin[self._color])
        else:
            value = 0
            color_value = 0
        msg += (self.type, color_value, value, 247)
        self._send_midi(msg)
        return