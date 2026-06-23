!(import! &self ../core/vector_schema)
!(bind! &schemaSpace (new-space))


(= (addDimensionsToSpace $schemaSpace)
    (collapse (let $atoms (superpose (
              (Dimension test-schema goal safety 0 0.0 1.0 0.5 (safety-overgoal) v1 none 0.20 "Safety overgoal")
              (Dimension test-schema goal curiosity 1 0.0 1.0 0.3 (growth-goal novelty-seeking) v1 none 0.20 "Curiosity goal")
              (Dimension test-schema modulator valence 0 -1.0 1.0 0.0 (affect) v1 decay-linear 0.10 "Valence")
              (Dimension test-schema modulator threshold 1 0.0 1.0 0.5 (caution-modulator) v1 none 0.10 "Selection threshold")
              (Dimension test-schema stimulus risk 0 0.0 1.0 0.0 (risk-signal) v1 none 1.00 "Risk stimulus")
              (Dimension test-schema actionFeature expectedUtility 0 -1.0 1.0 0.0 (score-feature) v1 none 1.00 "Expected utility")
            )
          )
            (add-atom $schemaSpace $atoms)
          )
    )
)

!(addDimensionsToSpace &schemaSpace)
!(test (validDimensionKind goal) True)
!(test (validDimensionKind modulator) True)
!(test (validDimensionKind stimulus) True)
!(test (validDimensionKind actionFeature) True)
!(test (validDimensionKind unsupportedKind) False)

!(test (schemaMember safety-overgoal (safety-overgoal ethical-guard)) True)
!(test (schemaMember social-drive (safety-overgoal ethical-guard)) False)

!(test (valueWithinBounds 0.5 0.0 1.0) True)
!(test (valueWithinBounds -0.1 0.0 1.0) False)
!(test (valueWithinBounds 1.1 0.0 1.0) False)

!(test (dimensionSchemaId (Dimension s goal g 0 0.0 1.0 0.5 (role) v1 none 0.1 "d")) s)
!(test (dimensionKindOf (Dimension s goal g 0 0.0 1.0 0.5 (role) v1 none 0.1 "d")) goal)
!(test (dimensionIdOf (Dimension s goal g 0 0.0 1.0 0.5 (role) v1 none 0.1 "d")) g)
!(test (dimensionIndexOf (Dimension s goal g 0 0.0 1.0 0.5 (role) v1 none 0.1 "d")) 0)
!(test (dimensionBoundsOf (Dimension s goal g 0 0.0 1.0 0.5 (role) v1 none 0.1 "d")) (Bounds 0.0 1.0))
!(test (dimensionDefaultOf (Dimension s goal g 0 0.0 1.0 0.5 (role) v1 none 0.1 "d")) 0.5)
!(test (dimensionRolesOf (Dimension s goal g 0 0.0 1.0 0.5 (role) v1 none 0.1 "d")) (role))
!(test (dimensionVersionOf (Dimension s goal g 0 0.0 1.0 0.5 (role) v1 none 0.1 "d")) v1)
!(test (dimensionDecayPolicyOf (Dimension s goal g 0 0.0 1.0 0.5 (role) v1 decay-linear 0.1 "d")) decay-linear)
!(test (dimensionUpdateLimitOf (Dimension s goal g 0 0.0 1.0 0.5 (role) v1 none 0.1 "d")) 0.1)
!(test (dimensionDescriptionOf (Dimension s goal g 0 0.0 1.0 0.5 (role) v1 none 0.1 "d")) "d")
!(test (dimensionHasRole (Dimension s goal g 0 0.0 1.0 0.5 (role other-role) v1 none 0.1 "d") other-role) True)
!(test (dimensionHasRole (Dimension s goal g 0 0.0 1.0 0.5 (role) v1 none 0.1 "d") missing-role) False)

