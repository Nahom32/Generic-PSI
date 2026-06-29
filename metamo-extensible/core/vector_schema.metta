;; Vector schema primitives for MetaMo motivational state.
;;
;; Dimension records use this shape:
;; (Dimension schema-id kind id index lower upper default roles version decay update-limit description)
;;
;; Supported kinds are:
;; goal, modulator, stimulus, actionFeature

(: DimensionType Type)
(: Dimension (-> Symbol Symbol Symbol Number Number Number Number Expression Symbol Symbol Number String DimensionType ))

(= (validDimensionKind $kind)
   (case $kind
      (
      (goal True)
       (modulator True)
       (stimulus True)
       (actionFeature True)
       ($other False)
      )
    )
)

(= (schemaMember $item $items)
   (if (== $items ())
       False
       (let ($head $tail)
            (decons-atom $items)
            (if (== $item $head)
                True
                (schemaMember $item $tail)))))

(= (validRoleTag $role)
   (case $role
      (
       (safety-overgoal True)
       (growth-overgoal True)
       (growth-goal True)
       (caution-modulator True)
       (exploration-modulator True)
       (ethical-guard True)
       (social-drive True)
       (novelty-signal True)
       (novelty-seeking True)
       (risk-signal True)
       (safety-margin True)
       (score-feature True)
       (affect True)
       ($other False)
      )
   ))

(= (validRoleTags $roles)
   (if (== $roles ())
       True
       (let ($head $tail)
            (decons-atom $roles)
            (if (validRoleTag $head)
                (validRoleTags $tail)
                False))))

(= (valueWithinBounds $value $lower $upper)
   (if (< $value $lower)
       False
       (if (> $value $upper)
           False
           True
        )
    )
)

