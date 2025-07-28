{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.mignis;

  mignisConf = pkgs.writeText "mignis.conf" ''
    OPTIONS
    ${optionalString (cfg.options.default_rules) "default_rules yes"}
    ${optionalString (cfg.options.logging) "logging yes"}

    INTERFACES
    ${concatStringsSep "\n" (mapAttrsToList (name: value: "${name} ${value.interface} ${value.subnet} ${optionalString (value.ignore) "ignore"}") cfg.interfaces)}

    ALIASES
    ${concatStringsSep "\n" (mapAttrsToList (name: value: "${name} ${value}") cfg.aliases)}

    FIREWALL
    ${concatStringsSep "\n" cfg.firewall}

    POLICIES
    ${concatStringsSep "\n" cfg.policies}

    CUSTOM
    ${concatStringsSep "\n" cfg.custom}
  '';
in
{
  options.services.mignis = {
    enable = mkEnableOption "Mignis firewall";

    options = {
      default_rules = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Mignis default rules.";
      };
      logging = mkOption {
        type = types.bool;
        default = false;
        description = "Enable logging of dropped packets.";
      };
    };

    interfaces = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          interface = mkOption {
            type = types.str;
            description = "Name of the network interface (e.g., eth0).";
          };
          subnet = mkOption {
            type = types.str;
            description = "Subnet in CIDR notation (e.g., 192.168.1.0/24).";
          };
          ignore = mkOption {
            type = types.bool;
            default = false;
            description = "Ignore traffic on this interface.";
          };
        };
      });
      default = {};
      description = "Network interfaces for Mignis.";
    };

    aliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "IP address aliases.";
    };

    firewall = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Firewall rules in Mignis syntax.";
    };

    policies = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Default policies for unmatched packets.";
    };

    custom = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Custom raw iptables rules.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.mignis ];

    systemd.services.mignis-firewall = {
      description = "Mignis Firewall";
      wantedBy = [ "multi-user.target" ];
      before = [ "network.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        echo "Applying Mignis firewall rules..."

        ${pkgs.mignis}/bin/mignis -c ${mignisConf} -e --force
      '';
    };
  };
}
