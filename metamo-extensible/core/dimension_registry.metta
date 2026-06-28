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

(= (schemaRegistered $registrySpace $schemaId)
   (not (== (schemaRecords $registrySpace $schemaId) ())))

(= (registryAtomExists $registrySpace $atom)
   (let $atoms (collapse (get-atoms $registrySpace))
      (schemaMember $atom $atoms)))

(= (registerSchemaMetadata $registrySpace $schemaId $version $description)
   (if (schemaRegistered $registrySpace $schemaId)
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

(= (dimensionRegistered
      $registrySpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description))
   (if (dimensionIdentityRegistered $registrySpace $schemaId $kind $id)
       True
       (dimensionIndexRegistered $registrySpace $schemaId $kind $index)))

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

(= (registerSchemaDefinition $registrySpace $schemaId $version $description $dimensions)
   (if (validateSchemaDimensions $schemaId $dimensions)
       (let* (
          ($metadata (registerSchemaMetadata $registrySpace $schemaId $version $description))
          ($registeredDimensions (registerDimensionList $registrySpace $dimensions)))
          (RegisteredSchema $schemaId $version))
       (InvalidSchema $schemaId)))

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

(= (dimensionByIndex $registrySpace $schemaId $kind $index)
   (match $registrySpace
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)
      (Dimension $schemaId $kind $id $index $lower $upper $default $roles $version $decayPolicy $updateLimit $description)))

(= (dimensionsByIndex $registrySpace $schemaId $kind $index)
   (collapse (dimensionByIndex $registrySpace $schemaId $kind $index)))

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

(= (validateStimulusDimensions $registrySpace $schemaId $ids)
   (validateDeclaredDimensions $registrySpace $schemaId stimulus $ids))

(= (validateActionFeatureDimensions $registrySpace $schemaId $ids)
   (validateDeclaredDimensions $registrySpace $schemaId actionFeature $ids))

(= (validateStimulusVector $registrySpace $schemaId $values)
   (validateValuesForSchemaKind $registrySpace $schemaId stimulus $values))

(= (validateActionFeatureVector $registrySpace $schemaId $values)
   (validateValuesForSchemaKind $registrySpace $schemaId actionFeature $values))
