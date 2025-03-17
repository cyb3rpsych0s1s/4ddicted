module Addicted.Crossover

@if(ModuleExists("SurvivalSystemModule"))
import SurvivalSystemModule.SurvivalSystem

@if(!ModuleExists("SurvivalSystemModule"))
public func StressPreventWeanOff(game: GameInstance) -> Bool = false;

@if(ModuleExists("SurvivalSystemModule"))
public func StressPreventWeanOff(game: GameInstance) -> Bool = SurvivalSystem.GetInstance(game).GetStressCurrent() > 60.;

@if(!ModuleExists("SurvivalSystemModule"))
public func ConditionModifier(game: GameInstance) -> Int32 = 0;

@if(ModuleExists("SurvivalSystemModule"))
public func ConditionModifier(game: GameInstance) -> Int32 {
    let condition = SurvivalSystem.GetInstance(game).GetCurrentCondition();
    return condition >= 0.85
    ? 1
    : condition < 0.4
        ? -1
        : condition < 0.25
            ? -2
            : 0;
}
