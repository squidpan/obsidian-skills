--- NOTE START ---
filename: References/Chatgpt/sre/skills/site-reliability-engineer.md
template: Skill Template
-------------------------
---
categories:
  - "[[Skills]]"
type: skill
description: Core Site Reliability Engineering skills for monitoring and maintaining low latency market data systems using Grafana and Prometheus.
source: chatgpt
tags:
  - sre
  - grafana
  - prometheus
  - monitoring
  - alerting
  - low-latency
  - market-data
created: 2026-04-17
last: 2026-04-17
status: draft
---

# Site Reliability Engineer

## Summary
- Responsible for reliability, performance, and observability of production systems
- Critical role in low latency trading environments
- Focus on monitoring, alerting, and incident response

## Key Points
- Designs monitoring systems using [[Grafana]] and [[Prometheus]]
- Defines alerting strategies
- Optimizes performance and handles incidents

## Interview Insights
- Understand latency vs reliability tradeoffs
- Monitoring must detect issues before impact

## Real-World Usage
- Monitor market data feeds
- Detect latency spikes and data loss

## Key Areas
- [[Monitoring Systems]]
- [[Observability]]

## Tools
- [[Grafana]]
- [[Prometheus]]

## Usecases
- [[Market Data Latency Spike]]

## Processes
- [[Monitoring and Alerting Workflow]]

## Runbooks
- [[Latency Incident Response Runbook]]

## Related Notes
- [[Monitoring Systems]]
- [[Observability]]

--- NOTE END ---

--- NOTE START ---
filename: References/Chatgpt/sre/concepts/monitoring-systems.md
template: Concept Template
-------------------------
---
categories:
  - "[[Concepts]]"
type: concept
description: Systems used to collect and analyze metrics for system health.
source: chatgpt
tags:
  - monitoring
  - sre
created: 2026-04-17
last: 2026-04-17
status: draft
---

# Monitoring Systems

## Summary
- Collect and analyze metrics
- Provide system visibility

## Key Points
- Metrics collection via tools like [[Prometheus]]
- Visualization via [[Grafana]]

## Interview Insights
- Monitoring shows system health trends

## Real-World Usage
- Track latency and throughput

## Related Notes
- [[Observability]]
- [[Prometheus]]

--- NOTE END ---

--- NOTE START ---
filename: References/Chatgpt/sre/concepts/observability.md
template: Concept Template
-------------------------
---
categories:
  - "[[Concepts]]"
type: concept
description: Ability to understand system behavior using metrics, logs, and traces.
source: chatgpt
tags:
  - observability
  - sre
created: 2026-04-17
last: 2026-04-17
status: draft
---

# Observability

## Summary
- Explains system behavior
- Uses metrics, logs, traces

## Key Points
- Metrics show trends
- Logs give context
- Traces show flow

## Interview Insights
- Observability answers “why”

## Real-World Usage
- Debug latency issues

## Related Notes
- [[Monitoring Systems]]

--- NOTE END ---

--- NOTE START ---
filename: References/Chatgpt/sre/tools/grafana.md
template: Tool Template
-------------------------
---
categories:
  - "[[Tools]]"
type: tool
description: Visualization platform for monitoring data.
source: chatgpt
tags:
  - grafana
  - monitoring
created: 2026-04-17
last: 2026-04-17
status: draft
---

# Grafana

## Summary
- Visualizes metrics
- Builds dashboards

## Key Points
- Integrates with [[Prometheus]]
- Real-time visualization

## Interview Insights
- Grafana visualizes data only

## Real-World Usage
- Monitor latency dashboards

## Related Notes
- [[Prometheus]]

--- NOTE END ---

--- NOTE START ---
filename: References/Chatgpt/sre/tools/prometheus.md
template: Tool Template
-------------------------
---
categories:
  - "[[Tools]]"
type: tool
description: Time-series metrics collection system.
source: chatgpt
tags:
  - prometheus
  - monitoring
created: 2026-04-17
last: 2026-04-17
status: draft
---

# Prometheus

## Summary
- Collects metrics
- Stores time-series data

## Key Points
- Pull-based system
- Uses PromQL

## Interview Insights
- Core monitoring tool

## Real-World Usage
- Trigger alerts

## Related Notes
- [[Grafana]]

--- NOTE END ---

--- NOTE START ---
filename: References/Chatgpt/sre/processes/monitoring-and-alerting-workflow.md
template: Process Template
-------------------------
---
categories:
  - "[[Processes]]"
type: process
description: Workflow for monitoring and alerting.
source: chatgpt
tags:
  - monitoring
  - process
created: 2026-04-17
last: 2026-04-17
status: draft
---

# Monitoring and Alerting Workflow

## Summary
- End-to-end monitoring process

## Key Points
- Collect metrics
- Visualize
- Alert
- Respond

## Interview Insights
- Shows system lifecycle

## Real-World Usage
- Incident detection

## Related Notes
- [[Prometheus]]

--- NOTE END ---

--- NOTE START ---
filename: References/Chatgpt/sre/runbooks/latency-incident-response-runbook.md
template: Runbook Template
-------------------------
---
categories:
  - "[[Runbooks]]"
type: runbook
description: Steps to resolve latency incidents.
source: chatgpt
tags:
  - latency
  - runbook
created: 2026-04-17
last: 2026-04-17
status: draft
---

# Latency Incident Response Runbook

## Summary
- Steps to fix latency issues

## Key Points
- Check alerts
- Validate metrics
- Identify bottleneck

## Interview Insights
- Shows incident response ability

## Real-World Usage
- Fix latency spikes

## Related Notes
- [[Monitoring Systems]]

--- NOTE END ---

--- NOTE START ---
filename: References/Chatgpt/sre/usecases/market-data-latency-spike.md
template: Usecase Template
-------------------------
---
categories:
  - "[[Usecases]]"
type: usecase
description: Latency spike scenario in market data systems.
source: chatgpt
tags:
  - latency
  - usecase
created: 2026-04-17
last: 2026-04-17
status: draft
---

# Market Data Latency Spike

## Summary
- Sudden latency increase

## Key Points
- Detected via dashboards
- Requires quick mitigation

## Interview Insights
- Tests troubleshooting skills

## Real-World Usage
- Trading system delays

## Related Notes
- [[Latency Incident Response Runbook]]

--- NOTE END ---
