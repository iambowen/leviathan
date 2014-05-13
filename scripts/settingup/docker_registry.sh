#!/bin/bash
yum install docker-io -y && docker run -p 5000:5000 registry &
