!(bind! &goalSpace (new-space))


(= (addGoal $goalSpace $goal)
    (if (existsIn $goalSpace $goal) ("The goal Exists within the goalspace") (add-atom $goalSpace $goal))
)
