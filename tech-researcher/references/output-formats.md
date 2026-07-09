# Output Formats

Load when producing the final answer. Pick the format that matches what the user asked for; for shorter answers, compress but keep the same logic: recommendation, evidence, risks, next step.

## Research answer format

```md
# Technical Research Result

## Question

<One sentence describing what was researched.>

## Recommendation

<Clear recommendation. No hedging unless uncertainty is real.>

## Why

- <reason>
- <reason>
- <reason>

## Current evidence

- <source or documentation checked — include URL and date/version where relevant>
- <source>
- <source>

## Alternatives considered

- `<option>` — <when it makes sense>
- `<option>` — <when it makes sense>

## Risks / stale assumptions

- <risk>
- <risk>

## Implementation notes

- <practical next step>
- <practical next step>
```

## Comparison format

When comparing tools, use:

```md
# Tool Comparison

## Best choice

<tool>

## Use this when

<conditions>

## Avoid this when

<conditions>

## Comparison

### <Tool A>

Strengths:
- <point>

Weaknesses:
- <point>

### <Tool B>

Strengths:
- <point>

Weaknesses:
- <point>

## Final recommendation

<direct answer>
```

## Implementation planning format

When the user wants an implementation plan, use:

```md
# Implementation Plan

## Recommended stack

- <tool/library/service>

## Assumptions

- <assumption>

## Steps

1. <step>
2. <step>
3. <step>

## Version-sensitive notes

- <note>

## Risks

- <risk>

## Validation

- <how to test>
```

## Decision-grade format (pivots / build-vs-buy / stack changes)

When the question is a direction decision rather than a tool lookup, use:

```md
# Decision Brief: <the decision>

## Recommendation

<one clear call>

## Criteria table

| Criterion (weight) | <Option A> | <Option B> | <Stay as-is> |
|---|---|---|---|
| Fit for the actual need (high) | | | |
| Maintenance burden for a solo operator (high) | | | |
| Lock-in / resale-readiness (high) | | | |
| Switching cost from current state (med) | | | |
| Maturity & maintenance signals (med) | | | |
| Cost at expected scale (med) | | | |

## Reversibility

<How hard is it to undo this choice in 6 months? One-way door or two-way door?>

## Cost of change vs cost of staying

<what migrating costs now · what staying costs over time>

## Current evidence

- <source + date/version>

## What would change this call

<the condition that flips the recommendation>
```
