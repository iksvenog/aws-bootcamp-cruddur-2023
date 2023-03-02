#!/bin/bash
# runs the starting frontend task
docker run --rm -it -p 3000:3000 -d frontend-react-js:latest npm start
