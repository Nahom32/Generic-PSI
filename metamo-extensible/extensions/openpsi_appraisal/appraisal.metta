!(import! &self ../../core/dimension_registry)

;; Schema-aware OpenPsi appraisal.
;;
;; The extension still implements the concrete OpenPsi equations for valence,
;; arousal, approach, resolution, threshold, and securing, but all vector access
;; goes through registered Dimension metadata. This lets callers reorder
;; dimensions or add unrelated dimensions without changing the appraisal logic.

(= (openPsiAppraisalExtensionId) openpsi-appraisal)
(= (openPsiAppraisalKind) appraisal)
(= (openPsiAppraisalRequiredGoals) (gInd gTrans))
(= (openPsiAppraisalRequiredModulators) (valence arousal approach resolution threshold securing))
(= (openPsiAppraisalRequiredStimuli) (novelty conduciveness risk effort))

(= (stimulusVectorSchemaId (StimulusVector $schemaId $values))
   $schemaId)

(= (stimulusVectorValues (StimulusVector $schemaId $values))
   $values)

(= (motivationStateSchemaId (MotivationState $schemaId $goalValues $modulatorValues))
   $schemaId)

(= (motivationStateGoalValues (MotivationState $schemaId $goalValues $modulatorValues))
   $goalValues)

(= (motivationStateModulatorValues (MotivationState $schemaId $goalValues $modulatorValues))
   $modulatorValues)

(= (openPsiClamp $lower $upper $value)
   (if (< $value $lower)
       $lower
       (if (> $value $upper)
           $upper
           $value)))

(= (openPsiBoundedDelta $delta $scale $updateLimit)
   (openPsiClamp (- 0.0 $updateLimit) $updateLimit (* $delta $scale)))

(= (openPsiDimensionIndexByIdVersion $registrySpace $schemaId $version $kind $id)
   (match $registrySpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
      $index))

(= (openPsiDimensionLowerByIdVersion $registrySpace $schemaId $version $kind $id)
   (match $registrySpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
      $lower))

(= (openPsiDimensionUpperByIdVersion $registrySpace $schemaId $version $kind $id)
   (match $registrySpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
      $upper))

(= (openPsiDimensionUpdateLimitByIdVersion $registrySpace $schemaId $version $kind $id)
   (match $registrySpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
      $updateLimit))

(= (openPsiDimensionIdByIndexVersion $registrySpace $schemaId $version $kind $index)
   (match $registrySpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
      $id))

(= (openPsiValueByDimensionId $registrySpace $schemaId $version $kind $id $values)
   (let $index (openPsiDimensionIndexByIdVersion $registrySpace $schemaId $version $kind $id)
      (index-atom $values $index)))

(= (openPsiGoalValue $registrySpace $schemaId $version $goalValues $id)
   (openPsiValueByDimensionId $registrySpace $schemaId $version goal $id $goalValues))

(= (openPsiModulatorValue $registrySpace $schemaId $version $modulatorValues $id)
   (openPsiValueByDimensionId $registrySpace $schemaId $version modulator $id $modulatorValues))

(= (openPsiStimulusValue $registrySpace $schemaId $version $stimulusValues $id)
   (openPsiValueByDimensionId $registrySpace $schemaId $version stimulus $id $stimulusValues))

(= (openPsiBoundedModulatorUpdate $registrySpace $schemaId $version $id $current $delta $scale)
   (let*
      (
       ($lower (openPsiDimensionLowerByIdVersion $registrySpace $schemaId $version modulator $id))
       ($upper (openPsiDimensionUpperByIdVersion $registrySpace $schemaId $version modulator $id))
       ($updateLimit (openPsiDimensionUpdateLimitByIdVersion $registrySpace $schemaId $version modulator $id))
       ($boundedDelta (openPsiBoundedDelta $delta $scale $updateLimit)))
      (openPsiClamp $lower $upper (+ $current $boundedDelta))))

(= (openPsiArousalFeedback $arousal)
   (* -0.10 $arousal))

(= (openPsiTransScale $gTrans)
   (+ 1.0 (* 0.50 $gTrans)))

(= (openPsiIndScale $gInd)
   (+ 1.0 (* 0.50 $gInd)))

(= (openPsiBenignNovelty $novelty $risk)
   (* $novelty (- 1.0 $risk)))

(= (openPsiDemandingContext $effort $risk)
   (+ (* 0.50 $effort) (* 0.50 $risk)))

(= (openPsiDeltaValence $conduciveness $benignNovelty $risk $effort)
   (+ (+ (* 0.35 $conduciveness) (* 0.20 $benignNovelty))
      (+ (* -0.45 $risk) (* -0.20 $effort))))

(= (openPsiDeltaArousal $novelty $arousalFeedback $risk $effort)
   (+ (+ (* 0.35 $novelty) $arousalFeedback)
      (+ (* 0.30 $risk) (* 0.20 $effort))))

(= (openPsiDeltaApproach $benignNovelty $conduciveness $risk)
   (+ (+ (* 0.35 $benignNovelty) (* 0.35 $conduciveness))
      (* -0.50 $risk)))

(= (openPsiDeltaResolution $conduciveness $effort $risk)
   (+ (* 0.40 $conduciveness)
      (+ (* -0.25 $effort) (* -0.30 $risk))))

(= (openPsiDeltaThreshold $risk $demandingContext $conduciveness)
   (+ (+ (* 0.45 $risk) (* 0.25 $demandingContext))
      (* -0.20 $conduciveness)))

(= (openPsiDeltaSecuring $risk $effort $benignNovelty $conduciveness)
   (+ (+ (* 0.45 $risk) (* 0.30 $effort))
      (+ (* -0.25 $benignNovelty) (* -0.20 $conduciveness))))

(= (openPsiNextValence $registrySpace $schemaId $version $current $delta)
   (openPsiBoundedModulatorUpdate $registrySpace $schemaId $version valence $current $delta 1.0))

(= (openPsiNextArousal $registrySpace $schemaId $version $current $delta $transScale)
   (openPsiBoundedModulatorUpdate $registrySpace $schemaId $version arousal $current $delta $transScale))

(= (openPsiNextApproach $registrySpace $schemaId $version $current $delta $transScale)
   (openPsiBoundedModulatorUpdate $registrySpace $schemaId $version approach $current $delta $transScale))

(= (openPsiNextResolution $registrySpace $schemaId $version $current $delta)
   (openPsiBoundedModulatorUpdate $registrySpace $schemaId $version resolution $current $delta 1.0))

(= (openPsiNextThreshold $registrySpace $schemaId $version $current $delta $indScale)
   (openPsiBoundedModulatorUpdate $registrySpace $schemaId $version threshold $current $delta $indScale))

(= (openPsiNextSecuring $registrySpace $schemaId $version $current $delta $indScale)
   (openPsiBoundedModulatorUpdate $registrySpace $schemaId $version securing $current $delta $indScale))

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
