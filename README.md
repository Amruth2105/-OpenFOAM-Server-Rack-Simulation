# OpenFOAM Server Rack Thermal Simulation

A computational fluid dynamics (CFD) simulation of thermal airflow around a single server rack in a data center environment using **OpenFOAM 12**.

![OpenFOAM](https://img.shields.io/badge/OpenFOAM-12-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Overview

This simulation models **natural convection heat transfer** in a data center room section containing a server rack. It uses the Boussinesq approximation for buoyancy-driven flow with the k-epsilon turbulence model.

### Key Features

-  **Thermal analysis** of server rack heat dissipation
-  **Natural convection** buoyancy-driven flow
-  **Heat source modelling** via `setFields` initialisation
-  **Steady-state RANS** simulation with k-ε turbulence

## Simulation Parameters

| Parameter | Value |
|-----------|-------|
| **Domain size** | 2m × 2.5m × 1m |
| **Rack location** | Centred (0.7–1.3m × 0.1–2.1m × 0.1–0.9m) |
| **Mesh cells** | 40,000 hexahedra |
| **Solver** | `foamRun` (fluid solver, steady-state) |
| **Turbulence model** | k-epsilon (RAS) |
| **Thermodynamics** | Boussinesq approximation |

### Boundary Conditions

| Boundary | Velocity | Temperature |
|----------|----------|-------------|
| Floor | No-slip | 300 K (fixed) |
| Ceiling | No-slip | Zero gradient |
| Walls (inlet/outlet/frontAndBack) | No-slip | Zero gradient |
| Server rack zone (internal) | — | 330 K (initial via `setFields`) |

## Prerequisites

- **OpenFOAM 12** (Foundation version)
- **ParaView** for visualisation (optional)

### Installing OpenFOAM 12 on Ubuntu/WSL

```bash
# Add OpenFOAM repository
sudo sh -c "wget -O - https://dl.openfoam.org/gpg.key > /etc/apt/trusted.gpg.d/openfoam.asc"
sudo add-apt-repository http://dl.openfoam.org/ubuntu

# Install
sudo apt update
sudo apt install -y openfoam12

# Add to bashrc
echo "source /opt/openfoam12/etc/bashrc" >> ~/.bashrc
source ~/.bashrc
```

## Quick Start

```bash
# Clone the repository
git clone https://github.com/Amruth2105/-OpenFOAM-Server-Rack-Simulation.git
cd -OpenFOAM-Server-Rack-Simulation

# Run the full simulation (mesh, setFields, solve, post-process)
./Allrun

# Or run steps manually:
blockMesh          # Generate mesh
setFields          # Set initial hot zone (330 K in rack region)
foamRun            # Run solver

# View results (requires ParaView)
paraFoam
```

## File Structure

```
serverRack/
├── 0/                          # Initial & boundary conditions
│   ├── T                       # Temperature field
│   ├── U                       # Velocity field
│   ├── p                       # Pressure field
│   ├── p_rgh                   # Pressure (buoyancy-corrected)
│   ├── k                       # Turbulent kinetic energy
│   ├── epsilon                 # Turbulent dissipation rate
│   ├── nut                     # Turbulent viscosity
│   └── alphat                  # Turbulent thermal diffusivity
├── constant/                   # Physical properties
│   ├── g                       # Gravitational acceleration
│   ├── physicalProperties      # Thermophysical properties (Boussinesq)
│   └── momentumTransport       # Turbulence model settings (k-epsilon)
├── system/                     # Simulation controls
│   ├── controlDict             # Run control parameters
│   ├── fvSchemes               # Discretisation schemes
│   ├── fvSolution              # Linear solver settings
│   ├── blockMeshDict           # Mesh definition
│   ├── setFieldsDict           # Initial field setup (hot zone)
│   ├── topoSetDict             # Cell zone definitions
│   └── snappyHexMeshDict       # Detailed geometry meshing (optional)
├── Allrun                      # Run script
├── Allclean                    # Clean script
└── README.md
```

## Results

After running the simulation, results are saved in time directories (100, 200, ..., 1000).

### Expected Temperature Distribution

- **Ambient (walls)**: 300 K (27°C)
- **Hot zone (rack)**: Up to 330 K (57°C) initial, diffuses over time
- **Thermal plume**: Rising above the rack due to buoyancy

### Visualisation

Open ParaView to visualise:
- **Temperature contours** — `T` field
- **Velocity vectors** — `U` field
- **Streamlines** — Air flow patterns
- **Pressure distribution** — `p_rgh` field

## Customisation

### Increase Heat Source
Edit `system/setFieldsDict`:
```cpp
boxToCell
{
    box (0.7 0.1 0.1) (1.3 2.1 0.9);
    fieldValues ( volScalarFieldValue T 350 );  // Higher temperature
}
```

### Add Forced Ventilation
To convert from natural to forced convection:

1. Change wall patches to `type patch` in `system/blockMeshDict`:
```cpp
inlet
{
    type patch;
    ...
}
outlet
{
    type patch;
    ...
}
```

2. Set inlet velocity in `0/U`:
```cpp
inlet
{
    type            fixedValue;
    value           uniform (1 0 0);  // 1 m/s inlet
}
```

3. Update pressure BCs, turbulence BCs, etc. accordingly.

### Refine Mesh
Edit `system/blockMeshDict`:
```cpp
blocks
(
    hex (0 1 2 3 4 5 6 7) (80 100 40) simpleGrading (1 1 1)  // 2x refinement
);
```

## Physics

### Boussinesq Approximation
The density variation due to temperature is modelled as:
```
ρ = ρ₀[1 - β(T - T₀)]
```
where:
- ρ₀ = 1 kg/m³ (reference density)
- T₀ = 300 K (reference temperature)
- β = 0.003 K⁻¹ (thermal expansion coefficient)

### Turbulence Modelling
The standard k-ε model is used with wall functions for near-wall treatment.

## Troubleshooting

### Simulation Diverges
1. Increase relaxation factors in `fvSolution`
2. Reduce temperature difference
3. Check mesh quality with `checkMesh`

### Very Slow Convergence
1. Reduce relaxation factors for velocity
2. Use first-order schemes initially
3. Initialise with potentialFoam

## License

This project is open source and available under the MIT License.

## Author

Created for data centre thermal CFD analysis with OpenFOAM.

## References

- [OpenFOAM Documentation](https://openfoam.org/documentation/)
- [OpenFOAM Tutorials](https://github.com/OpenFOAM/OpenFOAM-12/tree/master/tutorials)
