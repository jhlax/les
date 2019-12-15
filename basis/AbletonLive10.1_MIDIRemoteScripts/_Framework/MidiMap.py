# uncompyle6 version 3.4.1
# Python bytecode 2.7 (62211)
# Decompiled from: Python 2.7.16 (v2.7.16:413a49145e, Mar  2 2019, 14:32:10) 
# [GCC 4.2.1 Compatible Apple LLVM 6.0 (clang-600.0.57)]
# Embedded file name: /Users/versonator/Jenkins/live/output/mac_64_static/Release/python-bundle/MIDI Remote Scripts/_Framework/MidiMap.py
# Compiled at: 2019-04-09 19:23:45
from __future__ import absolute_import, print_function, unicode_literals
import Live
from .ButtonMatrixElement import ButtonMatrixElement
from .ButtonElement import ButtonElement
from .EncoderElement import EncoderElement
from .SliderElement import SliderElement

def make_button(name, channel, number, midi_message_type):
    is_momentary = True
    return ButtonElement(not is_momentary, midi_message_type, channel, number, name=name)


def make_slider(name, channel, number, midi_message_type):
    return SliderElement(midi_message_type, channel, number, name=name)


def make_encoder(name, channel, number, midi_message_type):
    return EncoderElement(midi_message_type, channel, number, Live.MidiMap.MapMode.absolute, name=name)


class MidiMap(dict):

    def add_button(self, name, channel, number, midi_message_type):
        assert name not in self.keys()
        self[name] = make_button(name, channel, number, midi_message_type)

    def add_matrix(self, name, element_factory, channel, numbers, midi_message_type):
        assert name not in self.keys()

        def one_dimensional_name(base_name, x, _y):
            return '%s[%d]' % (base_name, x)

        def two_dimensional_name(base_name, x, y):
            return '%s[%d,%d]' % (base_name, x, y)

        name_factory = two_dimensional_name if len(numbers) > 1 else one_dimensional_name
        elements = [ [ element_factory(name_factory(name, column, row), channel, identifier, midi_message_type) for column, identifier in enumerate(identifiers) ] for row, identifiers in enumerate(numbers)
                   ]
        self[name] = ButtonMatrixElement(rows=elements)