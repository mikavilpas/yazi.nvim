## hycov

clients overview for hyprland plugin

https://github.com/DreamMaoMao/hycov/assets/30348075/c8c9cf56-daba-47d8-9e16-11462eac8c3a

Welcome to fork, if you improve the hycov plugin, please let me know, I will be happy to use your fork.

### Manual Installation

_only support hyprland sourc code after(2023-12-22)_

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
plugin = /path/to/libhycov.so
bind = CTRL_ALT,h,hycov:enteroverview
bind = CTRL_ALT,m,hycov:leaveoverview
bind = CTRL_ALT,k,hycov:toggleoverview

plugin {
    hycov {
        overview_gappo = 60 #gas width from screem
        overview_gappi = 24 #gas width from clients
	    hotarea_size = 10 #hotarea size in bottom left,10x10
	    enable_hotarea = 1 # enable mouse cursor hotarea
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

    hycov.url = "github:DreamMaoMao/hycov";
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
