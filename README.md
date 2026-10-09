# Active Directory Attack & Defend Lab

This repository contains the documentation, configuration files, and automation scripts used to deploy my personal On-Premise Active Directory Homelab. The environment is designed for executing Red Team tradecraft (MITRE ATT&CK) and engineering high-fidelity Blue Team detections (Sigma/Sysmon).

## 🏗️ Lab Architecture

The environment consists of a logically separated network running on a Type-1 Hypervisor, featuring centralized log collection via Windows Event Forwarding (WEF).

```mermaid
flowchart TD
    subgraph Attacker Network
        K[Kali Linux - 10.0.1.50]
    end

    subgraph Enterprise Network (corp.local)
        DC[Domain Controller - WS2022]
        WEF[WEF Collector / SIEM - WS2022]
        EP[Endpoint 01 - Win 11]
        
        DC <--> EP
        EP -.->|Sysmon & EVTX Forwarding| WEF
        DC -.->|EVTX Forwarding| WEF
    end
    
    K -.->|Adversary Emulation| DC
    K -.->|Lateral Movement| EP
```

## 🛠️ Automated Deployment Scripts
Located in the `/scripts` directory, these PowerShell scripts automate the baseline security configurations of the lab:
- `Deploy-Sysmon-Baseline.ps1`: Automatically fetches, installs, and configures Sysmon using an enterprise-tuned configuration file.
- `Configure-WEF-Subscriptions.ps1`: Sets up the WinRM listeners and configures the endpoints to forward Event IDs 4624, 4625, 4688, and 4662 to the centralized collector.

## ⚔️ Simulated Attack Scenarios
This lab is regularly used to validate the detection rules found in my [detection-rules](https://github.com/ZlightkunZ/detection-rules) repository:
1. **AS-REP Roasting (T1558.004):** Validating Event ID 4768 anomalies.
2. **DCSync (T1003.006):** Emulating Mimikatz to trigger replication events (Event ID 4662).
3. **Kerberoasting (T1558.003):** Detecting weak RC4 (0x17) ticket requests (Event ID 4769).
