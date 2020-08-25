#!/bin/bash -l
set -e
Rscript -e "universe::cran_registry_as_json()"
echo "Action complete!"
