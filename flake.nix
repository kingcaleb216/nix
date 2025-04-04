##############################
# flake.nix
##############################
{
   description = "NixOS + Home Manager setup for laptop (Hyprland, dotfiles, themed)";

   inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      home-manager = {
         url = "github:nix-community/home-manager";
         inputs.nixpkgs.follows = "nixpkgs";
      };
      hyprlandDotfiles = {
         url = "github:kingcaleb216/hyprland";
         flake = false;
      };
   };

   outputs = { self, nixpkgs, home-manager, hyprlandDotfiles }: let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
         inherit system;
         config.allowUnfree = true;
      };
   in {
      nixosConfigurations = {
         laptop = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [

               ({ config, pkgs, ... }: {
                  imports = [ ./hardware-configuration.nix ];

                  networking.hostName = "laptop";
                  networking.networkmanager.enable = true;
                  time.timeZone = "America/Chicago";
                  i18n.defaultLocale = "en_US.UTF-8";
                  console.keyMap = "us";

                  users.users.caleb = {
                     isNormalUser = true;
                     extraGroups = [ "wheel" "networkmanager" "video" ];
                     shell = pkgs.zsh;
                  };

                  environment.systemPackages = with pkgs; [
                     git zsh vim wget curl unzip zip htop
                     hyprland kitty waybar rofi
                     pipewire wireplumber pavucontrol
                     xdg-utils xdg-desktop-portal xdg-desktop-portal-hyprland
                     mesa vulkan-loader
                     fontconfig dejavu_fonts grub2_full
                     fastfetch
                  ];

                  services.xserver.enable = true;

                  services.greetd = {
                     enable = true;
                     settings = {
                        default_session = {
                           command = "Hyprland";
                           user = "caleb";
                        };
                     };
                  };

                  programs.zsh.enable = true;

                  hardware.pulseaudio.enable = false;
                  services.pipewire = {
                     enable = true;
                     audio.enable = true;
                     pulse.enable = true;
                  };

                  boot.loader = {
                     efi = {
                        canTouchEfiVariables = true;
                        efiSysMountPoint = "/boot";
                     };
                     grub = {
                        enable = true;
                        efiSupport = true;
                        efiInstallAsRemovable = false;
                        useOSProber = false;
                        forceInstall = false;
                        devices = [ "nodev" ];
                     };
                  };
                  
                  fonts.packages = with pkgs; [
                     dejavu_fonts
                     pkgs.nerd-fonts.fira-code
                  ];

                  system.stateVersion = "24.05";
               })

               home-manager.nixosModules.home-manager

               ({ config, pkgs, ... }: {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;

                  home-manager.users.caleb = {
                     home.username = "caleb";
                     home.homeDirectory = "/home/caleb";

                     home.stateVersion = "24.05";

                     home.packages = with pkgs; [
                        starship zoxide bat fzf eza neovim
                     ];

                     programs.zsh = {
                        enable = true;
                        oh-my-zsh.enable = true;
                        oh-my-zsh.theme = "agnoster";
                        oh-my-zsh.plugins = [ "git" "zoxide" "fzf" ];
                        shellAliases = {
                           ll = "eza -la";
                           gs = "git status";
                        };
                     };

                     programs.kitty.enable = true;

                     xdg.configFile = {
                        "hypr".source = "${hyprlandDotfiles}/hypr";
                        "kitty/kitty.conf".source = "${hyprlandDotfiles}/kitty/kitty.conf";
                        "waybar/config".source = "${hyprlandDotfiles}/waybar/config";
                        "waybar/style.css".source = "${hyprlandDotfiles}/waybar/style.css";
                     };

                     home.file.".config/wall.png".source = "${hyprlandDotfiles}/swww/wallpaper.jpg";
                  };
               })
            ];
         };
      };
   };
}
