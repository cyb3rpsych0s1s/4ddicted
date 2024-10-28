module Addicted

import Codeware.Localization.*

public class French extends LocalizationPackage {
    protected func DefineTexts() -> Void {
        super.DefineTexts();
        
        // base vocabulary
        this.Text("Mod-Addicted-Thresholds",                            "Paliers");
        this.Text("Mod-Addicted-Threshold-Barely-Desc",                 "V commence à être à peine accro à ce stade");
        this.Text("Mod-Addicted-Threshold-Mildly-Desc",                 "V commence à être passablement accro à ce stade");
        // addiction vocabulary
        this.Text("Mod-Addicted-Substance",                             "substance");
        this.Text("Mod-Addicted-Threshold",                             "palier");
        // each threshold of addiction
        this.Text("Mod-Addicted-Threshold-Clean",                       "clean");
        this.Text("Mod-Addicted-Threshold-Barely",                      "à peine");
        this.Text("Mod-Addicted-Threshold-Mildly",                      "passablement");
        this.Text("Mod-Addicted-Threshold-Notably",                     "notoirement");
        this.Text("Mod-Addicted-Threshold-Severely",                    "sévèrement");
        // addiction progress warnings (biomonitor UI)
        this.Text("Mod-Addicted-Warn-Increased",                        "symptômes d'accoutumance détectés");
        this.Text("Mod-Addicted-Warn-Decreased",                        "symptômes d'accoutumance en récession");
        this.Text("Mod-Addicted-Warn-Gone",                             "symptômes d'accoutumance dissipés");
        // booting sequence (biomonitor UI)
        this.Text("Mod-Addicted-Biomonitor-Booting",                    "CHARGEMENT");
        // different types of consumables
        this.Text("Mod-Addicted-Consumable-Unknown",                    "Consommable inconnu");
        this.Text("Mod-Addicted-Consumable-MaxDOC",                     "MaxDoc");
        this.Text("Mod-Addicted-Consumable-BounceBack",                 "Revitalisant");
        this.Text("Mod-Addicted-Consumable-BlackLace",                  "Lien Noir");
        this.Text("Mod-Addicted-Consumable-MemoryBooster",              "Sursaut de Mémoire Vive");
        // addictions state warnings (biomonitor UI)
        this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Severely",  "SYMPTÔMES D'ACCOUTUMANCE ALARMANTS");
        this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Notably",   "SYMPTÔMES D'ACCOUTUMANCE NOTOIRES");
        // addictions withdrawal symptoms descriptions (radial wheel UI)
        this.Text("Mod-Addicted-Withdrawn-BlackLace-Desc",              "{int_0}% Réflexes");
        this.Text("Mod-Addicted-Withdrawn-StaminaBooster-Desc",         "{int_0}% Endurance max.");
        this.Text("Mod-Addicted-Withdrawn-CarryCapacityBooster-Desc",   "{int_0}% Capacité de charge");
        this.Text("Mod-Addicted-Withdrawn-MemoryBooster-Desc",          "{int_0}% Max d'unités de mémoire vive");
        // addictions craving descriptions (radial wheel UI)
        this.Text("Mod-Addicted-Craving-For-StaminaBooster",            "Accro au Booster d'Endurance");
        this.Text("Mod-Addicted-Craving-For-CarryCapacityBooster",      "Accro au Booster de Charge");
        this.Text("Mod-Addicted-Craving-For-MemoryBooster",             "Accro au Sursaut de Mémoire Vive");
        this.Text("Mod-Addicted-Craving-For-BlackLace",                 "Accro au Lien Noir");
        // chemical description when biomonitor warns V
        this.Text("Mod-Addicted-Chemical-Benzedrine",                   "Benzedrine");
        this.Text("Mod-Addicted-Chemical-Cortisone",                    "Cortisone");
        this.Text("Mod-Addicted-Chemical-Dynorphin",                    "Dynorphine");
        this.Text("Mod-Addicted-Chemical-Ethanol",                      "Éthanol");
        this.Text("Mod-Addicted-Chemical-Hydrocortisone",               "Hydrocortisone");
        this.Text("Mod-Addicted-Chemical-Methadone",                    "Méthadone");
        this.Text("Mod-Addicted-Chemical-Modafinil",                    "Modafinil");
        this.Text("Mod-Addicted-Chemical-Oxandrin",                     "Oxandrine");
        this.Text("Mod-Addicted-Chemical-Prednisone",                   "Prednisone");
        this.Text("Mod-Addicted-Chemical-Testosterone",                 "Testostérone");
        this.Text("Mod-Addicted-Chemical-Trimix",                       "Trimix");
        this.Text("Mod-Addicted-Chemical-Nicotine",                     "Nicotine");
        this.Text("Mod-Addicted-Chemical-Epinephrine",                  "Épinéphrine");
        this.Text("Mod-Addicted-Chemical-Paracetamol",                  "Paracetamol");
        this.Text("Mod-Addicted-Chemical-Nanites",                      "Nanites");
        this.Text("Mod-Addicted-Chemical-Prazosin",                     "Prazosin");
        this.Text("Mod-Addicted-Chemical-Brevibloc",                    "Brevibloc");
        this.Text("Mod-Addicted-Chemical-Lopressor",                    "Lopressor");
        this.Text("Mod-Addicted-Chemical-Irrelevant",                   "Non-applicable");
        // displayed on screen to dismiss biomonitor
        this.Text("Mod-Addicted-Dismiss-Biomonitor",                    "Eteindre le biomoniteur");
        // WannaBe EdgeRunner
        this.Text("Mod-Addicted-Edgerunning-BlackLace-Penalty",         "Overdose de Lien Noir");
        this.Text("Mod-Addicted-Unknown",                               "INCONNUE", "INCONNU");
        // status effects (radial wheel UI)
        this.Text("Mod-Addicted-Totter",                                "Titube");
        this.Text("Mod-Addicted-Totter-Desc",                           "Titubant");

        this.Text("Mod-Addicted-Overdose-BlackLace",                    "Sous l'emprise du Lien Noir");
        this.Text("Mod-Addicted-Overdose-BlackLace-Desc",               "On dit que la surconsommation de Lien Noir peut entraîner des crises de Cyberpsychose");
        
        this.Text("Mod-Addicted-ShortBreath",                           "Souffle court");
        this.Text("Mod-Addicted-ShortBreath-Desc",                      "Tu es à court d'Endurance choom, prends le temps de respirer ! {int_0}% regen. Endurance, courir consomme ton Endurance");

        this.Text("Mod-Addicted-BreathLess",                            "A bout de souffle");
        this.Text("Mod-Addicted-BreathLess-Desc",                       "Ton Endurance est à plat, tu arrives à peine à respirer: {int_0}% regen. d'Endurance, {int_1}% de délai additionnel par palier, courir et esquiver consomment ton Endurance");
        
        this.Text("Mod-Addicted-Jitters",                               "La tremblotte");
        this.Text("Mod-Addicted-Jitters-Desc",                          "Tes mains tremblent, choom... Viser devient hasardeux");
        
        this.Text("Mod-Addicted-PhotoSensitive",                        "Photosensible");
        this.Text("Mod-Addicted-PhotoSensitive-Desc",                   "Les grenades flash t'affectent plus longtemps");
        // cautions (inventory tooltip UI)
        this.Text("Mod-Addicted-Consumable-Healers-Caution",            "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Mise en garde</>\nBien que nos produits thérapeutiques <Rich color=\"MainColors.ActiveBlue\">TraumaTeam</> offrent un soulagement puissant et presque instantané, ils ne remplacent pas le processus de guérison naturelle. Une utilisation excessive peut entraîner une diminution de leur efficacité et retarder votre guérison.");
        this.Text("Mod-Addicted-Consumable-Alcohols-Caution",           "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Mise en garde</>\nBien que nous apprécions tous les joies de l'ébriété, prenez garde car toute consommation excessive est susceptible d'entraîner des tremblottements. Veuillez consommer avec modération pour une expérience satisfaisante, tant socialement que physiologiquement.");
        this.Text("Mod-Addicted-Consumable-MemoryBooster-Caution",      "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Mise en garde</>\nToute consommation excessive de Sursaut de mémoire vive peut entraîner des effets indésirables, tels le phénomène de manque, des capacités cognitives diminuées, des migraines et une sensibilité exacerbée à la luminosité. Veillez à consommer avec modération et n'hésitez pas à faire appel à un spécialiste si vous êtes l'objet d'effets secondaires.\n<Rich color=\"MainColors.ActiveBlue\">Arasaka</> ne saurait en aucun cas être tenue pour responsable.");
        this.Text("Mod-Addicted-Consumable-StaminaBooster-Caution",     "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Mise en garde</>\nToute consommation excessive de Booster d'Endurance peut entraîner des effets indésirables tels qu'une endurance amoindrie, de la fatigue, et une diminution de performances. Veillez à consommer avec modération et n'hésitez pas à faire appel à un spécialiste si vous êtes l'objet d'effets secondaires.\n<Rich color=\"MainColors.ActiveBlue\">Militech Corporation</> ne saurait en aucun cas être tenue pour responsable.");
        this.Text("Mod-Addicted-Consumable-CarryCapacityBooster-Caution","\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Mise en garde</>\nToute consommation excessive de Booster de Charge peut entraîner des effets indésirables tels qu'une mobilité diminuée, des muscles endoloris et des stigmates corporels. Veillez à consommer avec modération et n'hésitez pas à faire appel à un spécialiste si vous êtes l'objet d'effets secondaires.\n<Rich color=\"MainColors.ActiveBlue\">Kang Tao Corporation</> ne saurait en aucun cas être tenue pour responsable.");
        this.Text("Mod-Addicted-Consumable-Tobacco-Caution",            "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Mise en garde</>\nFumer cigarettes ou cigares peut nuire ou carrément vous couper le souffle. Consommer avec modération et gardez en tête les potentiels risques de santé liés au tabagisme.");
        this.Text("Mod-Addicted-Consumable-BlackLace-Caution",          "\n<Rich color=\"MainColors.ActiveRed\" style=\"Semi-Bold\">Attention</>\nLe Lien Noir est une substance prohibée qui provoque une forte accoutumance. Une consommation régulière vous expose à de graves phénomènes d'accoutumance et de nombreux effets indésirables, tels que la fibromyalgie et une plus grande propention à la Cyberpsychose. L'usage de cette substance est fortement déconseillée et peut gravement nuire à votre santé ainsi qu'à votre bien-être.");
        this.Text("Mod-Addicted-Consumable-NeuroBlocker-Caution",       "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Mise en garde</>\nLes inhibiteurs neuraux, bien qu'initialement prévus pour atténuer la fatigue mentale et les risques de Cyberpsychose, peuvent rapidement devenir addictifs lorsqu'ils sont utilisés conjointement avec des neuros-stimulants cybernétiques tels que le Sandevistan ou l'Ex-Disk, entre autres. Veuillez en user avec modération, et n'hésitez pas à consulter en cas d'accoutumance.");
        // Drug Pump
        this.Text("Gameplay-Cyberware-DisplayName-DrugPump",            "Pompe noire");
        this.Text("Gameplay-Cyberware-LocalizedDescription-DrugPump",   "Cette Pompe sanguine trafiquée augmente la capacité de guérison de son détenteur, en lui injectant directement du Lien Noir dans le sang.");
        this.Text("Gameplay-Cyberware-Abilities-DrugPump",              "\nConsomme un Lien Noir, si possédé, seulement <Rich color=\"TooltipText.cyberwareDescriptionHighlightColor\" style=\"Semi-Bold\">{int_0}%</> du temps.");
    }
}