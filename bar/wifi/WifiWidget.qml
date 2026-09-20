import QtQuick
import Quickshell.Networking

Text {
    property var wifiDevice: {
        for (const device of Networking.devices.values) {
            if (device.type === DeviceType.Wifi)
                return device;
        }

        return null;
    }

    property var connectedNetwork: {
        if (!wifiDevice)
            return null;

        for (const network of wifiDevice.networks.values) {
            if (network.connected)
                return network;
        }

        return null;
    }

    function wifiIcon(strength) {
        if (strength >= 0.75)
            return "󰤨"; // strong
        if (strength >= 0.50)
            return "󰤥"; // medium
        if (strength >= 0.25)
            return "󰤢"; // weak

        return "󰤟";     // very weak
    }
    
    text: {
        if (!Networking.wifiEnabled)
            return "󰤭 Wi-Fi Off";

        if (!wifiDevice)
            return "󰤭 No Wi-Fi";

        if (!connectedNetwork)
            return "󰤯 Disconnected";

        return wifiIcon(connectedNetwork.signalStrength) + " " + connectedNetwork.name;
    }

    color: "white"
    font.family: "DejaVu Sans Mono"
    font.weight: Font.Medium
}
