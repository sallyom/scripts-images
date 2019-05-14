#! /bin/bash
set -x

cleanup() {
  rm -fv terraform terraform_0.12.0-rc1_linux_amd64.zip
}
trap "cleanup" EXIT
ctr=$(buildah from alpine) || (echo "Must be root to execute buildah" && exit 1)
mnt=`buildah mount $ctr` || (echo "Must be root to execute buildah" && exit 1)
wget https://releases.hashicorp.com/terraform/0.12.0-rc1/terraform_0.12.0-rc1_linux_amd64.zip
unzip terraform_0.12.0-rc1_linux_amd64.zip
cp terraform "${mnt}/usr/bin" || exit 1
buildah unmount $ctr
buildah config $ctr
buildah commit $ctr terraform-alpine:v0.12.0-rc1
set +x
echo "to cleanup run 'podman stop [containerid from podman run]; podman rm [containerid from podman run]'"
echo "to push to docker-daemon run 'buildah push [imageID] docker-daemon:terraform-alpine:v0.12.0-rc1'"
