# Ideas on the Generic Implementation of a Motivation System

The implementation of an `OpenPsi` like motivation system that corresponds to the parameters would be to give the user of the library the liberty of adding the parameters. But this has the following problems the user might add an incomplete initial configuration which will result in an erroneous updates, runtime errors and a lot of hard-coded prior information.

If the hard-coded prior (initial information) is a lot it will defeat the purpose of building this extensible framework because it might be easier to build a customized system for that environment. Hence, we will have the problem of having multiple motivation systems for different instances (which is a problem and quite different from DRY).

So at least the extensible system should provide a check for correctness, meaningful errors on the encoding (which requires extensive work).

## What type of representations do we need?

We need a representation for the `demands`, `modulators` , `the relationships` `the rules` and `the goals`. Why do we need the rules I mean it can be separated. In addition, we will need `contexts` representation. This will follow what the context should be. Since the context can be a prior goal achieved, a perceived environment.

```scheme
(: demandType Type)
(: demand (-> Number Number demandType ))

```

The demand type assumed in the above code snippet would have both the current value of the demand and the max value it can take as a demand. So we need a check (a type check) whether the `maxValue` has been reached. So we might need dependent types.

The implementation of the modulators will be the same as the old implementation which instances:

```scheme
(: modulatorType Type)
(: modulator (-> Number Modulator))

```

The modulators benefits from type checking because it will be beneficial check whether the max threshold has been reached. Then we might need to change the values to vectors as ben proposed. This can benefit from matrix based computations like `broadcasting` or if they are needed for embeddings. In addition they might serve as priors for decisions in bayesian reasoning.

The goals should be placed explicitly, instead of placing them in a cognitive schema which is a complete `IMPLICATION_LINK` relationship, we just tabulate the goals an agent could have. Maybe a perception module (or mind-agent) in minsky's terminology can be used to derive new goals based on perceived outcomes. The goals can have stv values, which in turn be used to modify the belief of the goals the agent has on them.

```scheme
(: goalType Type)
(: Goal (-> Number Number goalType))

```

## How should we represent condition rules?

Condition rules are used for to satisify a certain specification has been matched or not. So the condition rules should be represented in such a way that a modulator takes a certain value.
But each rule should have some kind of an id to implement relationship otherwise it won't work. Especially if you want to build something in which conditions are related and effect functions are related to new function

```scheme
(: relType Type)
(: relation (-> Symbol relType))
(: conditionType Type)
(: condition (-> Number modulatorType|demand Number relType conditionType))

```

So the relationship between effect functions and condition rules should be specified right? So how can we do that? Because we should find a way to relate the conditions and effect functions.
