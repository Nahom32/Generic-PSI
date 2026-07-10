!(import! &self ../core/dimension_registry)
!(import! &self ../extensions/openpsi_appraisal/appraisal)
!(import! &self ../schemas/magus_goals_v1)
!(import! &self ../schemas/openpsi_modulators_v1)
!(bind! &openPsiAppraisalRegistrySpace (new-space))
!(bind! &openPsiMissingStimulusRegistrySpace (new-space))

(= (openPsiAppraisalTestStimulusDimensions)
   ((Dimension openpsi-magus stimulus novelty 0 0.0 1.0 0.0 (novelty-signal) v1 none 1.00 "Novelty")
    (Dimension openpsi-magus stimulus conduciveness 1 -1.0 1.0 0.0 (affect) v1 none 1.00 "Conduciveness")
    (Dimension openpsi-magus stimulus risk 2 0.0 1.0 0.0 (risk-signal) v1 none 1.00 "Risk")
    (Dimension openpsi-magus stimulus effort 3 0.0 1.0 0.0 () v1 none 1.00 "Effort")))

(= (openPsiAppraisalTestDimensions)
   (union-atom
      (union-atom (openPsiGoalDimensions) (openPsiModulatorDimensions))
      (openPsiAppraisalTestStimulusDimensions)))

(= (openPsiAppraisalGoalValues)
   (0.5 0.5 0.3 0.3 0.3 0.3 0.5 0.3))

(= (openPsiAppraisalModulatorValues)
   (0.0 0.0 0.0 0.5 0.5 0.5))

!(let $dimensions (openPsiAppraisalTestDimensions)
   (registerSchema
      &openPsiAppraisalRegistrySpace
      openpsi-magus
      v1
      $dimensions
      "OpenPsi appraisal test schema"))

!(let* (
   ($goals (openPsiGoalDimensions))
   ($modulators (openPsiModulatorDimensions))
   ($dimensions (union-atom $goals $modulators)))
   (registerSchema
      &openPsiMissingStimulusRegistrySpace
      openpsi-magus
      v1
      $dimensions
      "OpenPsi appraisal schema without stimulus dimensions"))

!(test (openPsiAppraisalExtensionId) openpsi-appraisal)
!(test (openPsiAppraisalKind) appraisal)
!(test (openPsiAppraisalRequiredGoals) (gInd gTrans))
!(test (openPsiAppraisalRequiredModulators) (valence arousal approach resolution threshold securing))
!(test (openPsiAppraisalRequiredStimuli) (novelty conduciveness risk effort))

!(test (schemaDimensionCountVersion &openPsiAppraisalRegistrySpace openpsi-magus v1 goal) 8)
!(test (schemaDimensionCountVersion &openPsiAppraisalRegistrySpace openpsi-magus v1 modulator) 6)
!(test (schemaDimensionCountVersion &openPsiAppraisalRegistrySpace openpsi-magus v1 stimulus) 4)
!(test (openPsiAppraisalContractDeclared &openPsiAppraisalRegistrySpace openpsi-magus v1) True)
!(test (openPsiAppraisalContractDeclared &openPsiMissingStimulusRegistrySpace openpsi-magus v1) False)
!(test (openPsiGoalValue &openPsiAppraisalRegistrySpace openpsi-magus v1 (openPsiAppraisalGoalValues) gInd) 0.5)
!(test (openPsiModulatorValue &openPsiAppraisalRegistrySpace openpsi-magus v1 (openPsiAppraisalModulatorValues) threshold) 0.5)
!(test (openPsiStimulusValue &openPsiAppraisalRegistrySpace openpsi-magus v1 (0.0 0.0 0.5 0.5) risk) 0.5)

!(test
   (openPsiValidAppraisalInput
      &openPsiAppraisalRegistrySpace
      openpsi-magus
      v1
      (MotivationState openpsi-magus (openPsiAppraisalGoalValues) (openPsiAppraisalModulatorValues))
      (StimulusVector openpsi-magus (0.0 0.0 0.0 0.0)))
   True)

!(test
   (openPsiValidAppraisalInput
      &openPsiAppraisalRegistrySpace
      openpsi-magus
      v1
      (MotivationState openpsi-magus (openPsiAppraisalGoalValues) (openPsiAppraisalModulatorValues))
      (StimulusVector openpsi-magus (0.0 0.0 1.5 0.0)))
   False)

!(test
   (openPsiAppraise
      &openPsiAppraisalRegistrySpace
      v1
      (MotivationState openpsi-magus (openPsiAppraisalGoalValues) (openPsiAppraisalModulatorValues))
      (StimulusVector openpsi-magus (0.0 0.0 0.0 0.0)))
   (MotivationState openpsi-magus (openPsiAppraisalGoalValues) (openPsiAppraisalModulatorValues)))

!(test
   (openPsiAppraise
      &openPsiAppraisalRegistrySpace
      v1
      (MotivationState openpsi-magus (openPsiAppraisalGoalValues) (openPsiAppraisalModulatorValues))
      (StimulusVector openpsi-magus (0.0 0.0 0.5 0.5)))
   (MotivationState openpsi-magus (openPsiAppraisalGoalValues) (-0.1 0.1 -0.1 0.4 0.6 0.6)))

!(test
   (openPsiAppraise
      &openPsiMissingStimulusRegistrySpace
      v1
      (MotivationState openpsi-magus (openPsiAppraisalGoalValues) (openPsiAppraisalModulatorValues))
      (StimulusVector openpsi-magus (0.0 0.0 0.5 0.5)))
   (InvalidOpenPsiAppraisal openpsi-magus v1))
