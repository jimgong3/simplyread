#!/bin/bash

# start node server
nohup node index.js >/dev/null 2>&1 &
echo 'node server started.'

# start http-server
nohup http-server >/dev/null 2>&1 &
echo 'http server started.'
