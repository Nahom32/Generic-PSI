# Pluggable Motivation System Task Set

This task set turns the critique in `metamo-extensible/docs/critique.md` into
implementation work for a pluggable MetaMo-style motivation system. It assumes
the current repository state: `open-psi/` contains a small Generic-PSI prototype,
while `metamo-extensible/` mostly contains empty module placeholders for a more
general motivation substrate.

The target architecture is:

```text
MetaMo motivation kernel
  -> vector schema registry
  -> extension API
  -> proposal bus
  -> merge and safety kernel
  -> incremental embodiment
  -> audit, migration, verification, and neural adapters

Default instantiation
  -> OpenPsi appraisal
  -> MAGUS-style decision
  -> research-assistant stimulus/action adapters
```

## 0. Repository Baseline And Source Of Truth

- [ ] Decide whether `metamo-extensible/` is the new canonical MetaMo substrate
      and `open-psi/` is legacy input, or whether both should remain active
      implementations.
- [ ] Add a short architecture note documenting that decision.
- [ ] Keep the existing `open-psi/` goal, modulator, demand, condition-rule, and
      utility code readable during migration.
- [ ] Treat empty files in `metamo-extensible/core/`, `schemas/`,
      `extensions/`, `domains/`, and `tests/` as reserved module boundaries, not
      completed implementations.
- [ ] Define the minimum runnable demo for the first milestone:
      register schemas, load OpenPsi/MAGUS extensions, accept a stimulus, emit
      proposals, merge them, safety-project them, blend state, and log the
      transition.
- [ ] Update `README.md` or add `metamo-extensible/README.md` with the intended
      module layout and test command once the first working slice exists.

## 1. Kernel State And Vector Schema Registry

- [x] Implement `core/vector_schema.metta` with a first-class schema shape for
      goals, modulators, stimuli, and action features.
- [x] Represent each dimension with at least:
      id, kind, index, bounds, default value, role tags, version, decay policy,
      update limit, and description.
- [x] Implement `core/dimension_registry.metta` for registering schemas and
      querying dimensions by id, kind, index, and role.
- [x] Add schema validators for duplicate ids, duplicate indices, non-contiguous
      indices, invalid bounds, missing defaults, and invalid role tags.
- [x] Add state validators for `X = G x M`:
      vector length, numeric values, per-dimension bounds, and schema id.
- [ ] Add stimulus and action-feature validators so plugins cannot consume or
      emit undeclared dimensions.
- [ ] Preserve compatibility with the simple `open-psi/` atom forms:
      `(modulator name value)`, `(demand name min max result)`, and future
      `(goal name value)` records.

## 2. OpenPsi/MAGUS Default Instantiation

- [ ] Populate `schemas/openpsi_modulators_v1.metta` with the six OpenPsi
      modulators: valence, arousal, approach, resolution, threshold, securing.
- [ ] Populate `schemas/magus_goals_v1.metta` with the default MAGUS/OpenPsi
      goal layout, including individuation and transcendence overgoals.
- [ ] Populate `schemas/research_assistant_stimuli_v1.metta` with the default
      stimulus dimensions from the critique: novelty, conduciveness, risk, and
      effort.
- [ ] Assign role tags used by generic kernel logic:
      `safety-overgoal`, `growth-overgoal`, `caution-modulator`,
      `exploration-modulator`, `ethical-guard`, `social-drive`, and
      `novelty-signal`.
- [ ] Implement `extensions/openpsi_appraisal/appraisal.metta` as the default
      appraisal plugin over the registered stimulus and modulator schemas.
- [ ] Implement `extensions/magus_decision/decision.metta` as the default
      decision plugin over the registered goal, modulator, and action schemas.
- [ ] Package OpenPsi/MAGUS as one registered default instantiation rather than
      allowing its dimension names to leak into generic kernel modules.
- [ ] Add a compatibility adapter that can ingest existing `open-psi/` facts and
      convert them into schema-validated MetaMo state.

## 3. Extension API And Plugin Manifests

- [ ] Implement `core/extension_api.metta` with extension kinds:
      appraisal, decision, safety, merge, stimulus-adapter, action-adapter,
      neural-scorer, migration, and audit-sink.
- [ ] Define manifest facts for every extension:
      id, version, kind, entrypoint, input schemas, output schemas, required
      roles, permissions, confidence policy, safety obligations, and tests.
- [ ] Populate manifests for:
      `openpsi_appraisal`, `magus_decision`, `ethical_risk_appraiser`, and
      `neural_action_scorer`.
