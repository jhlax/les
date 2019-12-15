# uncompyle6 version 3.4.1
# Python bytecode 2.7 (62211)
# Decompiled from: Python 2.7.16 (v2.7.16:413a49145e, Mar  2 2019, 14:32:10) 
# [GCC 4.2.1 Compatible Apple LLVM 6.0 (clang-600.0.57)]
# Embedded file name: /Users/versonator/Jenkins/live/output/mac_64_static/Release/python-bundle/MIDI Remote Scripts/SL_MkIII/channel_strip.py
# Compiled at: 2019-05-08 17:06:57
from __future__ import absolute_import, print_function, unicode_literals
import Live
from ableton.v2.base import clamp, listens, liveobj_valid
from ableton.v2.control_surface.components import ChannelStripComponent as ChannelStripComponentBase
from ableton.v2.control_surface.elements import DisplayDataSource, SysexRGBColor
from ableton.v2.control_surface.control import ButtonControl, ColorSysexControl
from .control import BinaryControl
from .messenger import Messenger
from .parameter_mapping_sensitivities import CONTINUOUS_MAPPING_SENSITIVITY
from .util import color_for_track, convert_parameter_value_to_midi_value, normalized_parameter_value

def hex_to_channels(color_in_hex):
    return (
     (color_in_hex & 16711680) >> 16,
     (color_in_hex & 65280) >> 8,
     color_in_hex & 255)


monitoring_states = Live.Track.Track.monitoring_states
MONITORING_STATES_TO_STR = {monitoring_states.IN: 'In', 
   monitoring_states.AUTO: 'Auto', 
   monitoring_states.OFF: 'Off'}

def has_monitoring_state(track):
    return liveobj_valid(track) and track.can_be_armed


class ChannelStripComponent(ChannelStripComponentBase, Messenger):
    empty_color = 'DefaultButton.Disabled'
    monitoring_state_button = ButtonControl()
    pan_encoder_color_field = ColorSysexControl()
    track_color_field = ColorSysexControl()
    volume_led = ColorSysexControl()
    track_selection_field = BinaryControl()

    def __init__(self, *a, **k):
        super(ChannelStripComponent, self).__init__(*a, **k)
        self._pan_value_display_data_source = DisplayDataSource()
        self.__on_selected_track_changed.subject = self.song.view

    @property
    def pan_value_display_data_source(self):
        return self._pan_value_display_data_source

    def set_track(self, track):
        super(ChannelStripComponent, self).set_track(track)
        self._update_pan_encoder_color_field()
        self._update_track_selection_field()
        self._update_listeners()

    def set_volume_control(self, control):
        super(ChannelStripComponent, self).set_volume_control(control)
        self.__on_volume_control_value_received.subject = control

    def set_pan_control(self, control):
        if control != None:
            control.mapping_sensitivity = CONTINUOUS_MAPPING_SENSITIVITY
        super(ChannelStripComponent, self).set_pan_control(control)
        return

    def set_send_controls(self, controls):
        for control in controls or []:
            if control != None:
                control.mapping_sensitivity = CONTINUOUS_MAPPING_SENSITIVITY

        super(ChannelStripComponent, self).set_send_controls(controls)
        return

    @monitoring_state_button.pressed
    def monitoring_state_button(self, _):
        if has_monitoring_state(self.track):
            self.track.current_monitoring_state = (self.track.current_monitoring_state + 1) % len(monitoring_states.values)
            self._message_monitoring_state()

    def _message_monitoring_state(self):
        track = self.track
        self.message(track.name, ('Monitor {}').format(MONITORING_STATES_TO_STR[track.current_monitoring_state]))

    def _update_monitoring_state_button(self):
        color = self.empty_color
        if liveobj_valid(self.track):
            if has_monitoring_state(self.track):
                color = ('Monitor.{}').format(MONITORING_STATES_TO_STR[self.track.current_monitoring_state])
            else:
                color = 'Monitor.Disabled'
        self.monitoring_state_button.color = color

    def _update_volume_led(self):
        track = self.track
        value = (0, 0, 0)
        if liveobj_valid(track):
            value = tuple([ clamp(int(round(channel * normalized_parameter_value(track.mixer_device.volume) / 2)), 0, 127) for channel in hex_to_channels(track.color)
                          ])
        self.volume_led.color = SysexRGBColor(value)

    def _message_volume_value(self):
        track = self.track
        if liveobj_valid(track):
            self.message(track.name, str(track.mixer_device.volume))

    def _update_pan_encoder_color_field(self):
        self.pan_encoder_color_field.color = 'Mixer.Pan' if liveobj_valid(self.track) else 'DefaultButton.Disabled'

    def _update_pan_value_display(self):
        track = self.track
        self.pan_value_display_data_source.set_display_string(str(track.mixer_device.panning) if liveobj_valid(track) else '')

    def _update_track_color_field(self):
        self.track_color_field.color = color_for_track(self.track)

    def _update_select_button(self):
        track = self.track
        color = 'DefaultButton.Disabled'
        if liveobj_valid(track):
            if track == self.song.view.selected_track:
                color = color_for_track(track)
            else:
                color = 'Mixer.TrackSelect'
        self.select_button.color = color

    def _update_track_selection_field(self):
        self.track_selection_field.is_on = self.track == self.song.view.selected_track

    @listens('current_monitoring_state')
    def __on_track_monitoring_state_changed(self):
        self._update_monitoring_state_button()

    @listens('value')
    def __on_volume_changed(self):
        self._update_volume_led()

    @listens('value')
    def __on_pan_changed(self):
        self._update_pan_value_display()

    @listens('color')
    def __on_track_color_changed(self):
        self._update_track_color_field()
        self._update_select_button()
        self._update_volume_led()

    @listens('selected_track')
    def __on_selected_track_changed(self):
        self._update_select_button()
        self._update_track_selection_field()

    @listens('value')
    def __on_volume_control_value_received(self, _):
        self._message_volume_value()

    def _update_listeners(self):
        track = self.track
        self.__on_track_monitoring_state_changed.subject = track
        self.__on_track_monitoring_state_changed()
        self.__on_volume_changed.subject = track.mixer_device.volume if liveobj_valid(track) else None
        self.__on_volume_changed()
        self.__on_pan_changed.subject = track.mixer_device.panning if liveobj_valid(track) else None
        self.__on_pan_changed()
        self.__on_track_color_changed.subject = track if liveobj_valid(track) else None
        self.__on_track_color_changed()
        return