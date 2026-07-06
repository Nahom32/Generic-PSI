;; OpenPsi/MAGUS default modulator dimensions.
;;
;; These dimensions keep the concrete OpenPsi names inside the default
;; instantiation while exposing generic roles for kernel code.

(= (openPsiModulatorSchemaId) openpsi-magus)
(= (openPsiModulatorSchemaVersion) v1)

(= (openPsiModulatorDimensions)
   ((Dimension openpsi-magus modulator valence 0 -1.0 1.0 0.0 (affect) v1 decay-linear 0.10 "Valence")
    (Dimension openpsi-magus modulator arousal 1 0.0 1.0 0.0 (exploration-modulator) v1 decay-linear 0.10 "Arousal")
    (Dimension openpsi-magus modulator approach 2 -1.0 1.0 0.0 (exploration-modulator) v1 decay-linear 0.10 "Approach tendency")
    (Dimension openpsi-magus modulator resolution 3 0.0 1.0 0.5 () v1 decay-linear 0.10 "Resolution")
    (Dimension openpsi-magus modulator threshold 4 0.0 1.0 0.5 (caution-modulator) v1 none 0.10 "Selection threshold")
    (Dimension openpsi-magus modulator securing 5 0.0 1.0 0.5 (caution-modulator) v1 none 0.10 "Securing")))
