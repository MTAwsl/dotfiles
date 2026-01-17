{ ... }:
{
  flake.modules.homeManager.yuri-zellij =
    { ... }:
    {
      programs = {
        zellij = {
          enable = true;
          settings = {
            on_force_close = "quit";
            default_layout = "compact";
            pane_frames = false;
            plugins = {
              compact-bar = {
                _props.location = "zellij:compact-bar";
                tooltip = "F1";
              };
            };

            default_mode = "locked";
            keybinds = {
              clear-defaults = true;

              normal = { };

              locked = {
                bind = {
                  "Ctrl g" = {
                    SwitchToMode = "Normal";
                  };
                };
              };

              resize = {
                bind = [
                  {
                    "r" = {
                      SwitchToMode = "Normal";
                    };
                  }
                  {
                    "h" = {
                      Resize = "Increase Left";
                    };
                    "Left" = {
                      Resize = "Increase Left";
                    };
                  }
                  {
                    "j" = {
                      Resize = "Increase Down";
                    };
                    "Down" = {
                      Resize = "Increase Down";
                    };
                  }
                  {
                    "k" = {
                      Resize = "Increase Up";
                    };
                    "Up" = {
                      Resize = "Increase Up";
                    };
                  }
                  {
                    "l" = {
                      Resize = "Increase Right";
                    };
                    "Right" = {
                      Resize = "Increase Right";
                    };
                  }
                  {
                    "H" = {
                      Resize = "Decrease Left";
                    };
                  }
                  {
                    "J" = {
                      Resize = "Decrease Down";
                    };
                  }
                  {
                    "K" = {
                      Resize = "Decrease Up";
                    };
                  }
                  {
                    "L" = {
                      Resize = "Decrease Right";
                    };
                  }
                  {
                    "=" = {
                      Resize = "Increase";
                    };
                    "+" = {
                      Resize = "Increase";
                    };
                  }
                  {
                    "-" = {
                      Resize = "Decrease";
                    };
                  }
                ];
              };

              pane = {
                bind = [
                  {
                    "p" = {
                      SwitchToMode = "Normal";
                    };
                  }
                  {
                    "h" = {
                      MoveFocus = "Left";
                    };
                    "Left" = {
                      MoveFocus = "Left";
                    };
                  }
                  {
                    "l" = {
                      MoveFocus = "Right";
                    };
                    "Right" = {
                      MoveFocus = "Right";
                    };
                  }
                  {
                    "j" = {
                      MoveFocus = "Down";
                    };
                    "Down" = {
                      MoveFocus = "Down";
                    };
                  }
                  {
                    "k" = {
                      MoveFocus = "Up";
                    };
                    "Up" = {
                      MoveFocus = "Up";
                    };
                  }
                  {
                    "Tab" = {
                      SwitchFocus = [ ];
                    };
                  }
                  {
                    "n" = {
                      NewPane = [ ];
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "d" = {
                      NewPane = "Down";
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "r" = {
                      NewPane = "Right";
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "s" = {
                      NewPane = "stacked";
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "x" = {
                      CloseFocus = [ ];
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "f" = {
                      ToggleFocusFullscreen = [ ];
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "z" = {
                      TogglePaneFrames = [ ];
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "w" = {
                      ToggleFloatingPanes = [ ];
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "e" = {
                      TogglePaneEmbedOrFloating = [ ];
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "c" = {
                      SwitchToMode = "RenamePane";
                      PaneNameInput = 0;
                    };
                  }
                  {
                    "i" = {
                      TogglePanePinned = [ ];
                      SwitchToMode = "Locked";
                    };
                  }
                ];
              };

              move = {
                bind = [
                  {
                    "m" = {
                      SwitchToMode = "Normal";
                    };
                  }
                  {
                    "n" = {
                      MovePane = [ ];
                    };
                    "Tab" = {
                      MovePane = [ ];
                    };
                  }
                  {
                    "p" = {
                      MovePaneBackwards = [ ];
                    };
                  }
                  {
                    "h" = {
                      MovePane = "Left";
                    };
                    "Left" = {
                      MovePane = "Left";
                    };
                  }
                  {
                    "j" = {
                      MovePane = "Down";
                    };
                    "Down" = {
                      MovePane = "Down";
                    };
                  }
                  {
                    "k" = {
                      MovePane = "Up";
                    };
                    "Up" = {
                      MovePane = "Up";
                    };
                  }
                  {
                    "l" = {
                      MovePane = "Right";
                    };
                    "Right" = {
                      MovePane = "Right";
                    };
                  }
                ];
              };

              tab = {
                bind = [
                  {
                    "t" = {
                      SwitchToMode = "Normal";
                    };
                  }
                  {
                    "r" = {
                      SwitchToMode = "RenameTab";
                      TabNameInput = 0;
                    };
                  }
                  {
                    "h" = {
                      GoToPreviousTab = [ ];
                    };
                    "Left" = {
                      GoToPreviousTab = [ ];
                    };
                    "Up" = {
                      GoToPreviousTab = [ ];
                    };
                    "k" = {
                      GoToPreviousTab = [ ];
                    };
                  }
                  {
                    "l" = {
                      GoToNextTab = [ ];
                    };
                    "Right" = {
                      GoToNextTab = [ ];
                    };
                    "Down" = {
                      GoToNextTab = [ ];
                    };
                    "j" = {
                      GoToNextTab = [ ];
                    };
                  }
                  {
                    "n" = {
                      NewTab = [ ];
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "x" = {
                      CloseTab = [ ];
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "s" = {
                      ToggleActiveSyncTab = [ ];
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "b" = {
                      BreakPane = [ ];
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "]" = {
                      BreakPaneRight = [ ];
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "[" = {
                      BreakPaneLeft = [ ];
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "1" = {
                      GoToTab = 1;
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "2" = {
                      GoToTab = 2;
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "3" = {
                      GoToTab = 3;
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "4" = {
                      GoToTab = 4;
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "5" = {
                      GoToTab = 5;
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "6" = {
                      GoToTab = 6;
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "7" = {
                      GoToTab = 7;
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "8" = {
                      GoToTab = 8;
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "9" = {
                      GoToTab = 9;
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "Tab" = {
                      ToggleTab = [ ];
                    };
                  }
                ];
              };

              scroll = {
                bind = [
                  {
                    "s" = {
                      SwitchToMode = "Normal";
                    };
                  }
                  {
                    "e" = {
                      EditScrollback = [ ];
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "f" = {
                      SwitchToMode = "EnterSearch";
                      SearchInput = 0;
                    };
                  }
                  {
                    "Ctrl c" = {
                      ScrollToBottom = [ ];
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "j" = {
                      ScrollDown = [ ];
                    };
                    "Down" = {
                      ScrollDown = [ ];
                    };
                  }
                  {
                    "k" = {
                      ScrollUp = [ ];
                    };
                    "Up" = {
                      ScrollUp = [ ];
                    };
                  }
                  {
                    "Ctrl f" = {
                      PageScrollDown = [ ];
                    };
                    "PageDown" = {
                      PageScrollDown = [ ];
                    };
                    "Right" = {
                      PageScrollDown = [ ];
                    };
                    "l" = {
                      PageScrollDown = [ ];
                    };
                  }
                  {
                    "Ctrl b" = {
                      PageScrollUp = [ ];
                    };
                    "PageUp" = {
                      PageScrollUp = [ ];
                    };
                    "Left" = {
                      PageScrollUp = [ ];
                    };
                    "h" = {
                      PageScrollUp = [ ];
                    };
                  }
                  {
                    "d" = {
                      HalfPageScrollDown = [ ];
                    };
                  }
                  {
                    "u" = {
                      HalfPageScrollUp = [ ];
                    };
                  }
                  {
                    "Alt left" = {
                      MoveFocusOrTab = "left";
                      SwitchToMode = "locked";
                    };
                  }
                  {
                    "Alt down" = {
                      MoveFocus = "down";
                      SwitchToMode = "locked";
                    };
                  }
                  {
                    "Alt up" = {
                      MoveFocus = "up";
                      SwitchToMode = "locked";
                    };
                  }
                  {
                    "Alt right" = {
                      MoveFocusOrTab = "right";
                      SwitchToMode = "locked";
                    };
                  }
                  {
                    "Alt h" = {
                      MoveFocusOrTab = "left";
                      SwitchToMode = "locked";
                    };
                  }
                  {
                    "Alt j" = {
                      MoveFocus = "down";
                      SwitchToMode = "locked";
                    };
                  }
                  {
                    "Alt k" = {
                      MoveFocus = "up";
                      SwitchToMode = "locked";
                    };
                  }
                  {
                    "Alt l" = {
                      MoveFocusOrTab = "right";
                      SwitchToMode = "locked";
                    };
                  }
                ];
              };

              search = {
                bind = [
                  {
                    "Ctrl c" = {
                      ScrollToBottom = [ ];
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "j" = {
                      ScrollDown = [ ];
                    };
                    "Down" = {
                      ScrollDown = [ ];
                    };
                  }
                  {
                    "k" = {
                      ScrollUp = [ ];
                    };
                    "Up" = {
                      ScrollUp = [ ];
                    };
                  }
                  {
                    "Ctrl f" = {
                      PageScrollDown = [ ];
                    };
                    "PageDown" = {
                      PageScrollDown = [ ];
                    };
                    "Right" = {
                      PageScrollDown = [ ];
                    };
                    "l" = {
                      PageScrollDown = [ ];
                    };
                  }
                  {
                    "Ctrl b" = {
                      PageScrollUp = [ ];
                    };
                    "PageUp" = {
                      PageScrollUp = [ ];
                    };
                    "Left" = {
                      PageScrollUp = [ ];
                    };
                    "h" = {
                      PageScrollUp = [ ];
                    };
                  }
                  {
                    "d" = {
                      HalfPageScrollDown = [ ];
                    };
                  }
                  {
                    "u" = {
                      HalfPageScrollUp = [ ];
                    };
                  }
                  {
                    "n" = {
                      Search = "down";
                    };
                  }
                  {
                    "p" = {
                      Search = "up";
                    };
                  }
                  {
                    "c" = {
                      SearchToggleOption = "CaseSensitivity";
                    };
                  }
                  {
                    "w" = {
                      SearchToggleOption = "Wrap";
                    };
                  }
                  {
                    "o" = {
                      SearchToggleOption = "WholeWord";
                    };
                  }
                ];
              };

              entersearch = {
                bind = [
                  {
                    "Ctrl c" = {
                      SwitchToMode = "Scroll";
                    };
                    "Esc" = {
                      SwitchToMode = "Scroll";
                    };
                  }
                  {
                    "Enter" = {
                      SwitchToMode = "Search";
                    };
                  }
                ];
              };

              renametab = {
                bind = [
                  {
                    "Ctrl c" = {
                      SwitchToMode = "Locked";
                    };
                    "Enter" = {
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "Esc" = {
                      UndoRenameTab = [ ];
                      SwitchToMode = "Tab";
                    };
                  }
                ];
              };

              renamepane = {
                bind = [
                  {
                    "Ctrl c" = {
                      SwitchToMode = "Locked";
                    };
                    "Enter" = {
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "Esc" = {
                      UndoRenamePane = [ ];
                      SwitchToMode = "Pane";
                    };
                  }
                ];
              };

              session = {
                bind = [
                  {
                    "o" = {
                      SwitchToMode = "Normal";
                    };
                  }
                  {
                    "d" = {
                      Detach = [ ];
                    };
                  }
                  {
                    "w" = {
                      LaunchOrFocusPlugin = "session-manager";
                      floating = true;
                      move_to_focused_tab = true;
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "c" = {
                      LaunchOrFocusPlugin = "configuration";
                      floating = true;
                      move_to_focused_tab = true;
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "p" = {
                      LaunchOrFocusPlugin = "plugin-manager";
                      floating = true;
                      move_to_focused_tab = true;
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "a" = {
                      LaunchOrFocusPlugin = "zellij:about";
                      floating = true;
                      move_to_focused_tab = true;
                      SwitchToMode = "Locked";
                    };
                  }
                  {
                    "s" = {
                      LaunchOrFocusPlugin = "zellij:share";
                      floating = true;
                      move_to_focused_tab = true;
                      SwitchToMode = "Locked";
                    };
                  }
                ];
              };

              # Shared Mode Mappings
              shared_except = [
                {
                  section = [
                    "locked"
                    "renametab"
                    "renamepane"
                  ];
                  bind = [
                    {
                      "Ctrl g" = {
                        SwitchToMode = "Locked";
                      };
                    }
                    {
                      "Ctrl q" = {
                        Quit = [ ];
                      };
                    }
                    {
                      "Enter" = {
                        SwitchToMode = "Locked";
                      };
                    }
                  ];
                }
                {
                  section = [
                    "renamepane"
                    "renametab"
                    "entersearch"
                    "locked"
                  ];
                  bind = {
                    "esc" = {
                      SwitchToMode = "locked";
                    };
                  };
                }
                {
                  section = [
                    "pane"
                    "locked"
                    "renametab"
                    "renamepane"
                    "entersearch"
                  ];
                  bind = {
                    "p" = {
                      SwitchToMode = "Pane";
                    };
                  };
                }
                {
                  section = [
                    "resize"
                    "locked"
                    "renametab"
                    "renamepane"
                    "entersearch"
                  ];
                  bind = {
                    "r" = {
                      SwitchToMode = "Resize";
                    };
                  };
                }
                {
                  section = [
                    "scroll"
                    "locked"
                    "renametab"
                    "renamepane"
                    "entersearch"
                  ];
                  bind = {
                    "s" = {
                      SwitchToMode = "Scroll";
                    };
                  };
                }
                {
                  section = [
                    "session"
                    "locked"
                    "renametab"
                    "renamepane"
                    "entersearch"
                  ];
                  bind = {
                    "o" = {
                      SwitchToMode = "Session";
                    };
                  };
                }
                {
                  section = [
                    "tab"
                    "locked"
                    "renametab"
                    "renamepane"
                    "entersearch"
                  ];
                  bind = {
                    "t" = {
                      SwitchToMode = "Tab";
                    };
                  };
                }
                {
                  section = [
                    "move"
                    "locked"
                    "renametab"
                    "renamepane"
                    "entersearch"
                  ];
                  bind = {
                    "m" = {
                      SwitchToMode = "Move";
                    };
                  };
                }
              ];

              shared_among = [
                {
                  section = [
                    "normal"
                    "locked"
                  ];
                  bind = [
                    {
                      "Alt n" = {
                        NewPane = [ ];
                      };
                    }
                    {
                      "Alt f" = {
                        ToggleFloatingPanes = [ ];
                      };
                    }
                    {
                      "Alt i" = {
                        MoveTab = "Left";
                      };
                    }
                    {
                      "Alt o" = {
                        MoveTab = "Right";
                      };
                    }
                    {
                      "Alt h" = {
                        MoveFocusOrTab = "Left";
                      };
                      "Alt Left" = {
                        MoveFocusOrTab = "Left";
                      };
                    }
                    {
                      "Alt l" = {
                        MoveFocusOrTab = "Right";
                      };
                      "Alt Right" = {
                        MoveFocusOrTab = "Right";
                      };
                    }
                    {
                      "Alt j" = {
                        MoveFocus = "Down";
                      };
                      "Alt Down" = {
                        MoveFocus = "Down";
                      };
                    }
                    {
                      "Alt k" = {
                        MoveFocus = "Up";
                      };
                      "Alt Up" = {
                        MoveFocus = "Up";
                      };
                    }
                    {
                      "Alt =" = {
                        Resize = "Increase";
                      };
                      "Alt +" = {
                        Resize = "Increase";
                      };
                    }
                    {
                      "Alt -" = {
                        Resize = "Decrease";
                      };
                    }
                    {
                      "Alt [" = {
                        PreviousSwapLayout = [ ];
                      };
                    }
                    {
                      "Alt ]" = {
                        NextSwapLayout = [ ];
                      };
                    }
                    {
                      "Alt p" = {
                        TogglePaneInGroup = [ ];
                      };
                    }
                    {
                      "Alt Shift p" = {
                        ToggleGroupMarking = [ ];
                      };
                    }
                  ];
                }
              ];
            };
          };
        };

        zsh.initContent = ''
          function current_dir() {
            local current_dir=$PWD
            if [[ $current_dir == $HOME ]]; then
              current_dir="~"
            else
              current_dir=/''${current_dir##*/}
            fi
            
            echo $current_dir
          }

          function change_tab_title() {
            local title=$1
            command nohup zellij action rename-tab $title >/dev/null 2>&1
          }

          function set_tab_to_working_dir() {
            local result=$?
            local title=$(current_dir)
            if [[ $result -gt 0 ]]; then
              title="$title [$result]" 
            fi

            change_tab_title $title
          }

          function set_tab_to_command_line() {
            local cmdline=$1
            local args=( ''${(Q)''${(z)cmdline}} )

            change_tab_title $args[1]
          }

          if [[ -n $ZELLIJ ]]; then
            add-zsh-hook precmd set_tab_to_working_dir
            add-zsh-hook preexec set_tab_to_command_line
          fi
        '';
      };
    };
}
