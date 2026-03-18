!(bind! &demandSpace  (new-space))


(= (e))
(= (addDemand $demandSpace $demand)
  (if (existsIn $demandSpace $demand)
      ("This demand exists in the atomspace")
      (add-atom $demandSpace $demand))
  )
