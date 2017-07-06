#!/bin/sh

set -e

USAGE="""
init.sh - kubeadm-nspawn master node init script
--version <ver>\tlets kubeadm retrieve the control plain with version ver >= 1.6.0
"""

if [ "$1" = "--version" ]; then
	K8S_VERSION=$2
else
	echo $USAGE
	exit
fi

set -x

KUBEADM_NSPAWN_TMP=/tmp/kubeadm-nspawn

kubeadm reset
systemctl start kubelet.service

kubeadm init --skip-preflight-checks --config /etc/kubeadm/kubeadm.yml --kubernetes-version=${K8S_VERSION}
kubeadm token generate > ${KUBEADM_NSPAWN_TMP}/token
kubeadm token create $(cat ${KUBEADM_NSPAWN_TMP}/token) --description 'kubeadm-nspawn bootstrap token' --ttl 0

kubectl apply -f https://git.io/weave-kube-1.6

install /etc/kubernetes/admin.conf ${KUBEADM_NSPAWN_TMP}/kubeconfig
