{
  inputs = {
    ros2nix.url = "github:wentasah/ros2nix";

    # important for ros overlay to work
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";
    nix-ros-overlay.url = "github:arcturusnavigation/nix-ros-overlay/develop";

    # for development
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };
  outputs =
    {
      self,
      nix-ros-overlay,
      ros2nix,
      nixpkgs,
      pre-commit-hooks,
    }:
    nix-ros-overlay.inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nix-ros-overlay.overlays.default ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "arcturus";
          LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
          packages = [
            # basic development tasks
            pkgs.git
            pkgs.bash

            # ros build tools
            pkgs.colcon
            ros2nix.packages.${pkgs.system}.ros2nix

            # project system dependencies
            pkgs.geographiclib
            pkgs.python3Packages.rosdep
            pkgs.python3Packages.scipy
            pkgs.python3Packages.transforms3d
            pkgs.python3Packages.torch
            pkgs.python3Packages.pyserial
            pkgs.SDL
            pkgs.yaml-cpp

            # add other system packages here
            (
              with pkgs.rosPackages.humble;
              buildEnv {
                paths = [
                  # empirically determined list of project ROS dependencies
                  ros-core
                  boost
                  ament-cmake-core
                  angles
                  diagnostic-updater
                  geographic-msgs
                  message-filters
                  tf-transformations
                  tf2-ros-py
                  tf2-eigen
                  tf2-geometry-msgs
                  yaml-cpp-vendor
                  python-cmake-module
                  rviz-common
                  tf2-sensor-msgs
                  mavros-msgs
                  pcl-ros
                  cv-bridge
                  image-geometry
                  rviz-satellite
                  rviz-default-plugins
                  rosbag2-py

                  # for simulation (requires insecure packages)
                  # gazebo-ros

                  # for launch
                  mavros
                  robot-localization
                  velodyne-pointcloud

                  # add other ROS packages here
                ];
              }
            )
          ];

          shellHook = ''
            alias install="./install.sh"
            alias pull="./pull.sh"
            alias build="./build.sh"
            alias update="./update.sh"
            alias run=". ./run.sh"
            alias launch="./launch.sh"
            alias hash="./hash.sh"
          '';
        };

        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixfmt-rfc-style.enable = true;
              shfmt.enable = true;
              bats.enable = true;
              markdownlint.enable = true;
              clang-format.enable = true;
              clang-tidy.enable = true;
              fix-encoding-pragma.enable = true;
              deadnix.enable = true;
              nil.enable = true;
              statix.enable = true;
              check-builtin-literals.enable = true;
              check-docstring-first.enable = true;
              check-python.enable = true;
              mypy.enable = true;
              isort.enable = true;
              sort-requirements-txt.enable = true;
              name-tests-test.enable = true;
              pyright.enable = true;
              python-debug-statements.enable = true;
              pyupgrade.enable = true;
              ruff.enable = true;
              ruff-format.enable = true;
              mdsh.enable = true;
              check-toml.enable = true;
              typos.enable = true;
              check-merge-conflicts.enable = true;
              commitizen.enable = true;
              forbid-new-submodules.enable = true;
              check-case-conflicts.enable = true;
              check-executables-have-shebangs.enable = true;
              check-shebang-scripts-are-executable.enable = true;
              check-symlinks.enable = true;
              check-vcs-permalinks.enable = true;
              end-of-file-fixer.enable = true;
              fix-byte-order-marker.enable = true;
              mixed-line-endings.enable = true;
              tagref.enable = true;
              trim-trailing-whitespace.enable = true;
              trufflehog.enable = true;
              check-yaml.enable = true;
              yamlfmt.enable = true;
              check-json.enable = true;
              actionlint.enable = true;
              checkmake.enable = true;
              check-xml.enable = true;
              cmake-format.enable = true;
              hadolint.enable = true;
              headache.enable = true;
            };
          };
        };

        devShells.dev = pkgs.mkShell {
          name = "development";

          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;

          packages = [
            # basic development tasks
            pkgs.git
            pkgs.bash
          ];
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
  nixConfig = {
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };
}
