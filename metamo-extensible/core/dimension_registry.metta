!(import! &self ../core/vector_schema)

;; Dimension registry for versioned MetaMo vector schemas.
;;
;; Registry atomspaces store:
;; (Schema schema-id version description)
;; (Dimension schema-id kind id index lower upper default roles version decay update-limit description)
;;
;; Dimension records are intentionally the same shape as core/vector_schema.metta.
;; This module adds schema registration, registry-level lookup, and declaration
;; checks for plugins that consume stimulus or action-feature dimensions.
(: SchemaType Type)
(: Schema (-> Symbol Symbol String SchemaType))

(= (schemaIdOf (Schema $schemaId $version $description))
   $schemaId)

(= (schemaVersionOf (Schema $schemaId $version $description))
   $version)

(= (schemaDescriptionOf (Schema $schemaId $version $description))
   $description)

(= (registeredSchemas $registrySpace)
   (collapse
      (match $registrySpace
         (Schema $schemaId $version $description)
         (Schema $schemaId $version $description))))

(= (schemaRecords $registrySpace $schemaId)
   (collapse
      (match $registrySpace
         (Schema $schemaId $version $description)
         (Schema $schemaId $version $description))))

(= (schemaVersionRecords $registrySpace $schemaId $version)
   (collapse
      (match $registrySpace
         (Schema $schemaId $version $description)
         (Schema $schemaId $version $description))))

(= (schemaRegistered $registrySpace $schemaId)
   (not (== (schemaRecords $registrySpace $schemaId) ())))

(= (schemaVersionRegistered $registrySpace $schemaId $version)
   (not (== (schemaVersionRecords $registrySpace $schemaId $version) ())))

(= (registryAtomExists $registrySpace $atom)
   (let $atoms (collapse (get-atoms $registrySpace))
      (schemaMember $atom $atoms)))

(= (registerSchemaMetadata $registrySpace $schemaId $version $description)
   (if (schemaVersionRegistered $registrySpace $schemaId $version)
       (SchemaAlreadyRegistered $schemaId)
       (add-atom $registrySpace (Schema $schemaId $version $description))))

(= (allDimensionsMatchSchema $schemaId $dimensions)
   (if (== $dimensions ())
       True
       (let* (
          (($head $tail) (decons-atom $dimensions))
          ((Dimension $headSchemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description) $head))
          (if (== $schemaId $headSchemaId)
              (allDimensionsMatchSchema $schemaId $tail)
              False))))

(= (allDimensionsMatchSchemaVersion $schemaId $version $dimensions)
   (if (== $dimensions ())
       True
       (let* (
          (($head $tail) (decons-atom $dimensions))
          ((Dimension $headSchemaId $kind $id $index $lower $upper $default $roles $headVersion $decayPolicy $updateLimit $description) $head))
          (if (== $schemaId $headSchemaId)
              (if (== $version $headVersion)
                  (allDimensionsMatchSchemaVersion $schemaId $version $tail)
                  False)
              False))))

