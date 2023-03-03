# Mod

⚠️ **Spoiler alert** !

The following description details **every feature** of this mod, which will ruin any surprise intended to be discovered and enjoyed by the player.

This is only for people who can't stand playing a mod without knowing each of their internal gameplay mechanics. 🫣

You've been warned !

**A note of caution too** : please note the gameplay below might evolve over time, as more content get released.

Since it has to be manually maintained and it can happen that I forgot to do it (*I'm a mere human after all choom's, not some methodic borg*), please let me know in the [Github issues](https://github.com/cyb3rpsych0s1s/4ddicted/issues) if ever something is outdated.

## Systems

This mod add the following gameplay systems to the game.

### Addiction

The way addiction is being kept track of is the following:

- whenever V consumes an addictive consumables (see which ones below),
his/her addiction to this specific consumable increases (you can think of it as a jauge).
- whenever V rests at home for long enough, gets energized or revigored, his/her addictions jauges decreases.
- mild drugs decreases twice as fast as they increase.
- hard drugs increases twice as fast as they decrease.

Addiction jauge has the following thresholds:

- `Clean` (never consumed, or withdrawn from for long enough)
- `Barely` (consumed a couple of times)
- `Mildly` (consumed frequently, but not too much)
- `Notably` (consumed on a regular basis, or the substance is very addictive in itself)
- `Severely` (consumed for way too long)

V is considered seriously addict whenever (s)he reaches `notable` or `severe` thresholds.

Of course (s)he can perfectly withdraw from consuming the addictive substance and, if long enough, his/her threshold will decrease back.

### Addictive consumables

The player will get hints from V whenever (s)he gets seriously addict:

- inhalers will make V cough, slightly after inhaling.
- injectors will make V feel pain, once their effect wears off.
- pills will have a specific effect on consumption, depending on their kind:
  - anabolics (Stamina Booster, Carry Capacity Booster) will make V grunts.
  - neuro transmitter (RAM Jolt) will make V experience migraine.

#### Families

Consumables are grouped by family, which gets their own gameplay mechanics.

##### Healers

- consumables: MaxDOC, BounceBack and Health Booster.
- healers are considered as mild drugs.

Whenever V becomes notably addict to any healer, the benefits of the consumables decrease. If (s)he is severely addict, the benefits gets even more lessened.

> e.g. if [MaxDOC](https://cyberpunk.fandom.com/wiki/MaxDoc) usually instantly restores 40% health, whenever notably addict it will only restore 30%, or 20% if severely addict. For some healers, it also lasts shorter.

The status effects of these consumables will also have their UI in radial wheel updated accordingly, with their own custom icon.

##### Stimulants

- consumables: RAM Jolt, Stamina Booster and Carry Capacity Booster.
- stimulants are considered as mild drugs.

Whenever V becomes notably addict to a booster (each being treated separately)
and (s)he hasn't consumed any for a certain duration, (s)he gets a debuff equals to what the consumable originally grants.

> e.g. if [RAM Jolt](https://cyberpunk.fandom.com/wiki/RAM_Jolt) increases max RAM units by 2, whenever V is withdrawing (s)he is at 90% memory if notably addict, or 70% memory if severely addict until (s)he consumes some again.

Craving for a stimulant will also be shown in radial wheel with custom icon.

##### Black Lace

Black Lace has always been an iconic drug in Cyberpunk lore, hence why it gets its own system.

Black Lace is considered as a hard drug.

Whenever V becomes notably or severely addict to Black Lace,
and (s)he hasn't consumed any for a certain duration (s)he is susceptible to Fibromalgya, a custom status effect which decreases his/her REF

> e.g. when experiencing Fibromalgya, V's REF decreases to 90% if notably addict or 70% if severely addict, until (s)he consumes some again.

When suffering from Fibromalgya, V will also express some pain.

Craving for Black Lace will also be shown in radial wheel with custom icon.

### Cyberware

Some cyberwares also have an impact on addiction in general.

#### Detoxifier

This item makes V's addictions decrease drastically more whenever getting a proper rest.

> e.g. whenever equipped with Detoxifier and properly resting at house, V sees his/her addiction decrease twice as fast (cumulable with Metabolic Editor).

This benefit is kept hidden from the player to discover.

#### Metabolic Editor

This item makes V's addictions decrease drastically more whenever getting a proper rest.

> e.g. whenever equipped with Metabolic Editor and properly resting at house, V sees his/her addiction decrease thrice as fast (cumulable with Detoxifier).

This benefit is kept hidden from the player to discover.

#### Biomonitor

This item will warn V whenever crossing a serious thresholds.

> e.g. a little animation will play on-screen with the Biomonitor warning V about his/her current condition.

The UI is also dismissable, and automatically hides whenever interacting with another interaction UI in the game.
