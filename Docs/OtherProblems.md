# Troubleshooting and Common Problems

This document lists common problems that may occur while setting up or operating the Spark cluster described in this repository. The solutions below are based on issues encountered during the setup process as well as other common configuration problems when working with Spark, Tailscale, automation scripts, and distributed clusters across multiple machines.

---

## Problem 1: Incorrect File Paths

Many Spark errors occur simply because the wrong directory or path is being used.

### 1. Symptoms

- `command not found`
- Spark scripts fail to start
- Python scripts cannot locate Spark

### 1. Solution

Ensure the commands are referencing the **correct Spark installation directory**.

Example:

```bash
$SPARK_HOME/sbin/start-master.sh
```

Verify the Spark path:

```bash
echo $SPARK_HOME
```

If this returns nothing, the environment variable was not set correctly.

If Spark was recently installed, review the installation instructions in **SetUpSteps.md** to confirm the environment variables were configured correctly.

---

## Problem 2: Conda Environment Not Activated

The cluster uses a Conda environment to standardize the Python version used by PySpark.

### 2. Symptoms

- Spark jobs fail with Python errors
- `pyspark` cannot be imported
- Workers crash immediately after starting

### 2. Solution

Activate the Conda environment before running Spark jobs.

```bash
conda activate spark310
```

Verify the correct Python version:

```bash
python --version
```

---

## Problem 3: Tailscale CLI Does Not Work After Installing the GUI

On macOS it is possible for the Tailscale GUI installation to create an incorrect CLI symlink.

### 3. Symptoms

- `tailscale` command does not work
- CLI reports a missing binary

### 3. Solution

Remove the incorrect symlink and link the Homebrew binary.

```bash
sudo rm /opt/homebrew/bin/tailscale
```

```bash
brew link tailscale
```

Restart the Tailscale service:

```bash
brew services restart tailscale
```

If networking problems continue, review the Tailscale setup instructions in **SetUpSteps.md**.

---

## Problem 4: Worker Nodes Cannot Connect to the Master

If worker nodes fail to register with the master, it is usually due to hostname or networking issues.

### 4. Symptoms

- Workers start but do not appear in the Spark UI
- `Connection refused` errors

### 4. Solution

Verify the master hostname being used.

Example:

```bash
spark://master-device-name:7077
```

Confirm the hostname resolves correctly:

```bash
tailscale status
```

If MagicDNS is working, the hostname should appear in the list of devices.

---

## Problem 5: Workers Start Before the Master

In automated startup scripts, workers may attempt to start before the master node is ready.

### 5. Symptoms

- Worker startup fails
- Workers immediately exit

### 5. Solution

Add a delay after starting the master node in the startup script.

Example:

```bash
sleep 3
```

This allows the master service to initialize before workers connect.

---

## Problem 6: SSH Prompts for a Password During Automation

The automation script starts worker nodes through SSH. If passwordless SSH is not configured, the script will pause waiting for input.

### 6. Solution

Review the instructions in:
[Automation Setup Guide](SettingUpAutomationScript(VSCodeJupyter).md)

That document explains how to configure **passwordless SSH** so the automation scripts can start worker nodes on other machines without manual input.

---

## Problem 7: Spark Jobs Run Only on One Machine

### 7. Symptoms

Jobs appear to run but tasks are not distributed across workers.

### 7. Solution

Verify the job is submitted to the cluster master rather than running locally.

Correct:

```bash
spark-submit \
--master spark://master-device-name:7077 \
script.py
```

Incorrect:

```bash
spark-submit script.py
```

Without the `--master` argument Spark may run in **local mode**.

---

## Problem 8: Spark Processes Do Not Shut Down

Occasionally Spark processes remain running after stopping the cluster.

### 8. Symptoms

`jps` shows processes such as:

Master
Worker
Executor

### 8. Solution

Force stop Spark processes:

```bash
pkill -f org.apache.spark
```

Verify shutdown:

```bash
jps
```

Only the `Jps` process should remain.

---

## Problem 9: Spark Connect Cannot Connect

### 9. Symptoms

Python notebooks fail with connection errors.

Example:

Connection refused: sc://master-device-name:15002

### 9. Solution

Ensure the Spark Connect server is running.

```bash
$SPARK_HOME/sbin/start-connect-server.sh
```

Also confirm the correct port is used:
15002

If Spark Connect is being started automatically, verify the configuration in [Automation Setup Guide](SettingUpAutomationScript(VSCodeJupyter).md)

---

## Useful Debugging Commands

The following commands are helpful when diagnosing Spark cluster issues.

Check running Java processes:

```bash
jps
```

Check cluster workers in the Spark UI:

[http://master-device-name:8080]

Verify Tailscale networking:

```bash
tailscale status
```

These tools can quickly identify whether problems originate from Spark, networking, or system configuration.
