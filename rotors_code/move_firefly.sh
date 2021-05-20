#!/usr/bin/env bash

rostopic pub -r 10 /firefly/gazebo/command/motor_speed mav_msgs/Actuators '{angular_velocities: [400, 400, 700, 700, 400, 400]}'
