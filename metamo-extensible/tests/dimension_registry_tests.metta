!(import! &self ../core/dimension_registry)
!(bind! &registrySpace (new-space))

(= (registryTestDimensions)
   ((Dimension registry-schema goal safety 0 0.0 1.0 0.5 (safety-overgoal) v1 none 0.20 "Safety overgoal")
    (Dimension registry-schema goal curiosity 1 0.0 1.0 0.3 (growth-overgoal novelty-signal) v1 none 0.20 "Curiosity goal")
    (Dimension registry-schema modulator valence 0 -1.0 1.0 0.0 (affect) v1 decay-linear 0.10 "Valence")
    (Dimension registry-schema modulator threshold 1 0.0 1.0 0.5 (caution-modulator) v1 none 0.10 "Selection threshold")
    (Dimension registry-schema stimulus risk 0 0.0 1.0 0.0 (risk-signal) v1 none 1.00 "Risk stimulus")
    (Dimension registry-schema actionFeature expectedUtility 0 -1.0 1.0 0.0 (score-feature) v1 none 1.00 "Expected utility")))

!(registerSchema &registrySpace registry-schema v1 (registryTestDimensions) "Registry test schema")

!(test (schemaRegistered &registrySpace registry-schema) True)
!(test (schemaRecords &registrySpace registry-schema)
       ((Schema registry-schema v1 "Registry test schema")))
!(test (schemaIdOf (Schema registry-schema v1 "Registry test schema")) registry-schema)
!(test (schemaVersionOf (Schema registry-schema v1 "Registry test schema")) v1)
!(test (schemaDescriptionOf (Schema registry-schema v1 "Registry test schema")) "Registry test schema")

!(test (dimensionById &registrySpace registry-schema goal safety)
       (Dimension registry-schema goal safety 0 0.0 1.0 0.5 (safety-overgoal) v1 none 0.20 "Safety overgoal"))
!(test (dimensionByIndex &registrySpace registry-schema modulator 1)
       (Dimension registry-schema modulator threshold 1 0.0 1.0 0.5 (caution-modulator) v1 none 0.10 "Selection threshold"))
!(test (dimensionIdByIndex &registrySpace registry-schema stimulus 0) risk)
!(test (dimensionKindById &registrySpace registry-schema actionFeature expectedUtility) actionFeature)

!(test (schemaHasRole &registrySpace registry-schema safety-overgoal) True)
!(test (schemaHasRole &registrySpace registry-schema missing-role) False)
!(test (dimensionIndicesByRole &registrySpace registry-schema caution-modulator)
       ((DimensionIndex registry-schema modulator threshold 1)))
!(test (dimensionsByKindRole &registrySpace registry-schema goal novelty-signal)
       ((Dimension registry-schema goal curiosity 1 0.0 1.0 0.3 (growth-overgoal novelty-signal) v1 none 0.20 "Curiosity goal")))

!(test (validateSchemaDimensions registry-schema (registryTestDimensions)) True)
!(test
   (validateSchemaDimensions registry-schema
      ((Dimension registry-schema goal safety 0 0.0 1.0 0.5 (safety-overgoal) v1 none 0.20 "Safety overgoal")
       (Dimension registry-schema goal curiosity 0 0.0 1.0 0.3 (growth-overgoal) v1 none 0.20 "Duplicate index")))
   False)
!(test
   (validateSchemaDimensions registry-schema
      ((Dimension registry-schema goal safety 0 0.0 1.0 0.5 (invalid-role) v1 none 0.20 "Invalid role")))
   False)
!(test
   (registerDimension &registrySpace
      (Dimension registry-schema goal invalidRoleGoal 2 0.0 1.0 0.5 (invalid-role) v1 none 0.20 "Invalid role"))
   (InvalidDimension registry-schema goal invalidRoleGoal))

!(test (validateStimulusDimensions &registrySpace registry-schema (risk)) True)
!(test (validateStimulusDimensions &registrySpace registry-schema (risk missingStimulus)) False)
!(test (validateActionFeatureDimensions &registrySpace registry-schema (expectedUtility)) True)
!(test (validateActionFeatureDimensions &registrySpace registry-schema (expectedUtility missingFeature)) False)
!(test (validatePluginStimulusInputs &registrySpace registry-schema (risk)) True)
!(test (validatePluginStimulusInputs &registrySpace registry-schema (risk missingStimulus)) False)
!(test (validatePluginActionFeatureOutputs &registrySpace registry-schema (expectedUtility)) True)
!(test (validatePluginActionFeatureOutputs &registrySpace registry-schema (expectedUtility missingFeature)) False)
!(test (validatePluginDimensionContract &registrySpace registry-schema (risk) (expectedUtility)) True)
!(test (validatePluginDimensionContract &registrySpace registry-schema (risk missingStimulus) (expectedUtility)) False)
!(test (validatePluginDimensionContract &registrySpace registry-schema (risk) (expectedUtility missingFeature)) False)
!(test
   (validatePluginDimensionContract
      &registrySpace
      (PluginDimensionContract registry-schema (risk) (expectedUtility)))
   True)

!(test (validateStimulusVector &registrySpace registry-schema (0.8)) True)
!(test (validateStimulusVector &registrySpace registry-schema (1.8)) False)
!(test (validateStimulusVector &registrySpace missing-schema ()) False)
!(test (validateActionFeatureVector &registrySpace registry-schema (0.8)) True)
!(test (validateActionFeatureVector &registrySpace registry-schema (1.8)) False)
!(test (validateActionFeatureVector &registrySpace missing-schema ()) False)

