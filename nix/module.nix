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

    network.bridge = lib.mkOption {
      type = lib.types.str;
      default = "incusbr0";
      description = "Incus bridge name used for VM NIC attachment.";
    };

    storage.pool = lib.mkOption {
      type = lib.types.str;
      default = "default";
      description = "Incus storage pool used for root and state volumes.";
    };

    remoteUser = lib.mkOption {
      type = lib.types.str;
      default = "vancouver";
      description = "SSH user used by bcrail helpers for remote VM operations.";
    };

    stateDevice = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional block device path inside guest for bcrail state disk (auto-detected when null).";
    };

    ignitionFile = lib.mkOption {
      type = lib.types.path;
      default = ../etc/bcrail/ignition.json;
      description = "Ignition JSON template to deploy at /etc/bcrail/ignition.json.";
    };

    locomotiveEnvFile = lib.mkOption {
      type = lib.types.path;
      default = ../etc/bcrail/locomotive.env;
      description = "Environment file deployed at /etc/bcrail/locomotive.env.";
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
    environment.etc."bcrail/locomotive.env".source = cfg.locomotiveEnvFile;

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0755 root root -"
      "d ${cfg.stateDir}/contexts 0755 root root -"
    ];

    environment.variables = {
      BCRAIL_STATE_DIR = cfg.stateDir;
      BCRAIL_CONFIG_DIR = cfg.configDir;
      BCRAIL_NETWORK_BRIDGE = cfg.network.bridge;
      BCRAIL_STORAGE_POOL = cfg.storage.pool;
      BCRAIL_REMOTE_USER = cfg.remoteUser;
      BCRAIL_STATE_DEVICE = if cfg.stateDevice == null then "" else cfg.stateDevice;
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
          "BCRAIL_NETWORK_BRIDGE=${cfg.network.bridge}"
          "BCRAIL_STORAGE_POOL=${cfg.storage.pool}"
          "BCRAIL_REMOTE_USER=${cfg.remoteUser}"
          "BCRAIL_STATE_DEVICE=${if cfg.stateDevice == null then "" else cfg.stateDevice}"
        ];
      };
      path = [ cfg.package ];
      script = ''
        ${cfg.package}/bin/bcrail setup
      '';
    };
  };
}
