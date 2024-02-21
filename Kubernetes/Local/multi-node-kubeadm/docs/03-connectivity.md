# Connectivity

First identify a system from where you will perform administrative tasks, such as creating certificates, kubeconfig files and distributing them to the different VMs.

If you are on a Linux laptop, then your laptop could be this system. In my case I chose the `kubemaster` node to perform administrative tasks. Whichever system you chose make sure that system is able to access all the provisioned VMs through SSH to copy files over.

## Access all VMs

Here we create an SSH key pair for the `vagrant` user who we are logged in as. We will copy the public key of this pair to both workers to permit us to use password-less SSH (and SCP) to get from `kubemaster` to these other nodes in the context of the `vagrant` user which exists on all nodes.

Generate Key Pair on `kubemaster` node

[//]: # (host:kubemaster)

```bash
ssh-keygen
```

Leave all settings to default (just press ENTER at any questions).

Add this key to the local authorized_keys (`kubemaster`)

Copy the key to the other hosts. For this step please enter `vagrant` where a password is requested.

The option `-o StrictHostKeyChecking=no` tells it not to ask if you want to connect to a previously unknown host. Not best practice in the real world, but speeds things up here.

```bash
ssh-copy-id -o StrictHostKeyChecking=no vagrant@kubenode01
ssh-copy-id -o StrictHostKeyChecking=no vagrant@kubenode02
```

For each host, the output should be similar to this. If it is not, then you may have entered an incorrect password. Retry the step.

```
Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'vagrant@kubenode01'"
and check to make sure that only the key(s) you wanted were added.
```


Prev: [Compute Resources](02-compute-resources.md)<br>
Next: [Node Setup](./04-node-setup.md)
