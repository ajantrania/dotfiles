# System identification
# This file identifies the current system and sets SYSTEM_TYPE variable
# Other configuration files can then use this variable to set appropriate values

# Get the hostname of the current machine
# Use LocalHostName (from System Settings) which is more reliable on macOS
HOSTNAME=$(scutil --get LocalHostName 2>/dev/null || hostname)

# Default to personal
SYSTEM_TYPE="personal"

# Identify system type based on hostname and other characteristics
case $HOSTNAME in
    # Personal machine
    "home-"*|"personal-"*)
        SYSTEM_TYPE="personal"
        ;;
    # # AWS work laptop
    # "aws"*|"work"*)
    #     SYSTEM_TYPE="aws-work"
    #     ;;
    # Archodex Work Laptop
    "work-aj-mbp"*)
        SYSTEM_TYPE="archodex-work"
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