(= (dimensionIfKind
      $kind
      (Dimension $schemaId $dimensionKind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   (if (== $kind $dimensionKind)
       (Dimension $schemaId $dimensionKind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
       (empty)))

(= (dimensionsByKindInList $dimensions $kind)
   (collapse (dimensionIfKind $kind (superpose $dimensions))))

(= (validateSchemaKindDimensions $schemaId $kind $dimensions)
   (validateDimensionList $schemaId $kind (dimensionsByKindInList $dimensions $kind)))

(= (validateSchemaDimensions $schemaId $dimensions)
   (if (== (allValidDimensions $dimensions) False)
       False
       (if (== (allDimensionsMatchSchema $schemaId $dimensions) False)
           False
           (if (== (validateSchemaKindDimensions $schemaId goal $dimensions) False)
               False
               (if (== (validateSchemaKindDimensions $schemaId modulator $dimensions) False)
                   False
                   (if (== (validateSchemaKindDimensions $schemaId stimulus $dimensions) False)
                       False
                       (validateSchemaKindDimensions $schemaId actionFeature $dimensions)))))))

(= (validateSchemaVersionDimensions $schemaId $version $dimensions)
   (if (== (validateSchemaDimensions $schemaId $dimensions) False)
       False
       (allDimensionsMatchSchemaVersion $schemaId $version $dimensions)))

(= (dimensionIdentityRegistered $registrySpace $schemaId $kind $id)
   (not
      (== (collapse
            (match $registrySpace
               (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
               (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)))
          ())))

(= (dimensionIndexRegistered $registrySpace $schemaId $kind $index)
   (not
      (== (collapse
            (match $registrySpace
               (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
               (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)))
          ())))

(= (dimensionVersionIdentityRegistered $registrySpace $schemaId $version $kind $id)
   (not
      (== (collapse
            (match $registrySpace
               (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
               (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)))
          ())))

(= (dimensionVersionIndexRegistered $registrySpace $schemaId $version $kind $index)
   (not
      (== (collapse
            (match $registrySpace
               (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
               (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)))
          ())))

(= (dimensionRegistered
      $registrySpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   (if (dimensionVersionIdentityRegistered $registrySpace $schemaId $version $kind $id)
       True
       (dimensionVersionIndexRegistered $registrySpace $schemaId $version $kind $index)))

(= (registerDimension
      $registrySpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   (if (validDimension
         (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
       (if (dimensionRegistered
             $registrySpace
             (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
           (DimensionAlreadyRegistered $schemaId $kind $id)
           (add-atom
              $registrySpace
              (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)))
       (InvalidDimension $schemaId $kind $id)))

(= (registerDimensionList $registrySpace $dimensions)
   (if (== $dimensions ())
       (RegisteredDimensions)
       (let* (
          (($head $tail) (decons-atom $dimensions))
          ($ignored (registerDimension $registrySpace $head)))
          (registerDimensionList $registrySpace $tail))))

(= (dimensionRegistrationConflict
      $registrySpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   (if (dimensionRegistered
         $registrySpace
         (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
       (DimensionAlreadyRegistered $schemaId $kind $id)
       (NoDimensionConflict)))

(= (firstDimensionRegistrationConflict $registrySpace $dimensions)
   (if (== $dimensions ())
       (NoDimensionConflict)
       (let* (
          (($head $tail) (decons-atom $dimensions))
          ($conflict (dimensionRegistrationConflict $registrySpace $head)))
          (if (== $conflict (NoDimensionConflict))
              (firstDimensionRegistrationConflict $registrySpace $tail)
              $conflict))))

(= (registerSchemaDefinition $registrySpace $schemaId $version $description $dimensions)
   (if (== (validateSchemaVersionDimensions $schemaId $version $dimensions) False)
       (InvalidSchema $schemaId)
       (if (schemaVersionRegistered $registrySpace $schemaId $version)
           (SchemaAlreadyRegistered $schemaId)
           (let $conflict (firstDimensionRegistrationConflict $registrySpace $dimensions)
              (if (== $conflict (NoDimensionConflict))
                  (let* (
                     ($metadata (registerSchemaMetadata $registrySpace $schemaId $version $description))
                     ($registeredDimensions (registerDimensionList $registrySpace $dimensions)))
                     (RegisteredSchema $schemaId $version))
                  $conflict)))))

(= (registerSchema $registrySpace $schemaId $version $dimensions)
   (registerSchemaDefinition $registrySpace $schemaId $version "" $dimensions))

(= (registerSchema $registrySpace $schemaId $version $dimensions $description)
   (registerSchemaDefinition $registrySpace $schemaId $version $description $dimensions))

(= (registerSchema $registrySpace (SchemaDefinition $schemaId $version $dimensions $description))
   (registerSchemaDefinition $registrySpace $schemaId $version $description $dimensions))

(= (registerSchema $registrySpace (SchemaDefinition $schemaId $version $dimensions))
   (registerSchemaDefinition $registrySpace $schemaId $version "" $dimensions))

(= (dimensionById $registrySpace $schemaId $kind $id)
   (match $registrySpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)))

(= (dimensionsById $registrySpace $schemaId $kind $id)
   (collapse (dimensionById $registrySpace $schemaId $kind $id)))

(= (dimensionByIdVersion $registrySpace $schemaId $version $kind $id)
   (match $registrySpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)))

(= (dimensionsByIdVersion $registrySpace $schemaId $version $kind $id)
   (collapse (dimensionByIdVersion $registrySpace $schemaId $version $kind $id)))

(= (dimensionByIndex $registrySpace $schemaId $kind $index)
   (match $registrySpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)))

(= (dimensionsByIndex $registrySpace $schemaId $kind $index)
   (collapse (dimensionByIndex $registrySpace $schemaId $kind $index)))

(= (dimensionByIndexVersion $registrySpace $schemaId $version $kind $index)
   (match $registrySpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)))

(= (dimensionsByIndexVersion $registrySpace $schemaId $version $kind $index)
   (collapse (dimensionByIndexVersion $registrySpace $schemaId $version $kind $index)))

(= (dimensionsByKindVersion $registrySpace $schemaId $version $kind)
   (collapse
      (match $registrySpace
         (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
         (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))))

(= (schemaDimensionCountVersion $registrySpace $schemaId $version $kind)
   (length (dimensionsByKindVersion $registrySpace $schemaId $version $kind)))

(= (validateValuesForSchemaKindVersion $registrySpace $schemaId $version $kind $values)
   (if (schemaVersionRegistered $registrySpace $schemaId $version)
       (let $dimensions (dimensionsByKindVersion $registrySpace $schemaId $version $kind)
          (if (== (length $values) (schemaDimensionCountVersion $registrySpace $schemaId $version $kind))
              (if (validateDimensionList $schemaId $kind $dimensions)
                  (valuesWithinDimensions $values $dimensions)
                  False)
              False))
       False))

(= (dimensionIdByIndex $registrySpace $schemaId $kind $index)
   (match $registrySpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
      $id))

(= (dimensionKindById $registrySpace $schemaId $kind $id)
   (match $registrySpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
      $kind))

(= (dimensionRoleIndex
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   (DimensionIndex $schemaId $kind $id $index))

(= (dimensionIndicesByRole $registrySpace $schemaId $role)
   (let $dimensions (dimensionsByRole $registrySpace $schemaId $role)
      (collapse
         (dimensionRoleIndex
            (superpose $dimensions)))))

(= (dimensionHasKindRole
      $kind
      $role
      (Dimension $schemaId $dimensionKind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   (if (schemaMember $role $roles)
       (if (== $kind $dimensionKind)
           True
           False)
       False))

(= (dimensionIfKindRole
      $kind
      $role
      (Dimension $schemaId $dimensionKind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   (if (dimensionHasKindRole
         $kind
         $role
         (Dimension $schemaId $dimensionKind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
       (Dimension $schemaId $dimensionKind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
       (empty)))

(= (dimensionsByKindRole $registrySpace $schemaId $kind $role)
   (collapse
      (dimensionIfKindRole $kind $role
         (match $registrySpace
            (Dimension $schemaId $dimensionKind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
            (Dimension $schemaId $dimensionKind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)))))

(= (dimensionIndicesByKindRole $registrySpace $schemaId $kind $role)
   (let $dimensions (dimensionsByKindRole $registrySpace $schemaId $kind $role)
      (collapse
         (dimensionRoleIndex
            (superpose $dimensions)))))

(= (schemaHasRole $registrySpace $schemaId $role)
   (not (== (dimensionsByRole $registrySpace $schemaId $role) ())))

(= (dimensionDeclared $registrySpace $schemaId $kind $id)
   (not (== (dimensionsById $registrySpace $schemaId $kind $id) ())))

(= (dimensionDeclaredVersion $registrySpace $schemaId $version $kind $id)
   (not (== (dimensionsByIdVersion $registrySpace $schemaId $version $kind $id) ())))

(= (allDimensionIdsDeclared $registrySpace $schemaId $kind $ids)
   (if (== $ids ())
       True
       (let ($head $tail)
            (decons-atom $ids)
            (if (dimensionDeclared $registrySpace $schemaId $kind $head)
                (allDimensionIdsDeclared $registrySpace $schemaId $kind $tail)
                False))))

(= (validateDeclaredDimensions $registrySpace $schemaId $kind $ids)
   (allDimensionIdsDeclared $registrySpace $schemaId $kind $ids))

(= (allDimensionIdsDeclaredVersion $registrySpace $schemaId $version $kind $ids)
   (if (== $ids ())
       True
       (let ($head $tail)
            (decons-atom $ids)
            (if (dimensionDeclaredVersion $registrySpace $schemaId $version $kind $head)
                (allDimensionIdsDeclaredVersion $registrySpace $schemaId $version $kind $tail)
                False))))

(= (validateDeclaredDimensionsVersion $registrySpace $schemaId $version $kind $ids)
   (allDimensionIdsDeclaredVersion $registrySpace $schemaId $version $kind $ids))

(= (validateStimulusDimensions $registrySpace $schemaId $ids)
   (validateDeclaredDimensions $registrySpace $schemaId stimulus $ids))

(= (validateStimulusDimensionsVersion $registrySpace $schemaId $version $ids)
   (validateDeclaredDimensionsVersion $registrySpace $schemaId $version stimulus $ids))

(= (validateActionFeatureDimensions $registrySpace $schemaId $ids)
   (validateDeclaredDimensions $registrySpace $schemaId actionFeature $ids))

(= (validateActionFeatureDimensionsVersion $registrySpace $schemaId $version $ids)
   (validateDeclaredDimensionsVersion $registrySpace $schemaId $version actionFeature $ids))

(= (validatePluginStimulusInputs $registrySpace $schemaId $ids)
   (validateStimulusDimensions $registrySpace $schemaId $ids))

(= (validatePluginStimulusInputsVersion $registrySpace $schemaId $version $ids)
   (validateStimulusDimensionsVersion $registrySpace $schemaId $version $ids))

(= (validatePluginActionFeatureOutputs $registrySpace $schemaId $ids)
   (validateActionFeatureDimensions $registrySpace $schemaId $ids))

(= (validatePluginActionFeatureOutputsVersion $registrySpace $schemaId $version $ids)
   (validateActionFeatureDimensionsVersion $registrySpace $schemaId $version $ids))

(= (validatePluginDimensionContract $registrySpace $schemaId $stimulusInputIds $actionFeatureOutputIds)
   (if (validatePluginStimulusInputs $registrySpace $schemaId $stimulusInputIds)
       (validatePluginActionFeatureOutputs $registrySpace $schemaId $actionFeatureOutputIds)
       False))

(= (validatePluginDimensionContractVersion $registrySpace $schemaId $version $stimulusInputIds $actionFeatureOutputIds)
   (if (validatePluginStimulusInputsVersion $registrySpace $schemaId $version $stimulusInputIds)
       (validatePluginActionFeatureOutputsVersion $registrySpace $schemaId $version $actionFeatureOutputIds)
       False))

(= (validatePluginDimensionContract
      $registrySpace
      (PluginDimensionContract $schemaId $stimulusInputIds $actionFeatureOutputIds))
   (validatePluginDimensionContract $registrySpace $schemaId $stimulusInputIds $actionFeatureOutputIds))

(= (validatePluginDimensionContractVersion
      $registrySpace
      (PluginDimensionContract $schemaId $version $stimulusInputIds $actionFeatureOutputIds))
   (validatePluginDimensionContractVersion $registrySpace $schemaId $version $stimulusInputIds $actionFeatureOutputIds))

(= (validateStimulusVector $registrySpace $schemaId $values)
   (validateValuesForSchemaKind $registrySpace $schemaId stimulus $values))

(= (validateStimulusVectorVersion $registrySpace $schemaId $version $values)
   (validateValuesForSchemaKindVersion $registrySpace $schemaId $version stimulus $values))

(= (validateActionFeatureVector $registrySpace $schemaId $values)
   (validateValuesForSchemaKind $registrySpace $schemaId actionFeature $values))

(= (validateActionFeatureVectorVersion $registrySpace $schemaId $version $values)
   (validateValuesForSchemaKindVersion $registrySpace $schemaId $version actionFeature $values))
