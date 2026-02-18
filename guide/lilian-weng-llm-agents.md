# LLM Powered Autonomous Agents

> **Source:** https://lilianweng.github.io/posts/2023-06-23-agent/
> **Author:** Lilian Weng
> **Date:** June 23, 2023
> **Archived:** 2026-02-16

## Agent System Overview

LLM-powered autonomous agents leverage large language models as their central control mechanism. The architecture comprises three essential components:

### Planning
- **Subgoal decomposition:** Agents break complex tasks into manageable smaller objectives
- **Reflection and refinement:** Self-criticism enables iterative improvement by learning from past mistakes

### Memory
- **Short-term memory:** In-context learning within the model's context window
- **Long-term memory:** External vector stores enabling retention of extensive information

### Tool Use
- Agents call external APIs to access information beyond model weights, including real-time data and code execution capabilities

---

## Component One: Planning

### Task Decomposition

**Chain of Thought (CoT)** instructs models to "think step by step," decomposing complex problems into simpler sequential steps. This enhances performance on reasoning-intensive tasks.

**Tree of Thoughts** extends CoT by exploring multiple reasoning branches at each step, creating tree structures evaluated through breadth-first or depth-first search.

**LLM+P** uses external classical planners with Planning Domain Definition Language (PDDL) as an intermediate interface, outsourcing long-horizon planning to specialized tools.

### Self-Reflection

**ReAct** integrates reasoning and action by combining discrete task-specific actions with natural language reasoning traces. The framework follows: Thought -> Action -> Observation cycles.

**Reflexion** implements dynamic memory and self-reflection through a reinforcement learning setup. A heuristic function identifies inefficient trajectories or hallucinations, allowing the agent to reset and retry.

**Chain of Hindsight (CoH)** fine-tunes models on sequences of past outputs ranked by quality, enabling progressive improvement through feedback-conditioned learning.

**Algorithm Distillation (AD)** applies similar principles to reinforcement learning, encapsulating learning progress across episodes into a history-conditioned policy.

---

## Component Two: Memory

### Types of Memory

Memory systems parallel human cognition:

1. **Sensory Memory:** Retains raw impressions (visual, auditory) for seconds
2. **Short-Term/Working Memory:** Holds ~7 items for 20-30 seconds
3. **Long-Term Memory:**
   - *Explicit/Declarative:* Facts and events (episodic and semantic)
   - *Implicit/Procedural:* Automatic skills and routines

### Mapping to AI Systems

- Sensory memory -> embedding representations
- Short-term memory -> in-context learning (constrained by context window)
- Long-term memory -> external vector stores with fast retrieval

### Maximum Inner Product Search (MIPS)

MIPS enables efficient similarity searches in high-dimensional spaces using approximate nearest neighbor algorithms:

- **LSH:** Hashing similar items to same buckets
- **ANNOY:** Random projection trees for scalable search
- **HNSW:** Hierarchical navigable small-world graphs with layer-based shortcuts
- **FAISS:** Vector quantization with coarse-to-fine search
- **ScaNN:** Anisotropic quantization preserving inner product similarity

---

## Component Three: Tool Use

Tools extend LLM capabilities beyond parametric knowledge.

**MRKL** (Modular Reasoning, Knowledge and Language) is a neuro-symbolic architecture where LLMs route tasks to specialized expert modules (neural or symbolic).

**TALM** and **Toolformer** fine-tune models to use external APIs by expanding training datasets with successful tool calls.

**HuggingGPT** uses ChatGPT as a task planner, selecting appropriate models from HuggingFace platform through four stages:
1. Task planning and decomposition
2. Model selection
3. Task execution
4. Response generation

**API-Bank** is a benchmark containing 53 API tools and 264 annotated dialogues (568 API calls), evaluating:
- Level-1: API calling ability
- Level-2: API retrieval capability
- Level-3: Multi-API planning

---

## Case Studies

### Scientific Discovery Agent

**ChemCrow** augments LLMs with 13 chemistry-domain tools for organic synthesis and drug discovery. Human evaluation showed significant advantages over GPT-4 on specialized tasks, highlighting "a potential problem with using LLM to evaluate its own performance on domains that requires deep expertise."

Boiko et al. (2023) demonstrated autonomous scientific experimentation, where agents could design anticancer drugs through internet research, target selection, and synthesis planning.

### Generative Agents Simulation

Park et al. (2023) created 25 AI-controlled virtual characters in a sandbox environment, demonstrating emergent social behaviors. The architecture combines:

- **Memory stream:** Long-term external database of observations
- **Retrieval model:** Surfaces relevant context by recency, importance, and relevance
- **Reflection mechanism:** Synthesizes memories into higher-level inferences
- **Planning & reacting:** Translates reflections into believable actions

This resulted in information diffusion, relationship continuity, and coordinated social events without explicit programming.

### Proof-of-Concept Examples

**AutoGPT** demonstrates autonomous agents but suffers reliability issues due to natural language interfaces. It includes ~20 commands from web search to code execution.

**GPT-Engineer** generates complete code repositories through iterative clarification then full implementation, using separate system prompts for questioning and coding phases.

---

## Challenges

Three significant limitations constrain current LLM-agent systems:

### Finite Context Length
Restricted context capacity limits historical information inclusion and detailed instruction sets. While vector stores provide expanded knowledge access, their representational power doesn't match full attention mechanisms.

### Long-Term Planning and Task Decomposition
LLMs struggle with extended planning horizons and solution space exploration. They lack robust error recovery compared to humans learning through trial-and-error iteration.

### Reliability of Natural Language Interface
Natural language creates fragile boundaries between LLMs and external components. Models exhibit formatting errors and occasional non-compliance, forcing significant agent code to focus on output parsing.

---

## Citation

```
@article{weng2023agent,
  title   = "LLM-powered Autonomous Agents",
  author  = "Weng, Lilian",
  journal = "lilianweng.github.io",
  year    = "2023",
  month   = "Jun",
  url     = "https://lilianweng.github.io/posts/2023-06-23-agent/"
}
```
