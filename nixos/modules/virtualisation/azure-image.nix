{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.virtualisation.azureImage;
in
{
  imports = [ ./azure-common.nix ];

  options = {
    virtualisation.azureImage.diskSize = mkOption {
      type = with types; either (enum [ "auto" ]) int;
      default = "auto";
      example = 2048;
      description = lib.mdDoc ''
        Size of disk image. Unit is MB.
      '';
    };
  };
  config = {
    system.build.azureImage = import ../../lib/make-disk-image.nix {
      name = "azure-image";
      postVM = ''
        ${pkgs.vmTools.qemu}/bin/qemu-img convert -f raw -o subformat=fixed,force_size -O vpc $diskImage $out/disk.vhd
        rm $diskImage
      '';
      configFile = ./azure-config-user.nix;
      format = "raw";
      inherit (cfg) diskSize;
      inherit config lib pkgs;
    };

  };
}
