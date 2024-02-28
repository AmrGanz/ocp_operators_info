- Please edit the script file to manually add the target image's name.
- The script relys on extra tools/commands, so make sure they are installed prior to running the script:
    > podman, column, jq
- The Operators index image is being pulled from `registry.redhat.io` registry which requires authentication

**Note:**
- This script assumes that the operators index image is using file-based catalog format which is the default starting OCP 4.11, hence it will give errors if used with operators index image for OCP vsersions < 4.11.
