# springboard_transition

An example of a circle wipe page transistion.

The `SpringboardPage` is a page configuration meant to be used with the `Navigator.pages` API. It's route builds the circle wipe effect based on an origin point. The origin, by default, is the center of the `Page`'s widget. It can be customized by updating `SpringboardScope.of(context)?.transitionOrigin`. You can do this automatically by wrapping your interactive component (button, gesture detector) with a
`SpringboardControl`.

![](assets/demo.mov)
