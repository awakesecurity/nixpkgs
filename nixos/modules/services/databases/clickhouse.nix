{ config, lib, pkgs, ... }:
let
  cfg = config.services.clickhouse;
in
with lib;
{

  ###### interface

  options = {

    services.clickhouse = {

      enable = mkEnableOption (lib.mdDoc "ClickHouse database server");

      package = mkOption {
        type = types.package;
        default = pkgs.clickhouse;
        defaultText = lib.literalExpression "pkgs.clickhouse";
        description = lib.mdDoc ''
          ClickHouse package to use.
        '';
      };

      usersXml = mkOption {
        type = types.path;
        default = "${cfg.package}/etc/clickhouse-server/users.xml";
        description = lib.mdDoc ''
          ClickHouse server users.xml override for
          declaring user access permissions and privileges
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    users.users.clickhouse = {
      name = "clickhouse";
      uid = config.ids.uids.clickhouse;
      group = "clickhouse";
      description = "ClickHouse server user";
    };

    users.groups.clickhouse.gid = config.ids.gids.clickhouse;

    systemd.services.clickhouse = {
      description = "ClickHouse server";

      wantedBy = [ "multi-user.target" ];

      after = [ "network.target" ];

      serviceConfig = {
        User = "clickhouse";
        Group = "clickhouse";
        ConfigurationDirectory = "clickhouse-server";
        AmbientCapabilities = "CAP_SYS_NICE";
        StateDirectory = "clickhouse";
        LogsDirectory = "clickhouse";
        ExecStart = "${cfg.package}/bin/clickhouse-server --config-file=/etc/clickhouse-server/config.xml";
      };
    };

    environment.etc = {
      "clickhouse-server/config.xml" = {
        source = "${cfg.package}/etc/clickhouse-server/config.xml";
      };

      "clickhouse-server/users.xml" = {
        source = cfg.usersXml;
      };
    };

    environment.systemPackages = [ cfg.package ];

    # startup requires a `/etc/localtime` which only if exists if `time.timeZone != null`
    time.timeZone = mkDefault "UTC";

  };

}
