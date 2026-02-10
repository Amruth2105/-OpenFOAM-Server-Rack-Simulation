# OpenFOAM Server Rack Thermal Simulation

A computational fluid dynamics (CFD) simulation of thermal airflow around a single server rack in a data center environment using **OpenFOAM 12**.

![OpenFOAM](https://img.shields.io/badge/OpenFOAM-12-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Overview

This simulation models **forced and natural convection heat transfer** in a data center room section containing a server rack. Cold air is supplied from a CRAC (Computer Room Air Conditioning) unit at the inlet, flows across the rack where it absorbs heat, and exits via the hot aisle return.

### Key Features

-  **Forced convection** — CRAC supply at 1 m/s, 290 K (17°C)
-  **Continuous heat source** — `fvOptions` keeps rack zone at 330 K
-  **Buoyancy coupling** — Boussinesq approximation for thermal plume
-  **Steady-state RANS** — k-ε turbulence with wall functions
-  **135k cell mesh** — 3× refinement over initial 40k mesh

## Domain Geometry

```
         2.0 m
    ◄────────────────►
    ┌─────────────────┐  ▲
    │    CEILING       │  │
    │   (zeroGradient) │  │
    │                  │  │
    │   ┌──────┐       │  │
    │   │SERVER│       │  │
 I  │   │ RACK │       │ O│  2.5 m
 N  │   │330 K │       │ U│  (height)
 L  │   │fvOpt │       │ T│
 E  │   │      │       │ L│
 T  │   │0.6m× │       │ E│
    │   │2.0m  │       │ T│
 →→→│   └──────┘       │→→→
 1m/s   x:0.7─1.3     │  │
 290K│                  │  │
    │    FLOOR (300 K)  │  ▼
    └─────────────────┘
         z-depth: 1.0 m (frontAndBack walls)
```

## Simulation Parameters

| Parameter | Value |
|-----------|-------|
| **Domain size** | 2m × 2.5m × 1m |
| **Rack location** | Centred (0.7–1.3m × 0.1–2.1m × 0.1–0.9m) |
| **Mesh cells** | 135,000 hexahedra (60×75×30) |
| **Solver** | `foamRun` (fluid solver, steady-state) |
| **Turbulence model** | k-epsilon (RAS) |
| **Thermodynamics** | Boussinesq approximation |
| **Heat source** | `fvOptions` fixedTemperatureConstraint (330 K) |
| **Inlet velocity** | 1 m/s (CRAC supply) |
| **Inlet temperature** | 290 K (17°C) |

### Boundary Conditions

| Boundary | Velocity | Temperature | Pressure (p_rgh) |
|----------|----------|-------------|-------------------|
| Inlet (left) | 1 m/s fixed | 290 K fixed | fixedFluxPressure |
| Outlet (right) | inletOutlet | inletOutlet | 0 Pa (reference) |
| Floor | No-slip | 300 K fixed | fixedFluxPressure |
| Ceiling | No-slip | Zero gradient | fixedFluxPressure |
| Front & Back | No-slip | Zero gradient | fixedFluxPressure |
| Server rack (internal) | — | 330 K (fvOptions) | — |

## Heat Source Modelling

The server rack heat is modelled using `fvOptions` with a `fixedTemperatureConstraint`, which keeps the rack cell zone at a constant 330 K throughout the simulation. This is more physically accurate than setting an initial temperature with `setFields` alone, as it models the continuous heat dissipation of server equipment.

The `serverRack` cell zone is created by `topoSet`, which selects all cells in the box `(0.7 0.1 0.1) (1.3 2.1 0.9)`.

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

# Run the full simulation (mesh, topoSet, setFields, solve, post-process)
./Allrun

# Or run steps manually:
blockMesh          # Generate mesh (135k cells)
checkMesh          # Verify mesh quality
topoSet            # Create serverRack cell zone
setFields          # Set initial hot zone (330 K in rack region)
foamRun            # Run solver
```

### Docker (recommended for Windows/macOS)

```bash
docker compose build
docker compose up
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
│   ├── momentumTransport       # Turbulence model settings (k-epsilon)
│   └── fvOptions               # Heat source (fixedTemperatureConstraint)
├── system/                     # Simulation controls
│   ├── controlDict             # Run control parameters
│   ├── fvSchemes               # Discretisation schemes
│   ├── fvSolution              # Linear solver settings
│   ├── blockMeshDict           # Mesh definition (135k cells)
│   ├── setFieldsDict           # Initial field setup (hot zone)
│   ├── topoSetDict             # Cell zone definitions (serverRack)
│   └── snappyHexMeshDict       # Detailed geometry meshing (optional)
├── Allrun                      # Run script
├── Allclean                    # Clean script
└── README.md
```

## Results

After running the simulation, results are saved in time directories (100, 200, ..., 1000).

### Expected Thermal Behaviour

- **Inlet supply**: 290 K (17°C) from CRAC unit
- **Server rack**: Maintained at 330 K (57°C) by fvOptions
- **Return air**: Heated air exits through outlet at elevated temperature
- **Thermal plume**: Buoyancy-driven upward flow above the rack
- **Floor**: Isothermal at 300 K (27°C)

### Visualisation

Open ParaView to visualise:
- **Temperature contours** — `T` field
- **Velocity vectors** — `U` field
- **Streamlines** — Air flow patterns from inlet to outlet
- **Pressure distribution** — `p_rgh` field

```bash
# View results (requires ParaView)
paraFoam
```

## Customisation

### Change Heat Source Temperature
Edit `constant/fvOptions`:
```cpp
serverRackHeatSource
{
    type            fixedTemperatureConstraint;
    selectionMode   cellZone;
    cellZone        serverRack;
    mode            uniform;
    temperature     350;    // Higher temperature
}
```

### Change Inlet Conditions
Edit `0/U` and `0/T`:
```cpp
// In 0/U - increase CRAC supply velocity
inlet
{
    type            fixedValue;
    value           uniform (2 0 0);  // 2 m/s inlet
}

// In 0/T - change supply temperature
inlet
{
    type            fixedValue;
    value           uniform 285;  // Colder supply (12°C)
}
```

### Refine Mesh
Edit `system/blockMeshDict`:
```cpp
blocks
(
    hex (0 1 2 3 4 5 6 7) (80 100 40) simpleGrading (1 1 1)  // ~320k cells
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

### Forced + Natural Convection
The simulation combines:
- **Forced convection**: CRAC supply drives air at 1 m/s across the domain
- **Natural convection**: Buoyancy (Boussinesq) creates thermal plumes above the rack

The Richardson number (Ri ≈ gβΔTL/U²) indicates the relative importance of buoyancy vs. inertia.

## Troubleshooting

### Simulation Diverges
1. Increase relaxation factors in `fvSolution`
2. Reduce temperature difference or inlet velocity
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
