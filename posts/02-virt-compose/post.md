---
title: virt-compose
published: false
description: Declarative virtual machine management
tags: tooling, virtualization
cover_image: https://raw.githubusercontent.com/rikyiso01/blog/main/posts/02-virt-compose/images/libvirt-compose.jpg
---

## Introduction

I really like containers but sometimes a virtual machine is necessary for certain jobs.
For example when I need to test my arch installation script I need to use a virtual machine
to see if the installation process completes successfully.
But, I find virtual machines harder to maintain than containers due to their primarily
imperative tools.
I like qemu for its wide range support, but I don't like its defaults and flags for achieving
greater performances.
I like libvirt for its abstraction over virtualization solutions, but I find its cli, virsh,
hard to use.
Also, when deploying complex scenarios, these tools become harder to use due to their
targeting single machines.
I want a solution that helps you from building images to running them in a declarative
way from the cli.

## Inspiration

- [quickemu](https://github.com/quickemu-project/quickemu): It doesn't support automated
    installations

## Idea

Create a docker-compose like command-line application that allows to easily build and
deploy virtual machines on libvirt.

## Implementation

### Format

For the compose file which defines the sets of virtual machines, I have decided to use a
format similar to a docker-compose.yml:

```yaml
machines:
  nixos:
    image: nixos
    memory: 4096
    os-variant: nixos
    boot:
      firmware: efi
      loader_secure: false

images:
  nixos:
    packerfile: ./nixos.yml
    output: ./build/nixos
```

### Building an image

For building, I have decided to use packer since it has a lot of examples available online for
building common images.
However, I don't like the hcl file format due to the limited amount of tooling available for
it, so I have decided to use the [json configuration syntax](https://developer.hashicorp.com/packer/docs/templates/hcl_templates/syntax-json).
Since I like yaml more than json and since packer [doesn't support](https://github.com/hashicorp/packer/issues/4200) it natively, the program
firstly converts the yaml to a temporary json and then executes packer.

Example:

```yaml
packer:
  required_plugins:
    qemu:
      version: ">=1.1.0"
      source: "github.com/hashicorp/qemu"

source:
  qemu:
    nixos:
      disk_size: "60G"
      memory: 8192
      format: "qcow2"
      accelerator: "kvm"
      ssh_timeout: "2m"
      vm_name: "nixos"
      net_device: "virtio-net"
      disk_interface: "virtio"
      efi_boot: false
      communicator: "ssh"
      boot_key_interval: "10ms"
      boot_keygroup_interval: "10ms"

build:
  - name: step1
    source:
      "source.qemu.nixos":
        iso_url: "https://releases.nixos.org/nixos/24.11/nixos-24.11.715908.7105ae395770/nixos-minimal-24.11.715908.7105ae395770-x86_64-linux.iso"
        iso_checksum: "sha256:659a056261404810703188b986b818a723fd0bcf650e58c1ea9857086612822a"
        output_directory: "build"
        ssh_username: "nixos"
        boot_wait: "1s"
        shutdown_command: "sudo poweroff"
        boot_command:
          - "<return><wait30>mkdir .ssh<return>echo '{{ .SSHPublicKey }}' > .ssh/authorized_keys<return>"
    provisioner:
      - file:
          source: nix
          destination: /tmp/nix
      - shell:
          inline:
            - ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
            - cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
            - cd /tmp/nix && nix --extra-experimental-features 'nix-command flakes' run nixpkgs#nixos-anywhere -- --flake .#nix --generate-hardware-config nixos-generate-config ./hardware-configuration.nix --target-host 127.0.0.1 --phases kexec,disko,install
```

## Source code

I have published a prototype for this on [GitHub](https://github.com/rikyiso01/virt-compose)
It is possible to run it using nix with:
```bash
nix -- run github:rikyiso01/virt-compose up
```

## Conclusions

I like having a set of files for easily setting up and running virtual machines, I am using
this prototype since some months and I find it very useful for testing local setups and
home servers.
I will continue in the future to use it and fix bugs until I find a use case which isn't easily covered
by this approach.
