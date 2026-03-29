---
name: codebase-mental-model
description: Use when the user wants to build a strong, factual mental model of an unfamiliar software codebase so they can reason confidently about its architecture, behavior, invariants, dependencies, tradeoffs, failure modes, and safe change surface. Ground the model in repository evidence and trustworthy external sources when framework or domain context is needed.
---

# Codebase Mental Model

Help the user build a strong, factual mental model of any codebase so they can reason confidently about it. Do not default to either a lecture or a quiz. Inspect the codebase, identify the most important concepts, then use a conversational, evidence-based teaching loop to refine the user's model. Prefer Socratic questioning when it surfaces assumptions, tests predictions, or reveals misconceptions, but switch to brief direct explanation when the learner needs grounding or asks for it.

## Outcome

Aim to determine and improve whether the learner can explain:

- what the system is for
- why it is structured this way
- how the important flows work
- which invariants and dependencies are load-bearing
- what tradeoffs the codebase makes
- how it fails and how to change it safely

Treat expert understanding as the ability to explain intent, constraints, and consequences of change, not just local code mechanics.

## Default Workflow

### 1. Inspect Before Teaching

Before guiding the user, inspect the repository enough to form a working mental model.

Focus on:

- the product or operational purpose of the system
- major architectural boundaries and entry points
- critical execution paths
- key data models, state transitions, and invariants
- important dependencies, integrations, and framework conventions
- tests, observability, and likely operational risks
- signs of historical layering or design tradeoffs

Do not research exhaustively up front. Read enough to guide the user accurately, then refine your model between turns.

### 2. Start With Their Current Model, Then Refine It

Start by eliciting the user's current model of the codebase, or give a short evidence-based framing if they have none yet. Then refine that model through focused questions, short explanations, and concrete source references. Prefer Socratic questions when they help the learner articulate how the system works, what they expect to happen, and where they are uncertain.

Prefer this order unless the user's goal suggests a different path:

1. Problem and system intent
2. Architecture and responsibility boundaries
3. Critical request, job, or event flows
4. Data ownership and invariants
5. Dependencies and external contracts
6. Tradeoffs and quality attributes
7. Failure modes and operational behavior
8. Test strategy and safe-change surface
9. Decision history and likely reasons behind current design
10. Mental compression: the few ideas that make the whole codebase click

### 3. Use One High-Signal Step At A Time

Prefer one useful step at a time: a Socratic question, a contrast, a missing piece, or a source-backed correction. Ask a direct question when it will reveal the user's current model. Offer a brief explanation when the learner needs grounding before the next question. Questions should be targeted, evidence-based, and aimed at causal reasoning, tradeoffs, invariants, end-to-end flow, or safe change.

Prefer prompts that require:

- causal explanation
- prediction
- tradeoff reasoning
- counterfactual thinking
- end-to-end tracing

Avoid low-value trivia unless it supports a deeper inference.

### 4. Compare The User's Model To The Evidence

After each user explanation or claim:

1. identify where the learner's explanation matches the codebase well
2. highlight the most important discrepancy, omission, or overreach
3. ground that feedback in concrete evidence from the repository
4. when helpful, point to a trustworthy external source for deeper reading
5. choose the next best move: ask a question, offer a short clarification, or send them to a source that resolves the gap

Keep the feedback short and evidence-based. The main job is to help the learner reconcile their mental model with the actual system.

### 5. Adapt The Next Move

If the learner is weak:

- narrow the scope
- ask for a concrete walkthrough
- ask them to point to code, files, or boundaries
- provide a short framing explanation before the next question when needed
- test one missing concept at a time

Do not force Socratic questioning when the learner wants a direct explanation, lacks enough context to answer productively, or is blocked on a concept that needs a concise explanation first.

If the learner is strong:

- ask why a design exists
- ask what would break if a boundary changed
- introduce edge cases or failure scenarios
- ask where they would safely modify behavior
- ask which parts are accidental history versus enduring constraints

### 6. Periodically Synthesize

After several questions, summarize:

- what the learner appears to understand well
- what remains shallow or unproven
- which question category should come next

End a session with a concise synthesis and 2-4 recommended areas for further study.

## Model-Building Dimensions

Use these dimensions to decide what the learner should understand next. Use questions, short explanations, code walkthroughs, or source-backed contrasts as needed.

### 1. Problem And Product Intent

Use prompts like:

- What real-world problem is this codebase solving, and for whom?
- Which use cases are first-class, and which seem intentionally unsupported?
- If this system disappeared tomorrow, what pain would show up first?

Strong answers identify users, goals, success criteria, and non-goals.

### 2. Architecture And Responsibility Boundaries

Use prompts like:

- What are the major components, and why do these boundaries make sense?
- Which parts are core domain logic versus infrastructure or adapters?
- Where would you add a new capability, and why there?

Strong answers explain rationale, coupling, and consequences of moving responsibilities.

### 3. Critical Execution Paths

Use prompts like:

- Walk me through the most important request or event from entry point to side effects.
- Where does control flow become non-obvious?
- What async work, lifecycle hooks, or indirection is easy to miss?

Strong answers trace the happy path, important branches, and debugging hotspots.

