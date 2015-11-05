#!/bin/bash

set -ev

COMMIT_TITLE="$(git log -1 --pretty='%s')"
DEPLOY_BRANCH="${DEPLOY_BRANCH:-blue}"

eval "$(ssh-agent -s)"
openssl aes-256-cbc -K $encrypted_bc17f26e8500_key -iv $encrypted_bc17f26e8500_iv -in .travis.id_rsa.enc -out .travis.id_rsa -d
chmod 0600 .travis.id_rsa
ssh-add .travis.id_rsa

mkdir deploy-images
pushd deploy-images
    git clone -b "${DEPLOY_BRANCH}" git@github.com:DevelBoard/images.git .
    git config user.email "noreply@develer.com"
    git config user.name "Develer Bot"

    cp ../buildroot/output/images/{*.bin,*.dtb,zImage} ./
    git add -A .

    cat > .commit-message <<EOF
${COMMIT_TITLE}

Images built automatically from https://github.com/${TRAVIS_REPO_SLUG}/commits/${TRAVIS_COMMIT}
EOF
    git commit -F .commit-message

    git push origin "${DEPLOY_BRANCH}"
popd
