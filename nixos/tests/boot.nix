{
  system ? builtins.currentSystem,
  config ? { },
  pkgs ? import ../.. { inherit system config; },
}:

with import ../lib/testing-python.nix { inherit system pkgs; };

let
  lib = pkgs.lib;
  qemu-common = import ../lib/qemu-common.nix { inherit lib pkgs; };

  mkStartCommand =
    {
      memory ? 2048,
      cdrom ? null,
      usb ? null,
      pxe ? null,
      uboot ? false,
      uefi ? false,
      extraFlags ? [ ],
    }:
    let
      qemu = qemu-common.qemuBinary pkgs.qemu_test;

      flags =
        [
          "-m"
          (toString memory)
          "-netdev"
          ("user,id=net0" + (lib.optionalString (pxe != null) ",tftp=${pxe},bootfile=netboot.ipxe"))
          "-device"
          (
            "virtio-net-pci,netdev=net0"
            + (lib.optionalString (pxe != null && uefi) ",romfile=${pkgs.ipxe}/ipxe.efirom")
          )
        ]
        ++ lib.optionals (cdrom != null) [
          "-cdrom"
          cdrom
        ]
        ++ lib.optionals (usb != null) [
          "-device"
          "usb-ehci"
          "-drive"
          "id=usbdisk,file=${usb},if=none,readonly"
          "-device"
          "usb-storage,drive=usbdisk"
        ]
        ++ lib.optionals (pxe != null) [
          "-boot"
          "order=n"
        ]
        ++ lib.optionals uefi [
          "-drive"
          "if=pflash,format=raw,unit=0,readonly=on,file=${pkgs.OVMF.firmware}"
          "-drive"
          "if=pflash,format=raw,unit=1,readonly=on,file=${pkgs.OVMF.variables}"
        ]
        ++ extraFlags;

      flagsStr = lib.concatStringsSep " " flags;
    in
    "${qemu} ${flagsStr}";

  isoConfig =
    (import ../lib/eval-config.nix {
      inherit system;
      modules = [
        ../modules/installer/cd-dvd/installation-cd-minimal.nix
        ../modules/testing/test-instrumentation.nix
      ];
    }).config;

  iso = isoConfig.system.build.isoImage;

  customGrubRootSearchFile = "/EFI/custom-nixos-installer-image";

  customIsoConfig =
    (import ../lib/eval-config.nix {
      inherit system;
      modules = [
        ../modules/installer/cd-dvd/installation-cd-minimal.nix
        {
          isoImage.grubRootSearchFile = customGrubRootSearchFile;
          isoImage.showConfiguration = false;
        }
      ];
    }).config;

  customEfiDir =
    (lib.findFirst (entry: entry.target == "/EFI") null customIsoConfig.isoImage.contents).source;

  grubRootSearchFileAccepted =
    grubRootSearchFile:
    (builtins.tryEval (
      (import ../lib/eval-config.nix {
        inherit system;
        modules = [
          ../modules/installer/cd-dvd/installation-cd-minimal.nix
          { isoImage.grubRootSearchFile = grubRootSearchFile; }
        ];
      }).config.isoImage.grubRootSearchFile
    )).success;

  sd =
    (import ../lib/eval-config.nix {
      inherit system;
      modules = [
        ../modules/installer/sd-card/sd-image-x86_64.nix
        ../modules/testing/test-instrumentation.nix
        { sdImage.compressImage = false; }
      ];
    }).config.system.build.sdImage;

  makeBootTest =
    name: config:
    let
      startCommand = mkStartCommand config;
    in
    makeTest {
      name = "boot-" + name;
      nodes = { };
      testScript = ''
        machine = create_machine("${startCommand}")
        machine.start()
        machine.wait_for_unit("multi-user.target")
        machine.succeed("nix store verify --no-trust -r --option experimental-features nix-command /run/current-system")

        with subtest("Check whether the channel got installed correctly"):
            machine.succeed("nix-instantiate --dry-run '<nixpkgs>' -A hello")
            machine.succeed("nix-env --dry-run -iA nixos.procps")

        machine.shutdown()
      '';
    };

  makeNetbootTest =
    name: extraConfig:
    let
      config =
        (import ../lib/eval-config.nix {
          inherit system;
          modules = [
            ../modules/installer/netboot/netboot.nix
            ../modules/testing/test-instrumentation.nix
            {
              boot.kernelParams = [
                "serial"
                "live.nixos.passwordHash=$6$jnwR50SkbLYEq/Vp$wmggwioAkfmwuYqd5hIfatZWS/bO6hewzNIwIrWcgdh7k/fhUzZT29Vil3ioMo94sdji/nipbzwEpxecLZw0d0" # "password"
              ];
            }
            {
              key = "serial";
            }
          ];
        }).config;
      ipxeBootDir = pkgs.symlinkJoin {
        name = "ipxeBootDir";
        paths = [
          config.system.build.netbootRamdisk
          config.system.build.kernel
          config.system.build.netbootIpxeScript
        ];
      };
      startCommand = mkStartCommand (
        {
          pxe = ipxeBootDir;
        }
        // extraConfig
      );
    in
    makeTest {
      name = "boot-netboot-" + name;
      nodes = { };
      testScript = ''
        machine = create_machine("${startCommand}")
        machine.start()
        machine.wait_for_unit("multi-user.target")
        machine.succeed("grep 'serial' /proc/cmdline")
        machine.succeed("grep 'live.nixos.passwordHash' /proc/cmdline")
        machine.succeed("grep '$6$jnwR50SkbLYEq/Vp$wmggwioAkfmwuYqd5hIfatZWS/bO6hewzNIwIrWcgdh7k/fhUzZT29Vil3ioMo94sdji/nipbzwEpxecLZw0d0' /etc/shadow")
        machine.shutdown()
      '';
    };
