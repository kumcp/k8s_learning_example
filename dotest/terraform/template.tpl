#!/bin/bash

%{ for script in script_list ~}

${script}

%{ endfor ~}