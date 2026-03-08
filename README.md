# Spark Cluster with Tailscale

This project documents the setup of a small distributed **Apache Spark cluster** running across multiple macOS machines of various ages connected through **Tailscale using MagicDNS** instead of static IP addresses.

The goal of this setup is to allow several personal machines to function together as a distributed compute environment for experimenting with:

- Distributed data processing
- PySpark workloads
- Spark architecture and cluster behavior

The idea of this project came from needing to use AWS Glue for a semester long project in MIS 584 "Big Data Technologies". Previously, AWS was only running AWS Lambda API calls, adding daily Glue jobs to transform the data was rapidly increasing the cost. Since AWS Glue uses Spark, I decided to try running the jobs using Spark on my own devices.

---

## Table of Contents

- [Spark Cluster with Tailscale](#spark-cluster-with-tailscale)
  - [Table of Contents](#table-of-contents)
    - [Setup and Configuration Guides](#setup-and-configuration-guides)
  - [Cluster Architecture](#cluster-architecture)
    - [Master Node](#master-node)
    - [Worker Nodes](#worker-nodes)
  - [Software Stack](#software-stack)
  - [Networking](#networking)
  - [Scripts](#scripts)
    - [Start Cluster](#start-cluster)
    - [Stop Cluster](#stop-cluster)
  - [Spark Web UI](#spark-web-ui)
  - [Example Job Submission](#example-job-submission)
  - [Purpose of This Project](#purpose-of-this-project)
  - [Future Improvements](#future-improvements)

### Setup and Configuration Guides

The detailed setup documentation is located in the **Docs** folder:

- [Cluster Setup Steps](Docs/SetUpSteps.md)
- [Automation Scripts Setup](Docs/SettingUpAutomationScript(VSCodeJupyter).md)
- [Enabling Event Logging](Docs/EnablingEventLogging.md)
- [Troubleshooting and Common Problems](Docs/OtherProblems.md)
- [My Hardware and Software Versions](Docs/MyDevicesAndSoftwareVersions.md)

---

## Cluster Architecture

The cluster is composed of three macOS machines connected through a Tailscale network.

```text
        ┌───────────────────────────┐
        │      MacBook Pro          │
        │     Spark Master Node     │
        │                           │
        │  spark://MASTER:7077      │
        └─────────────┬─────────────┘
                      │
              Tailscale Network
                      │
        ┌─────────────┴─────────────┐
        │                           │
┌────────────────────┐     ┌──────────────────┐
│ Mac Pro "Trashcan" │     │      iMac        │
│   Worker Node      │     │   Worker Node    │
│                    │     │                  │
│  Spark Executor    │     │  Spark Executor  │
└────────────────────┘     └──────────────────┘
```

### Master Node

- MacBook Pro
  - Runs the Spark master service
  - Submits distributed jobs

### Worker Nodes

- Mac Pro "Trashcan"
- iMac
- MacBook Pro *(optional worker if additional cores are desired)*

Workers execute Spark tasks and store intermediate computation results.

---

## Software Stack

The cluster uses the following software versions to ensure compatibility across both **Apple Silicon** and **older Intel-based macOS machines**.

- **Apache Spark** – 4.1.1
- **Python** – 3.10
- **OpenJDK** – 21
- **Tailscale** – Any recent stable release

Due to the age of the TrashCan and iMac, both machines are limited to older macOS versions and hardware architectures compared to the MacBook Pro. Because of this, the software stack used in this cluster was selected based on compatibility across all three machines.

Java, Spark, and Python versions were chosen that run reliably on both the newer Apple Silicon system and the older Intel-based systems so the cluster can operate consistently across the mixed hardware environment.

---

## Networking

All machines are connected through a **Tailscale tailnet**, which provides:

- Secure encrypted networking
- Stable private IP addresses
- Connectivity across different physical locations

The cluster uses **MagicDNS hostnames** rather than raw IP addresses.

Example Spark master address:

```bash
spark://<master-hostname>:7077
```

---

## Scripts

### Start Cluster

Start the Spark master and worker nodes using:

```bash
./start_cluster.sh
```

This script:

- Starts the Spark master node
- Starts Spark workers on each machine
- Optionally starts Spark Connect

---

### Stop Cluster

Stop the entire Spark cluster using:

```bash
./stop_cluster.sh
```

This shuts down:

- Spark workers
- Spark master
- Spark Connect (if running)

---

## Spark Web UI

Once the cluster is running, the Spark web interface can be accessed from a browser.

Default URL:

```bash
http://<master-hostname>:8080
```

The UI allows you to monitor:

- Worker nodes
- Running jobs
- Task distribution
- Resource usage

---

## Example Job Submission

Example command used to submit a distributed Spark job:

```bash
spark-submit \
  --master spark://<master-hostname>:7077 \
  ~/spark_projects/test_distributed/distributed_test.py
```

---

## Purpose of This Project

This cluster is used for:

- Learning distributed computing concepts
- Running PySpark workloads across multiple machines
- Experimenting with Spark architecture and performance
- Developing data engineering skills using a small home lab environment

---

## Future Improvements

Potential future additions to this setup include:

- Adding Kafka for streaming pipelines
- Experimenting with Spark Streaming
- Adding distributed storage
- Expanding the cluster with additional nodes
- Learning how to interpet the Spark UI websites
