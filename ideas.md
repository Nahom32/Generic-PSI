## Ideas on the Generic Implementation of a Motivation System

The implementation of an `OpenPsi` like motivation system that corresponds to the parameters would be to give the user of the library the liberty of adding the parameters. But this has the following problems the user might add an incomplete initial configuration which will result in an erroneous updates, runtime errors and a lot of hard-coded prior information.

If the hard-coded prior (initial information) is a lot it would defeat the purpose of building this extensible framework because it might be easier to build a customized system for that environment. Hence, we will have the problem of having multiple motivation systems for different instances (which is a problem and quite different from DRY).

So at least the extensible system should provide a check for correctness, meaningful errors on the encoding (which requires extensive work).

## What type of representations do we need?

We need a representation for the `demands`, `modulators` , `the relationships` `the rules` and `the goals`.
