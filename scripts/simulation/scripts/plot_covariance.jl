using Plots; gr()
using LinearAlgebra

function plot_3d_covariance(mean, cov, std=1.,
                       ax=nothing, title=nothing,
                       color=nothing, alpha=1.,
                       label_xyz=true,
                       N=60,
                       shade=true,
                       limit_xyz=true
                       )
    """
    Plots a covariance matrix `cov` as a 3D ellipsoid centered around
    the `mean`.
    Parameters
    ----------
    mean : 3-vector
        mean in x, y, z. Can be any type convertable to a row vector.
    cov : ndarray 3x3
        covariance matrix
    std : double, default=1
        standard deviation of ellipsoid
    ax : matplotlib.axes._subplots.Axes3DSubplot, optional
        Axis to draw on. If not provided, a new 3d axis will be generated
        for the current figure
    title : str, optional
        If provided, specifies the title for the plot
    color : any value convertible to a color
        if specified, color of the ellipsoid.
    alpha : float, default 1.
        Alpha value of the ellipsoid. <1 makes is semi-transparent.
    label_xyz: bool, default True
        Gives labels 'X', 'Y', and 'Z' to the axis.
    N : int, default=60
        Number of segments to compute ellipsoid in u,v space. Large numbers
        can take a very long time to plot. Default looks nice.
    shade : bool, default=True
        Use shading to draw the ellipse
    limit_xyz : bool, default=True
        Limit the axis range to fit the ellipse
    **kwargs : optional
        keyword arguments to supply to the call to plot_surface()
    """


    # force mean to be a 1d vector no matter its shape when passed in
    mean = reshape(mean, (3, 1))

    # force covariance to be 3x3 np.array
    cov = reshape(cov, (3, 3))

    # The idea is simple - find the 3 axis of the covariance matrix
    # by finding the eigenvalues and vectors. The eigenvalues are the
    # radii (squared, since covariance has squared terms), and the
    # eigenvectors give the rotation. So we make an ellipse with the
    # given radii and then rotate it to the proper orientation.

    eig = eigen(cov, sortby = x -> +x)
    eigval = eig.values
    eigvec = eig.vectors

    radii = std * sqrt.(real.(eigval))

    if eigval[1] < 0
        return
    end


    # calculate cartesian coordinates for the ellipsoid surface
    u = LinRange(0.0, 2.0*pi, N)
    v = LinRange(0.0, pi, N)
    x = radii[1] * (cos.(u) * sin.(v)') 
    y = radii[2] * (sin.(u) * sin.(v)') 
    z = radii[3] * (ones(size(u)) * cos.(v)') 

    
    # rotate data with eigenvector and center on mu
    a = kron(eigvec[:, 1], x)'
    b = kron(eigvec[:, 2], y)'
    c = kron(eigvec[:, 3], z)'
    
    data = a + b + c

    N = size(data)[1]
    x = data[:,   1:N]   .+ mean[1]
    y = data[:,   (N+1):(N*2)] .+ mean[2]
    z = data[:,   (N*2+1):end]    .+ mean[3]


    pl = surface(
        x, y, z, c=:viridis, legend=:none,
        nx=3, ny=3 # <-- series[:extra_kwargs]
      )

    if limit_xyz == true
        r = maximum(radii)
        xlims!(pl, -r + mean[1], r + mean[1])
        ylims!(pl, -r + mean[2], r + mean[2])
        zlims!(pl, -r + mean[3], r + mean[3])
    end

    xlabel!(pl, "x")
    ylabel!(pl, "y")
    zlabel!(pl, "z")


    # fig = plt.gcf()
    # if ax is None:
    #     ax = fig.add_subplot(111, projection='3d')

    # ax.plot_surface(x, y, z,
    #                 rstride=3, cstride=3, linewidth=0.1, alpha=alpha,
    #                 shade=shade, color=color, **kwargs)

    # # now make it pretty!

    # if label_xyz:
    #     ax.set_xlabel('X')
    #     ax.set_ylabel('Y')
    #     ax.set_zlabel('Z')



    # if title is not None:
    #     plt.title(title)

    # #pylint: disable=pointless-statement
    # Axes3D #kill pylint warning about unused import

    return pl
end


m = [0, 0, 0]

covariance = [1. 0. 0.;
                0. 1. 0.;
                0. 0. 1.]

pl = plot_3d_covariance(m, covariance)

display(pl)