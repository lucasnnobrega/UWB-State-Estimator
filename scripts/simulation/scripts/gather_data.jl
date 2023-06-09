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

include("unscented_transform.jl")

@rosimport mrs_msgs.msg:RangeWithCovarianceArrayStamped, ControlManagerDiagnostics, PoseWithCovarianceArrayStamped
@rosimport geometry_msgs.msg:PoseWithCovarianceStamped
rostypegen()

global data = DataFrame(
    timestamp=Float64[],
    range_gt=Float64[],
    range_ot=Float64[],
    range_var_ot=Float64[],
    mh=Float64[],
    x_gt=Float64[],
    y_gt=Float64[],
    z_gt=Float64[],
    x_ot=Float64[],
    y_ot=Float64[],
    z_ot=Float64[]
)
global data_uwb = DataFrame(
    timestamp=Float64[], 
    range_uwb=Float64[], 
    variance=Float64[]
)

global uav1_gt = geometry_msgs.msg.PoseWithCovarianceStamped()
global uav2_gt = geometry_msgs.msg.PoseWithCovarianceStamped()

global START_TIME::Float64 = NaN

global tracking_trajectory::Bool = false

function diagnostic_cb(msg::mrs_msgs.msg.ControlManagerDiagnostics)
    global tracking_trajectory

    tracking_trajectory = msg.tracker_status.tracking_trajectory
end

function position_to_vector(pos)
    return [pos.x, pos.y, pos.z]
end

function rotate_vector(q, u)
    if length(u) != 3
        error("Must be a 3-vector")
    end
    q_u = Quaternion(0, u[1], u[2], u[3])
    q_v = q * q_u * conj(q)
    return [imag_part(q_v)...]
end

function rotmatrix_from_quat(q::Quaternion)
    sx, sy, sz = 2q.s * q.v1, 2q.s * q.v2, 2q.s * q.v3
    xx, xy, xz = 2q.v1^2, 2q.v1 * q.v2, 2q.v1 * q.v3
    yy, yz, zz = 2q.v2^2, 2q.v2 * q.v3, 2q.v3^2
    r = [1-(yy+zz) xy-sz xz+sy
        xy+sz 1-(xx+zz) yz-sx
        xz-sy yz+sx 1-(xx+yy)]
    return r
end

function object_tracker_cb(msg::mrs_msgs.msg.PoseWithCovarianceArrayStamped)
    try
        time_stamp::Float64 = (convert(Float64, msg.header.stamp.secs) + msg.header.stamp.nsecs * 1e-9)
        global START_TIME

        global tracking_trajectory

        if !tracking_trajectory
            if START_TIME == NaN
                return
            end
            START_TIME = NaN
            empty!(data)
            return
        end

        @printf "Got data from object tracker\n\r"

        if (isnan(START_TIME) || time_stamp < START_TIME)
            START_TIME = time_stamp
        end

        time_stamp = time_stamp - START_TIME

        uav1 = position_to_vector(uav1_gt.pose.pose.position)
        position_gt_g = position_to_vector(uav2_gt.pose.pose.position)

        position_gt_r = position_gt_g - uav1
        ground_truth_dist = (position_gt_r' * position_gt_r)^(1 / 2)

        uav1_q = uav1_gt.pose.pose.orientation
        quaternion = quat(uav1_q.w, uav1_q.x, uav1_q.y, uav1_q.z)

        for measurement in msg.poses
            position_r_raw = position_to_vector(measurement.pose.position)
            position_r = rotate_vector(conj(quaternion), position_r_raw)
            position_g = position_r + uav1
            range = (position_r' * position_r)^(1 / 2)

            covariance_raw = reshape(measurement.covariance, (6, 6))
            covariance_raw = covariance_raw'
            covariance_raw = covariance_raw[1:3, 1:3]
            covariance = rotmatrix_from_quat(conj(quaternion)) * covariance_raw
            mahanalobis = sqrt((position_gt_r - position_r)' * inv(covariance) * (position_gt_r - position_r))

            σ, Wm, Wc = UT.compute_sigma_pts(position_r_raw, covariance_raw)

            @. σ ^= 2 
            σ = sum(σ, dims=2)
            @. σ ^= 1/2

            μ = Wm'*σ
            Σ = zeros(Float64, (1, 1))

            for (index, value) in enumerate(Wc)
                @. Σ += value*(σ[index, :] - μ)*(σ[index, :] - μ)'
            end

            push!(data, [time_stamp 
            ground_truth_dist 
            μ[1, 1] 
            Σ[1, 1] 
            mahanalobis 
            position_gt_g...
            position_g...])
            # filter!(row -> row.timestamp > time_stamp - 20, data[measurement.id])
        end

        CSV.write("object_tracker.csv", data)
    catch y
        println(y)
        rethrow(y)
    end
end


function uwb_cb(msg::mrs_msgs.msg.RangeWithCovarianceArrayStamped)
    time_stamp::Float64 = (convert(Float64, msg.header.stamp.secs) + msg.header.stamp.nsecs * 1e-9)
    global START_TIME
    global data_uwb

    global tracking_trajectory

    if !tracking_trajectory
        if START_TIME == NaN
            return
        end
        START_TIME = NaN
        empty!(data_uwb)
        return
    end
    @printf "Got data from UWB\n\r"

    if (isnan(START_TIME) || time_stamp < START_TIME)
        return
    end

    time_stamp = time_stamp - START_TIME

    for measurement in msg.ranges
        if (measurement.range.range < 0)
            return
        end

        push!(data_uwb, [time_stamp measurement.range.range measurement.variance])
    end

    CSV.write("uwb_data.csv", data_uwb)
end

function ground_truth_cb(msg::geometry_msgs.msg.PoseWithCovarianceStamped, uav::Int)
    global uav1_gt
    global uav2_gt

    if uav == 1
        uav1_gt = msg
    end
    if uav == 2
        uav2_gt = msg
    end
end

function uav1_cb(msg::geometry_msgs.msg.PoseWithCovarianceStamped)
    ground_truth_cb(msg, 1)
end

function uav2_cb(msg::geometry_msgs.msg.PoseWithCovarianceStamped)
    ground_truth_cb(msg, 2)
end

function main()

    global data_uwb
    global data

    init_node("gather_data", anonymous=true)

    CSV.write("object_tracker.csv", data)
    CSV.write("uwb_data.csv", data_uwb)

    @printf "Gather data\n\r"

    Subscriber{mrs_msgs.msg.ControlManagerDiagnostics}("/uav2/control_manager/diagnostics", diagnostic_cb)

    uav1_gt_sub = Subscriber{geometry_msgs.msg.PoseWithCovarianceStamped}("/uav1/ground_truth_pose", uav1_cb)
    uav2_gt_sub = Subscriber{geometry_msgs.msg.PoseWithCovarianceStamped}("/uav2/ground_truth_pose", uav2_cb)
    object_tracker_sub = Subscriber{mrs_msgs.msg.PoseWithCovarianceArrayStamped}("/uav1/object_tracker/filtered_poses", object_tracker_cb)

    uwb_sub = Subscriber{mrs_msgs.msg.RangeWithCovarianceArrayStamped}("/uav1/uwb_range/distance", uwb_cb)

    spin()
end

main()