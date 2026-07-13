
(= (openPsiNextModulatorValue
      $registrySpace
      $schemaId
      $version
      $modulatorValues
      $id
      $nextValence
      $nextArousal
      $nextApproach
      $nextResolution
      $nextThreshold
      $nextSecuring)
   (case $id
      (
       (valence $nextValence)
       (arousal $nextArousal)
       (approach $nextApproach)
       (resolution $nextResolution)
       (threshold $nextThreshold)
       (securing $nextSecuring)
       ($other (openPsiModulatorValue $registrySpace $schemaId $version $modulatorValues $id))
      )))

(= (openPsiBuildNextModulatorValues
      $registrySpace
      $schemaId
      $version
      $modulatorValues
      $nextValence
      $nextArousal
      $nextApproach
      $nextResolution
      $nextThreshold
      $nextSecuring
      $index
      $count
      $acc)
   (if (== $index $count)
       $acc
       (let*
          (
           ($id (openPsiDimensionIdByIndexVersion $registrySpace $schemaId $version modulator $index))
           ($nextValue
              (openPsiNextModulatorValue
                 $registrySpace
                 $schemaId
                 $version
                 $modulatorValues
                 $id
                 $nextValence
                 $nextArousal
                 $nextApproach
                 $nextResolution
                 $nextThreshold
                 $nextSecuring))
           ($nextAcc (union-atom $acc ($nextValue))))
          (openPsiBuildNextModulatorValues
             $registrySpace
             $schemaId
             $version
             $modulatorValues
             $nextValence
             $nextArousal
             $nextApproach
             $nextResolution
             $nextThreshold
             $nextSecuring
             (+ $index 1)
             $count
             $nextAcc))))

(= (openPsiAppraisalContractDeclared $registrySpace $schemaId $version)
   (if (validateDeclaredDimensionsVersion $registrySpace $schemaId $version goal (openPsiAppraisalRequiredGoals))
       (if (validateDeclaredDimensionsVersion $registrySpace $schemaId $version modulator (openPsiAppraisalRequiredModulators))
           (validateDeclaredDimensionsVersion $registrySpace $schemaId $version stimulus (openPsiAppraisalRequiredStimuli))
           False)
       False))

(= (openPsiValidAppraisalInput
      $registrySpace
      $schemaId
      $version
      (MotivationState $schemaId $goalValues $modulatorValues)
      (StimulusVector $schemaId $stimulusValues))
   (if (openPsiAppraisalContractDeclared $registrySpace $schemaId $version)
       (if (validateValuesForSchemaKindVersion $registrySpace $schemaId $version goal $goalValues)
           (if (validateValuesForSchemaKindVersion $registrySpace $schemaId $version modulator $modulatorValues)
               (validateValuesForSchemaKindVersion $registrySpace $schemaId $version stimulus $stimulusValues)
               False)
           False)
       False))

(= (openPsiAppraiseWithSchema
      $registrySpace
      $schemaId
      $version
      (MotivationState $schemaId $goalValues $modulatorValues)
      (StimulusVector $schemaId $stimulusValues))
   (if (openPsiValidAppraisalInput
         $registrySpace
         $schemaId
         $version
         (MotivationState $schemaId $goalValues $modulatorValues)
         (StimulusVector $schemaId $stimulusValues))
       (let*
          (
           ($gInd (openPsiGoalValue $registrySpace $schemaId $version $goalValues gInd))
           ($gTrans (openPsiGoalValue $registrySpace $schemaId $version $goalValues gTrans))
           ($valence (openPsiModulatorValue $registrySpace $schemaId $version $modulatorValues valence))
           ($arousal (openPsiModulatorValue $registrySpace $schemaId $version $modulatorValues arousal))
           ($approach (openPsiModulatorValue $registrySpace $schemaId $version $modulatorValues approach))
           ($resolution (openPsiModulatorValue $registrySpace $schemaId $version $modulatorValues resolution))
           ($threshold (openPsiModulatorValue $registrySpace $schemaId $version $modulatorValues threshold))
           ($securing (openPsiModulatorValue $registrySpace $schemaId $version $modulatorValues securing))
           ($novelty (openPsiStimulusValue $registrySpace $schemaId $version $stimulusValues novelty))
           ($conduciveness (openPsiStimulusValue $registrySpace $schemaId $version $stimulusValues conduciveness))
           ($risk (openPsiStimulusValue $registrySpace $schemaId $version $stimulusValues risk))
           ($effort (openPsiStimulusValue $registrySpace $schemaId $version $stimulusValues effort))
           ($arousalFeedback (openPsiArousalFeedback $arousal))
           ($transScale (openPsiTransScale $gTrans))
           ($indScale (openPsiIndScale $gInd))
           ($benignNovelty (openPsiBenignNovelty $novelty $risk))
           ($demandingContext (openPsiDemandingContext $effort $risk))
           ($deltaValence (openPsiDeltaValence $conduciveness $benignNovelty $risk $effort))
           ($deltaArousal (openPsiDeltaArousal $novelty $arousalFeedback $risk $effort))
           ($deltaApproach (openPsiDeltaApproach $benignNovelty $conduciveness $risk))
           ($deltaResolution (openPsiDeltaResolution $conduciveness $effort $risk))
           ($deltaThreshold (openPsiDeltaThreshold $risk $demandingContext $conduciveness))
           ($deltaSecuring (openPsiDeltaSecuring $risk $effort $benignNovelty $conduciveness))
           ($nextValence (openPsiNextValence $registrySpace $schemaId $version $valence $deltaValence))
           ($nextArousal (openPsiNextArousal $registrySpace $schemaId $version $arousal $deltaArousal $transScale))
           ($nextApproach (openPsiNextApproach $registrySpace $schemaId $version $approach $deltaApproach $transScale))
           ($nextResolution (openPsiNextResolution $registrySpace $schemaId $version $resolution $deltaResolution))
           ($nextThreshold (openPsiNextThreshold $registrySpace $schemaId $version $threshold $deltaThreshold $indScale))
           ($nextSecuring (openPsiNextSecuring $registrySpace $schemaId $version $securing $deltaSecuring $indScale))
           ($modulatorCount (schemaDimensionCountVersion $registrySpace $schemaId $version modulator))
           ($nextModulatorValues
              (openPsiBuildNextModulatorValues
                 $registrySpace
                 $schemaId
                 $version
                 $modulatorValues
                 $nextValence
                 $nextArousal
                 $nextApproach
                 $nextResolution
                 $nextThreshold
                 $nextSecuring
                 0
                 $modulatorCount
                 ())))
          (MotivationState $schemaId $goalValues $nextModulatorValues))
       (InvalidOpenPsiAppraisal $schemaId $version)))

(= (openPsiAppraise
      $registrySpace
      $version
      (MotivationState $schemaId $goalValues $modulatorValues)
      (StimulusVector $schemaId $stimulusValues))
   (openPsiAppraiseWithSchema
      $registrySpace
      $schemaId
      $version
      (MotivationState $schemaId $goalValues $modulatorValues)
      (StimulusVector $schemaId $stimulusValues)))