- [ ] Add manifest validation:
      declared entrypoint exists, schema ids resolve, output dimensions are
      declared, required roles exist, and version constraints are satisfiable.
- [ ] Add extension lifecycle hooks:
      initialize, appraise, decide, propose, validate, merge, project, commit,
      rollback, replay, and shutdown.
- [ ] Add extension isolation rules:
      plugins may emit proposals but may not directly mutate committed
      motivational state.
- [ ] Add `tests/extension_contract_tests.metta` covering valid and invalid
      manifests, schema mismatches, missing hooks, and invalid outputs.

## 4. Proposal Format And Motivation Bus

- [ ] Implement `core/proposal.metta` with a proposal shape containing:
      source extension, kind, target schema, delta goals, delta modulators,
      action scores, confidence, affected dimensions, safety flags, and
      explanation.
- [ ] Implement proposal validators:
      schema compatibility, vector shape, affected-dimension accuracy,
      confidence bounds, safety-flag vocabulary, and output bounds.
- [ ] Implement `core/motivation_bus.metta` to collect proposals from appraisal,
      decision, safety, and neural extensions.
- [ ] Implement `core/proposal_merge.metta` for weighted merge, veto,
      role-specific merge policy, conflict detection, and confidence decay.
- [ ] Ensure the bus sequence is explicit:
      collect -> validate -> merge -> project -> blend -> commit -> audit.
- [ ] Preserve selected action, score trace, and state transition trace for
      downstream explainability.
- [ ] Add negative tests proving malformed proposals fail before state commit.
- [ ] Add equivalence tests proving a single OpenPsi/MAGUS proposal path matches
      the expected default behavior.

## 5. Role-Based Safety Kernel

- [ ] Implement `core/safety_kernel.metta` without hardcoding OpenPsi names like
      `gInd`, `threshold`, or `securing`.
- [ ] Compute safety from dimensions tagged with roles such as
      `safety-overgoal`, `caution-modulator`, `ethical-guard`, and
      `safety-margin`.
- [ ] Define safe-region checks:
      minimum safety support, bounded goal norm, bounded modulator range, and
      optional domain-specific constraints.
- [ ] Implement projection into the safe region for out-of-bounds goal and
      modulator updates.
- [ ] Implement boundary pressure and caution raising through role-based
      dimension lookup.
- [ ] Add a policy for plugin vetoes and mandatory safety projection before
      commit.
- [ ] Add `tests/safety_invariant_tests.metta` for safe-region invariance,
      projection idempotence, boundary caution, and non-OpenPsi schemas.

## 6. Incremental Embodiment And State Continuity

- [ ] Implement target-state blending as:
      `next = (1 - alpha) * current + alpha * projected_target`.
- [ ] Make alpha configurable by schema, plugin, and safety state while keeping
      a conservative default.
- [ ] Add self-model drift checks so large motivational jumps are backed off or
      rejected.
- [ ] Add a deterministic backoff loop for failed drift or safety checks.
- [ ] Ensure blending happens after merge and safety projection, before commit.
- [ ] Record alpha, target state, projected target, accepted state, and rejected
      candidates in the audit log.
- [ ] Add tests for zero alpha, full alpha, partial alpha, drift rejection, and
      safety projection before blending.

## 7. Schema Compatibility And Migration

- [ ] Implement `core/compatibility.metta` for schema compatibility checks:
      exact match, compatible superset, compatible subset, role-compatible, and
      incompatible.
- [ ] Implement `core/schema_migration.metta` with migration rules from one
      schema version to another.
- [ ] Represent migration rules with:
      from schema, to schema, kind, source dimension, target dimension,
      transform, loss estimate, confidence, and notes.
- [ ] Implement migration outputs containing:
      migrated state, information loss, confidence, warnings, and replay notes.
- [ ] Support added dimensions by filling defaults.
- [ ] Support renamed dimensions through explicit rules.
- [ ] Support removed dimensions by recording information loss.
- [ ] Add replay tests proving old audit logs can be interpreted under a newer
      schema.
- [ ] Add `tests/migration_tests.metta` for copy, add, rename, remove, and
      incompatible migration cases.

## 8. Neural Adapter Layer

- [ ] Implement `core/neural_adapter.py` with fixed-vector encoding:
      `[goals, modulators, stimulus, context]`.
- [ ] Implement token/set encoding for evolving schemas:
      dimension id, kind, value, bounds, confidence, roles, and schema version.
