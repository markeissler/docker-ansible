#!/usr/bin/env bash
#
# init.sh
#
# This is a place to initialize the system by running config adjustments that
# would otherwise be run by rc.local on a real system. Once configured, we then
# call supervisord to handle the rest of our lifetime. We also run rc.local for
# compatibility since some applications might append to that file during their
# installation.
#

function legacy_runner() {
  local _my_resp _my_rslt

  if [ -f "/etc/rc.local" ]; then
    echo -n "Processing /etc/rc.local: "
    _my_resp=$({ /bin/bash "/etc/rc.local"; } 2>&1 )
    _my_rslt=$?
    if [[ ${_my_rslt} -ne 0 ]]; then
      echo "ERROR"
      echo "${_my_resp}"
      return 1
    fi
    echo "Done."
  fi

  return 0
}

function prepare_system() {
  legacy_runner
}

echo "Running system init..."

primary_ip=$(ip addr | awk '/inet/ && /eth0/{sub(/\/.*$/,"",$2); print $2}')
echo "Listening on ${primary_ip}"

prepare_system $master_ip

/usr/local/bin/supervisord -c /usr/local/etc/supervisor/supervisord.conf
