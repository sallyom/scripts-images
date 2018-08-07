#! /bin/bash
set -x

ctr=$(buildah from scratch)
mnt=`buildah mount $ctr`
dnf install -y --installroot=$mnt mongoose --releasever=27 --disablerepo=* --enablerepo=fedora --enablerepo=updates
dnf clean all --installroot=$mnt
buildah unmount $ctr
buildah config --entrypoint=/usr/bin/mongoose $ctr
buildah commit $ctr mongoose-test
contID=`podman run -td mongoose-test`
ipAddress=`podman inspect $contID | awk -F  ":" '/IPAddress\"/ {print $2}' | sed 's/"//g' | sed 's/,//g'`
curl $ipAddress:8080
set +x
echo "run 'podman exec -it $contID /bin/bash' to see what's in this container"
echo "to cleanup run 'podman stop $contID; podman rm $contID'"