- [ ] Add masks for missing dimensions, plugin-disabled dimensions, and
      migration-created defaults.
- [ ] Add normalization and denormalization using schema bounds.
- [ ] Add adapter metadata so neural models know which schema version and
      encoding produced a tensor.
- [ ] Implement `extensions/neural_action_scorer/model_adapter.py` as a minimal
      scorer that consumes adapter output and emits action-score proposals.
- [ ] Add `tests/neural_adapter_tests.py` for encoding shape, bounds
      normalization, masks, schema metadata, and invalid inputs.

## 9. Audit Log, Replay, And Rollback

- [ ] Implement `core/audit_log.metta` with immutable transition records.
- [ ] Log every bus stage:
      incoming state, stimulus, proposals, validation failures, merge result,
      safety projection, alpha blend, final state, selected action, and plugin
      versions.
- [ ] Add replay support that can re-run a transition from logged inputs and
      extension versions.
- [ ] Add rollback support to restore a previous committed state after failed
      safety, migration, or plugin validation.
- [ ] Include schema migration notes in audit records whenever replay crosses
      schema versions.
- [ ] Add tests for deterministic replay and rollback after rejected proposals.

## 10. Domain Adapters And Current Generic-PSI Integration

- [ ] Implement `domains/research_assistant/stimulus_adapter.metta` to convert
      domain observations into registered stimulus vectors.
- [ ] Implement `domains/research_assistant/action_adapter.metta` to convert
      selected actions into domain commands.
- [ ] Bridge `open-psi/condition_rules.metta` into the extension flow so current
      condition checks can participate as appraisal or safety signals.
- [ ] Add missing `open-psi/mindAgents/perception.metta` behavior or replace it
      with the research-assistant stimulus adapter.
- [ ] Add missing `open-psi/mindAgents/actionSelector.metta` behavior or replace
      it with the MAGUS decision extension.
- [ ] Add missing `open-psi/mindAgents/monitorChanges.metta` behavior or replace
      it with audit/replay hooks.
- [ ] Add an end-to-end example that starts from simple goal, modulator, demand,
      and stimulus atoms and produces a selected action plus an audited next
      state.

## 11. Verification Harness For MetaMo Principles

- [ ] Add tests for bounded appraisal-decision commutation error.
- [ ] Add tests for safe-region invariance: `F(R) subset R`.
- [ ] Add tests for boundary-band contractivity.
- [ ] Add tests for schema-correct parallel motivational merge.
- [ ] Add tests for reciprocal translation and simulation error bounds.
- [ ] Add tests for self-model drift bounds under incremental embodiment.
- [ ] Add tests for migration replay consistency.
- [ ] Add tests for neural-adapter output validity.
- [ ] Keep deterministic MeTTa tests as the first layer.
- [ ] Add Python property-style tests only where deterministic fixtures are too
      weak.
- [ ] Update `.github/workflows/metta-tests.yml` once non-empty tests exist.

## 12. Delivery Milestones

- [ ] M1: Schema registry and validators work for OpenPsi/MAGUS dimensions.
- [ ] M2: OpenPsi appraisal and MAGUS decision are registered extensions with
      valid manifests.
- [ ] M3: Proposal bus can run one complete OpenPsi/MAGUS transition and commit
      an audited next state.
- [ ] M4: Safety kernel is role-based and passes invariance tests on both
      OpenPsi/MAGUS and one toy non-OpenPsi schema.
- [ ] M5: Incremental embodiment, drift checks, and rollback are active in the
      default transition path.
- [ ] M6: Schema migration can upgrade a logged v1 state to a v2 schema with
      visible loss/confidence metadata.
- [ ] M7: Neural adapter emits fixed and token encodings with masks and schema
      metadata.
- [ ] M8: Verification harness covers the five MetaMo principles plus migration
      and neural-adapter validity.

## Definition Of Done

- [ ] A new motivation extension can be added by writing a manifest and
      entrypoint without editing the kernel.
- [ ] The kernel rejects incompatible plugin outputs before commit.
- [ ] OpenPsi/MAGUS remains available as the default instantiation.
- [ ] Safety logic uses schema roles, not concrete OpenPsi dimension names.
- [ ] Motivational state updates are projected and blended before commit.
- [ ] Schema versions and migrations are explicit and auditable.
- [ ] Neural encoders include enough schema metadata to survive dimension
      changes.
- [ ] Tests prove the major MetaMo principles rather than only checking example
      outputs.
