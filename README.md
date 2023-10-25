## hycov

clients overview for hyprland plugin

https://github.com/DreamMaoMao/hycov/assets/30348075/76998ed6-4046-4403-8236-7b9c2f913bc0

Welcome to fork, if you improve the hycov plugin, please let me know, I will be happy to use your fork.

### Manual Installation

_only support hyprland sourc code after the date(2023-10-22)_,

Because this plug-in require a [commit](https://github.com/hyprwm/Hyprland/commit/a61eb7694df25a75f45502ed64b1536fda370c1d) in hyprland(was commited in 2023-10-21)

##### use meson and ninja:

```console
$ git clone https://github.com/DreamMaoMao/hycov.git
$ cd hycov
$ sudo meson setup build --prefix=/usr
$ sudo ninja -C build
$ sudo ninja -C build install # `libhycov.so` path: /usr/lib/libhycov.so
```

##### use cmake:

```console
$ git clone https://github.com/DreamMaoMao/hycov.git
$ cd hycov
$ bash install.sh # `libhycov.so` path: /usr/lib/libhycov.so
```

### Useage(hyprland.conf)

```
# when enter overview, you can use letf-button to jump,right-button to kill or use keybind
plugin = /path/to/libhycov.so
bind = CTRL_ALT,h,hycov:enteroverview
bind = CTRL_ALT,m,hycov:leaveoverview
bind = CTRL_ALT,k,hycov:toggleoverview

# The direction switch shortcut key binding.
# calculate the window closest to the direction to switch focus.
# This keybind is applicable not only to the overview  but also to the general layout
bind=ALT,left,hycov:movefocus,l
bind=ALT,right,hycov:movefocus,r
bind=ALT,up,hycov:movefocus,u
bind=ALT,down,hycov:movefocus,d

plugin {
    hycov {
      overview_gappo = 60 # gas width from screen
      overview_gappi = 24 # gas width from clients
	    hotarea_size = 10   # hotarea size in bottom left,10x10
	    enable_hotarea = 1  # move cursor to bottom-left can toggle overview
    }
}

```

### NixOS with home—manager

```nix
# flake.nix

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    hycov={
      url = "github:DreamMaoMao/hycov";
      inputs.hyprland.follows = "hyprland";
    };
  };

  outputs = { nixpkgs, home-manager, hyprland, hycov, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."user@hostname" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;

        modules = [
          hyprland.homeManagerModules.default
          {
            wayland.windowManager.hyprland = {
              enable = true;
              plugins = [
                hycov.packages.${pkgs.system}.hycov
              ];
              extraConfig = ''
                bind = CTRL_ALT,h,hycov:enteroverview
                bind = CTRL_ALT,m,hycov:leaveoverview
                bind = CTRL_ALT,k,hycov:toggleoverview
                bind=ALT,left,hycov:movefocus,l
                bind=ALT,right,hycov:movefocus,r
                bind=ALT,up,hycov:movefocus,u
                bind=ALT,down,hycov:movefocus,d

                plugin {
                    hycov {
                        overview_gappo = 60 #gas width from screem
                        overview_gappi = 24 #gas width from clients
                	    hotarea_size = 10 #hotarea size in bottom left,10x10
                	    enable_hotarea = 1 # enable mouse cursor hotarea
                    }
                }
              '' + ''
                # your othor config
              '';
            };
          }
          # ...
        ];
      };
    };
}
```
