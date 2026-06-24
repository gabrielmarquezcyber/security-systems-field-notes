# AI Trust Architecture

This folder is for public notes on secure AI interaction systems.

Focus areas:

- confidential AI
- privacy-preserving inference
- policy-bound tool use
- scoped delegation
- deterministic authorization boundaries
- human-reviewed approval thresholds
- tamper-evident audit logs
- AI-assisted SecOps guardrails

Core rule:

LLM output should not directly authorize high-impact action. High-impact actions should pass policy checks, permission checks, evidence validation, tool-scope validation, approval thresholds, and audit logging.
