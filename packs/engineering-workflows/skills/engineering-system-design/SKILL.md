---
name: engineering-system-design
description: Use when designing a system, service, or architecture from requirements and constraints, especially for API design, data modeling, service boundaries, scale, or reliability trade-offs.
---

# Engineering System Design

Help design systems and services with explicit assumptions, scale constraints,
and trade-offs.

## Good Fits

- greenfield design from product requirements
- design review before implementation
- API, storage, queue, and service-boundary decisions that need a coherent whole

## Framework

1. Requirements: functional, non-functional, constraints
2. High-level design: components, data flow, API contracts, storage
3. Deep dive: data model, endpoints, caching, queues, retries
4. Scale and reliability: estimates, failover, monitoring
5. Trade-offs: complexity, cost, familiarity, speed, maintainability

## Useful Inputs

- the core user or business problem
- target scale, latency, or availability expectations
- hard constraints such as timeline, team size, or existing stack
- any interfaces or data sources that already exist

## Output

Produce a clear design note with:

- assumptions
- architecture overview
- important trade-offs
- what should be revisited as the system grows

For narrower design-decision documents, prefer `engineering-architecture`.
