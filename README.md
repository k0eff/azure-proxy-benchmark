# A proxy benchmark in Azure environment

## What is it and how it works?


Currently in the repo we have the following setup:

- a Kubernetes Cluster - to host our reverse proxies and stuff
- a VM - to connect to and execute tests against the reverse proxies in the K8s Cluster

The k8s cluster is provisioned with 3 deployments and their corresponding configuration and services:

- Apache serves as a static http server (simulating a quick API response)
- Nginx and Envoy are set up to reverse proxy to the Apache server

The VM is provisioned with the following benchmarking tools:
- 

In order to initiate a test, you need to consider a few things:

The services defined are NodePort services, so in order for anyone to connect to the reverse proxies, at least 1 node ip needs to be found out. 

```
➜  azure-proxy-benchmark git:(main) kubectl get nodes -o wide
NAME                              STATUS   ROLES   AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
aks-aksnp00-43011376-vmss000000   Ready    agent   30h   v1.21.9   10.0.64.4     <none>        Ubuntu 18.04.6 LTS   5.4.0-1073-azure   containerd://1.4.12+azure-3
aks-aksnp01-39269963-vmss000000   Ready    agent   29h   v1.21.9   10.0.64.35    <none>        Ubuntu 18.04.6 LTS   5.4.0-1073-azure   containerd://1.4.12+azure-3
```
So, the node ip we’d use is: `10.0.64.35`

