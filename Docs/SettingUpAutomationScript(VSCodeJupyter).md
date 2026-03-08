# Automating Cluster Management for VS Code and Jupyter

This section describes how to automate management of the Spark cluster so that it can be started, connected to, and stopped using simple scripts. When working with a small distributed cluster across multiple machines, manually starting each component can become repetitive and error‑prone.

Automation scripts make it possible to:

- Start the Spark **master node**
- Start **worker nodes** on multiple machines
- Start the **Spark Connect server** used by Python clients
- Shut down the cluster cleanly when work is finished

With these scripts in place, the entire cluster can be managed with only a few commands.

Because worker nodes are started remotely using `ssh`, the machines must first be configured for **passwordless SSH access**.

---

## Enable Passwordless SSH Between Machines

The startup script uses `ssh` to start worker nodes on other machines. The master node must therefore be able to connect to the worker machines **without prompting for a password**.

Run the following on the machine that will act as the **master node**.

### Create an SSH Key

```bash
ssh-keygen -t ed25519
```

Press **Enter** to accept the default file location.

### Copy the Key to Each Worker Machine

```bash
ssh-copy-id user@worker-machine-name
```

Example:

```bash
ssh-copy-id user@trashcan
ssh-copy-id user@imac
```

### Verify Passwordless SSH

```bash
ssh user@trashcan
ssh user@imac
```

If configured correctly, the connection should open **without asking for a password**.

---

## Startup Script

This script starts the Spark master and worker nodes across the cluster.

### Step 1: Create a Scripts Directory

```bash
mkdir scripts
cd scripts
```

### Step 2: Create the Startup Script

```bash
nano start_cluster.sh
```

Paste the following script and modify the device names or paths to match your environment.

```bash
#!/bin/bash

MASTER="spark://master-device-name:7077"

MBP_SPARK="/path/to/spark"
TRASH_SPARK="/path/to/spark"
IMAC_SPARK="/path/to/spark"

# Start master - replace master-device-name with Tailscale MagicDNS name
$MBP_SPARK/sbin/start-master.sh --host master-device-name

sleep 3

# Start worker on master machine
$MBP_SPARK/sbin/start-worker.sh $MASTER

# Start workers on remote machines
ssh user@trashcan "$TRASH_SPARK/sbin/start-worker.sh $MASTER"
ssh user@imac "$IMAC_SPARK/sbin/start-worker.sh $MASTER"

sleep 5

# Start Spark Connect server
$MBP_SPARK/sbin/start-connect-server.sh \
  --master $MASTER


echo "Cluster startup complete"
echo "Spark UI: http://master-device-name:8080"
```

### Step 3: Make the Script Executable

```bash
chmod +x start_cluster.sh
```

### Step 4: Start the Cluster

```bash
./start_cluster.sh
```

This will start:

- The Spark master
- Worker nodes on all machines
- The Spark Connect server

---

## Spark Connect (VS Code / Jupyter)

Once the cluster is running, Python clients such as VS Code notebooks or Jupyter notebooks can connect using **Spark Connect**.

### Example Python Connection

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .remote("sc://master-device-name:15002") \
    .getOrCreate()
```

This allows notebooks to run distributed Spark jobs on the cluster.

---

## Shutdown Script

This script stops the Spark Connect server, worker nodes, and master node so the cluster shuts down cleanly.

### Step 1: Create the Shutdown Script

```bash
nano stop_cluster.sh
```

Paste the following script and modify device names or paths if necessary.

```bash
#!/bin/bash

MASTER_DEVICE="master-device-name"
MASTER="spark://master-device-name:7077"

MBP_SPARK="/path/to/spark"
TRASH_SPARK="/path/to/spark"
IMAC_SPARK="/path/to/spark"

# Stop Spark Connect server
$MBP_SPARK/sbin/stop-connect-server.sh

sleep 2

# Stop worker on master
$MBP_SPARK/sbin/stop-worker.sh

# Stop workers on remote machines
ssh user@trashcan "$TRASH_SPARK/sbin/stop-worker.sh"
ssh user@imac "$IMAC_SPARK/sbin/stop-worker.sh"

sleep 2

# Stop master
$MBP_SPARK/sbin/stop-master.sh


echo "Cluster shutdown complete"
```

### Step 2: Make the Script Executable

```bash
chmod +x stop_cluster.sh
```

### Step 3: Stop the Cluster

```bash
./stop_cluster.sh
```

This will stop:

- Spark Connect
- All worker nodes
- The Spark master

Using both startup and shutdown scripts simplifies cluster management and prevents leftover Spark processes from continuing to run in the background.
