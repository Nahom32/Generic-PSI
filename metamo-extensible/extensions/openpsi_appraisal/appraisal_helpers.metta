

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
