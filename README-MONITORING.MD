# 🚀 EKS Monitoring Setup with Prometheus & Grafana

This guide explains how to install **Prometheus + Grafana monitoring on an Amazon EKS cluster** and expose Grafana through an **existing AWS ALB Load Balancer using Ingress Grouping**.

The monitoring stack will be deployed in the **`monitoring` namespace**, and Grafana will be accessible through the **existing Load Balancer** without using port-forward.

---

# 📊 Architecture

```
EKS Cluster
│
└── monitoring namespace
      ├── 📈 Prometheus
      ├── 📊 Grafana
      ├── 📦 kube-state-metrics
      ├── 🖥 node-exporter
      ├── 🚨 Alertmanager
      └── 🌐 monitoring-ingress
            └── /grafana
```

Grafana is exposed using the existing **AWS Application Load Balancer (ALB)** by using the annotation:

```
alb.ingress.kubernetes.io/group.name: healthcare-alb
```

---

# 🧰 1. Prerequisites

Ensure the following tools are installed and configured.

### ✅ Verify cluster access

```bash
kubectl get nodes
```

### ✅ Verify Helm

```bash
helm version
```

### 📦 Required Tools

| Tool                         | Purpose                        |
| ---------------------------- | ------------------------------ |
| kubectl                      | Kubernetes CLI                 |
| Helm                         | Package manager for Kubernetes |
| AWS CLI                      | Manage AWS resources           |
| EKS Cluster                  | Running Kubernetes cluster     |
| AWS Load Balancer Controller | Creates ALB for ingress        |

---

# 📁 2. Create Monitoring Namespace

Create a dedicated namespace for monitoring resources.

```bash
kubectl create namespace monitoring
```

Verify:

```bash
kubectl get ns
```

Expected output should include:

```
monitoring
```

---

# 📦 3. Add Prometheus Helm Repository

Add the official Prometheus Helm repository.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

Update repositories:

```bash
helm repo update
```

---

# ⚙️ 4. Install Prometheus + Grafana Stack

Install the **kube-prometheus-stack** Helm chart.

```bash
helm install monitoring prometheus-community/kube-prometheus-stack \
-n monitoring
```

This installs the following components:

| Component             | Description               |
| --------------------- | ------------------------- |
| 📈 Prometheus         | Metrics collection        |
| 📊 Grafana            | Visualization dashboards  |
| 🚨 Alertmanager       | Alerting system           |
| 📦 kube-state-metrics | Kubernetes object metrics |
| 🖥 node-exporter      | Node level metrics        |

---

# 🔎 5. Verify Installation

### Check Pods

```bash
kubectl get pods -n monitoring
```

Example output:

```
monitoring-kube-prometheus-prometheus
monitoring-grafana
monitoring-kube-state-metrics
monitoring-prometheus-node-exporter
monitoring-alertmanager
```

### Check Services

```bash
kubectl get svc -n monitoring
```

Important services:

```
monitoring-grafana
monitoring-kube-prometheus-prometheus
```

---

# 🌐 6. Create Grafana Ingress

Create an ingress in the **monitoring namespace** that uses the **existing AWS ALB**.

📄 File: `grafana-ingress.yaml`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: monitoring-ingress
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/group.name: healthcare-alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip

spec:
  rules:
  - http:
      paths:
      - path: /grafana
        pathType: Prefix
        backend:
          service:
            name: monitoring-grafana
            port:
              number: 80
```

Apply the ingress:

```bash
kubectl apply -f grafana-ingress.yaml
```

---

# 🔍 7. Verify Ingress

```bash
kubectl get ingress -n monitoring
```

Example output:

```
NAME                ADDRESS
monitoring-ingress  k8s-healthcare-xxxx.elb.amazonaws.com
```

Grafana will now be accessible via the existing ALB.

---

# ⚙️ 8. Configure Grafana for Subpath

Because Grafana is accessed via `/grafana`, configure Grafana to serve from a subpath.

```bash
helm upgrade monitoring prometheus-community/kube-prometheus-stack \
-n monitoring \
--set grafana.grafana.ini.server.root_url=%(protocol)s://%(domain)s/grafana \
--set grafana.grafana.ini.server.serve_from_sub_path=true
```

Wait for Grafana pods to restart:

```bash
kubectl get pods -n monitoring
```

---

# 🌍 9. Access Grafana

Retrieve the ALB DNS:

```bash
kubectl get ingress -n monitoring
```

Open in browser:

```
http://<ALB-DNS>/grafana
```

Example:

```
http://k8s-healthcare-123456.us-east-1.elb.amazonaws.com/grafana
```

---

# 🔐 10. Get Grafana Login Credentials

Default username:

```
admin
```

Retrieve password:

```bash
kubectl get secret monitoring-grafana -n monitoring \
-o jsonpath="{.data.admin-password}" | base64 --decode
```

---

# 🔌 11. Verify Prometheus Data Source

Inside Grafana:

```
Connections → Data Sources
```

Verify the **Prometheus datasource**.

Expected URL:

```
http://monitoring-kube-prometheus-prometheus:9090
```

Click:

```
Save & Test
```

---

# 📊 12. Import Kubernetes Dashboards

Go to:

```
Dashboards → Import
```

Import dashboards using the following IDs.

| 📊 Dashboard                  | ID   |
| ----------------------------- | ---- |
| Kubernetes Cluster Monitoring | 315  |
| Node Exporter Full            | 1860 |
| Kubernetes Pods Monitoring    | 6417 |
| Kubernetes Deployment Metrics | 8588 |

Steps:

1. Click **Import**
2. Enter Dashboard ID
3. Select **Prometheus** datasource
4. Click **Import**

---

# 📁 13. Built-in Dashboards

The Prometheus stack automatically installs several dashboards.

Navigate to:

```
Dashboards → Browse
```

Available dashboards include:

```
Kubernetes / Compute Resources / Cluster
Kubernetes / Compute Resources / Namespace
Kubernetes / Compute Resources / Pod
Node Exporter
Prometheus
```

---

# 📈 14. Useful Prometheus Queries

### 🖥 Node CPU Usage

```
100 - (avg by(instance)(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

### 📦 Pod CPU Usage

```
sum(rate(container_cpu_usage_seconds_total{container!=""}[5m])) by (pod)
```

### 💾 Pod Memory Usage

```
sum(container_memory_usage_bytes{container!=""}) by (pod)
```

### 🔁 Pod Restart Count

```
sum(kube_pod_container_status_restarts_total) by (pod)
```

---

# 🧩 Monitoring Components Installed

| Component             | Purpose                   |
| --------------------- | ------------------------- |
| 📈 Prometheus         | Metrics collection        |
| 📊 Grafana            | Visualization dashboards  |
| 🖥 node-exporter      | Node-level metrics        |
| 📦 kube-state-metrics | Kubernetes object metrics |
| 🚨 Alertmanager       | Alerting system           |

---

# 🎯 Result

After completing this setup, will be able to monitor:

* 📊 Cluster CPU and memory usage
* 🖥 Node health
* 📦 Pod CPU and memory usage
* 🔁 Pod restart count
* 📊 Deployment replicas
* 📈 Container metrics
* ☸ Kubernetes cluster health

Grafana dashboards will be accessible via:

```
http://<ALB-DNS>/grafana
```
