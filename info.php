<?php phpinfo(); ?>

docker run -it --rm  -v /tmp/envbuilder:/workspaces   -e ENVBUILDER_GIT_URL=https://github.com/coder/envbuilder-starter-devcontainer  -e ENVBUILDER_INIT_SCRIPT=bash    ghcr.io/coder/envbuilder