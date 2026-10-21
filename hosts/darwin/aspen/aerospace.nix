{
  services.aerospace = {
    enable = true;

    settings = {
      config-version = 2;

      # Layout
      gaps = {
        outer.left = 8;
        outer.bottom = 8;
        outer.top = 8;
        outer.right = 8;
        inner.horizontal = 8;
        inner.vertical = 8;
      };

      default-root-container-orientation = "horizontal";

      # Keep named workspaces available even when empty.
      persistent-workspaces = [
        "wrk"
        "web"
        "pro"
        "cht"
        "mus"
        "ref"
      ];

      # Display assignments
      #
      # Portable:
      #   wrk, web, pro — summoned to the focused display
      #
      # Fixed:
      #   cht, mus — MacBook
      #
      # Preferred:
      #   ref — Sidecar, falling back to Dell or MacBook
      workspace-to-monitor-force-assignment = {
        cht = "built-in";
        mus = "built-in";

        ref = [
          "Sidecar Display"
          "DELL S2725QC"
          "built-in"
        ];
      };

      # Main mode
      mode.main.binding = {
        # Focus
        cmd-ctrl-alt-shift-h = "focus left";
        cmd-ctrl-alt-shift-j = "focus down";
        cmd-ctrl-alt-shift-k = "focus up";
        cmd-ctrl-alt-shift-l = "focus right";

        # Layout
        cmd-ctrl-alt-shift-slash = "layout tiles horizontal vertical";
        cmd-ctrl-alt-shift-comma = "layout accordion horizontal vertical";

        # Portable workspaces
        cmd-ctrl-alt-shift-1 = "summon-workspace wrk";
        cmd-ctrl-alt-shift-2 = "summon-workspace web";
        cmd-ctrl-alt-shift-3 = "summon-workspace pro";

        # Fixed MacBook workspaces
        cmd-ctrl-alt-shift-4 = "workspace cht";
        cmd-ctrl-alt-shift-5 = "workspace mus";

        # Sidecar / reference workspace
        cmd-ctrl-alt-shift-6 = "workspace ref";

        # Jump back to previous workspace
        cmd-ctrl-alt-shift-tab = "workspace-back-and-forth";

        # Manipulation mode
        cmd-ctrl-alt-shift-m = "mode move";

        # Service mode
        cmd-ctrl-alt-shift-semicolon = "mode service";
      };

      # Window manipulation
      #
      # Hyper+M enters this mode.
      # Hyper can then be released.
      mode.move.binding = {
        # Move windows
        h = "move left";
        j = "move down";
        k = "move up";
        l = "move right";

        # Join containers
        shift-h = "join-with left";
        shift-j = "join-with down";
        shift-k = "join-with up";
        shift-l = "join-with right";

        # Layout
        t = "layout tiles horizontal vertical";
        a = "layout accordion horizontal vertical";

        # Move focused window to workspace
        "1" = [
          "move-node-to-workspace wrk"
          "mode main"
        ];

        "2" = [
          "move-node-to-workspace web"
          "mode main"
        ];

        "3" = [
          "move-node-to-workspace pro"
          "mode main"
        ];

        "4" = [
          "move-node-to-workspace cht"
          "mode main"
        ];

        "5" = [
          "move-node-to-workspace mus"
          "mode main"
        ];

        "6" = [
          "move-node-to-workspace ref"
          "mode main"
        ];

        # Resize
        minus = "resize smart -50";
        equal = "resize smart +50";

        # Rebalance workspace
        b = "balance-sizes";

        # Leave move mode
        esc = "mode main";
        enter = "mode main";
      };

      # Maintenance / less-common operations
      mode.service.binding = {
        esc = [
          "reload-config"
          "mode main"
        ];

        r = [
          "flatten-workspace-tree"
          "mode main"
        ];

        f = [
          "layout floating tiling"
          "mode main"
        ];

        b = [
          "balance-sizes"
          "mode main"
        ];
      };

      # Automatic application routing
      on-window-detected = [
        # Browser
        {
          "if".app-id = "net.imput.helium";
          run = "move-node-to-workspace web";
        }

        # Productivity
        {
          "if".app-id = "md.obsidian";
          run = "move-node-to-workspace wrk";
        }
        {
          "if".app-id = "com.apple.iCal";
          run = "move-node-to-workspace wrk";
        }

        # Communications
        {
          "if".app-id = "dev.vencord.vesktop";
          run = "move-node-to-workspace cht";
        }
        {
          "if".app-id = "com.apple.MobileSMS";
          run = "move-node-to-workspace cht";
        }

        # Music
        {
          "if".app-id = "com.apple.Music";
          run = "move-node-to-workspace mus";
        }
        {
          "if".app-id = "org.jeffvli.feishin";
          run = "move-node-to-workspace mus";
        }
      ];
    };
  };
}
