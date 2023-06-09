#!/usr/bin/env julia

using Printf
using CSV
using DataFrames

function trajectory(t)
    x = 0
    y = 65 + 55*sin(2*pi*t)
    z = 5

    return x, y, z
end

function trajectory(t)
    r = 10

    x = r*cos(2*pi*t + 1*pi)
    y = r*sin(2*pi*t + 1*pi)
    z = 5

    return x, y, z
end

# function trajectory(t)
#     r = 20/(sqrt(2)* (abs(sin(2*pi*t+pi/4 + pi)) + abs(cos(2*pi*t+pi/4 + pi))))

#     x = r*cos(2*pi*t + pi)
#     y = r*sin(2*pi*t + pi)
#     z = 5

#     return x, y, z
# end

global data = DataFrame(
    x = Float32[],
    y = Float32[],
    z = Float32[],
    heading = Float32[]
)

function main()
    push!(data.heading, 0)
    t = LinRange(0, 1, 800)

    for i in t
        x, y, z = trajectory(i)
        push!(data.x, x)
        push!(data.y, y)
        push!(data.z, z)
    end

    for i in 2:length(data.x)
        x_diff = data.x[i] - data.x[i-1]
        y_diff = data.y[i] - data.y[i-1]

        a = atan(y_diff, x_diff)

        push!(data.heading, a)
    end

    data.heading[1] = data.heading[2]

    CSV.write("circle_inverted.txt", data, header=false)

    return
end

main()