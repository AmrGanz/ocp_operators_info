# Introduction:

This tool helps you extract OpenShift Operators' metadata when it comes to getting details about the default channel and other avaialble channels:

```
[root]# head script.sh
#!/bin/bash

MYWORKDIR="/var/tmp/operators-extracted-data"
IMAGE="registry.redhat.io/redhat/certified-operator-index:v4.15"
...

[root]# ./script.sh
 >> CLEANING UP OLD USED DIRECTORIES (if exists) 

=============================================================================================================================================================

 >> Trying to pull the target image if not already downloaded 


/// Image Details /// 
Image Name          = registry.redhat.io/redhat/certified-operator-index:v4.15
Image Id            = b2f2e75f53ca46bd4e9ed00d171e7ad6f3c5e38b240fc118dc5d2a4a3c061403
Image Digest        = sha256:c44f70c1d4919b5a4edf21148cc528e43fbfbcd86195441b6fb64b14529b2a5b
Image Creation Time = 2024-05-24T14:35:08.663382423Z

=============================================================================================================================================================

 >> Trying to start a temporary container from the provided image 

=============================================================================================================================================================

 >> Extracting Operators data from the temporary container 

=============================================================================================================================================================

 >> Building up the Operators data map file 

Operators data is saved under /var/tmp/operators-extracted-data/operators-data.txt

NAME                                         DEFAULT_CHANNEL  OTHER_CHANNELS
abinitio-runtime-operator                    release-4.3      stable
accuknox-operator-certified                  alpha
aci-containers-operator                      stable
aikit-operator                               alpha
ako-operator                                 stable           alpha              beta
alloy                                        alpha
anchore-engine                               alpha
anzograph-operator                           stable
anzo-operator                                stable
anzounstructured-operator                    stable
appdynamics-cloud-operator                   alpha
appdynamics-operator                         alpha
aqua-operator-certified                      2022.4
bookkeeper-operator                          alpha            beta               stable
cass-operator                                stable
ccm-node-agent-dcap-operator                 alpha
ccm-node-agent-operator                      alpha
cilium                                       1.15             1.10               1.11           1.12           1.13           1.14           1.9            stable
cilium-enterprise                            1.15             1.10               1.11           1.12           1.13           1.14
citrix-adc-istio-ingress-gateway-operator    alpha
citrix-cpx-istio-sidecar-injector-operator   alpha
citrix-cpx-with-ingress-controller-operator  stable           alpha
citrix-ingress-controller-operator           stable           alpha
cloudbees-ci                                 alpha
cloudnative-pg                               stable-v1
...
```

# Time consumption compared to using "oc-mirror" tool to get a similar output:

```
[root]# time ./script.sh
...
real	1m18.085s
user	1m5.313s
sys	0m13.547s


[root]# time oc-mirror list operators --catalog registry.redhat.io/redhat/redhat-operator-index:v4.14
...
real	6m34.951s
user	3m49.470s
sys	1m21.049s
```

# Prerequistes:
    - Please edit the script and manually add the target image's name (check the notes section below).
    - The script relys on extra tools/commands, so make sure they are installed prior to running the script:
        > podman
        > column
        > jq
    - The Operators index image is being pulled from `registry.redhat.io` registry which requires authentication

# Notes:
    - This script assumes that the operators index image is using file-based catalog format which is the default starting OCP 4.11, hence it will give errors if used with operators index image for OCP vsersions < 4.11.
