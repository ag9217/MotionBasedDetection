#!/usr/bin/env bash


# Traj 1
#rostopic pub --once /gazebo/set_model_state gazebo_msgs/ModelState '{model_name: firefly, pose: { position: { x: -12.5, y: 5.2, z: 0.08 }, orientation: {x: 0, y: 0, z: -0.383, w: 0.924 } }, twist: { linear: { x: 0, y: 0, z: 0 }, angular: { x: 0, y: 0, z: 0}  }, reference_frame: world }'

# Traj 2
#rostopic pub --once /gazebo/set_model_state gazebo_msgs/ModelState '{model_name: firefly, pose: { position: { x: -6.9, y: -3.56, z: 0.08 }, orientation: {x: 0, y: 0, z: -0.383, w: 0.924 } }, twist: { linear: { x: 0, y: 0, z: 0 }, angular: { x: 0, y: 0, z: 0}  }, reference_frame: world }'

# Traj 3
#rostopic pub --once /gazebo/set_model_state gazebo_msgs/ModelState '{model_name: firefly, pose: { position: { x: -2.846, y: 1.211, z: 0.08 }, orientation: {x: 0, y: 0, z: -0.383, w: 0.924 } }, twist: { linear: { x: 0, y: 0, z: 0 }, angular: { x: 0, y: 0, z: 0}  }, reference_frame: world }'

# Traj 4
#rostopic pub --once /gazebo/set_model_state gazebo_msgs/ModelState '{model_name: firefly, pose: { position: { x: -6.07, y: -0.866, z: 0.08 }, orientation: {x: 0, y: 0, z: -0.383, w: 0.924 } }, twist: { linear: { x: 0, y: 0, z: 0 }, angular: { x: 0, y: 0, z: 0}  }, reference_frame: world }'

# Traj 5
#rostopic pub --once /gazebo/set_model_state gazebo_msgs/ModelState '{model_name: firefly, pose: { position: { x: -4.687, y: 4.182, z: 0.08 }, orientation: {x: 0, y: 0, z: -0.383, w: 0.924 } }, twist: { linear: { x: 0, y: 0, z: 0 }, angular: { x: 0, y: 0, z: 0}  }, reference_frame: world }'



# Traj 2 with clutter
#rostopic pub --once /gazebo/set_model_state gazebo_msgs/ModelState '{model_name: firefly, pose: { position: { x: -11.36, y: 7.14, z: 0.08 }, orientation: {x: 0, y: 0, z: -0.383, w: 0.924 } }, twist: { linear: { x: 0, y: 0, z: 0 }, angular: { x: 0, y: 0, z: 0}  }, reference_frame: world }'

# Traj 3 with clutter
#rostopic pub --once /gazebo/set_model_state gazebo_msgs/ModelState '{model_name: firefly, pose: { position: { x: -4.83, y: 2.73, z: 0.08 }, orientation: {x: 0, y: 0, z: -0.383, w: 0.924 } }, twist: { linear: { x: 0, y: 0, z: 0 }, angular: { x: 0, y: 0, z: 0}  }, reference_frame: world }'

# Traj 4 with clutter
#rostopic pub --once /gazebo/set_model_state gazebo_msgs/ModelState '{model_name: firefly, pose: { position: { x: -6.242, y: -0.694, z: 0.08 }, orientation: {x: 0.0, y: 0.0, z: 2.5, w: 0.94 } }, twist: { linear: { x: 0, y: 0, z: 0 }, angular: { x: 0, y: 0, z: 0}  }, reference_frame: world }'

# Traj 5 with clutter
#rostopic pub --once /gazebo/set_model_state gazebo_msgs/ModelState '{model_name: firefly, pose: { position: { x: -8.43, y: -2.83, z: 0.08 }, orientation: {x: 0.0, y: 0.0, z: 1.2, w: 0.94 } }, twist: { linear: { x: 0, y: 0, z: 0 }, angular: { x: 0, y: 0, z: 0}  }, reference_frame: world }'

# Traj 6 with clutter
#rostopic pub --once /gazebo/set_model_state gazebo_msgs/ModelState '{model_name: firefly, pose: { position: { x: -12.0, y: -0.519, z: 0.08 }, orientation: {x: 0.0, y: 0.0, z: 0.5, w: 0.94 } }, twist: { linear: { x: 0, y: 0, z: 0 }, angular: { x: 0, y: 0, z: 0}  }, reference_frame: world }'
# Traj 7 with clutter
rostopic pub --once /gazebo/set_model_state gazebo_msgs/ModelState '{model_name: firefly, pose: { position: { x: -11.7, y: 1.793, z: 0.08 }, orientation: {x: 0.0, y: 0.0, z: 0.0, w: 0.94 } }, twist: { linear: { x: 0, y: 0, z: 0 }, angular: { x: 0, y: 0, z: 0}  }, reference_frame: world }'
