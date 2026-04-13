(= (existsIn $atomSpace $atom)
    (let $atoms (collapse (get-atoms $atomSpace)) (isMember $atom $atoms))
)


(= (isMember $atom $atoms) 
    (if (== $atoms ()) False 
    (let ($head $tail) 
          (decons-atom $atoms) 
          (if (==  $atom $head) 
              True 
              (isMember $atom $tail)))))



(= (changeModulatorToVector $modulators $acc)
    (if (== $modulators ())
      $acc
      (let* (
        (($head $tail) (decons-atom $modulators))
        ((modulator $name $value) $head)
        ($acc' (union-atom $acc ($value)))
      )
        (changeModulatorToVector $tail $acc')
      )
    )
    
)


;;!(changeModulatorToVector ((modulator valence 0.4) (modulator appraisal 0.3) (modulator selection-threshold 0.2)) ())
