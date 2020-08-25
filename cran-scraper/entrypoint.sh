#!/bin/bash -l
set -e
Rscript -e "universe::cran_registry_update_json()"
echo "Action complete!"
