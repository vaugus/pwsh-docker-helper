# DockerHelper PowerShell Module

[![Github Actions](https://github.com/vaugus/pwsh-docker-helper//actions/workflows/ci.yaml/badge.svg)](https://github.com/vaugus/pwsh-docker-helper/actions/workflows/ci.yaml)


#### Table of Contents

* [Overview](#overview)
* [Installation and Setup](#installation-and-setup)
* [Correctness](#correctness)
* [Room for improvement](#room-for-improvement)
* [Legal and Licensing](#legal-and-licensing)

----------

## Overview

This repository contains a PowerShell module named `DockerHelper` and a simple Fibonacci script with a Dockerfile as usage example. At a very high level, the module consists of the following Cmdlets:

1. **Build-DockerImage**: builds a Docker image from the $Dockerfile with a name $Tag on a remote host $ComputerName, where Docker is installed. If $ComputerName is omitted cmdlet is executed locally. 

- Mandatory parameters:

    - -Dockerfile `<String>`: path to a Dockerfile, which is used for building an image
    - -Tag `<String>`: Docker image name
    - -Context `<String>`: path to Docker context directory

- Optional parameters:

    - -ComputerName `<String>`: name of a computer, where Docker is installed
    - -Port `<Int.32>`: 

2. **Copy-Prerequisites**: copies files and/or directories from $Path on a local machine to $ComputerName local $Destination directory (these files could be required by some Dockerfiles). It assumes you have admin access to a remote host and you are able to use admin shares.

- Mandatory parameters:

    - -ComputerName `<String>`: name of a remote computer
    - -Path `<String[]>`: local path(s) where to copy files from
    - -Destination `<String>`: local path on a remote host where to copy files

- Optional parameters:
    - -SessionProperties `<System.Collections.Hashtable>`: in order to copy files to a remote host, this parameter should be a map with the following keys:

    ```shell
        $sessionProperties = @{
          "Port" = 2222
          "UserName" = "root"
          "KeyFilePath" = "/local/path/to/private/key"
        }
    ```
    
3. **Run-DockerContainer**: run container on a remote host. If $ComputerName is omitted, this cmdlet is executed locally. 

- Mandatory parameters:

    - -ImageName `<String>`

- Optional parameters:

    - -ComputerName `<String>`
    - -DockerParams `<String[]>`
    - -Port `<Int.32>`
    - -Command `<String>`

- Returns the container name as string

This module was built on top of version 7.4.1 of PowerShell for Linux.

----------

## Installation and Setup

Run the following command in a PowerShell script or in the terminal. It's necessary to navigate to the root directory of this repository.

```shell
Import-Module ./src/DockerHelper
```

----------

## Correctness

Each Cmdlet is tested with the [Pester](https://pester.dev/) framework. There is a simple "remote server" built on top of the [Docker in Docker (dind) image](https://hub.docker.com/layers/library/docker/dind/images/sha256-c84968d89ea608b1c71c19f27346b6e4b215544c82a5825940073b454c3fc598?context=explore) that is used for testing the remote execution of the Cmdlets. To run the unit tests, run the following command in a terminal:

```shell
pwsh run_tests.ps1
```

There is also a test to assess the correctness of the remote server itself - the "smoke" test. It's disabled by default because it may interfere with the docker container engine.

----------

## Room for improvement

There are some known limitations and future improvements, e.g.:

- There are optional parameters such as `SessionProperties` that are not really optional if you want to run the `Copy-Prerequisites` Cmdlet remotely.
- There are `begin` and `end` blocks in the Cmdlets that may be deduplicated in some sort of "wrapper", a new block that may receive the `process` block content and execute it.
- The remote server user is currently `root` - not the most secure approach, even for testing.
- Cmdlet naming may be improved and can be compliant with Powershell accepted verbs.
- Code Coverage and reports may be improved.


----------

## Legal and Licensing

This project is licensed under the [MIT license](LICENSE).
