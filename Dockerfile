# OpenFOAM 12 Docker container for Server Rack Thermal Simulation
# Uses the official OpenFOAM Foundation image

FROM openfoam/openfoam12-graphical-apps:latest

# Set working directory
WORKDIR /home/openfoam/serverRack

# Copy case files with correct ownership
COPY --chown=openfoam:openfoam 0/ ./0/
COPY --chown=openfoam:openfoam constant/ ./constant/
COPY --chown=openfoam:openfoam system/ ./system/
COPY --chown=openfoam:openfoam Allrun Allclean ./

# Make scripts executable
RUN chmod +x Allrun Allclean

# Switch to openfoam user
USER openfoam

# Default command - run the simulation
CMD ["./Allrun"]
