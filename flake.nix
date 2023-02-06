{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }@inputs:
    let pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      packages.x86_64-linux.default = self.packages.x86_64-linux.goes-notify;
      packages.x86_64-linux.goes-notify = import ./goes-notify.nix { inherit pkgs; };
      packages.x86_64-linux.goes-appts = import ./goes-appts.nix { inherit pkgs; };
      packages.x86_64-linux.goes-dbwrite = import ./goes-dbwrite.nix { inherit pkgs; };

      nixosModules.goes-notify = import ./module.nix { inherit inputs; };
      nixosModules.default = self.nixosModules.goes-notify;
    };
}
