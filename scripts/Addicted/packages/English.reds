module Addicted

import Codeware.Localization.*

public class English extends ModLocalizationPackage {
    protected func DefineTexts() -> Void {
        super.DefineTexts();

        // base vocabulary
        this.Text("Mod-Addicted-Thresholds",                            "Thresholds");
        this.Text("Mod-Addicted-Threshold-Barely-Desc",                 "V start getting barely addicted past this threshold");
        this.Text("Mod-Addicted-Threshold-Mildly-Desc",                 "V start getting mildly addicted past this threshold");
        // mod difficulty
        this.Text("Mod-Addicted-Mode",                                  "Mode");
        this.Text("Mod-Addicted-Mode-Normal",                           "easy pizzy");
        this.Text("Mod-Addicted-Mode-Hard",                             "more... lethal");
        // addiction vocabulary
        this.Text("Mod-Addicted-Substance",                             "substance");
        this.Text("Mod-Addicted-Threshold",                             "threshold");
        // each threshold of addiction
        this.Text("Mod-Addicted-Threshold-Clean",                       "clean");
        this.Text("Mod-Addicted-Threshold-Barely",                      "barely");
        this.Text("Mod-Addicted-Threshold-Mildly",                      "mildly");
        this.Text("Mod-Addicted-Threshold-Notably",                     "notably");
        this.Text("Mod-Addicted-Threshold-Severely",                    "severely");
        // addiction progress warnings (biomonitor UI)
        this.Text("Mod-Addicted-Warn-Increased",                        "symptoms of addiction detected");
        this.Text("Mod-Addicted-Warn-Decreased",                        "symptoms of addiction in recession");
        this.Text("Mod-Addicted-Warn-Gone",                             "symptoms of addiction gone");
        // booting sequence (biomonitor UI)
        this.Text("Mod-Addicted-Biomonitor-Booting",                    "BOOTING");
        // different types of consumables
        this.Text("Mod-Addicted-Consumable-Unknown",                    "Unknown consumable");
        this.Text("Mod-Addicted-Consumable-MaxDOC",                     "MaxDoc");
        this.Text("Mod-Addicted-Consumable-BounceBack",                 "Bounce Back");
        this.Text("Mod-Addicted-Consumable-BlackLace",                  "BlackLace");
        this.Text("Mod-Addicted-Consumable-MemoryBooster",              "RAM Jolt");
        // addictions state warnings (biomonitor UI)
        this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Severely",  "SERIOUS ADDICTION SYMPTOMS");
        this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Notably",   "NOTABLE ADDICTION SYMPTOMS");
        // addictions withdrawal symptoms descriptions (radial wheel UI)
        this.Text("Mod-Addicted-Withdrawn-BlackLace-Desc",              "{int_0}% Max Reflexes");
        this.Text("Mod-Addicted-Withdrawn-StaminaBooster-Desc",         "{int_0}% Max Stamina");
        this.Text("Mod-Addicted-Withdrawn-CarryCapacityBooster-Desc",   "{int_0}% Carry Capacity");
        this.Text("Mod-Addicted-Withdrawn-MemoryBooster-Desc",          "{int_0}% Max RAM Units");
        // addictions craving descriptions (radial wheel UI)
        this.Text("Mod-Addicted-Craving-For-StaminaBooster",            "Craving for Stamina Booster");
        this.Text("Mod-Addicted-Craving-For-CarryCapacityBooster",      "Craving for Carry Capacity Booster");
        this.Text("Mod-Addicted-Craving-For-MemoryBooster",             "Craving for Memory Booster");
        this.Text("Mod-Addicted-Craving-For-BlackLace",                 "Craving for Black Lace");
        // chemical description when biomonitor warns V
        this.Text("Mod-Addicted-Chemical-Benzedrine",                   "Benzedrine");
        this.Text("Mod-Addicted-Chemical-Cortisone",                    "Cortisone");
        this.Text("Mod-Addicted-Chemical-Dynorphin",                    "Dynorphin");
        this.Text("Mod-Addicted-Chemical-Ethanol",                      "Ethanol");
        this.Text("Mod-Addicted-Chemical-Hydrocortisone",               "Hydrocortisone");
        this.Text("Mod-Addicted-Chemical-Methadone",                    "Methadone");
        this.Text("Mod-Addicted-Chemical-Modafinil",                    "Modafinil");
        this.Text("Mod-Addicted-Chemical-Oxandrin",                     "Oxandrin");
        this.Text("Mod-Addicted-Chemical-Prednisone",                   "Prednisone");
        this.Text("Mod-Addicted-Chemical-Testosterone",                 "Testosterone");
        this.Text("Mod-Addicted-Chemical-Trimix",                       "Trimix");
        this.Text("Mod-Addicted-Chemical-Nicotine",                     "Nicotine");
        this.Text("Mod-Addicted-Chemical-Epinephrine",                  "Epinephrine");
        this.Text("Mod-Addicted-Chemical-Paracetamol",                  "Paracetamol");
        this.Text("Mod-Addicted-Chemical-Nanites",                      "Nanites");
        this.Text("Mod-Addicted-Chemical-Prazosin",                     "Prazosin");
        this.Text("Mod-Addicted-Chemical-Brevibloc",                    "Brevibloc");
        this.Text("Mod-Addicted-Chemical-Lopressor",                    "Lopressor");
        this.Text("Mod-Addicted-Chemical-Irrelevant",                   "Irrelevant");
        // displayed on screen to dismiss biomonitor
        this.Text("Mod-Addicted-Dismiss-Biomonitor",                    "Dismiss biomonitor");
        // WannaBe EdgeRunner
        this.Text("Mod-Addicted-Edgerunning-BlackLace-Penalty",         "BlackLace overdose");
        this.Text("Mod-Addicted-Unknown",                               "UNKNOWN");
        // status effects (radial wheel UI)
        this.Text("Mod-Addicted-Totter",                                "Totter");
        this.Text("Mod-Addicted-Totter-Desc",                           "Tottering");

        this.Text("Mod-Addicted-Overdose-BlackLace",                    "BlackLace insanity");
        this.Text("Mod-Addicted-Overdose-BlackLace-Desc",               "consuming too much BlackLace is said to potentially indulge Cyberpsychosis");
        
        this.Text("Mod-Addicted-ShortBreath",                           "Short breath");
        this.Text("Mod-Addicted-ShortBreath-Desc",                      "Your stamina runs short choom, take a time to breath! {int_0}% Stamina regen., sprint consumes Stamina");

        this.Text("Mod-Addicted-BreathLess",                            "Breathless");
        this.Text("Mod-Addicted-BreathLess-Desc",                       "Your stamina is drained, you can barely breath: {int_0}% Stamina regen., {int_1}% additional delay per stack, sprint and dodge consumes Stamina");
        
        this.Text("Mod-Addicted-Jitters",                               "Jitters");
        this.Text("Mod-Addicted-Jitters-Desc",                          "Your hands are shaking choom... Aiming is severely impaired");
        
        this.Text("Mod-Addicted-PhotoSensitive",                        "Photosensitive");
        this.Text("Mod-Addicted-PhotoSensitive-Desc",                   "Flashbang grenades impair you longer");
        // cautions (inventory tooltip UI)
        this.Text("Mod-Addicted-Consumable-Healers-Caution",            "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Caution</>\nWhile our healing products at <Rich color=\"MainColors.ActiveBlue\">TraumaTeam</> offer potent and almost instant relief, they are not a substitute for adequate rest and natural healing. Overuse may diminish their efficacy and delay recovery.");
        this.Text("Mod-Addicted-Consumable-Alcohols-Caution",           "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Caution</>\nWhile we all appreciate the social lubrication qualities of alcohols, please be advised that excessive consumption may result in the onset of 'spirited' jitters. Remember, moderation is the prescription for a smoother experience, both socially and physiologically.");
        this.Text("Mod-Addicted-Consumable-MemoryBooster-Caution",      "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Caution</>\nExcessive consumption of RAM Jolt may lead to adverse effects, including withdrawal symptoms, diminished memory capacity, migraines, and increased photosensitivity. Please use responsibly and consult a qualified medical professional if experiencing any negative reactions.\n<Rich color=\"MainColors.ActiveBlue\">Arasaka</> cannot be held responsible under any circumstances for improper use.");
        this.Text("Mod-Addicted-Consumable-StaminaBooster-Caution",     "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Caution</>\nOverconsumption of Stamina Booster may result in adverse effects, including diminished stamina, fatigue, and potential performance decline. Please use responsibly and consult a qualified medical professional if experiencing any negative reactions.\n<Rich color=\"MainColors.ActiveBlue\">Militech Corporation</> cannot be held responsible under any circumstances for improper use.");
        this.Text("Mod-Addicted-Consumable-CarryCapacityBooster-Caution","\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Caution</>\nOverconsumption of Carry Capacity Booster may lead to adverse effects, including decreased mobility, muscle fatigue, and potential strain on the body. Please use responsibly and consult a qualified medical professional if experiencing any negative reactions.\n<Rich color=\"MainColors.ActiveBlue\">Kang Tao Corporation</> cannot be held responsible under any circumstances for improper use.");
        this.Text("Mod-Addicted-Consumable-Tobacco-Caution",            "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Caution</>\nTobacco consumption, including cigarettes and cigars, may lead to shortness of breath or breathlessness. Please use with caution and consider the potential health risks associated with smoking.");
        this.Text("Mod-Addicted-Consumable-BlackLace-Caution",          "\n<Rich color=\"MainColors.ActiveRed\" style=\"Semi-Bold\">Warning</>\nBlackLace is a potent and highly addictive illegal substance. Regular consumption may lead to severe withdrawal symptoms and adverse effects, including fibromyalgia and heightened susceptibility to cyberpsychosis. Use of this substance is strongly discouraged and may have serious consequences for your health and well-being.");
        this.Text("Mod-Addicted-Consumable-NeuroBlocker-Caution",       "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Caution</>\nNeuroBlocker, while initially helpful in managing cognitive overload and cyberpsychosis symptoms, can lead to rapid addiction when used in conjunction with neuro-stimuli-based cyberware such as Sandevistan and Ex-Disk, among others. Please use sparingly and seek medical advice if dependence develops.");
        // Drug Pump
        this.Text("Gameplay-Cyberware-DisplayName-DrugPump",            "Black Lace Pump");
        this.Text("Gameplay-Cyberware-LocalizedDescription-DrugPump",   "This street-modified blood pump accelerates its possessor's healing while spiking their bloodstream with Black Lace.");
        this.Text("Gameplay-Cyberware-Abilities-DrugPump",              "\nUses Black Lace, if possessed, but with only a <Rich color=\"TooltipText.cyberwareDescriptionHighlightColor\" style=\"Semi-Bold\">{int_0}%</> chance to consume the item.");
    }
}