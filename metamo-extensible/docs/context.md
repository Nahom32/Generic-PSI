# MetaMo Extensible Context

Status as of 2026-07-02.

## Project Direction

`metamo-extensible/` is being built as the new pluggable MetaMo-style
motivation substrate. The older `open-psi/` implementation is still useful as
legacy input and behavioral reference material, but the current implementation
work is concentrated in `metamo-extensible/`.

The intended architecture is:

- vector schema registry
- extension/plugin API
- proposal bus
- merge and safety kernel
- incremental embodiment
- audit, migration, verification, and neural adapters

Many files under `core/`, `schemas/`, `extensions/`, `domains/`, and `tests/`
are still placeholders. Treat their presence as module boundaries, not finished
implementation.

## Implemented Slice

The current working slice is the schema foundation:

- `core/vector_schema.metta`
- `core/dimension_registry.metta`
- `tests/vector_schema_tests.metta`
- `tests/dimension_registry_tests.metta`

`vector_schema.metta` defines first-class dimension records for:

- `goal`
- `modulator`
- `stimulus`
- `actionFeature`

Each `Dimension` carries schema id, kind, id, index, bounds, default value,
role tags, version, decay policy, update limit, and description.

Implemented validation includes:

- valid dimension kind
- valid role tags
- nonnegative indices
- valid lower/upper bounds
- default value inside bounds
- duplicate id rejection within a schema/kind dimension list
- duplicate index rejection within a schema/kind dimension list
- contiguous index validation
- schema/kind matching
- vector length and bounds checks for goal, modulator, stimulus, and
  action-feature vectors
- motivation-state validation for `X = G x M`

## Registry Status

`dimension_registry.metta` now supports:

- schema metadata registration with `(Schema schema-id version description)`
- version-aware schema lookup
- registering multiple versions under the same schema id
- rejecting duplicate exact schema versions
- rejecting dimensions whose embedded version does not match the schema version
  being registered
- version-scoped dimension identity and index conflict checks
- lookup by id, index, kind, role, and version-aware variants

The registry now treats `(schema-id, version)` as the schema identity for
registration and conflict checks. Older unversioned helper functions still
exist for existing tests and simple callers.

## Plugin Dimension Contracts

Plugin-facing validators have been added so extensions cannot consume or emit
undeclared dimensions:

- `validatePluginStimulusInputs`
- `validatePluginStimulusInputsVersion`
- `validatePluginActionFeatureOutputs`
- `validatePluginActionFeatureOutputsVersion`
- `validatePluginDimensionContract`
- `validatePluginDimensionContractVersion`

These wrap the lower-level stimulus/action-feature declaration checks and
support both direct argument form and `PluginDimensionContract` record form.

This completes the task-set item:

```text
Add stimulus and action-feature validators so plugins cannot consume or emit
undeclared dimensions.
```

## Test Status

Focused PeTTa commands passing at this point:

```sh
petta metamo-extensible/tests/vector_schema_tests.metta
petta metamo-extensible/tests/dimension_registry_tests.metta
petta metamo-extensible/core/dimension_registry.metta
```

The registry tests cover:

- schema registration
- duplicate schema-version rejection
- invalid schema rejection
- duplicate dimension id/index rejection
- versioned schema coexistence
- version-specific vector bounds
- plugin stimulus input declaration checks
- plugin action-feature output declaration checks
- failed registration avoiding partial schema mutation

## Current Gaps

The next unfinished item in the schema section is compatibility with the simple
legacy `open-psi/` atom forms:

- `(modulator name value)`
- `(demand name min max result)`
- future `(goal name value)`

The next larger implementation area is the OpenPsi/MAGUS default instantiation:

- populate `schemas/openpsi_modulators_v1.metta`
- populate `schemas/magus_goals_v1.metta`
- populate `schemas/research_assistant_stimuli_v1.metta`
- assign generic role tags
- implement the default appraisal and decision extensions
- add a compatibility adapter from existing `open-psi/` facts into validated
  MetaMo state

The extension API, proposal bus, safety kernel, migration, audit log, and neural
adapter modules remain mostly placeholder boundaries.

## Design Rules To Preserve

- Kernel modules should depend on schema ids, kinds, roles, and contracts, not
  concrete OpenPsi names.
- Extensions should emit proposals rather than directly mutating committed
  state.
- Plugin input and output dimensions must be declared in registered schemas.
- Schema versions must be explicit and auditable.
- Safety projection should happen before blending and commit.
- Audit records should preserve enough metadata for replay, migration, and
  rollback.
