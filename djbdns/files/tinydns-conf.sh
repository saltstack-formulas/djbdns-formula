#!/bin/sh
LOCATION={{ LOCATION }}
IP={{ IP }}
mkdir -p $(dirname $LOCATION)
/usr/bin/tinydns-conf Gtinydns Gdnslog ${LOCATION} ${IP}
