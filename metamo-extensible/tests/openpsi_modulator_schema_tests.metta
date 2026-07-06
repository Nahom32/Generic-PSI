!(import! &self ../core/dimension_registry)
!(import! &self ../schemas/openpsi_modulators_v1)
!(bind! &openPsiModulatorSchemaSpace (new-space))

(= (addOpenPsiModulatorSchemaTestDimensions $schemaSpace $dimensions)
   (if (== $dimensions ())
       (AddedOpenPsiModulatorSchemaTestDimensions)
       (let* (
          (($head $tail) (decons-atom $dimensions))
          ($ignored (add-atom $schemaSpace $head)))
          (addOpenPsiModulatorSchemaTestDimensions $schemaSpace $tail))))

!(addOpenPsiModulatorSchemaTestDimensions &openPsiModulatorSchemaSpace (openPsiModulatorDimensions))

!(test (openPsiModulatorSchemaId) openpsi-magus)
!(test (openPsiModulatorSchemaVersion) v1)
!(test (length (openPsiModulatorDimensions)) 6)
!(test (schemaDimensionCount &openPsiModulatorSchemaSpace openpsi-magus modulator) 6)
!(test (validateValuesForSchemaKind &openPsiModulatorSchemaSpace openpsi-magus modulator (0.0 0.0 0.0 0.5 0.5 0.5)) True)
!(test (validateValuesForSchemaKind &openPsiModulatorSchemaSpace openpsi-magus modulator (0.0 0.0 0.0 0.5 0.5 1.5)) False)

!(test (dimensionIndex &openPsiModulatorSchemaSpace openpsi-magus modulator valence) 0)
!(test (dimensionIndex &openPsiModulatorSchemaSpace openpsi-magus modulator arousal) 1)
!(test (dimensionIndex &openPsiModulatorSchemaSpace openpsi-magus modulator approach) 2)
!(test (dimensionIndex &openPsiModulatorSchemaSpace openpsi-magus modulator resolution) 3)
!(test (dimensionIndex &openPsiModulatorSchemaSpace openpsi-magus modulator threshold) 4)
!(test (dimensionIndex &openPsiModulatorSchemaSpace openpsi-magus modulator securing) 5)

!(test (dimensionBounds &openPsiModulatorSchemaSpace openpsi-magus modulator valence) (Bounds -1.0 1.0))
!(test (dimensionDefault &openPsiModulatorSchemaSpace openpsi-magus modulator threshold) 0.5)
!(test (dimensionRoles &openPsiModulatorSchemaSpace openpsi-magus modulator arousal) (exploration-modulator))
!(test (dimensionRoles &openPsiModulatorSchemaSpace openpsi-magus modulator approach) (exploration-modulator))
!(test (dimensionRoles &openPsiModulatorSchemaSpace openpsi-magus modulator threshold) (caution-modulator))
!(test (dimensionRoles &openPsiModulatorSchemaSpace openpsi-magus modulator securing) (caution-modulator))

!(test
   (dimensionsByRole &openPsiModulatorSchemaSpace openpsi-magus caution-modulator)
   ((Dimension openpsi-magus modulator threshold 4 0.0 1.0 0.5 (caution-modulator) v1 none 0.10 "Selection threshold")
    (Dimension openpsi-magus modulator securing 5 0.0 1.0 0.5 (caution-modulator) v1 none 0.10 "Securing")))

!(test
   (dimensionsByKindRole &openPsiModulatorSchemaSpace openpsi-magus modulator exploration-modulator)
   ((Dimension openpsi-magus modulator arousal 1 0.0 1.0 0.0 (exploration-modulator) v1 decay-linear 0.10 "Arousal")
    (Dimension openpsi-magus modulator approach 2 -1.0 1.0 0.0 (exploration-modulator) v1 decay-linear 0.10 "Approach tendency")))
