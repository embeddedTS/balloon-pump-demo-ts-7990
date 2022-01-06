This Qt Application is used in our trade show demo showing how we
can interactively control devices.  Specifically, we are controlling
an air vacuum pump and valves in order to inflate and deflate a 9"
balloon.  It's a fun project that helps give an introduction of
just minor capabilities of our embedded systems.

There are three buttons:

  [Inflate]
     This button will turn on the vacuum pump and set the valves
     to pump air into the balloon.  This action will stop after 20
     seconds.  We start a 1ms timer and increment the time passed
     counter so we can track how full the balloon is (given 10 L/min
     pump).

  [Deflate]
     This button will turn on the vacuum pump and set the valves
     to suck air out of the balloon.  This action will stop after
     20 seconds.  We start a 1ms timer and decrement the time passed
     counter so we can track how full the balloon is (given 10 L/min
     pump).

  [Calibrate]
     This button gives us a way to zero out the percent fill guage.
     Let out all the air of the balloon, reattach it, and press
     Calibrate to zero time passed counter and percent filled..

There are three status indications:

  [Guage % Fill]
     A gauge with a needle from 0 to 100 to indicate the total
     balloon fill. A 9" balloon is full at 7.65L.

  [Warning Status Indicator]
     A light that will turn on when the percent fill is > 105%.
     This gives us an indication that we might be ready to burst
     the ballon.  This turns off when the balloon has been deflated
     to < 105% again.

  [CPU Temperature]
     Displays the current CPU temperature.  Mostly there for
     monitoring system health.  The valves put out quite a bit of
     heat.  Everything is in an enclosed TS-CAB799 cabinet.

TS-TPC-7990 Setup Instructions

1.) Copy the balloon-pump-demo-ts-7990 binary to /home/root 
2.) Export DISPLAY environment variable:

    export DISPLAY=:0

3.) Modify /usr/bin/mini-x-session:

    /home/root/balloon-pump-demo-ts-7990&
    exec matchbox-window-manager -use_titlebar no -use_cursor no

4.) Restart using shutdown -r now

5.) You should now be looking at a kiosk style screen with the Qt
application.

Versions:
   Ubuntu 18.04 LTS
   Qt Creator v4.5.2
   Based on Qt 5.9.5

Sources:
   https://wiki.embeddedTS.com/wiki/TS-TPC-7990#Configure_Qt_Creator_IDE


