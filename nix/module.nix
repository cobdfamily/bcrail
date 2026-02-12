{ config, lib, pkgs, ... }:

let
  cfg = config.services.bcrail;
in
{
  options.services.bcrail = {
    enable = lib.mkEnableOption "bcrail tooling";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.bcrail;
      defaultText = lib.literalExpression "pkgs.bcrail";
      description = "The bcrail package to install.";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/bcrail";
      description = "State directory used by bcrail contexts.";
    };

    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/etc/bcrail";
      description = "Configuration directory used by bcrail.";
    };

    ignitionFile = lib.mkOption {
      type = lib.types.path;
      default = ../etc/bcrail/ignition.json;
      description = "Ignition JSON template to deploy at /etc/bcrail/ignition.json.";
    };

    setupOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Run `bcrail setup` on boot.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    environment.etc."bcrail/ignition.json".source = cfg.ignitionFile;

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0755 root root -"
      "d ${cfg.stateDir}/contexts 0755 root root -"
    ];

    environment.variables = {
      BCRAIL_STATE_DIR = cfg.stateDir;
      BCRAIL_CONFIG_DIR = cfg.configDir;
    };

    systemd.services.bcrail-setup = lib.mkIf cfg.setupOnBoot {
      description = "Initialize BCRail state";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        Environment = [
          "BCRAIL_STATE_DIR=${cfg.stateDir}"
          "BCRAIL_CONFIG_DIR=${cfg.configDir}"
        ];
      };
      path = [ cfg.package ];
      script = ''
        ${cfg.package}/bin/bcrail setup
      '';
    };
  };
}