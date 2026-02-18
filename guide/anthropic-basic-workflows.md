# Basic Workflows

> **Source:** https://platform.claude.com/cookbook/patterns-agents-basic-workflows
> **Archived:** 2026-02-16

Three simple multi-LLM workflow patterns trading cost or latency for improved performance.

## Overview

This guide demonstrates three simple multi-LLM workflows that trade off cost or latency for potentially improved task performance:

1. **Prompt-Chaining**: Decomposes a task into sequential subtasks, where each step builds on previous results
2. **Parallelization**: Distributes independent subtasks across multiple LLMs for concurrent processing
3. **Routing**: Dynamically selects specialized LLM paths based on input characteristics

> Note: These are sample implementations meant to demonstrate core concepts - not production code.

## Core Implementations

### 1. Chain Workflow

```python
def chain(input: str, prompts: list[str]) -> str:
    """Chain multiple LLM calls sequentially, passing results between steps."""
    result = input
    for i, prompt in enumerate(prompts, 1):
        print(f"\nStep {i}:")
        result = llm_call(f"{prompt}\nInput: {result}")
        print(result)
    return result
```

**Use Case**: Data processing with progressive transformations

Example: Converting raw Q3 performance data into structured markdown table through 4 sequential steps:
- Extract numerical values and metrics
- Convert to percentages
- Sort by value
- Format as markdown table

### 2. Parallelization Workflow

```python
def parallel(prompt: str, inputs: list[str], n_workers: int = 3) -> list[str]:
    """Process multiple inputs concurrently with the same prompt."""
    with ThreadPoolExecutor(max_workers=n_workers) as executor:
        futures = [executor.submit(llm_call, f"{prompt}\nInput: {x}") for x in inputs]
        return [f.result() for f in futures]
```

**Use Case**: Stakeholder impact analysis, concurrent processing of independent tasks

Example: Process analysis for 4 stakeholder groups simultaneously:
- Customers
- Employees
- Investors
- Suppliers

Each receives impact analysis with specific priorities, recommended actions, and timelines.

### 3. Routing Workflow

```python
def route(input: str, routes: dict[str, str]) -> str:
    """Route input to specialized prompt using content classification."""
    # First determine appropriate route using LLM with chain-of-thought
    print(f"\nAvailable routes: {list(routes.keys())}")
    selector_prompt = f"""
    Analyze the input and select the most appropriate support team from these options: {list(routes.keys())}
    First explain your reasoning, then provide your selection in this XML format:

    <reasoning>
    Brief explanation of why this ticket should be routed to a specific team.
    Consider key terms, user intent, and urgency level.
    </reasoning>

    <selection>
    The chosen team name
    </selection>

    Input: {input}""".strip()

    route_response = llm_call(selector_prompt)
    reasoning = extract_xml(route_response, "reasoning")
    route_key = extract_xml(route_response, "selection").strip().lower()

    print("Routing Analysis:")
    print(reasoning)
    print(f"\nSelected route: {route_key}")

    # Process input with selected specialized prompt
    selected_prompt = routes[route_key]
    return llm_call(f"{selected_prompt}\nInput: {input}")
```

**Use Case**: Customer support ticket routing to specialized teams

## Example Applications

### Example 1: Chain Workflow - Data Processing

Input: Q3 Performance Summary with mixed metrics
- Customer satisfaction: 92 points
- Revenue growth: 45%
- Market share: 23%
- Employee satisfaction: 87 points
- etc.

Output through 4 sequential transformations:

```
| Metric | Value |
|:--|--:|
| Customer Satisfaction | 92% |
| Employee Satisfaction | 87% |
| Product Adoption Rate | 78% |
| Revenue Growth | 45% |
| User Acquisition Cost | 43.0 |
| Operating Margin | 34% |
| Market Share | 23% |
| Previous Customer Churn | 8% |
| Customer Churn | 5% |
```

### Example 2: Parallelization - Stakeholder Analysis

Processes 4 stakeholder groups concurrently:

**Customers**: Price sensitivity, tech demands, environmental concerns
- Impacts: Pricing pressure, tech advancement expectations, sustainability demand
- Actions: Tiered pricing, digital transformation, eco-friendly products

**Employees**: Job security, skills gaps, strategic direction
- Impacts: Uncertainty, skill obsolescence, engagement risks
- Actions: Transparent communication, training programs, career frameworks

**Investors**: Financial performance, risk management, transparency
- Impacts: Market volatility, regulatory changes, scrutiny
- Actions: Enhanced reporting, risk controls, frequent updates

**Suppliers**: Capacity constraints, price pressures, tech transitions
- Impacts: Demand fulfillment risks, margin squeeze, obsolescence risk
- Actions: Capacity expansion, cost optimization, technology roadmap

### Example 3: Routing - Customer Support

Routes 3 different support tickets to appropriate teams:

**Ticket 1**: Account access issue
- **Routed to**: Account Support
- **Response**: Identity verification, password reset steps, security recommendations

**Ticket 2**: Unexpected billing charge
- **Routed to**: Billing Support
- **Response**: Charge explanation, account review timeline, refund process

**Ticket 3**: Data export feature question
- **Routed to**: Technical Support
- **Response**: Step-by-step export instructions, system requirements, troubleshooting

## Key Takeaways

- **Chaining** is ideal for tasks requiring sequential refinement
- **Parallelization** reduces latency for independent subtasks at higher cost
- **Routing** optimizes quality by matching inputs to specialized handlers
- Each pattern trades different resources (cost, latency, complexity) for improved performance
