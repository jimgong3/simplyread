#!/bin/bash

nohup node app.js >/dev/null 2>&1 &
echo 'server started.'
