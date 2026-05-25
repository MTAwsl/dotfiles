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
      stateDirectory = "/run/argon-fan-hat";
      modeFile = "${stateDirectory}/mode";
      manualSpeedFile = "${stateDirectory}/manual-speed";
      sortedThresholds = sort (left: right: left.temperatureC < right.temperatureC) cfg.thresholds;

      thresholdCases = concatMapStringsSep "\n" (threshold: ''
        if [ "$temp_c" -ge ${toString threshold.temperatureC} ]; then
          target=${toString threshold.speedPercent}
        fi
      '') sortedThresholds;

      fanSpeedWriter = pkgs.writeShellApplication {
        name = "argon-fan-hat-write-speed";
        runtimeInputs = with pkgs; [
          coreutils
          i2c-tools
        ];
        text = ''
          set -euo pipefail

          readonly I2C_BUS="${cfg.i2cBus}"
          readonly I2C_ADDRESS="${cfg.i2cAddress}"
          readonly WRITE_METHOD="${cfg.writeMethod}"

          fail() {
            printf 'argon-fan-hat-write-speed: %s\n' "$1" >&2
            exit 1
          }

          if [ "$#" -ne 1 ]; then
            fail 'expected one speed argument from 0 to 100'
          fi

          speed="$1"

          case "$speed" in
            ""|*[!0-9]*)
              fail "invalid speed: $speed"
              ;;
          esac

          if [ "$speed" -gt 100 ]; then
            fail "speed out of range: $speed"
          fi

          case "$WRITE_METHOD" in
            auto)
              i2cset -y "$I2C_BUS" "$I2C_ADDRESS" "$speed" || i2cset -y "$I2C_BUS" "$I2C_ADDRESS" 0x80 "$speed"
              ;;
            register)
              i2cset -y "$I2C_BUS" "$I2C_ADDRESS" 0x80 "$speed"
              ;;
            raw)
              i2cset -y "$I2C_BUS" "$I2C_ADDRESS" "$speed"
              ;;
            *)
              fail "unsupported write method: $WRITE_METHOD"
              ;;
          esac
        '';
      };

      fanctl = pkgs.writeShellApplication {
        name = "fanctl";
        runtimeInputs = with pkgs; [ coreutils ];
        text = ''
          set -euo pipefail

          readonly STATE_DIR="${stateDirectory}"
          readonly MODE_FILE="${modeFile}"
          readonly MANUAL_SPEED_FILE="${manualSpeedFile}"
          readonly FAN_WRITER="${fanSpeedWriter}/bin/argon-fan-hat-write-speed"

          usage() {
            printf '%s\n' \
              'Usage: fanctl <command> [args]' \
              "" \
              'Commands:' \
              '  speed <0-100>  Set a manual fan speed percentage' \
              '  off            Turn the fan off and disable automatic control' \
              '  auto           Re-enable automatic temperature control' \
              '  toggle         Toggle between off and automatic control' \
              '  status         Show the current control mode'
          }

          ensure_state_dir() {
            mkdir -p "$STATE_DIR"
          }

          write_state_file() {
            local path="$1"
            local value="$2"

            printf '%s\n' "$value" > "$path"
            chmod 0664 "$path" || true
          }

          validate_speed() {
            speed="$1"

            case "$speed" in
              ""|*[!0-9]*)
                printf 'Invalid speed: %s\n' "$speed" >&2
                return 1
                ;;
            esac

            if [ "$speed" -gt 100 ]; then
              printf 'Speed must be between 0 and 100: %s\n' "$speed" >&2
              return 1
            fi
          }

          read_mode() {
            if [ -r "$MODE_FILE" ]; then
              mode="$(cat "$MODE_FILE")"
            else
              mode="auto"
            fi

            case "$mode" in
              auto|manual|off)
                printf '%s\n' "$mode"
                ;;
              *)
                printf 'auto\n'
                ;;
            esac
          }

          write_mode() {
            ensure_state_dir
            write_state_file "$MODE_FILE" "$1"
          }

          set_manual_speed() {
            speed="$1"
            validate_speed "$speed"
            ensure_state_dir
            write_state_file "$MANUAL_SPEED_FILE" "$speed"
            write_mode manual
            "$FAN_WRITER" "$speed"
            printf 'Fan set to %s%% in manual mode.\n' "$speed"
          }

          set_off() {
            ensure_state_dir
            write_state_file "$MANUAL_SPEED_FILE" 0
            write_mode off
            "$FAN_WRITER" 0
            printf 'Fan turned off.\n'
          }

          set_auto() {
            ensure_state_dir
            rm -f "$MANUAL_SPEED_FILE"
            write_mode auto
            printf 'Automatic fan control enabled.\n'
          }

          show_status() {
            mode="$(read_mode)"
            printf 'mode=%s\n' "$mode"

            if [ -r "$MANUAL_SPEED_FILE" ]; then
              printf 'manual_speed=%s\n' "$(cat "$MANUAL_SPEED_FILE")"
            fi
          }

          if [ "$#" -lt 1 ]; then
            usage >&2
            exit 1
          fi

          command="$1"
          shift

          case "$command" in
            speed)
              if [ "$#" -ne 1 ]; then
                usage >&2
                exit 1
              fi
              set_manual_speed "$1"
              ;;
            off)
              set_off
              ;;
            auto|on)
              set_auto
              ;;
            toggle)
              case "$(read_mode)" in
                off)
                  set_auto
                  ;;
                *)
                  set_off
                  ;;
              esac
              ;;
            status)
              show_status
              ;;
            -h|--help|help)
              usage
              ;;
            *)
              printf 'Unknown command: %s\n' "$command" >&2
              usage >&2
              exit 1
              ;;
          esac
        '';
      };

      buttonController = pkgs.writeShellApplication {
        name = "argon-fan-hat-button";
        runtimeInputs = with pkgs; [
          coreutils
          libgpiod
        ];
        text = ''
          set -euo pipefail

          readonly GPIO_CHIP="${cfg.button.gpioChip}"
          readonly GPIO_LINE="${toString cfg.button.gpioLine}"
          readonly DEBOUNCE_PERIOD="${cfg.button.debouncePeriod}"
          readonly FANCTL="${fanctl}/bin/fanctl"

          while true; do
            if gpiomon --quiet --num-events=1 --chip "$GPIO_CHIP" --bias=pull-down --debounce-period "$DEBOUNCE_PERIOD" --edges=rising "$GPIO_LINE"; then
              "$FANCTL" toggle
            else
              sleep 1
            fi
          done
        '';
      };

      fanController = pkgs.writeShellApplication {
        name = "argon-fan-hat-control";
        runtimeInputs = with pkgs; [
          bash
          coreutils
        ];
        text = ''
          set -euo pipefail

          readonly TEMP_FILE="/sys/class/thermal/thermal_zone0/temp"
          readonly POLL_INTERVAL="${toString cfg.pollIntervalSeconds}"
          readonly SLOWDOWN_DELAY="${toString cfg.slowdownDelaySeconds}"
          readonly MODE_FILE="${modeFile}"
          readonly MANUAL_SPEED_FILE="${manualSpeedFile}"
          readonly FAN_WRITER="${fanSpeedWriter}/bin/argon-fan-hat-write-speed"

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

            "$FAN_WRITER" "$speed"
          }

          read_mode() {
            local mode

            if [ -r "$MODE_FILE" ]; then
              mode="$(cat "$MODE_FILE")"
            else
              mode="auto"
            fi

            case "$mode" in
              auto|manual|off)
                printf '%s\n' "$mode"
                ;;
              *)
                printf 'auto\n'
                ;;
            esac
          }

          read_manual_speed() {
            local speed

            if [ -r "$MANUAL_SPEED_FILE" ]; then
              speed="$(cat "$MANUAL_SPEED_FILE")"
            else
              speed=0
            fi

            case "$speed" in
              ""|*[!0-9]*)
                printf '0\n'
                return
                ;;
            esac

            if [ "$speed" -gt 100 ]; then
              printf '0\n'
            else
              printf '%s\n' "$speed"
            fi
          }

          calculate_target_speed() {
            local temp_c="$1"
            local target=0

            ${thresholdCases}

            printf '%s\n' "$target"
          }

          apply_immediate_target() {
            local target_speed="$1"

            pending_speed=""
            pending_since=0

            if [ "$target_speed" -ne "$current_speed" ]; then
              set_fan_speed "$target_speed"
            fi
          }

          while true; do
            mode="$(read_mode)"
            now="$(date +%s)"

            case "$mode" in
              off)
                apply_immediate_target 0
                ;;
              manual)
                apply_immediate_target "$(read_manual_speed)"
                ;;
              auto)
                temp_c=$(( $(< "$TEMP_FILE") / 1000 ))
                target_speed="$(calculate_target_speed "$temp_c")"

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
                ;;
              *)
                apply_immediate_target 0
                ;;
            esac

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
          default = "raw";
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

        button = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = "Whether the Argon Fan HAT button toggles the fan between off and automatic control.";
          };

          gpioChip = mkOption {
            type = types.str;
            default = "gpiochip0";
            description = "GPIO chip containing the Argon Fan HAT button line.";
          };

          gpioLine = mkOption {
            type = types.ints.unsigned;
            default = 4;
            description = "BCM GPIO line used by the Argon Fan HAT button.";
          };

          debouncePeriod = mkOption {
            type = types.str;
            default = "100ms";
            description = "Debounce period passed to gpiomon for button press events.";
          };
        };
      };

      config = mkIf cfg.enable {
        hardware.i2c.enable = true;

        environment.systemPackages = [ fanctl ];

        systemd.tmpfiles.rules = [
          "d ${stateDirectory} 2775 root i2c - -"
        ];

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

        systemd.services.argon-fan-hat-button = mkIf cfg.button.enable {
          description = "Argon Fan HAT button fan toggle";
          wantedBy = [ "multi-user.target" ];
          after = [ "systemd-tmpfiles-setup.service" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${buttonController}/bin/argon-fan-hat-button";
            Restart = "always";
            RestartSec = "2s";
            Group = "i2c";
            UMask = "0002";
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
