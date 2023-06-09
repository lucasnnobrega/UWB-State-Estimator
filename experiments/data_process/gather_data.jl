#!/usr/bin/env julia

using Printf
using RobotOS
using Quaternions
using DelimitedFiles
using Plots
using Statistics
using Infiltrator
using Dates
using PlotThemes
using DataFrames
using DSP
using CSV

using Geodesy
using Distances

@rosimport mrs_msgs.msg: RangeWithCovarianceArrayStamped, Bestpos
@rosimport geometry_msgs.msg: PoseWithCovarianceStamped
rostypegen()

uwb_distance = []
gps_distance = []

UAV_38 = LLA(50, 14, 400)
UAV_39 = LLA(50, 14, 400)

function uwb_cb(msg::mrs_msgs.msg.RangeWithCovarianceArrayStamped)
    @printf "UWB data\n\r"
    global uwb_distance
    global gps_distance
    global UAV_38
    global UAV_39
    for measurement in msg.ranges
        if (measurement.range.range < 0)
            return
        end
        @printf "UWB data: %f\n\r" measurement.range.range
        dist = euclidean_distance(UAV_38, UAV_39)
        @printf "Distance: %f\n\r" dist

        if dist > 200
            return
        end

        push!(gps_distance, dist)
        push!(uwb_distance, measurement.range.range)
    end

    pl = plot(gps_distance)
    plot!(pl, uwb_distance)
    display(pl)
end

function uav38_rtk_cb(msg::mrs_msgs.msg.Bestpos)
    @printf "GPS data UAV38\n\r"
    global UAV_38
    UAV_38 = LLA(msg.latitude, msg.longitude, msg.height)
end

function uav39_rtk_cb(msg::mrs_msgs.msg.Bestpos)
    @printf "GPS data UAV39\n\r"
    global UAV_39
    UAV_39 = LLA(msg.latitude, msg.longitude, msg.height)
end

function main()

    init_node("gather_data")

    @printf "Gather data\n\r"

    pl = plot(gps_distance)
    plot!(pl, uwb_distance)
    display(pl)

    # Subscriber{mrs_msgs.msg.ControlManagerDiagnostics}("/uav2/control_manager/diagnostics", diagnostic_cb)
    
    uav38_sub = Subscriber{mrs_msgs.msg.Bestpos}("/uav38/rtk/bestpos", uav38_rtk_cb)
    uav39_sub = Subscriber{mrs_msgs.msg.Bestpos}("/uav39/rtk/bestpos", uav39_rtk_cb)
    # object_tracker_sub = Subscriber{mrs_msgs.msg.PoseWithCovarianceArrayStamped}("/uav1/object_tracker/filtered_poses", object_tracker_cb)
    
    @printf "Gather data sub\n\r"
    uwb_sub = Subscriber{mrs_msgs.msg.RangeWithCovarianceArrayStamped}("/uav39/uwb_range/range_out", uwb_cb)

    spin()
end

main()