{ config, lib, pkgs, ... }:
let
  cfg = config.services.terraform-cloud-agent;
in
{
  options.services.terraform-cloud-agent = {
    enable = lib.mkEnableOption "terraform-cloud-agent";

    name = lib.mkOption {
      type = lib.types.str;
    };

    log-level = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "trace" "debug" "info" "warn" "error" ]);
      default = null;
    };

    data-dir = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };

    cache-dir = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };

    address = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
    };

    tokenPath = lib.mkOption {
      type = lib.types.path;
      default = "/etc/terraform-cloud-agent-token";
    };

    accept = lib.mkOption {
      type = lib.types.commas;
      default = "plan,apply,policy,assessment";
    };
  };

  config.systemd.services.terraform-cloud-agent = lib.mkIf cfg.enable {
    description = "Agent that executes plans from Terraform Cloud";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    script = ''
      export TFC_AGENT_TOKEN=$(cat ${cfg.tokenPath})
      export TFC_AGENT_DATA_DIR=''${STATE_DIRECTORY:-${cfg.data-dir}}
      export TFC_AGENT_CACHE_DIR=''${CACHE_DIRECTORY:-${cfg.cache-dir}}

      ${pkgs.terraform-cloud-agent}/bin/tfc-agent ${pkgs.toGNUCommandLineShell { mkOptionName = k: "-${k}"; } {
        inherit (cfg) name log-level address accept;
        auto-update = "disabled";
      }}
    '';

    serviceConfig = {
      StateDirectory = lib.mkIf (cfg.dataDir  == null) "terraform-cloud-agents/${cfg.name}";
      CacheDirectory = lib.mkIf (cfg.cacheDir == null) "terraform-cloud-agents/${cfg.name}";
    };
  };
}
