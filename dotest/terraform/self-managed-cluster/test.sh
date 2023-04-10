#!/bin/bash

while [[ ! \"$a\" == */kubeadm* ]]; do a=$(which kubeadm); sleep 5; done 

NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-75675f5897   3         3         3       18s
