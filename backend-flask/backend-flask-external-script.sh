#!/bin/bash
# runs the starting backend task
docker run --rm -p 4567:4567 -it -e FRONTEND_URL='*' -e BACKEND_URL='*' backend-flask:latest python3 -m flask run --host=0.0.0.0 --port=4567
