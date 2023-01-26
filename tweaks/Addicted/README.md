# custom status effects

Relevant documentation: [YAML Tweaks](https://github.com/psiberx/cp2077-tweak-xl/wiki/YAML-Tweaks).

## troubleshooting

- some status effects literally bug if not associated with the proper `BaseStatusEffectTypes`
  > e.g. derive `BaseStatusEffect.Stun` with `BaseStatusEffectTypes.Misc` instead of `BaseStatusEffectTypes.Stunned`
- there's a limit in combining from multiple status effects: sometimes the field is a single `TweakDBID`. solution is to sequence status effects manually with e.g. `DelaySystem`.
- some status effects don't always play well together.
- custom defined VFX won't get applied (even if identical to existing one).
- sometimes SFX is directly included in VFX
  > e.g. with `BaseStatusEffect.InhalerBuff` there's a slight sound effect played altogether with the VFX (see Tweak Browser for reference, there's no SFX)
- sometimes there's no `SFX` field declared at the top, but there can be `packages` defined with a `PlaySFXEffector`, or both.
 > `PlaySFXEffector`: see `BaseStatusEffect.JohnnySicknessHeavy`
 >
 > `SFX`: see `BaseStatusEffect.Madness`
 >
 > both: see `BaseStatusEffect.DruggedSevere`
 >
 > `activationSFXName` and `deactivationSFXName` echoe to what can be found in **Toxicity** mod: `GameObject.SetAudioParameter(this, n"vfx_fullscreen_drugged_level", 3.00);` where e.g. `BaseStatusEffect.DruggedSevere` has `vfx_fullscreen_drugged_start` and `vfx_fullscreen_drugged_stop`

## VFX

Visual effects applied.

e.g.
- `BaseStatusEffect.Blind_inline0`
- `BaseStatusEffect.InhalerBuff_inline0`
- `BaseStatusEffect.SandstormAbstract_inline0`
- `BaseStatusEffect.BlackLaceV0_inline0`
- `BaseStatusEffect.PlayerExhausted_inline0`
- `BaseStatusEffect.Bleeding_inline0`

## SFX

Sound effects applied.

e.g.
- `BaseStatusEffect.Bleeding_inline4`
- `BaseStatusEffect.Madness_inline22`
- `BaseStatusEffect.Stun_inline7`
- `BaseStatusEffect.BaseBrainMelt_inline4`
- `BaseStatusEffect.BaseContagion_inline2`
- `BaseStatusEffect.BaseContagionPoison_inline0`
- `BaseStatusEffect.Poisoned_inline31`
- `BaseStatusEffect.DruggedSevere_inline3`

## Breathing

Character breathing effect, must be applied in `packages`.
> see `BaseStatusEffect.JohnnySicknessHeavy`