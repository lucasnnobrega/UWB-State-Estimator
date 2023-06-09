module UT

using LinearAlgebra
using Plots

function compute_sigma_pts(x, P, α=1e-3, β=2, κ=0)
    n = size(x)[1]
    x = reshape(x, (n, 1))
    P = reshape(P, (n, n))

    w = 2 * n + 1
    λ = α^2 * (n + α) - n

    U = sqrt((λ + n) * P)

    sigma = zeros(Float64, n, w)

    c = 0.5 / (n + λ)

    Wm = fill(c, (w, 1))
    Wc = fill(c, (w, 1))

    Wc[1] = λ / (n + λ) + (1 - α^2 + β)
    Wm[1] = λ / (n + λ)

    σ = zeros(Float64, w, n)
    for i in 1:w
        σ[i, :] = x'
    end
    σ[2:1+n, :] .+= U
    σ[2+n:end, :] .-= U

    return σ, Wm, Wc
end

export compute_sigma_pts

pose = [10, 1, 2]
cov = [1 0 0;
        0 1 0;
        0 0 1]

σ, Wm, Wc = UT.compute_sigma_pts(pose, cov)


@. σ ^= 2 
σ = sum(σ, dims=2)
@. σ ^= 1/2

println(sum(Wm))
println(size(Wm))
println(size(σ))

μ = Wm'*σ
Σ = zeros(Float64, (1,1))

for (index, value) in enumerate(Wc)
    @. Σ += value*(σ[index, :] - μ)*(σ[index, :] - μ)'
end

println(μ)
println(Σ)

end