in
{
  isoGrubRootSearchFile = pkgs.runCommand "iso-grub-root-search-file" { } ''
    test ${lib.escapeShellArg isoConfig.isoImage.grubRootSearchFile} = /EFI/nixos-installer-image
    test ${lib.boolToString (grubRootSearchFileAccepted "/not-efi/marker")} = false
    test ${lib.boolToString (grubRootSearchFileAccepted "/EFI/BOOT")} = false
    test ${lib.boolToString (grubRootSearchFileAccepted "/EFI/BOOT/grub-theme/marker")} = false
    test -e ${customEfiDir}/custom-nixos-installer-image
    grep -F 'search --set=root --file ${customGrubRootSearchFile}' ${customEfiDir}/BOOT/grub.cfg
    touch $out
  '';

  uefiCdrom = makeBootTest "uefi-cdrom" {
    uefi = true;
    cdrom = "${iso}/iso/${iso.isoName}";
  };

  uefiUsb = makeBootTest "uefi-usb" {
    uefi = true;
    usb = "${iso}/iso/${iso.isoName}";
  };

  uefiNetboot = makeNetbootTest "uefi" {
    uefi = true;
  };
}
// lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
  biosCdrom = makeBootTest "bios-cdrom" {
    cdrom = "${iso}/iso/${iso.isoName}";
  };

  biosUsb = makeBootTest "bios-usb" {
    usb = "${iso}/iso/${iso.isoName}";
  };

  biosNetboot = makeNetbootTest "bios" { };

  ubootExtlinux =
    let
      sdImage = "${sd}/sd-image/${sd.imageName}";
      mutableImage = "/tmp/linked-image.qcow2";

      startCommand = mkStartCommand {
        extraFlags = [
          "-bios"
          "${pkgs.ubootQemuX86}/u-boot.rom"
          "-machine"
          "type=pc,accel=tcg"
          "-drive"
          "file=${mutableImage},if=virtio"
        ];
      };
    in
    makeTest {
      name = "boot-uboot-extlinux";
      nodes = { };
      testScript = ''
        import os

        # Create a mutable linked image backed by the read-only SD image
        if os.system("qemu-img create -f qcow2 -F raw -b ${sdImage} ${mutableImage}") != 0:
            raise RuntimeError("Could not create mutable linked image")

        machine = create_machine("${startCommand}")
        machine.start()
        machine.wait_for_unit("multi-user.target")
        machine.succeed("nix store verify -r --no-trust --option experimental-features nix-command /run/current-system")
        machine.shutdown()
      '';

      # kernel can't find rootfs after boot - investigate?
      meta.broken = true;
    };
}
