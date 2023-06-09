#!/usr/bin/env julia

using Printf
using RobotOS

using StatsPlots, Distributions
using Quaternions
using LinearAlgebra
using DelimitedFiles
using Plots, Measures
using Statistics
using Infiltrator
using Dates
using PlotThemes
using DataFrames
using DSP

using CSV

Plots.theme(:vibrant, fmt = :PDF)

function main()
    @printf "Julia visualizer\n\r"

    object_tracker = DataFrame(CSV.File("./object_tracker.csv"))
    uwb_range = DataFrame(CSV.File("./uwb_data.csv"))

    l = @layout [a{0.25h}; b{0.25h}; c{0.25h}; grid(1,2){0.25h}]

    range_plot = plot(
        minorgrid=true, 
        title="Range", 
        fontfamily="Computer Modern",
        titlefontsize=11,
        label="",
        yguide = "range [m]",
        xguide = "time [s]",
        labelfontsize=8,
        guidefontsize=9,
        legend_position=:topleft,
        color_palette=:lighttest,
    )  
  
    range_error_plot = plot(
        minorgrid=true, 
        title="Range error", 
        fontfamily="Computer Modern",
        titlefontsize=11,
        label="",
        yguide = "value",
        xguide = "time [s]",
        labelfontsize=8,
        guidefontsize=9,
        legend_position=:topleft,
        color_palette=:lighttest,
    )   

    pose_error_plot = plot(
        minorgrid=true, 
        title="Position error", 
        fontfamily="Computer Modern",
        titlefontsize=11,
        label="",
        yguide = "value",
        xguide = "time [s]",
        labelfontsize=8,
        guidefontsize=9,
        legend_position=:topleft,
        color_palette=:lighttest,
    )   
    
    height_plot = plot(
        minorgrid=true, 
        title="Height", 
        fontfamily="Computer Modern",
        titlefontsize=11,
        label="",
        yguide = "height [m]",
        xguide = "time [s]",
        labelfontsize=8,
        guidefontsize=9,
        legend_position=:topleft,
        color_palette=:lighttest,
    )   

    trajectory_plot = plot(
        minorgrid=true, 
        title="Trajectory", 
        fontfamily="Computer Modern",
        titlefontsize=11,
        label="",
        xguide = "x [m]",
        yguide = "y [m]",
        labelfontsize=8,
        guidefontsize=9,
        legend_position=:topleft,
        color_palette=:lighttest,
    )    

    A = [object_tracker.x_ot object_tracker.y_ot object_tracker.z_ot]
    B = [object_tracker.x_gt object_tracker.y_gt object_tracker.z_gt]

    C = A.-B
    C = C.^2
    C = sum(C, dims=2)

    E = C.^(1/2)

    MSE = mean(C)
    MAE = mean(E)

    MH_range = sqrt.((object_tracker.range_gt .- object_tracker.range_ot).*object_tracker.range_var_ot.^(-1).*(object_tracker.range_gt .- object_tracker.range_ot))

    plot!(range_plot, object_tracker.timestamp, object_tracker.range_gt, label="Ground truth")
    plot!(range_plot, object_tracker.timestamp, object_tracker.range_ot, ribbon=sqrt.(object_tracker.range_var_ot),label="Object tracker and σ")
    plot!(range_plot, uwb_range.timestamp, uwb_range.range_uwb, ribbon=sqrt.(uwb_range.variance), label="Raw UWB and σ")
    
    plot!(range_error_plot, object_tracker.timestamp, object_tracker.range_gt.-object_tracker.range_ot, ribbon=sqrt.(object_tracker.range_var_ot), label="Difference and σ")
    plot!(range_error_plot, object_tracker.timestamp, MH_range, label="Mahanalobis")

    plot!(pose_error_plot, object_tracker.timestamp, E, label="L2 norm")
    plot!(pose_error_plot, object_tracker.timestamp, object_tracker.mh, label="Mahanalobis")

    plot!(height_plot, object_tracker.timestamp, object_tracker.z_gt, label="Ground truth")
    plot!(height_plot, object_tracker.timestamp, object_tracker.z_ot, label="Object tracker")
    
    plot!(trajectory_plot, object_tracker.x_gt, object_tracker.y_gt, aspect_ratio=:equal, label="Ground truth")
    plot!(trajectory_plot, object_tracker.x_ot, object_tracker.y_ot, aspect_ratio=:equal, label="Object tracker")

    pl = plot(range_plot, range_error_plot, pose_error_plot, height_plot, trajectory_plot, plot_titlefontsize=12, plot_title= "\n\rRMSE = $(@sprintf("%.2f", MSE^(1/2))), MAE = $(@sprintf("%.2f", MAE))",layout = l, size=(1000*210/297,1000), margin = 5mm)

    savefig(pl, "plot.pdf")
    # display(pl)

end

main()