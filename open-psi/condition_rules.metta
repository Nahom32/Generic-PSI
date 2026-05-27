!(bind! &conditionSpace (new-space))



(= (extractType $value)
  (let $descriptor (car-atom $value) 
      (case $descriptor (
            (modulator MODULATOR)
            (demand DEMAND)
            ($_ NONE)
        )
      )
  ) 
)

(= (checkValue $nodeValue $threshold gt)
    (>= $nodeValue $threshold)
)

(= (checkValue $nodeValue $threshold lt)
    (< $nodeValue $threshold)
)

(: executeConditionRule (-> Expression Bool))
(= (executeConditionRule $conditionRule)
    (let* (
        ((condition  $conditionId $substrate $condValue $relation) $conditionRule)
        ((relation $relVal) $relation)
        ($type (extractType $substrate))

    ) 
        (case $type(
            (MODULATOR   
              (let (modulator $modulatorType $modulatorValue) $substrate 
                    (checkValue $modulatorValue $condValue $relVal) 
              )
            )
            (DEMAND (let (demand $demandType $minValue $maxValue $result) $substrate  
                (checkValue $result $condValue $relVal)))
            ($_ False)
        )
    )
  )
)


