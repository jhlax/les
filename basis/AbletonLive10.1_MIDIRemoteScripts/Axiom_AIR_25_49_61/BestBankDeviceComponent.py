# uncompyle6 version 3.4.1
# Python bytecode 2.7 (62211)
# Decompiled from: Python 2.7.16 (v2.7.16:413a49145e, Mar  2 2019, 14:32:10) 
# [GCC 4.2.1 Compatible Apple LLVM 6.0 (clang-600.0.57)]
# Embedded file name: /Users/versonator/Jenkins/live/output/mac_64_static/Release/python-bundle/MIDI Remote Scripts/Axiom_AIR_25_49_61/BestBankDeviceComponent.py
# Compiled at: 2019-04-09 19:23:44
from __future__ import absolute_import, print_function, unicode_literals
from _Framework.DeviceComponent import DeviceComponent
from _Generic.Devices import parameter_bank_names, parameter_banks, DEVICE_DICT, BANK_NAME_DICT, DEVICE_BOB_DICT
BOP_BANK_NAME = 'Best of Parameters'

class BestBankDeviceComponent(DeviceComponent):
    u""" Special Device component that uses the best of bank of a device as default """

    def __init__(self, *a, **k):
        super(BestBankDeviceComponent, self).__init__(*a, **k)
        new_banks = {}
        new_bank_names = {}
        self._device_banks = DEVICE_DICT
        self._device_bank_names = BANK_NAME_DICT
        self._device_best_banks = DEVICE_BOB_DICT
        for device_name in self._device_banks.keys():
            current_banks = self._device_banks[device_name]
            if len(current_banks) > 1:
                current_banks = self._device_best_banks[device_name] + current_banks
                new_bank_names[device_name] = (
                 BOP_BANK_NAME,) + self._device_bank_names[device_name]
            new_banks[device_name] = current_banks

        self._device_banks = new_banks
        self._device_bank_names = new_bank_names

    def set_parameter_controls(self, controls):
        if self._parameter_controls != None:
            for control in self._parameter_controls:
                if self._device != None:
                    control.release_parameter()

        self._parameter_controls = controls
        self.update()
        return

    def _number_of_parameter_banks(self):
        result = 0
        if self._device != None:
            if self._device.class_name in self._device_banks.keys():
                result = len(self._device_banks[self._device.class_name])
            else:
                result = DeviceComponent._number_of_parameter_banks(self)
        return result

    def _parameter_banks(self):
        return parameter_banks(self._device, self._device_banks)

    def _parameter_bank_names(self):
        return parameter_bank_names(self._device, self._device_bank_names)

    def _is_banking_enabled(self):
        return True