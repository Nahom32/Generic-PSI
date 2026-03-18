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
