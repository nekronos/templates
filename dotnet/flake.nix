{
  description = "Hello World in .NET";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fsharpfmt.url = "github:nekronos/fsharpfmt";
  };
  outputs = {
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        projectFile = "./HelloWorld/HelloWorld.fsproj";
        testProjectFile = "./HelloWorld.Test/HelloWorld.Test.fsproj";
        dotnet-sdk = pkgs.dotnet-sdk_9;
        dotnet-runtime = pkgs.dotnet-runtime_9;
        version = "0.0.1";
      in {
        packages = {
          default = pkgs.buildDotnetModule {
            inherit projectFile testProjectFile dotnet-sdk dotnet-runtime;
            pname = "HelloWorld";
            version = version;
            src = ./.;
            nugetDeps = ./deps.json;
            doCheck = true;
          };
        };
        devShells = {
          default = pkgs.mkShell {
            packages = let
              fsharpfmt = inputs.fsharpfmt.packages."${system}".fsharpfmt;
              dotnet = [
                dotnet-sdk
                dotnet-runtime
              ];
            in
              with pkgs;
                [
                  fantomas
                  fsautocomplete
                  fsharpfmt
                  nuget-to-json
                  xq-xml
                ]
                ++ dotnet;
          };
        };
      }
    );
}