!(test (validDimension (Dimension s goal g 0 0.0 1.0 0.5 (role) v1 none 0.1 "d")) True)
!(test (validDimension (Dimension s unsupportedKind g 0 0.0 1.0 0.5 (role) v1 none 0.1 "d")) False)
!(test (validDimension (Dimension s goal g -1 0.0 1.0 0.5 (role) v1 none 0.1 "d")) False)
!(test (validDimension (Dimension s goal g 0 1.0 0.0 0.5 (role) v1 none 0.1 "d")) False)
!(test (validDimension (Dimension s goal g 0 0.0 1.0 1.5 (role) v1 none 0.1 "d")) False)

!(test (dimensionIndex &schemaSpace test-schema goal safety) 0)
!(test (dimensionBounds &schemaSpace test-schema modulator valence) (Bounds -1.0 1.0))
!(test (dimensionDefault &schemaSpace test-schema modulator threshold) 0.5)
!(test (dimensionRoles &schemaSpace test-schema goal curiosity) (growth-goal novelty-seeking))
!(test (schemaDimensionCount &schemaSpace test-schema goal) 2)
!(test (schemaDimensionCount &schemaSpace test-schema modulator) 2)
!(test (schemaDimensionCount &schemaSpace test-schema stimulus) 1)
!(test (schemaDimensionCount &schemaSpace test-schema actionFeature) 1)
!(test (dimensionsByRole &schemaSpace test-schema safety-overgoal)
       ((Dimension test-schema goal safety 0 0.0 1.0 0.5 (safety-overgoal) v1 none 0.20 "Safety overgoal")))
!(test (dimensionsByRole &schemaSpace test-schema caution-modulator)
       ((Dimension test-schema modulator threshold 1 0.0 1.0 0.5 (caution-modulator) v1 none 0.10 "Selection threshold")))

!(test
   (validateDimensionList test-schema goal
      ((Dimension test-schema goal safety 0 0.0 1.0 0.5 (safety-overgoal) v1 none 0.20 "Safety overgoal")
       (Dimension test-schema goal curiosity 1 0.0 1.0 0.3 (growth-goal novelty-seeking) v1 none 0.20 "Curiosity goal")))
   True)

!(test
   (validateDimensionList test-schema goal
      ((Dimension test-schema goal safety 0 0.0 1.0 0.5 (safety-overgoal) v1 none 0.20 "Safety overgoal")
       (Dimension test-schema goal safety 1 0.0 1.0 0.3 (growth-goal) v1 none 0.20 "Duplicate id")))
   False)

!(test
   (validateDimensionList test-schema goal
      ((Dimension test-schema goal safety 0 0.0 1.0 0.5 (safety-overgoal) v1 none 0.20 "Safety overgoal")
       (Dimension test-schema goal curiosity 0 0.0 1.0 0.3 (growth-goal) v1 none 0.20 "Duplicate index")))
   False)

!(test
   (validateDimensionList test-schema goal
      ((Dimension test-schema goal safety 0 0.0 1.0 0.5 (safety-overgoal) v1 none 0.20 "Safety overgoal")
       (Dimension test-schema goal curiosity 2 0.0 1.0 0.3 (growth-goal) v1 none 0.20 "Index gap")))
   False)

!(test
   (validateDimensionList other-schema goal
      ((Dimension test-schema goal safety 0 0.0 1.0 0.5 (safety-overgoal) v1 none 0.20 "Wrong schema")))
   False)

!(test
   (validateDimensionList test-schema modulator
      ((Dimension test-schema goal safety 0 0.0 1.0 0.5 (safety-overgoal) v1 none 0.20 "Wrong kind")))
   False)

!(test (validateValuesForSchemaKind &schemaSpace test-schema goal (0.8 0.2)) True)
!(test (validateValuesForSchemaKind &schemaSpace test-schema goal (1.2 0.2)) False)
!(test (validateValuesForSchemaKind &schemaSpace test-schema goal (0.8)) False)
!(test (validateValuesForSchemaKind &schemaSpace test-schema modulator (0.0 0.8)) True)
!(test (validateValuesForSchemaKind &schemaSpace test-schema modulator (-1.2 0.8)) False)

!(test (validateMotivationState &schemaSpace  (MotivationState test-schema (0.8 0.2) (0.0 0.8))) True)
!(test (validateMotivationState &schemaSpace (MotivationState test-schema (0.8 0.2) (0.0 1.8))) False)
