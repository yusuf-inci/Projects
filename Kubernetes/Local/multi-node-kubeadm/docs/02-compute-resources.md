# Provisioning Compute Resources

Note: You must have VirtualBox and Vagrant configured at this point

Download this github repository and cd into the vagrant folder

```bash
git clone https://github.com/kodekloudhub/certified-kubernetes-administrator-course.git
```

CD into the virtualbox directory

```bash
cd kubeadm-clusters/virtualbox
```

Run Vagrant up

```bash
vagrant up
```


This does the below:

- Deploys 3 VMs - 1 Master, 2 Worker
    > These are the default settings. This can be changed at the top of the Vagrant file.
    > If you choose to change these settings, please also update vagrant/ubuntu/vagrant/setup-hosts.sh
    > to add the additional hosts to the /etc/hosts default before running "vagrant up".

- Set's IP addresses in the range 192.168.56

    | VM            |  VM Name               | Purpose       | IP            | Forwarded Port   | RAM  |
    | ------------  | ---------------------- |:-------------:| -------------:| ----------------:|-----:|
    | kubemaster    | kubemaster             | Master        | 192.168.56.11 |     2711         | 2048 |
    | kubenode01    | kubenode01             | Worker        | 192.168.56.21 |     2721         | 1024 |
    | kubenode02    | kubenode02             | Worker        | 192.168.56.22 |     2722         | 1024 |

    > These are the default settings. These can be changed in the Vagrant file

- Adds a DNS entry to each of the nodes to access internet
    > DNS: 8.8.8.8

See [Vagrantfile](../Vagrantfile) for details.

## SSH to the nodes

There are two ways to SSH into the nodes:

### 1. SSH using Vagrant

  From the directory you ran the `vagrant up` command, run `vagrant ssh <vm>` for example `vagrant ssh master-1`.

  This is the easiest way as it requires no configuration.

### 2. SSH Using SSH Client Tools

Use your favourite SSH Terminal tool (PuTTY/MobaXTerm etc.).

Use the above IP addresses. Username and password based SSH is disabled by default.
Vagrant generates a private key for each of these VMs. It is placed under the .vagrant folder (in the directory you ran the `vagrant up` command from) at the below path for each VM:

**Private Key Path:** `.vagrant/machines/<machine name>/virtualbox/private_key`

**Username/Password:** `vagrant/vagrant`


## Verify Environment

- Ensure all VMs are up
- Ensure VMs are assigned the above IP addresses
- Ensure you can SSH into these VMs using the IP and private keys, or `vagrant ssh`
- Ensure the VMs can ping each other

## Troubleshooting Tips

### Failed Provisioning

If any of the VMs failed to provision, or is not configured correct, delete the VM using the command:

```bash
vagrant destroy <vm>
```

Then re-provision. Only the missing VMs will be re-provisioned

```bash
vagrant up
```


Sometimes the delete does not delete the folder created for the VM and throws an error similar to this:

VirtualBox error:

    VBoxManage.exe: error: Could not rename the directory 'D:\VirtualBox VMs\ubuntu-bionic-18.04-cloudimg-20190122_1552891552601_76806' to 'D:\VirtualBox VMs\kubernetes-ha-worker-2' to save the settings file (VERR_ALREADY_EXISTS)
    VBoxManage.exe: error: Details: code E_FAIL (0x80004005), component SessionMachine, interface IMachine, callee IUnknown
    VBoxManage.exe: error: Context: "SaveSettings()" at line 3105 of file VBoxManageModifyVM.cpp

In such cases delete the VM, then delete the VM folder and then re-provision, e.g.

```bash
vagrant destroy kubenode02
rmdir "<path-to-vm-folder>\kubenode02
vagrant up
```

### Provisioner gets stuck

This will most likely happen at "Waiting for machine to reboot"

1. Hit `CTRL+C`
1. Kill any running `ruby` process, or Vagrant will complain.
1. Destroy the VM that got stuck: `vagrant destroy <vm>`
1. Re-provision. It will pick up where it left off: `vagrant up`

# Pausing the Environment

You do not need to complete the entire lab in one session. You may shut down and resume the environment as follows, if you need to power off your computer.

To shut down. This will gracefully shut down all the VMs in the reverse order to which they were started:

```
vagrant halt
```

To power on again:

```
vagrant up
```

Prev: [Prerequisites](./01-prerequisites.md)<br>
Next: [Connectivity](./03-connectivity.md)