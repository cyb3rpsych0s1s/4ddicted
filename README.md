# Addicted

An amplifier mod based on `Toxicity` and `WE3D - Drugs in Night City`.
Basically adds a chance to become addicted to substances too frequently consumed, like MAXdoc and the likes.

## Gameplay

Whenever:

- V consumes substance `T: Addictive` over `4ddicted_daily_consumption_threshold` time(s) a day
- V consumes substance `T: Addictive` unremittingly for `4ddicted_consecutive_days_duration`

V might get a chance to increase his/her `4ddicted_addiction_threshold` for consumed `T: Addictive`.
It should be suggested by e.g. some message on screen of V talking to himself/herself like:

- oh damn I like it
- what would I do without this sh*t
- I already feel like I want another one

or any kind of sentence really, that actually indicates to the player that his/her V is slipping toward addiction.
visual effects would be even better, but not sure if game has something that can be reused this way.

*update* actually there's already `Status effects icons` and probably `Cold blood` is an appropriate one. `Stunned` could be useful too.

Being dependent introduces new buf and debuf in-game.
For example, given V becomes addicted to MAXdoc, one could imagine:

- V does not heal back as much as (s)he used to when consuming
- V does get an extended duration for MAXdoc's `REF` debuf
- V does not heal back as much as (s)he used to from sleeping

e.g. addiction thresholds should probably be 3:

1. consuming a MAXdoc restores 10% less health
2. consuming a MAXdoc restores 15% less health
   `REF` debuf now lasts for way longer
3. consuming a MAXdoc restores 30% less health
   `REF` debuf now lasts until sleep
   `REF` gets a malus of (a reasonable amount?) while addiction lasts
   sleep restores 50% less health

Of course different substances should yield different side effects.

Recovering from addiction should be a related and interesting gameplay.

- V should spend extensive time weaning off from the substance `T: Addictive`: the higher his/her threshold, the harder to wean off
- during abstinence, V should get worse debuf and side effects in general, that gets worse at first when weaning off, but that slightly vanish over time
- on relapse, V should get temporary better buf
- in general going from addiction to abstinence or relapse : it's always easier to fall again than to get past it
- if possible, interesting animations could be reused from game natives : maybe the character will puke, or randomly pass out during the hardest first step in his/her way to abstinence

## Even crazier ideas

Combined with `Kiroshi Opticals - Crowd Scanner`:

randomly add addiction details for NPCs in InfoComp, which can come in the form of:

- medical file
- antecedents
- events
- etc

Effects could be entirely ignored with `Detoxifier` cyberware. Very good idea especially since this item can only be acquired with Fingers, depending on the outcome of the story mission, and is a pricey one. `Synaptic Accelerator` cyberware could increase the chances of getting addict, unless of `Rare` or `Legendary` levels. `Biomonitor` cyberware could display more accurate infos about addiction on screen. `Nanorelays` cyberware might also be a potential modifier here. `Cataresist` cyberware should also help fight the addiction off. Also `Syn-lungs` cyberware could potentially influence wearing off at least inhaled drugs. Same with `Bioplastic Blood Vessels`, `Blood Pump`, and the likes for injected drugs.
