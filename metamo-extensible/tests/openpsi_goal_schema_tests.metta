!(import! &self ../core/dimension_registry)
!(import! &self ../schemas/magus_goals_v1)
!(bind! &openPsiGoalSchemaSpace (new-space))
!(bind! &openPsiGoalRegistrySpace (new-space))

(= (addOpenPsiGoalSchemaTestDimensions $schemaSpace $dimensions)
   (if (== $dimensions ())
       (AddedOpenPsiGoalSchemaTestDimensions)
       (let* (
          (($head $tail) (decons-atom $dimensions))
          ($ignored (add-atom $schemaSpace $head)))
          (addOpenPsiGoalSchemaTestDimensions $schemaSpace $tail))))

!(addOpenPsiGoalSchemaTestDimensions &openPsiGoalSchemaSpace (openPsiGoalDimensions))

!(test (openPsiGoalSchemaId) openpsi-magus)
!(test (openPsiGoalSchemaVersion) v1)
!(test (length (openPsiGoalDimensions)) 8)
!(test (schemaDimensionCount &openPsiGoalSchemaSpace openpsi-magus goal) 8)
!(test (validateDimensionList openpsi-magus goal (openPsiGoalDimensions)) True)
!(test (validateValuesForSchemaKind &openPsiGoalSchemaSpace openpsi-magus goal (0.5 0.5 0.3 0.3 0.3 0.3 0.5 0.3)) True)
!(test (validateValuesForSchemaKind &openPsiGoalSchemaSpace openpsi-magus goal (0.5 0.5 0.3 0.3 0.3 0.3 0.5 1.5)) False)

!(test (dimensionIndex &openPsiGoalSchemaSpace openpsi-magus goal gInd) 0)
!(test (dimensionIndex &openPsiGoalSchemaSpace openpsi-magus goal gTrans) 1)
!(test (dimensionIndex &openPsiGoalSchemaSpace openpsi-magus goal gHelp) 2)
!(test (dimensionIndex &openPsiGoalSchemaSpace openpsi-magus goal gCurio) 3)
!(test (dimensionIndex &openPsiGoalSchemaSpace openpsi-magus goal gNovel) 4)
!(test (dimensionIndex &openPsiGoalSchemaSpace openpsi-magus goal gSelf) 5)
!(test (dimensionIndex &openPsiGoalSchemaSpace openpsi-magus goal gEthic) 6)
!(test (dimensionIndex &openPsiGoalSchemaSpace openpsi-magus goal gSoc) 7)

!(test (dimensionBounds &openPsiGoalSchemaSpace openpsi-magus goal gInd) (Bounds 0.0 1.0))
!(test (dimensionDefault &openPsiGoalSchemaSpace openpsi-magus goal gInd) 0.5)
!(test (dimensionDefault &openPsiGoalSchemaSpace openpsi-magus goal gCurio) 0.3)
!(test (dimensionRoles &openPsiGoalSchemaSpace openpsi-magus goal gInd) (safety-overgoal))
!(test (dimensionRoles &openPsiGoalSchemaSpace openpsi-magus goal gTrans) (growth-overgoal novelty-seeking))
!(test (dimensionRoles &openPsiGoalSchemaSpace openpsi-magus goal gEthic) (ethical-guard))
!(test (dimensionRoles &openPsiGoalSchemaSpace openpsi-magus goal gSoc) (social-drive))

!(test
   (dimensionsByRole &openPsiGoalSchemaSpace openpsi-magus safety-overgoal)
   ((Dimension openpsi-magus goal gInd 0 0.0 1.0 0.5 (safety-overgoal) v1 none 0.20 "Individuation overgoal")))

!(test
   (dimensionsByKindRole &openPsiGoalSchemaSpace openpsi-magus goal growth-overgoal)
   ((Dimension openpsi-magus goal gTrans 1 0.0 1.0 0.5 (growth-overgoal novelty-seeking) v1 none 0.20 "Transcendence overgoal")))

!(test
   (dimensionsByKindRole &openPsiGoalSchemaSpace openpsi-magus goal social-drive)
   ((Dimension openpsi-magus goal gHelp 2 0.0 1.0 0.3 (growth-goal social-drive) v1 none 0.20 "Helpfulness")
    (Dimension openpsi-magus goal gSoc 7 0.0 1.0 0.3 (social-drive) v1 none 0.20 "Social drive")))

!(test
   (registerSchema &openPsiGoalRegistrySpace (openPsiGoalSchemaId) (openPsiGoalSchemaVersion) (openPsiGoalDimensions) "OpenPsi/MAGUS goal schema")
   (RegisteredSchema openpsi-magus v1))
!(test (schemaVersionRegistered &openPsiGoalRegistrySpace openpsi-magus v1) True)
!(test (schemaDimensionCountVersion &openPsiGoalRegistrySpace openpsi-magus v1 goal) 8)
