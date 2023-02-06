{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager }@inputs:
    let pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      packages.x86_64-linux.default = self.packages.x86_64-linux.goes-notify;
      packages.x86_64-linux.goes-notify = import ./goes-notify.nix { inherit pkgs; };
      packages.x86_64-linux.goes-appts = import ./goes-appts.nix { inherit pkgs; };
      packages.x86_64-linux.goes-dbwrite = import ./goes-dbwrite.nix { inherit pkgs; };
      packages.x86_64-linux.goes-dbread = import ./goes-dbread.nix { inherit pkgs; };

      packages.x86_64-linux.goes-check = pkgs.writeShellApplication {
        name = "goes-check";
        text = ''
          goes-appts "$1" | goes-dbwrite "$2"
        '';
        runtimeInputs = [
          self.packages.x86_64-linux.goes-appts
          self.packages.x86_64-linux.goes-dbwrite
        ];
      };

      nixosModules.goes-notify = import ./module.nix inputs;
      nixosModules.default = self.nixosModules.goes-notify;
    };
}
