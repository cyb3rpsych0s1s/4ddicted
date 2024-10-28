module Addicted

import Codeware.Localization.*

public class Italian extends ModLocalizationPackage {
    protected func DefineTexts() -> Void {
        super.DefineTexts();

        // base vocabulary
        this.Text("Mod-Addicted-Thresholds",                            "Elenco");
        this.Text("Mod-Addicted-Threshold-Barely-Desc",                 "V inizia ad essere un pò dipendente superata questa soglia");
        this.Text("Mod-Addicted-Threshold-Mildly-Desc",                 "V inizia ad essere abbastanza dipendente dopo questa soglia");
        // addiction vocabulary
        this.Text("Mod-Addicted-Substance",                             "sostanza");
        this.Text("Mod-Addicted-Threshold",                             "elenco");
        // each threshold of addiction
        this.Text("Mod-Addicted-Threshold-Clean",                       "pulito");
        this.Text("Mod-Addicted-Threshold-Barely",                      "appena");
        this.Text("Mod-Addicted-Threshold-Mildly",                      "leggermente");
        this.Text("Mod-Addicted-Threshold-Notably",                     "palese");
        this.Text("Mod-Addicted-Threshold-Severely",                    "severamente");
        // addiction progress warnings (biomonitor UI)
        this.Text("Mod-Addicted-Warn-Increased",                        "sintomi di rilevata dipendenza");
        this.Text("Mod-Addicted-Warn-Decreased",                        "sintomi di dipendenza in recessione");
        this.Text("Mod-Addicted-Warn-Gone",                             "sintomi di dipendenza scomparsi");
        // booting sequence (biomonitor UI)
        this.Text("Mod-Addicted-Biomonitor-Booting",                    "AVVIO");
        // different types of consumables
        this.Text("Mod-Addicted-Consumable-Unknown",                    "Sostanza sconosciuta");
        this.Text("Mod-Addicted-Consumable-MaxDOC",                     "MaxDoc");
        this.Text("Mod-Addicted-Consumable-BounceBack",                 "Rimbalzo");
        this.Text("Mod-Addicted-Consumable-BlackLace",                  "Morte nera");
        this.Text("Mod-Addicted-Consumable-MemoryBooster",              "Scossa RAM");
        // addictions state warnings (biomonitor UI)
        this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Severely",  "PERICOLOSI SINTOMI DI DIPENDENZA");
        this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Notably",   "VISIBILI SINTOMI DI DIPENDENZA");
        // addictions withdrawal symptoms descriptions (radial wheel UI)
        this.Text("Mod-Addicted-Withdrawn-BlackLace-Desc",              "{int_0}% Riflessi Massimizzati");
        this.Text("Mod-Addicted-Withdrawn-StaminaBooster-Desc",         "{int_0}% Resistenza Massimizzata");
        this.Text("Mod-Addicted-Withdrawn-CarryCapacityBooster-Desc",   "{int_0}% Capacità di Trasporto");
        this.Text("Mod-Addicted-Withdrawn-MemoryBooster-Desc",          "{int_0}% Massime Unità di Ram");
        // addictions craving descriptions (radial wheel UI)
        this.Text("Mod-Addicted-Craving-For-StaminaBooster",            "Bramando lo Potenziatore resistenza");
        this.Text("Mod-Addicted-Craving-For-CarryCapacityBooster",      "Bramando lo Potenziatore capacità");
        this.Text("Mod-Addicted-Craving-For-MemoryBooster",             "Bramando lo Scossa RAM");
        this.Text("Mod-Addicted-Craving-For-BlackLace",                 "Bramando lo Morte nera");
        // chemical description when biomonitor warns V
        this.Text("Mod-Addicted-Chemical-Benzedrine",                   "Benzedrina");
        this.Text("Mod-Addicted-Chemical-Cortisone",                    "Cortisone");
        this.Text("Mod-Addicted-Chemical-Dynorphin",                    "Dinorfina");
        this.Text("Mod-Addicted-Chemical-Ethanol",                      "Etanolo");
        this.Text("Mod-Addicted-Chemical-Hydrocortisone",               "Hydrocortisone");
        this.Text("Mod-Addicted-Chemical-Methadone",                    "Metadone");
        this.Text("Mod-Addicted-Chemical-Modafinil",                    "Modafinile");
        this.Text("Mod-Addicted-Chemical-Oxandrin",                     "Oxandrolone");
        this.Text("Mod-Addicted-Chemical-Prednisone",                   "Deltacortene");
        this.Text("Mod-Addicted-Chemical-Testosterone",                 "Testosterone");
        this.Text("Mod-Addicted-Chemical-Trimix",                       "Trimix");
        this.Text("Mod-Addicted-Chemical-Nicotine",                     "Nicotina");
        this.Text("Mod-Addicted-Chemical-Epinephrine",                  "Epinefrina");
        this.Text("Mod-Addicted-Chemical-Paracetamol",                  "Paracetamolo");
        this.Text("Mod-Addicted-Chemical-Nanites",                      "Naniti");
        this.Text("Mod-Addicted-Chemical-Prazosin",                     "Prazosina");
        this.Text("Mod-Addicted-Chemical-Brevibloc",                    "Breviblocco");
        this.Text("Mod-Addicted-Chemical-Lopressor",                    "Lopressor");
        this.Text("Mod-Addicted-Chemical-Irrelevant",                   "Irrilevante");
        // displayed on screen to dismiss biomonitor
        this.Text("Mod-Addicted-Dismiss-Biomonitor",                    "Disattiva Biomonitor");
        // WannaBe EdgeRunner
        this.Text("Mod-Addicted-Edgerunning-BlackLace-Penalty",         "Overdose di Morte nera");
        this.Text("Mod-Addicted-Unknown",                               "SCONOSCIUTA", "SCONOSCIUTO");
        // status effects (radial wheel UI)
        this.Text("Mod-Addicted-Totter",                                "Vacillare");
        this.Text("Mod-Addicted-Totter-Desc",                           "Vacillante");

        this.Text("Mod-Addicted-Overdose-BlackLace",                    "Follia da Morte nera");
        this.Text("Mod-Addicted-Overdose-BlackLace-Desc",               "Abusare della Morte nera si dice possa portarti alla cybepsicosi");
        
        this.Text("Mod-Addicted-ShortBreath",                           "Respiro corto");
        this.Text("Mod-Addicted-ShortBreath-Desc",                      "Stai esaurendo la resistenza, choom, prenditi del tempo per respirare! {int_0}% Rigenerazione Stamina, gli scatti riducono la resistenza.");

        this.Text("Mod-Addicted-BreathLess",                            "Senza fiato");
        this.Text("Mod-Addicted-BreathLess-Desc",                       "La tua resistenza è esaurita, puoi a malapena respirare: {int_0}% Rigenerazione Stamina, {int_1}% ritardo addizionale, scatti e schivate riducono la resistenza");
        
        this.Text("Mod-Addicted-Jitters",                               "Nervosismi");
        this.Text("Mod-Addicted-Jitters-Desc",                          "Ti tremano le mani choom...la mira è molto imprecisa");
        
        this.Text("Mod-Addicted-PhotoSensitive",                        "Fotosensibilità");
        this.Text("Mod-Addicted-PhotoSensitive-Desc",                   "Le flashbang ti danneggiano più a lungo");
        // cautions (inventory tooltip UI)
        this.Text("Mod-Addicted-Consumable-Healers-Caution",            "");
        this.Text("Mod-Addicted-Consumable-Alcohols-Caution",           "");
        this.Text("Mod-Addicted-Consumable-MemoryBooster-Caution",      "");
        this.Text("Mod-Addicted-Consumable-StaminaBooster-Caution",     "");
        this.Text("Mod-Addicted-Consumable-CarryCapacityBooster-Caution","");
        this.Text("Mod-Addicted-Consumable-Tobacco-Caution",            "");
        this.Text("Mod-Addicted-Consumable-BlackLace-Caution",          "");
        this.Text("Mod-Addicted-Consumable-NeuroBlocker-Caution",       "");
        // Drug Pump
        this.Text("Gameplay-Cyberware-DisplayName-DrugPump",            "");
        this.Text("Gameplay-Cyberware-LocalizedDescription-DrugPump",   "");
        this.Text("Gameplay-Cyberware-Abilities-DrugPump",              "");
    }
}