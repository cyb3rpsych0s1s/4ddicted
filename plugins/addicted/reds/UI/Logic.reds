module Addicted

private func GetUIIcon(threshold: Threshold, name: String) -> String {
    if !IsSerious(threshold) { return "UIIcon." + name; }
    let icon = name;
    switch(icon) {
        case "first_aid_whiff_icon":
        case "regeneration_icon":
        case "health_booster_icon":
            icon = (Equals(threshold, Threshold.Severely) ? "severely" : "notably") + "_weakened_" + icon;
    }
    return "UIIcon." + icon;
}
