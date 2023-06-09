#!/usr/bin/env julia

using Printf
using RobotOS

using CSV
using DataFrames
using Quaternions

@rosimport mrs_msgs.msg: Path, Reference, ControlManagerDiagnostics, RangeWithCovarianceArrayStamped, PoseWithCovarianceArrayStamped
@rosimport geometry_msgs.msg: Point, PoseWithCovarianceStamped
@rosimport mrs_msgs.srv: PathSrv
rostypegen()

global tracking_trajectory::Bool = false

function trajectory(t)
    r = 10 + 2*sin(5*2*pi*t)

    x = r*cos(2*pi*t)
    y = r*sin(2*pi*t)
    z = 5 + 0.5*cos(5*2*pi*t)

    # x = 5 + 15*t
    # y = 0
    # z = 2

    return x, y, z
end

function diagnostic_cb(msg::mrs_msgs.msg.ControlManagerDiagnostics)
    global tracking_trajectory

    tracking_trajectory = msg.tracker_status.tracking_trajectory
end

function main()
    global tracking_trajectory

    @printf "Julia trajectory generator and recorder\n\r"
    init_node("path_generator", anonymous = true)

    service_name = "/uav2/trajectory_generation/path"
    wait_for_service(service_name)
    trajectory_srv = ServiceProxy{mrs_msgs.srv.PathSrv}(service_name)

    Subscriber{mrs_msgs.msg.ControlManagerDiagnostics}("/uav2/control_manager/diagnostics", diagnostic_cb)

    path = mrs_msgs.msg.Path()

    path.header.stamp = RobotOS.now()
    path.input_id = 5

    path.use_heading = false
    path.fly_now = true
    path.stop_at_waypoints = false
    path.loop = false

    path.override_constraints = false
    path.relax_heading = true

    x_vec = []
    y_vec = []
    z_vec = []

    t = LinRange(0, 1, 100)

    for i in t
        x, y, z = trajectory(i)
        point = mrs_msgs.msg.Reference(geometry_msgs.msg.Point(x, y, z), 0)
        push!(path.points, point)
        push!(x_vec, x)
        push!(y_vec, y)
        push!(z_vec, z)
    end

    rossleep(Duration(1))

    # pl = scatter(x_vec, y_vec, mode="lines")
    # display(pl)

    while tracking_trajectory
        rossleep(Duration(0.1))
    end

    resp = trajectory_srv(mrs_msgs.srv.PathSrvRequest(path))
    print(resp)
    if  !resp.success
        @printf "Path request failed\n\r"
        return
    end

    @printf "Message published\n\r"
    tracking_trajectory = true

    while tracking_trajectory
        rossleep(Duration(0.1))
    end

    @printf "Trajectory finished\n\r"


    return
end

main()