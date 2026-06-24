# MetaMo Extensible Motivation Substrate

`metamo-extensible/` is the planned canonical MetaMo substrate for this
repository. The older `open-psi/` directory remains useful as a reference
implementation and compatibility source during migration, but new extensibility
work should live here.

The goal of this directory is to separate the invariant motivation kernel from
any one OpenPsi/MAGUS instantiation. Generic kernel modules should reason over
registered schemas, roles, proposals, and plugin contracts rather than hardcoded
dimension names or fixed vector indices.

## Architecture

```text
Domain observation
  -> stimulus adapter
  -> registered stimulus vector
  -> appraisal, decision, safety, and neural extensions
  -> proposal bus
  -> proposal validation
  -> merge
  -> safety projection
  -> incremental embodiment / state blend
  -> commit
  -> audit log
```

The default instantiation is expected to be:

```text
OpenPsi modulators
  + MAGUS-style goals
  + research-assistant stimuli/actions
  + OpenPsi appraisal extension
  + MAGUS decision extension
```

That instantiation should be registered through schemas and manifests. Its
concrete names, such as OpenPsi modulators or MAGUS goal labels, should not leak
into generic kernel modules.

## Core Concepts

### Dimensions

Motivational state is represented with typed vector dimensions. A dimension is
first-class metadata, not just an index:

```text
(Dimension schema-id kind id index lower upper default roles version decay update-limit description)
```

Supported dimension kinds are:

- `goal`
- `modulator`
- `stimulus`
- `actionFeature`

Role tags, such as `safety-overgoal`, `caution-modulator`,
`exploration-modulator`, `ethical-guard`, and `novelty-signal`, let kernel
logic remain schema-neutral.

### Schemas

A schema is a versioned collection of dimensions. Schemas define the legal shape
of goal vectors, modulator vectors, stimulus vectors, and action-feature
vectors. Schema validators check duplicate ids, duplicate indices, contiguous
indices, bounds, defaults, vector length, and per-dimension values.

### Extensions

Extensions are intended to be replaceable units of motivation logic. Planned
extension kinds include:

- `appraisal`
- `decision`
- `safety`
- `merge`
- `stimulus-adapter`
- `action-adapter`
- `neural-scorer`
- `migration`
- `audit-sink`

Extensions should emit proposals, not directly mutate committed motivational
state.

### Proposals

A proposal is the communication format between extensions and the kernel. It is
expected to contain the source extension, target schema, proposed goal or
modulator deltas, action scores, confidence, affected dimensions, safety flags,
and explanation metadata.

The bus sequence is intended to be:

```text
collect -> validate -> merge -> project -> blend -> commit -> audit
```

### Safety

The safety kernel should operate over schema roles, not fixed OpenPsi names or
indices. For example, it should query dimensions tagged with roles like
`safety-overgoal`, `caution-modulator`, `ethical-guard`, or `safety-margin`.

### Migration And Replay

Schema changes should be explicit and auditable. Migration rules should support
copying, adding dimensions with defaults, renaming dimensions, removing
dimensions with information-loss records, and replaying older audit logs under
newer schemas.

### Neural Adapters

Neural adapters should support both fixed-vector encodings for stable schemas
and token/set encodings for evolving schemas. Encodings should include dimension
metadata, bounds, values, confidence, masks, and schema version information.

## Module Layout

```text
core/
  vector_schema.metta        Dimension shape, accessors, and validators.
  dimension_registry.metta   Schema registration and dimension lookup API.
  extension_api.metta        Extension kinds, manifests, and lifecycle hooks.
  proposal.metta             Proposal record shape and proposal validators.
  motivation_bus.metta       Proposal collection and transition sequencing.
  proposal_merge.metta       Merge policy, weighting, veto, and conflicts.
  safety_kernel.metta        Role-based safety checks and projection.
  compatibility.metta        Schema compatibility checks.
  schema_migration.metta     Version-to-version migration rules.
  audit_log.metta            Transition logging, replay, and rollback.
  neural_adapter.py          Neural encoding and normalization utilities.

schemas/
  openpsi_modulators_v1.metta
  magus_goals_v1.metta
  research_assistant_stimuli_v1.metta

extensions/
  openpsi_appraisal/
  magus_decision/
  ethical_risk_appraiser/
  neural_action_scorer/

domains/
  research_assistant/

tests/
  *_tests.metta
  neural_adapter_tests.py
```

Some modules are currently placeholders reserved for the architecture above.
Treat their presence as ownership boundaries, not as completed implementation.

## Current Working Slice

The implemented schema foundation currently includes:

- `core/vector_schema.metta`
- `core/dimension_registry.metta`
- `tests/vector_schema_tests.metta`
- `tests/dimension_registry_tests.metta`

These cover first-class dimensions, schema registration, lookup by id/index/role,
dimension-list validation, motivation-state validation, and stimulus/action
feature declaration checks.

## Running Tests

Run focused MeTTa tests with the local `petta` command:

```sh
petta metamo-extensible/tests/vector_schema_tests.metta
petta metamo-extensible/tests/dimension_registry_tests.metta
```

Run the registry module directly as a compile check:

```sh
petta metamo-extensible/core/dimension_registry.metta
```

The repository also contains a Python test harness in `scripts/run-tests.py`,
but `petta` is the direct command used for the current MeTTa files.

## Design Rules

- Kernel modules should depend on schema ids, kinds, roles, and proposal
  contracts, not concrete OpenPsi names.
- Extensions may propose state changes but should not directly mutate committed
  state.
- All plugin input and output dimensions should be declared in registered
  schemas.
- Safety projection should happen before state blending and commit.
- Audit records should preserve enough information for replay, migration, and
  rollback.
