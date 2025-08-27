---
mode: 'agent'
description: 'Plan an implementation'
---

Your goal is to generate an implementation plan for a specification document provided to you.

Before generating the implementation plan, be sure to review the #file:../../docs/idea.md file to understand an overview of the project.

RULES:
- Keep implementations simple, do not over architect
- Do not generate real code for your plan, pseudocode is OK
- For each step in your plan, include the objective of the step, the steps to achieve that objective, and any necessary pseudocode.
- Call out any necessary user intervention required for each step

Output your plan in #folder: docs/plans

OUTPUT FORMAT:
Create a markdown file with the following structure:
- # Implementation Plan: [Feature Name]
- ## Overview
- ## Implementation Steps
  - ### Step 1: [Step Name]
    - **Objective:** [What this step achieves]
    - **Steps:** [Numbered list of implementation steps]
    - **Pseudocode:** [High-level pseudocode if needed]
    - **User Intervention:** [Any required user actions]
  - ### Step 2: [Step Name]
    - [Continue format...]
- ## Dependencies
- ## Success Criteria
- ## Risk Mitigation

EXAMPLE OUTPUT FILE: See docs/plans/example-implementation-plan.md for reference.