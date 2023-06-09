#!/bin/bash

cd rosbag
rosbag record /uav2/ground_truth_pose /uav1/ground_truth_pose /uav1/uwb_range/distance  /uav1/object_tracker/poses /uav2/control_manager/diagnostics
