module Addicted

public class NoCorpoDistricts extends IScriptablePrereq {
  public const func IsFulfilled(game: GameInstance, context: ref<IScriptable>) -> Bool {
    let ps: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
    let district = ps.GetCurrentDistrict().GetDistrictID();
    let corpos = [
        t"Districts.ArasakaTowerSaburoOffice",
        t"Districts.ArasakaTowerAtrium",
        t"Districts.ArasakaTowerNest",
        t"Districts.CharterHill",
        t"Districts.ArasakaTowerJenkins",
        t"Districts.ArasakaWarehouse",
        t"Districts.Arasaka_Estate",
        t"Districts.q110Cyberspace",
        t"Districts.CorpoPlaza",
        t"Districts.ArasakaTowerUpperAtrium",
        t"Districts.q201Cyberspace",
        t"Districts.ArasakaTowerCEOFloor",
        t"Districts.q201SpaceStation",
        t"Districts.CityCenter",
        t"Districts.ArasakaTowerLobby",
        t"Districts.ArasakaTowerJungle",
        t"Districts.ArasakaWaterfront"
    ];
    return !ArrayContains(corpos, district);
  }
}
