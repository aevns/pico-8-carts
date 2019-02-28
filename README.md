# PICO-8 Carts

Playable carts and forum threads can also be found on [**the lexaloffle forums**](https://www.lexaloffle.com/bbs/?uid=34308).

## UNYIELDING (*work in progress*)
My first time working with PICO-8, this cart is meant as a proof-of-concept for a combat system I've been cooking up. The design is inspired by what I most enjoy about Soulslike combat mechanics; slow, strategic combat that forces the player to think one or two steps ahead. With that said, combat in the Souls series has a number of shortcomings that I'd like to iterate on — which I won't go into detail on here.

![gameplay example 1](https://i.imgur.com/fGLKa1L.gif)
![gameplay example 2](https://i.imgur.com/8IpGA7O.gif)

### The Combat System
[**A short design document on the combat system's controls can be found here.**](https://docs.google.com/document/d/1QBwIBs72zgdClWGkVCTEFVCA7pSMcFZF0BdWYCU7jxs/edit?usp=sharing) The specific implementation used in-game has changed slightly from the one outlined in the design doc, but not in a significant way.

While that document outlines the ideas behind the control scheme, the efffect and interactions between different abilities is a whole other discussion. In short, the combat system uses a contested check to determine the effects of an attack: Each action has associated **force**, **stability**, and **damage**. When using an ability, that ability's **stability** determines whether you **block** incoming attacks. If your **stability** exceeds the **force** of an incoming attack, it is **blocked**, and you take no damage. If the force exceeds your **stability**, you will be **stunned** for a duration determined by the difference of those values; you will also take any **damage** the incoming effect might cause. An ability's **stability** frames usually begin a few frames before its active frames (much like the hyperarmor / superarmor used in other systems). Thus, two agents attacking each-other at the same time are likely to block each-other's attacks.

![gameplay example 3](https://i.imgur.com/J83NhL4.gif)
![gameplay example 4](https://i.imgur.com/rSPczeA.gif)
