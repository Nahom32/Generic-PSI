
!(bind! &modulatorSpace (new-space))

(= (addModulator $modulatorSpace $modulator)
  (if (existsIn $modulatorSpace $modulator)
      ("This modulator exists in the atomspace")
      (add-atom $modulatorSpace $modulator))
  )
