#!/bin/bash

ps -ef | grep node | grep -v grep | awk '{print $2}' | xargs kill
echo 'server stopped.'
