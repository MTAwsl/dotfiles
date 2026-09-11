_: {
  flake.modules.features.usb = _: {
    boot.initrd.availableKernelModules = [
      "xhci_pci"
      "ehci_pci"
      "usbhid"
      "usb_storage"
    ];
  };
}