(to connect to the k8s cluster, please use the kubeconfig output (shown below) and consider removing the heredoc tags in the beginning and end of the output string. I.e. `terraform output kubeconfig > ~/.kube/config-azure-proxy-test`

Then we connect to the VM. To do so, we need to find out the IP of the VM:
```
➜  azure-proxy-benchmark git:(main) terraform output
clientCertificate = <sensitive>
kubeconfig = <sensitive>
kubeconfigTf = <sensitive>
vmIpPriv = "10.0.1.4"
vmIpPub = "104.45.94.206"
```
Then:
```
~   ssh vm1user@104.45.94.206 -p 22 -i ~/.ssh/key -o StrictHostKeyChecking=no
```
( In order to change the ssh key, please generate a new one and change /vm.tf:60 https://github.com/k0eff/azure-proxy-benchmark/blob/f690f8d90bf535bd35ad5d1199e65636259017d3/vm.tf#L60)

Execution of a few tests

```
cd /home/vm1user/benchmark
./hey -c 500 -n 10000 http://10.0.64.35:30010/ # nginx svc
./hey -c 500 -n 10000 http://10.0.64.35:30011/ # envoy svc
```





# Test data


## 10k requests, 500 concurrent:

`Nginx`:

```
root@vm1:/home/vm1user/benchmark# ./hey -c 500 -n 10000 http://10.0.64.35:30010/

Summary:
  Total:	4.3612 secs
  Slowest:	1.9834 secs
  Fastest:	0.0012 secs
  Average:	0.1850 secs
  Requests/sec:	2292.9374

  Total data:	450000 bytes
  Size/request:	45 bytes

Response time histogram:
  0.001 [1]	    |
  0.199 [6672]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.398 [3119]	|■■■■■■■■■■■■■■■■■■■
  0.596 [36]	|
  0.794 [5]	    |
  0.992 [4]	    |
  1.191 [7]	    |
  1.389 [5]	    |
  1.587 [4]	    |
  1.785 [8]	    |
  1.983 [139]	|■


Latency distribution:
  10% in 0.0727 secs
  25% in 0.1234 secs
  50% in 0.1510 secs
  75% in 0.2126 secs
  90% in 0.2240 secs
  95% in 0.2333 secs
  99% in 1.8459 secs

Details (average, fastest, slowest):
  DNS+dialup:	0.0011 secs, 0.0012 secs, 1.9834 secs
  DNS-lookup:	0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:	0.0002 secs, 0.0000 secs, 0.0359 secs
  resp wait:	0.1832 secs, 0.0011 secs, 1.9604 secs
  resp read:	0.0000 secs, 0.0000 secs, 0.0278 secs

Status code distribution:
  [200]	10000 responses
```

`Envoy`:

```
root@vm1:/home/vm1user/benchmark# ./hey -c 500 -n 10000 http://10.0.64.35:30011/

Summary:
  Total:	3.8051 secs
  Slowest:	0.8782 secs
  Fastest:	0.0015 secs
  Average:	0.1720 secs
  Requests/sec:	2628.0855

  Total data:	464750 bytes
  Size/request:	46 bytes

Response time histogram:
  0.002 [1]	    |
  0.089 [2894]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.177 [2793]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.265 [2281]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.352 [1232]	|■■■■■■■■■■■■■■■■■
  0.440 [600]	|■■■■■■■■
  0.528 [96]	|■
  0.615 [55]	|■
  0.703 [4]	    |
  0.791 [11]	|
  0.878 [33]	|


Latency distribution:
  10% in 0.0326 secs
  25% in 0.0771 secs
  50% in 0.1520 secs
  75% in 0.2432 secs
  90% in 0.3322 secs
  95% in 0.3847 secs
  99% in 0.5388 secs

Details (average, fastest, slowest):
  DNS+dialup:	0.0005 secs, 0.0015 secs, 0.8782 secs
  DNS-lookup:	0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:	0.0001 secs, 0.0000 secs, 0.0072 secs
  resp wait:	0.1703 secs, 0.0014 secs, 0.8345 secs
  resp read:	0.0000 secs, 0.0000 secs, 0.0024 secs

Status code distribution:
  [200]	9705 responses
  [503]	295 responses
```



## 10k requests, 250 concurrent:


`Nginx`:

```
root@vm1:/home/vm1user/benchmark# ./hey -c 250 -n 10000 http://10.0.64.35:30010/

Summary:
  Total:	4.5108 secs
  Slowest:	1.0182 secs
  Fastest:	0.0025 secs
  Average:	0.1046 secs
  Requests/sec:	2216.8856

  Total data:	450000 bytes
  Size/request:	45 bytes

Response time histogram:
  0.002 [1]	    |
  0.104 [4902]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.206 [4983]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.307 [29]	|
  0.409 [8]	    |
  0.510 [3]	    |
  0.612 [5]	    |
  0.713 [3]	    |
  0.815 [4]	    |
  0.917 [5]	    |
  1.018 [57]	|


Latency distribution:
  10% in 0.0645 secs
  25% in 0.0847 secs
  50% in 0.1044 secs
  75% in 0.1145 secs
  90% in 0.1240 secs
  95% in 0.1342 secs
  99% in 0.2404 secs

Details (average, fastest, slowest):
  DNS+dialup:	0.0002 secs, 0.0025 secs, 1.0182 secs
  DNS-lookup:	0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:	0.0000 secs, 0.0000 secs, 0.0057 secs
  resp wait:	0.1042 secs, 0.0024 secs, 1.0015 secs
  resp read:	0.0000 secs, 0.0000 secs, 0.0015 secs

Status code distribution:
  [200]	10000 responses
```



`Envoy`:
```
root@vm1:/home/vm1user/benchmark# ./hey -c 250 -n 10000 http://10.0.64.35:30011/

Summary:
  Total:	3.7220 secs
  Slowest:	0.3748 secs
  Fastest:	0.0012 secs
  Average:	0.0863 secs
  Requests/sec:	2686.6964

  Total data:	452300 bytes
  Size/request:	45 bytes

Response time histogram:
  0.001 [1]	|
  0.039 [2431]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.076 [2692]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.113 [2253]	|■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  0.151 [1200]	|■■■■■■■■■■■■■■■■■■
  0.188 [710]	|■■■■■■■■■■■
  0.225 [329]	|■■■■■
  0.263 [210]	|■■■
  0.300 [100]	|■
  0.337 [55]	|■
  0.375 [19]	|


Latency distribution:
  10% in 0.0178 secs
  25% in 0.0399 secs
  50% in 0.0745 secs
  75% in 0.1158 secs
  90% in 0.1696 secs
  95% in 0.2106 secs
  99% in 0.2912 secs

Details (average, fastest, slowest):
  DNS+dialup:	0.0003 secs, 0.0012 secs, 0.3748 secs
  DNS-lookup:	0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:	0.0001 secs, 0.0000 secs, 0.0088 secs
  resp wait:	0.0858 secs, 0.0012 secs, 0.3747 secs
  resp read:	0.0000 secs, 0.0000 secs, 0.0036 secs

Status code distribution:
  [200]	9954 responses
  [503]	46 responses

```