(= (dimensionSchemaId
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   $schemaId)

(= (dimensionKindOf
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   $kind)

(= (dimensionIdOf
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   $id)

(= (dimensionIndexOf
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   $index)

(= (dimensionBoundsOf
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   (Bounds $lower $upper))

(= (dimensionDefaultOf
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   $default)

(= (dimensionRolesOf
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   $roles)

(= (dimensionVersionOf
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   $version)

(= (dimensionDecayPolicyOf
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   $decayPolicy)

(= (dimensionUpdateLimitOf
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   $updateLimit)

(= (dimensionDescriptionOf
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   $description)

(= (dimensionHasRole
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
      $role)
   (schemaMember $role $roles))

(= (validDimension
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   (if (== (validDimensionKind $kind) False)
       False
       (if (< $index 0)
           False
           (if (> $lower $upper)
               False
               (if (valueWithinBounds $default $lower $upper)
                   (validRoleTags $roles)
                   False)))))

(= (dimensionIndex $schemaSpace $schemaId $kind $id)
   (match $schemaSpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
      $index))

(= (dimensionBounds $schemaSpace $schemaId $kind $id)
   (match $schemaSpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
      (Bounds $lower $upper)))

(= (dimensionDefault $schemaSpace $schemaId $kind $id)
   (match $schemaSpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
      $default))

(= (dimensionRoles $schemaSpace $schemaId $kind $id)
   (match $schemaSpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
      $roles))

(= (dimensionsByKind $schemaSpace $schemaId $kind)
   (collapse
      (match $schemaSpace
         (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
         (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))))

(= (dimensionIfRole
      $role
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   (if (schemaMember $role $roles)
       (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
       (empty)
    )
)

(= (dimensionsByRole $schemaSpace $schemaId $role)
   (collapse
      (dimensionIfRole $role
         (match $schemaSpace
            (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
            (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)))))

(= (schemaDimensionCount $schemaSpace $schemaId $kind)
   (length (dimensionsByKind $schemaSpace $schemaId $kind)))

(= (schemaDimensions $schemaSpace $schemaId)
   (collapse
      (match $schemaSpace
         (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
         (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))))

(= (schemaIdDeclared $schemaSpace $schemaId)
   (not (== (schemaDimensions $schemaSpace $schemaId) ())))

(= (validateSchemaId $schemaSpace $schemaId)
   (schemaIdDeclared $schemaSpace $schemaId))

(= (dimensionIdInList $id $dimensions)
   (if (== $dimensions ())
       False
       (let* (
          (($head $tail) (decons-atom $dimensions))
          ((Dimension $schemaId $kind $headId $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description) $head))
          (if (== $id $headId)
              True
              (dimensionIdInList $id $tail)))))

(= (dimensionIndexInList $index $dimensions)
   (if (== $dimensions ())
       False
       (let* (
          (($head $tail) (decons-atom $dimensions))
          ((Dimension $schemaId $kind $id $headIndex $lower $upper $default $roles $version $decayPolicy $updateLimit $description) $head))
          (if (== $index $headIndex)
              True
              (dimensionIndexInList $index $tail)))))

(= (allValidDimensions $dimensions)
   (if (== $dimensions ())
       True
       (let ($head $tail)
            (decons-atom $dimensions)
            (if (== (validDimension $head) False)
                False
                (allValidDimensions $tail)))))

(= (allDimensionsMatchSchemaKind $schemaId $kind $dimensions)
   (if (== $dimensions ())
       True
       (let* (
          (($head $tail) (decons-atom $dimensions))
          ((Dimension $headSchemaId $headKind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description) $head))
          (if (== $headSchemaId $schemaId)
              (if (== $headKind $kind)
                  (allDimensionsMatchSchemaKind $schemaId $kind $tail)
                  False)
              False))))

(= (uniqueDimensionIds $dimensions)
   (if (== $dimensions ())
       True
       (let* (
          (($head $tail) (decons-atom $dimensions))
          ((Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description) $head))
          (if (dimensionIdInList $id $tail)
              False
              (uniqueDimensionIds $tail)))))

(= (uniqueDimensionIndices $dimensions)
   (if (== $dimensions ())
       True
       (let* (
          (($head $tail) (decons-atom $dimensions))
          ((Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description) $head))
          (if (dimensionIndexInList $index $tail)
              False
              (uniqueDimensionIndices $tail)))))

(= (contiguousDimensionIndicesFrom $expected $count $dimensions)
   (if (== $expected $count)
       True
       (if (dimensionIndexInList $expected $dimensions)
           (contiguousDimensionIndicesFrom (+ $expected 1) $count $dimensions)
           False)))

(= (contiguousDimensionIndices $dimensions)
   (contiguousDimensionIndicesFrom 0 (length $dimensions) $dimensions))

(= (validateDimensionList $schemaId $kind $dimensions)
   (if (not (allValidDimensions $dimensions)) 
       False
       (if (== (allDimensionsMatchSchemaKind $schemaId $kind $dimensions) False)
           False
           (if (== (uniqueDimensionIds $dimensions) False)
               False
               (if (== (uniqueDimensionIndices $dimensions) False)
                   False
                   (contiguousDimensionIndices $dimensions))))))



(= (valuesWithinDimensions $values $dimensions)
   (if (== $dimensions ())
       True
       (let* (
          (($head $tail) (decons-atom $dimensions))
          ((Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description) $head)
          ($value (index-atom $values $index)))
          (if (valueWithinBounds $value $lower $upper)
              (valuesWithinDimensions $values $tail)
              False))))

(= (validateValuesForSchemaKind $schemaSpace $schemaId $kind $values)
   (if (validateSchemaId $schemaSpace $schemaId)
       (let $dimensions (dimensionsByKind $schemaSpace $schemaId $kind)
          (if (== (length $values) (schemaDimensionCount $schemaSpace $schemaId $kind))
              (if (validateDimensionList $schemaId $kind $dimensions)
                  (valuesWithinDimensions $values $dimensions)
                  False)
              False))
       False))

(= (validateMotivationState $schemaSpace (MotivationState $schemaId $goalValues $modulatorValues))
   (if (validateSchemaId $schemaSpace $schemaId)
       (if (validateValuesForSchemaKind $schemaSpace $schemaId goal $goalValues)
           (validateValuesForSchemaKind $schemaSpace $schemaId modulator $modulatorValues)
           False)
       False))
