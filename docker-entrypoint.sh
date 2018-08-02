#!/usr/bin/env bash
#
# docker-entrypoint.sh for auth_manager app
#
configApp() {
    printf "%s\n" "-> Configuring app..."

    # add app config here

    printf "%s\n\n" "-> App configured"
}

configPostgres() {
    printf "%s\n" "-> Configuring database..."

    # add database config here

    printf "%s\n\n" "-> Database configured"
}

configVolumes() {
    #
    # Setup volume permissions
    #
    printf "%s\n" "-> Setting volume permissions..."
    for f in "${BUILD_HOME}/.locks"; do
        [[ -d "${f}" ]] && sudo chown "${BUILD_USER}:${BUILD_USER}" "${f}"
    done
    printf "%s\n" "-> Volume permissions set"
}

configLinks() {
    printf "%s\n" "-> Creating symlinks..."

    # add symlink configs

    printf "%s\n" "-> Symlinks created"
}

#
# Check if app is mounted in source before continuing
#
printf "\n%s\n" "Checking configuration..."
if ! [[ -f "${BUILD_ROOT}/ansible.cfg" ]]; then
    printf "\n%s\n" "-> App not found!"
cat <<- EOF

You must start this container with the app mounted in the working directory:

    ${BUILD_ROOT}

Refer to the dockerfiles/DOCKER.md file documentation for help.

EOF
    exit 1
fi

#
# Configure
#
printf "%s\n" "-> App found. Configuring..."

# always run in app source directory!
cd "${BUILD_ROOT}" 2>&1 > /dev/null

# check for previously initialized environment
if [[ ! -f "${BUILD_LOCK}/.bootstrap.lock" ]]; then
    touch "${BUILD_LOCK}/.bootstrap.lock"
    configVolumes
    configApp
    configPostgres
    configLinks
fi

printf "%s\n\n" "Configuration finished"

#
# Run command (usually starts the target app)
#

# run any other command passed on cli
exec "$@"
