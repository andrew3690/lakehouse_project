# 🏝️ Hybrid Data Lakehouse (Home Lab Edition)

> Transformando um PC Linux e smartphones Android antigos em um Cluster de Big Data distribuído e funcional.

![Spark Version](https://img.shields.io/badge/Apache%20Spark-3.5.0-orange) ![Delta Lake](https://img.shields.io/badge/Delta%20Lake-3.0.0-blue) ![Infrastructure](https://img.shields.io/badge/Nodes-x86%20%2B%20ARM64-green) ![Status](https://img.shields.io/badge/Build-Stable-success)

This project implements a complete **Data Lakehouse** within a local network (Home Lab), utilizing a unique **hybrid architecture**. The **Master/Driver** node runs on a standard Linux PC (x86_64), while the **Worker Nodes** run on repurposed Android smartphones (ARM64) via the Termux environment.

The goal is to demonstrate a zero-cost, sustainable, and high-performance data platform capable of distributed processing using industry-standard technologies.

---

## 🏗️ Architecture

The system operates on a local Wi-Fi network and is orchestrated via **Ansible** playbooks and custom Shell Scripts.



| Component | Role | Tech Stack | Hardware |
| :--- | :--- | :--- | :--- |
| **Master Node** | Orchestration, Driver, Resource Manager | Spark Master 3.5.0 | PC Linux (x86_64) |
| **Worker Nodes** | Distributed Processing (Executors) | Spark Worker (Termux) | Androids (ARM64) |
| **Storage** | Object Storage (S3 Compatible) | MinIO (Docker) | PC Linux |
| **Metastore** | Metadata Management | Hive + PostgreSQL | PC Linux |
| **IDE** | Development Environment | JupyterLab + VS Code Web | PC Linux |
| **DevOps** | Configuration Management | Ansible | PC Linux |

---

## 🚀 Key Features

* **Dynamic Operation Modes:** Custom control scripts (`mode-dev` / `mode-media`) that allocate or free up server resources on demand.
* **Delta Lake Storage:** Full ACID transactions, Time Travel, and Schema Evolution support over local MinIO storage.
* **Hybrid Execution:** The x86 Driver seamlessly delegates tasks to ARM CPUs (Phones), handling cross-platform Python path resolution automatically (`venv` vs `termux`).
* **Zero Network Overhead:** Heavy dependencies (AWS SDK, Delta Core) are pre-injected into worker nodes to prevent network bottlenecks during startup.
* **Secure Configuration:** Sensitive credentials and configurations are managed via environment variables (`.env`).

---

## 🛠️ Prerequisites

### Master Node (PC)
* OS: Linux (Ubuntu/Mint/Debian recommended)
* Python 3.12+
* Docker & Docker Compose
* Java 11 or 17 (OpenJDK)
* SSH Access enabled

### Worker Nodes (Android)
* **Termux** App installed.
* Packages: `python`, `openjdk-17`, `openssh`, `rsync`.
* SSH Server enabled (default port 8022).

---

## ⚙️ Installation & Setup

### 1. Clone the Repository

```bash
git clone [https://github.com/YOUR_USERNAME/home-lakehouse.git](https://github.com/YOUR_USERNAME/home-lakehouse.git)

cd home-lakehouse

```