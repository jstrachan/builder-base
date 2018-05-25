#!/usr/bin/env bash
set -e
set -u

# ensure we're not on a detached head
git checkout master

# until we switch to the new kubernetes / jenkins credential implementation use git credentials store
git config credential.helper store

export VERSION="$(jx-release-version)"
echo "Releasing version to ${VERSION}"

# build all the base images and generate the Dockerfile
export PUSH="true"
$(dirname $0)/build-images.sh

docker tag docker.io/$ORG/$APP_NAME:${VERSION} docker.io/$ORG/$APP_NAME:latest

docker push docker.io/$ORG/$APP_NAME:${VERSION}
docker push docker.io/$ORG/$APP_NAME:latest

#jx step tag --version ${VERSION}
git tag -fa v${VERSION} -m "Release version ${VERSION}"
git push origin v${VERSION}

updatebot push-version --kind docker jenkinsxio/builder-base ${VERSION} jenkinsxio/builder-ruby ${VERSION} jenkinsxio/builder-swift ${VERSION}
updatebot push-version --kind helm jenkinsxio/builder-base ${VERSION} jenkinsxio/builder-ruby ${VERSION} jenkinsxio/builder-swift ${VERSION}

updatebot update-loop
