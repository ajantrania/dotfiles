# System identification
# This file identifies the current system and sets SYSTEM_TYPE variable
# Other configuration files can then use this variable to set appropriate values

# Get the hostname of the current machine
HOSTNAME=$(hostname)

# Default to personal
SYSTEM_TYPE="personal"

# Identify system type based on hostname and other characteristics
case $HOSTNAME in
    # Personal machine - you can add more patterns for your personal machines
    "home-"*|"personal-"*)
        SYSTEM_TYPE="personal"
        ;;
    # AWS work laptop - you can add more patterns for AWS work laptops
    "aws"*|"work"*)
        SYSTEM_TYPE="aws-work"
        ;;
    # Add more cases for future work laptops or systems
    *)
        # You might want to add more sophisticated detection here
        # For example, checking for specific files, environment variables, etc.
        SYSTEM_TYPE="personal"
        ;;
esac

# Export the system type so other scripts can use it
export SYSTEM_TYPE

# Optional: Print the detected system type
# echo "Detected system type: $SYSTEM_TYPE"