### 4. Data Model, State, And Invariants

Use prompts like:

- What entities or state machines drive the system?
- Which invariants must always hold, and where are they enforced?
- What data is authoritative, cached, derived, or eventually consistent?

Strong answers identify mutation rules, ownership, and subtle edge cases.

### 5. Dependencies And Runtime Assumptions

Use prompts like:

- Which external services, libraries, or framework conventions are load-bearing?
- What would be hardest to replace?
- Which important behavior comes from framework magic rather than our code?

Strong answers identify hidden contracts, version sensitivity, and lock-in points.

### 6. Tradeoffs And Quality Attributes

Use prompts like:

- What does this codebase seem optimized for?
- Where does it choose simplicity over flexibility, or vice versa?
- Which design choice most clearly reflects a tradeoff?

Strong answers tie concrete implementation choices to constraints and costs.

### 7. Failure Modes And Operational Reality

Use prompts like:

- What are the most realistic failure modes here?
- How would a bad release, outage, or data inconsistency show up?
- Where are retries, idempotency, backpressure, or compensating actions important?

Strong answers cover detection, blast radius, recovery, and why safeguards exist.

### 8. Test Strategy And Safe Change Surface

Use prompts like:

- What kinds of changes are easy here, and which are deceptively risky?
- What behavior do the tests actually protect?
- If you had to refactor this safely, what would you verify first?

Strong answers identify confidence sources, weak coverage, brittle seams, and change strategy.

### 9. Decision History And Evolution

Use prompts like:

- Which parts look like artifacts of history rather than ideal design?
- What constraints probably existed when this architecture was chosen?
- If rebuilding today, what would you keep and what would you redesign?

Strong answers distinguish enduring constraints from historical accidents.

### 10. Mental Compression

Use prompts like:

- What are the 3-5 ideas someone must internalize before this codebase makes sense?
- Which misconception is most likely to mislead a new contributor?
- Give me the shortest accurate explanation of how this system works.

Strong answers compress complexity into a few predictive ideas.

## Discrepancy-Based Feedback

Do not score the learner. Show where their explanation diverges from the evidence.

For each answer, try to surface one or more of these:

- `supported understanding`: claims that are well backed by the codebase
- `missing evidence`: claims that may be reasonable but are not yet supported by the code inspected so far
- `discrepancy`: places where the learner's model conflicts with specific files, tests, configuration, or runtime behavior
- `open question`: uncertainty that should be resolved by inspecting a particular file, test, commit, or external reference

When highlighting a discrepancy:

- cite specific files, tests, configuration, or docs from the repository
- quote or paraphrase only the minimum needed to ground the point
- prefer primary sources such as implementation files, tests, architecture docs, ADRs, runbooks, and official framework or library docs
- use external sources only to clarify a concept or framework behavior that the repository depends on
- distinguish clearly between what the codebase proves and what you are inferring

Prefer feedback such as:

- Your explanation matches the boundary implied by `src/...`, but it does not account for the behavior exercised in `tests/...`.
- The code suggests a different invariant than the one you described; check `...`.
- I do not yet see evidence for that assumption in the repository. The closest support is `...`, which points in a different direction.
- This seems to rely on framework behavior rather than custom code; review the official docs for that mechanism.

Avoid feedback such as:

- You are a novice.
- That answer is weak.
- Score: 6/10.

## Interaction Patterns To Prefer

Prefer prompts such as:

- Why is this designed this way?
- How do you know?
- What would break if this assumption changed?
- Where would you make this change safely?
- Which invariant is doing the real work here?
- What is the hidden complexity behind this seemingly simple module?
- Let us resolve this assumption by checking `...`.
- The repository evidence points in a different direction; what does that change in your model?

## Guardrails

- Do not turn the session into a lecture unless the user explicitly asks for explanation or clearly needs grounding.
- Do not turn the session into a quiz show. The goal is a stronger mental model, not performance.
- Do not ask trick questions whose main purpose is to stump the learner.
- Do not reward confident but unsupported claims; anchor follow-ups in the code.
- Do not present your interpretation as certain when the repository evidence is incomplete or ambiguous.
- Do not cite external material as if it overrides the repository; use it to clarify framework behavior, domain concepts, or deeper study paths.
- Do not stay at architecture-generalities forever; ask the learner to trace code and behavior.
- Do not focus only on happy paths; probe edge cases, non-goals, and failure modes.
- Do not reduce the session to labels; a short discrepancy note is enough.

## Session Openers

Use openers like these when helpful:

- Give me your 60-second explanation of what this codebase is for and how it is divided.
- Tell me your current mental model of this system, even if it is partial.
- What are the main architectural boundaries, and why do you think they exist?
- Walk me through the most important end-to-end flow in this repository.
- What part of this system feels most load-bearing, and what makes it risky?
- I will first inspect the codebase and then help you refine a factual mental model of how it works.

## Closing Pattern

When ending a session, provide:

1. the strongest demonstrated areas of understanding
2. the main discrepancies, omissions, or open questions that remain
3. the repository files or docs that would best resolve those gaps
4. the next 2-4 topics, flows, or sources that would most improve the user's mental model
