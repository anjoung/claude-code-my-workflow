# AutoGPT: Build, Deploy, and Run AI Agents

> **Source:** https://github.com/Significant-Gravitas/AutoGPT
> **Archived:** 2026-02-16

**AutoGPT** is a robust platform enabling creation, deployment, and management of continuous AI agents that handle complex automation workflows.

## Hosting Options

- Download for self-hosting (Free)
- Cloud-hosted beta (Coming Soon)

## System Requirements

### Hardware
- CPU: 4+ cores recommended
- RAM: Minimum 8GB, 16GB preferred
- Storage: At least 10GB free space

### Software
- **Operating Systems**: Linux (Ubuntu 20.04+), macOS (10.15+), Windows 10/11 with WSL2
- **Docker Engine** (20.10.0+)
- **Docker Compose** (2.0.0+)
- **Git** (2.30+)
- **Node.js** (16.x+)
- **npm** (8.x+)

### Network
- Stable internet connection
- Port access (configured via Docker)
- Outbound HTTPS capability

## Quick Setup

**macOS/Linux:**
```bash
curl -fsSL https://setup.agpt.co/install.sh -o install.sh && bash install.sh
```

**Windows (PowerShell):**
```powershell
powershell -c "iwr https://setup.agpt.co/install.bat -o install.bat; ./install.bat"
```

## Core Components

**Frontend**: Low-code agent builder with workflow management, deployment controls, and monitoring analytics.

**Server**: Executes deployed agents continuously, triggered by external sources through the Agent Protocol.

**Marketplace**: Pre-built agent library for immediate deployment.

## Example Use Cases

1. **Viral Video Generation**: Monitors Reddit trends, identifies popular topics, generates short-form videos automatically
2. **Social Media Content Extraction**: Transcribes YouTube videos, identifies impactful quotes, auto-publishes to social channels

## Licensing

- **autogpt_platform folder**: Polyform Shield License
- **All other code**: MIT License (includes Forge, agbenchmark, Classic GUI)

## Mission

Provide accessible AI tools for building, testing, and delegating automation tasks.

## Resources

- [Official Documentation](https://docs.agpt.co)
- [Discord Community](https://discord.gg/autogpt)

## AutoGPT Classic Components

**Forge**: Toolkit with boilerplate reduction for custom agent development
**Benchmark** (`agbenchmark`): Performance measurement compatible with Agent Protocol
**CLI**: Command-line interface for setup and agent management

## Agent Protocol

AutoGPT adopts the [Agent Protocol](https://agentprotocol.ai/) standard from the AI Engineer Foundation for seamless compatibility across applications.

---

*Repository Stats (at archive time): 182k stars, 46.2k forks, 792 contributors, 7,877 commits*
