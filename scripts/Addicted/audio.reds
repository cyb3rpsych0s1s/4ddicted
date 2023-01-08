module Addicted

private func Coughing(gender: CName, threshold: Threshold) -> array<CName> {
    if Equals(gender, n"Female") {
        switch(threshold) {
            case Threshold.Severely:
                return [
                    n"q114_sc_02_v_vo_cough",
                    n"q115_sc_00b_vo_v_cough"
                ];
            case Threshold.Notably:
                return [
                    n"q203_sc_01_v_female_cough",
                    n"q114_sc_02_v_vo_cough"
                ];
            default:
                break;
        }
        return [
            n"q203_sc_01_v_female_cough",
            n"q114_sc_02_v_vo_cough",
            n"q115_sc_00b_vo_v_cough"
        ];
    }
    switch(threshold) {
        case Threshold.Severely:
            return [
                n"g_sc_v_sickness_cough_hard",
                n"g_sc_v_sickness_cough_blood"
            ];
        case Threshold.Notably:
            return [
                n"g_sc_v_sickness_cough_light",
                n"g_sc_v_sickness_cough_hard"
            ];
        default:
            break;
    }
    return [
        n"g_sc_v_sickness_cough_light"
    ];
}

public func RandomCoughing(gender: CName, threshold: Threshold) -> CName {
    let audios = Coughing(gender, threshold);
    let count = ArraySize(audios);
    if count == 1 {
        return audios[0];
    }
    let idx = RandRange(0, count - 1);
    return audios[idx];
}