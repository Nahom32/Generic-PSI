
!(bind! &demandSpace  (new-space))
;;An Example of the demand
;; (demand $demandName $demandValue)


(= (addDemand $demandSpace $demand)
  (if (existsIn $demandSpace $demand)
      ("This demand exists in the atomspace")
      (add-atom $demandSpace $demand))
  )
