{ lib, ... }:
let
  inherit (lib)
    concatMapStringsSep
    mkEnableOption
    mkIf
    mkOption
    sort
    types
    ;
in
{
  flake.modules.features.argon-fan-hat =
    {
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.hardware.argonFanHat;
      sortedThresholds = sort (left: right: left.temperatureC < right.temperatureC) cfg.thresholds;

      thresholdCases = concatMapStringsSep "\n" (threshold: ''
        if [ "$temp_c" -ge ${toString threshold.temperatureC} ]; then
          target=${toString threshold.speedPercent}
        fi
      '') sortedThresholds;

      fanController = pkgs.writeShellApplication {
        name = "argon-fan-hat-control";
        runtimeInputs = with pkgs; [
          bash
          coreutils
          i2c-tools
        ];
        text = ''
          set -euo pipefail

          readonly TEMP_FILE="/sys/class/thermal/thermal_zone0/temp"
          readonly I2C_BUS="${cfg.i2cBus}"
          readonly I2C_ADDRESS="${cfg.i2cAddress}"
          readonly POLL_INTERVAL="${toString cfg.pollIntervalSeconds}"
          readonly SLOWDOWN_DELAY="${toString cfg.slowdownDelaySeconds}"
          readonly WRITE_METHOD="${cfg.writeMethod}"

          current_speed=0
          pending_speed=""
          pending_since=0

          set_fan_speed() {
            local requested_speed="$1"
            local speed="$requested_speed"

            if [ "$speed" -gt 0 ] && [ "$speed" -lt 25 ]; then
              speed=25
            fi

            if [ "$current_speed" -eq 0 ] && [ "$speed" -gt 0 ] && [ "$speed" -lt 100 ]; then
              write_i2c_speed 100
              sleep 1
            fi

            write_i2c_speed "$speed"
            current_speed="$speed"
          }

          write_i2c_speed() {
            local speed="$1"

            case "$WRITE_METHOD" in
              auto)
                i2cset -y "$I2C_BUS" "$I2C_ADDRESS" 0x80 "$speed" || i2cset -y "$I2C_BUS" "$I2C_ADDRESS" "$speed"
                ;;
              register)
                i2cset -y "$I2C_BUS" "$I2C_ADDRESS" 0x80 "$speed"
                ;;
              raw)
                i2cset -y "$I2C_BUS" "$I2C_ADDRESS" "$speed"
                ;;
              *)
                printf 'Unsupported Argon Fan HAT write method: %s\n' "$WRITE_METHOD" >&2
                exit 1
                ;;
            esac
          }

          calculate_target_speed() {
            local temp_c="$1"
            local target=0

            ${thresholdCases}

            printf '%s\n' "$target"
          }

          while true; do
            temp_c=$(( $(< "$TEMP_FILE") / 1000 ))
            target_speed="$(calculate_target_speed "$temp_c")"
            now="$(date +%s)"

            if [ "$target_speed" -gt "$current_speed" ]; then
              pending_speed=""
              pending_since=0
              set_fan_speed "$target_speed"
            elif [ "$target_speed" -lt "$current_speed" ]; then
              if [ "$pending_speed" != "$target_speed" ]; then
                pending_speed="$target_speed"
                pending_since="$now"
              elif [ $(( now - pending_since )) -ge "$SLOWDOWN_DELAY" ]; then
                set_fan_speed "$target_speed"
                pending_speed=""
                pending_since=0
              fi
            else
              pending_speed=""
              pending_since=0
            fi

            sleep "$POLL_INTERVAL"
          done
        '';
      };
    in
    {
      options.hardware.argonFanHat = {
        enable = mkEnableOption "Argon Fan HAT temperature-based fan control";

        i2cBus = mkOption {
          type = types.str;
          default = "1";
          description = "I2C bus used by the Argon Fan HAT controller.";
        };

        i2cAddress = mkOption {
          type = types.str;
          default = "0x1a";
          description = "I2C address used by the Argon Fan HAT controller.";
        };

        writeMethod = mkOption {
          type = types.enum [
            "auto"
            "raw"
            "register"
          ];
          default = "auto";
          description = "How the service writes fan speed to the Argon Fan HAT MCU.";
        };

        pollIntervalSeconds = mkOption {
          type = types.ints.positive;
          default = 10;
          description = "How often the fan controller polls CPU temperature.";
        };

        slowdownDelaySeconds = mkOption {
          type = types.ints.positive;
          default = 30;
          description = "Delay before lowering fan speed to reduce oscillation.";
        };

        thresholds = mkOption {
          type = types.listOf (
            types.submodule {
              options = {
                temperatureC = mkOption {
                  type = types.ints.between 0 120;
                  description = "CPU temperature threshold in Celsius.";
                };

                speedPercent = mkOption {
                  type = types.ints.between 0 100;
                  description = "Fan speed percentage applied at or above the threshold.";
                };
              };
            }
          );
          default = [
            {
              temperatureC = 55;
              speedPercent = 30;
            }
            {
              temperatureC = 60;
              speedPercent = 55;
            }
            {
              temperatureC = 65;
              speedPercent = 100;
            }
          ];
          description = "Temperature to fan-speed mappings for the Argon Fan HAT.";
        };
      };

      config = mkIf cfg.enable {
        boot.kernelModules = [ "i2c-dev" ];

        systemd.services.argon-fan-hat = {
          description = "Argon Fan HAT controller";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${fanController}/bin/argon-fan-hat-control";
            Restart = "always";
            RestartSec = "5s";
            ProtectSystem = "strict";
            ProtectHome = true;
            PrivateTmp = true;
            NoNewPrivileges = true;
            ProtectKernelModules = true;
            ProtectControlGroups = true;
            LockPersonality = true;
          };
        };
      };
    };
}
