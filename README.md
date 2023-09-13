# TS-TPC-7990 Balloon Pump Demo

This repository hosts the software package for our trade show demo of our TS-TPC-7990 interfacing with an air pump to inflage and deflate balloons. The air system is running closed loop, allowing the user to specify a volume of air to inflate or deflate the balloon with. The airflow sensor is a Sensirion SFM3400-F which communicates over I2C to the TS-TPC-7990.

This repository is dual purpose, it is both the Qt application code as well as a Buildroot br2-external tree nested with our existing [Buildroot br2-external](https://github.com/embeddedTS/buildroot-ts) project. This nesting allows this project to add necessary packages and configurations, but still take advantages of packages provided by our existing Buildroot br2-external repository, which itself takes advantage of the mainline Buildroot project.


## About Buildroot and Runtime

The final generated runtime uses the `linux-5.10.y` branch of our [linux-lts](https://github.com/embeddedTS/linux-lts/) project. The kernel supports full GPU acceleration using the open-source Etnaviv driver for the i.MX6 Vivante GC2000 which integrates with OpenGL 2.0 ES shaders.

The main UI interface is provided by X11 with DRI2 to interface with Mesa3D and OpenGL.

The Qt runtime is able to take advantage of the graphics framework to be fully hardware accelerated. Even under operation, the main application only consumes a few % of CPU time. This allows much more intense background processing to take place while keeping the UI responsive and keeping up with data from the airflow sensor.

All of this is build and packaged by Buildroot.


## About Qt Application

The Qt application mostly uses QML to describe the interface as well as handle some signals from the main application code.

The interface boils down to a Fill Queue and a Fill Total Volume display, as well as a system info display, and a handful of secondary interface buttons.

### Fill Queue

The Fill Queue can be modified by the grouping of buttons in the middle of the interface. This allows direct queue modification by adding or subtracting a volume of air from the queue in 1, 2, and 5 L steps, as well as resetting the Fill Queue.

Additionally, the right side of the screen contains Quick Fill buttons to set the Fill Queue to 100%, 50%, and 25% of the total volume of an 11" latex balloon, and then run the pump.

Once the pump is running, the Fill Queue decrements while the Fill Total Volume increments as air is pumped in or out of the balloon. Once the Fill Queue is emptied, the pump is stopped.


### Fill Total Volume

The Fill Total Volume display shows a running total of the amount of air moved in and out of a balloon. As the total volume approaches 100% of the balloon's rated air volume the display will turn green. Once the volume total rises above 104% and 115% of the balloon's rated air volume, the display will turn yellow and then red as a warning. The interface does not prevent overfilling a balloon, so continuing to fill beyond this risks bursting a balloon.

Pressing the Fill Total Volume display will tare the current measurement back to 0.00 L.

The above values are set up for an 11" latex balloon (nominally rated for 11 L of air). The nominal rating can be adjusted at compile time to allow for different sizes of balloons.


### System Statistics

On the left side of the interface is a list of system statistics including CPU temperature, CPU load, memory usage, and system uptime. This is intended to show how few resources are consumed by this whole application.

Below that is a button that will start a system stress test. This creates 6 threads of execution on the CPU, as well as two more threads which consumes and frees 256 MB of RAM each. This runs for 1 minute and automatically stops. Even under heavy load, the UI remains responsive and the airflow measurement remains accurate.


### Help and About

On the right side of the interface are two on-screen buttons to provide a quick Help and About overlay respectively.


### Pump and Application Protections

The application implements protection of the pump by ensuring there is a valid amount of airflow while the pump is running. If the airflow stalls for longer than 1 second while inflating or deflating, the pump is turned off and the Total Fill Volume displays a pump error. This error must be acknowledged and cleared by pressing the Fill Total Volume display before the pump can be run again.

If there is ever an error reported by the sensor, the pump is stopped if it is running and the Total Fill Volume displays a sensor error. As above, this error must be acknowledged and cleared before the pump can be run again.


## Building the Distribution

The following instructions can be used to build the whole application and Buildroot distribution:

```
git clone --recurse-submodules https://github.com/embeddedTS/balloon-pump-demo-ts-7990
cd balloon-pump-demo-ts-7990/buildroot
./buildroot-ts/scripts/run_docker_buildroot.sh make ts7990_balloon_defconfig clean all
```

The last command above configures and builds the final output image. It does this by using a Docker container to ensure a known good build environment. If it is preferred to not use docker, the whole distribution can be built natively instead:

```
# From the balloon-pump-demo-ts-7990/buildroot/ directory
make ts7990_balloon_defconfig clean all
```


This will output a `rootfs.tar.xz` tarball in `balloon-pump-demo-ts-7990/buildroot/buildroot-ts/buildroot/output/images/`.

The rootfs can be directly unpacked to the eMMC of the TS-TPC-7990. This can be accomplished manually or by utilizing our [Image Relicator tool for the TS-TPC-7990](https://docs.embeddedts.com/TS-TPC-7990#Image_Replicator) by copying the tarball to `/emmcimage.tar.xz` of a bootable Image Replicator USB disk.
