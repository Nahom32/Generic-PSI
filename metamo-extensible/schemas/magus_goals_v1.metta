;; OpenPsi/MAGUS default goal dimensions.
;;
;; The ordering follows the concrete research-assistant MAGUS vector described
;; in the docs: dual overgoals first, then task, self, ethical, and social goals.

(= (openPsiGoalSchemaId) openpsi-magus)
(= (openPsiGoalSchemaVersion) v1)

(= (openPsiGoalDimensions)
   ((Dimension openpsi-magus goal gInd 0 0.0 1.0 0.5 (safety-overgoal) v1 none 0.20 "Individuation overgoal")
    (Dimension openpsi-magus goal gTrans 1 0.0 1.0 0.5 (growth-overgoal novelty-seeking) v1 none 0.20 "Transcendence overgoal")
    (Dimension openpsi-magus goal gHelp 2 0.0 1.0 0.3 (growth-goal social-drive) v1 none 0.20 "Helpfulness")
    (Dimension openpsi-magus goal gCurio 3 0.0 1.0 0.3 (growth-goal novelty-seeking) v1 none 0.20 "Curiosity")
    (Dimension openpsi-magus goal gNovel 4 0.0 1.0 0.3 (growth-goal novelty-seeking) v1 none 0.20 "Novelty seeking")
    (Dimension openpsi-magus goal gSelf 5 0.0 1.0 0.3 (growth-goal safety-margin) v1 none 0.20 "Self-model maintenance")
    (Dimension openpsi-magus goal gEthic 6 0.0 1.0 0.5 (ethical-guard) v1 none 0.20 "Ethical guard")
    (Dimension openpsi-magus goal gSoc 7 0.0 1.0 0.3 (social-drive) v1 none 0.20 "Social drive")))
