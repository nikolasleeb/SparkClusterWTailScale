# Setting up a Spark Cluster with TailScale Using MagicDNS

## Getting Started with Tailscale

### Setting up Account

- create an account at: [https://login.tailscale.com/start]
- Once an account has been created, enable MagicDNS. (under DNS tab at top)

### Installing Tailscale

- Download the Tailscale App (GUI): [https://tailscale.com/download]
- Download the Command Line Interface (CLI):

```python
brew install tailscale
sudo tailscale up
```

\* if you don't have homebrew, follow the instructions on this website [https://mac.install.guide/homebrew/3]

## Installing Necessary Software Stack

For EACH DEVICE in the cluster, the following steps will need to be followed on ALL DEVICES. All devices must be using the same versions of Java and Spark, Python needs to be at least 4.10. Due to the age of the iMac and MacPro, older versions of the softwares are being installed.

### OpenJDK 21

```python
curl -L -o OpenJDK21.pkg \ https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2+13/OpenJDK21U-jdk_x64_mac_hotspot_21.0.2_13.pkg
```

```python
sudo installer -pkg OpenJDK21.pkg -target /
```

```python
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 21)' >> ~/.zshrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Spark 4.1.1

```python
curl -L -o spark-4.1.1.tgz \
https://downloads.apache.org/spark/spark-4.1.1/spark-4.1.1-bin-hadoop3.tgz
```

```python
tar -xzf spark-4.1.1.tgz
mv spark-4.1.1-bin-hadoop3 ~/spark
```

### Installing MINIConda to Enforce Python Versions

```python
curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
```

```python
bash Miniconda3-latest-MacOSX-x86_64.sh
```

some prompts will pop up:

- hit enter
- yes
- accept the defaults

```python
conda create -n spark310 python=3.10 pyspark -y
```

```python
conda activate spark310
```

## Testing the Cluster

```python
conda activate spark310
```

- do this on each device
- .
