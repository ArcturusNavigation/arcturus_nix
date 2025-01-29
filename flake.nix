{
  inputs = {
    ros2nix.url = "github:wentasah/ros2nix";

    # important for ros overlay to work
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";
    nix-ros-overlay.url = "github:arcturusnavigation/nix-ros-overlay/develop";
  };
  outputs =
    {
      self,
      nix-ros-overlay,
      ros2nix,
      nixpkgs,
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
        };

        packages = {
          install = pkgs.stdenv.mkDerivation {
            pname = "install";
            version = "1.0";

            src = ./.;

            nativeBuildInputs = [
              pkgs.makeWrapper
            ];

            buildInputs = [
              pkgs.bash
            ];

            propagatedBuildInputs = [
              # basic development tasks
              pkgs.git
              pkgs.bash
              pkgs.cmake

              # ros build tools
              pkgs.colcon
              ros2nix.packages.${pkgs.system}.ros2nix

              # cmake
              (
                with pkgs.rosPackages.humble;
                buildEnv {
                  paths = [
                    ros-core
                    ament-package
                    ament-cmake-core
                    diagnostic-updater
                    geographic-msgs
                    message-filters
                    tf2-geometry-msgs
                    yaml-cpp-vendor
                    python-cmake-module
                    tf2-sensor-msgs
                    mavros-msgs
                    rosbag2-py
                  ];
                }
              )
            ];

            dontUseCmakeConfigure = true;

            buildPhase = ''
              mkdir -p $out/bin
              cp install.sh $out/bin/install
              chmod +x $out/bin/install
            '';

            installPhase = ''
              wrapProgram $out/bin/install \
                --set PATH "${ros2nix.packages.${pkgs.system}.ros2nix}/bin:${pkgs.colcon}/bin:${pkgs.rosPackages.humble.ament-package}/bin:${pkgs.rosPackages.humble.python-cmake-module}:$PATH"
            '';
          };
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );

  nixConfig = {
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };
}