!(bind! &versionedSchemaSpace (new-space))
!(registerSchema &versionedSchemaSpace versioned-schema v1
   ((Dimension versioned-schema goal safety 0 0.0 1.0 0.5 (safety-overgoal) v1 none 0.20 "Safety overgoal")
    (Dimension versioned-schema stimulus risk 0 0.0 1.0 0.0 (risk-signal) v1 none 1.00 "Risk stimulus v1")
    (Dimension versioned-schema actionFeature expectedUtility 0 -1.0 1.0 0.0 (score-feature) v1 none 1.00 "Expected utility v1"))
   "First schema")

!(test
   (registerSchema &versionedSchemaSpace versioned-schema v2
      ((Dimension versioned-schema goal curiosity 0 0.0 1.0 0.3 (growth-overgoal) v2 none 0.20 "Curiosity goal")
       (Dimension versioned-schema stimulus risk 0 0.0 2.0 0.0 (risk-signal) v2 none 1.00 "Risk stimulus v2")
       (Dimension versioned-schema actionFeature expectedUtility 0 -2.0 2.0 0.0 (score-feature) v2 none 1.00 "Expected utility v2"))
      "Second schema")
   (RegisteredSchema versioned-schema v2))
!(test (schemaVersionRegistered &versionedSchemaSpace versioned-schema v1) True)
!(test (schemaVersionRegistered &versionedSchemaSpace versioned-schema v2) True)
!(test (schemaVersionRegistered &versionedSchemaSpace versioned-schema v3) False)
!(test (schemaVersionRecords &versionedSchemaSpace versioned-schema v1)
       ((Schema versioned-schema v1 "First schema")))
!(test (schemaVersionRecords &versionedSchemaSpace versioned-schema v2)
       ((Schema versioned-schema v2 "Second schema")))
!(test (dimensionDeclaredVersion &versionedSchemaSpace versioned-schema v1 goal curiosity) False)
!(test (dimensionDeclaredVersion &versionedSchemaSpace versioned-schema v2 goal curiosity) True)
!(test (dimensionByIdVersion &versionedSchemaSpace versioned-schema v2 goal curiosity)
       (Dimension versioned-schema goal curiosity 0 0.0 1.0 0.3 (growth-overgoal) v2 none 0.20 "Curiosity goal"))
!(test (validateStimulusVectorVersion &versionedSchemaSpace versioned-schema v1 (1.5)) False)
!(test (validateStimulusVectorVersion &versionedSchemaSpace versioned-schema v2 (1.5)) True)
!(test (validateStimulusDimensionsVersion &versionedSchemaSpace versioned-schema v1 (risk)) True)
!(test (validateStimulusDimensionsVersion &versionedSchemaSpace versioned-schema v1 (risk missingRisk)) False)
!(test (validatePluginStimulusInputsVersion &versionedSchemaSpace versioned-schema v1 (risk)) True)
!(test (validatePluginStimulusInputsVersion &versionedSchemaSpace versioned-schema v1 (risk missingRisk)) False)
!(test (validatePluginActionFeatureOutputsVersion &versionedSchemaSpace versioned-schema v1 (expectedUtility)) True)
!(test (validatePluginActionFeatureOutputsVersion &versionedSchemaSpace versioned-schema v1 (expectedUtility missingFeature)) False)
!(test (validatePluginDimensionContractVersion &versionedSchemaSpace versioned-schema v1 (risk) (expectedUtility)) True)
!(test (validatePluginDimensionContractVersion &versionedSchemaSpace versioned-schema v1 (risk missingRisk) (expectedUtility)) False)
!(test (validatePluginDimensionContractVersion &versionedSchemaSpace versioned-schema v1 (risk) (expectedUtility missingFeature)) False)
!(test
   (validatePluginDimensionContractVersion
      &versionedSchemaSpace
      (PluginDimensionContract versioned-schema v1 (risk) (expectedUtility)))
   True)
!(test
   (registerSchema &versionedSchemaSpace versioned-schema v1
      ((Dimension versioned-schema goal duplicateSafety 0 0.0 1.0 0.5 (safety-overgoal) v1 none 0.20 "Duplicate schema version"))
      "Duplicate first schema")
   (SchemaAlreadyRegistered versioned-schema))
!(test (dimensionDeclaredVersion &versionedSchemaSpace versioned-schema v1 goal duplicateSafety) False)

!(bind! &versionMismatchSpace (new-space))
!(test
   (registerSchema &versionMismatchSpace mismatch-schema v2
      ((Dimension mismatch-schema goal safety 0 0.0 1.0 0.5 (safety-overgoal) v1 none 0.20 "Wrong dimension version"))
      "Version mismatch schema")
   (InvalidSchema mismatch-schema))
!(test (schemaVersionRegistered &versionMismatchSpace mismatch-schema v2) False)

!(bind! &dimensionConflictSpace (new-space))
!(registerDimension &dimensionConflictSpace
   (Dimension conflict-schema goal safety 0 0.0 1.0 0.5 (safety-overgoal) v1 none 0.20 "Safety overgoal"))

!(test
   (registerSchema &dimensionConflictSpace conflict-schema v1
      ((Dimension conflict-schema goal curiosity 0 0.0 1.0 0.3 (growth-overgoal) v1 none 0.20 "Curiosity goal"))
      "Index conflict schema")
   (DimensionAlreadyRegistered conflict-schema goal curiosity))
!(test (schemaRegistered &dimensionConflictSpace conflict-schema) False)
!(test (schemaRecords &dimensionConflictSpace conflict-schema) ())
!(test
   (registerSchema &dimensionConflictSpace conflict-schema v2
      ((Dimension conflict-schema goal curiosity 0 0.0 1.0 0.3 (growth-overgoal) v2 none 0.20 "Curiosity goal"))
      "Non-conflicting schema version")
   (RegisteredSchema conflict-schema v2))
!(test (schemaVersionRegistered &dimensionConflictSpace conflict-schema v2) True)
