module Addicted

import Codeware.Localization.*

public class Spanish extends LocalizationPackage {
    protected func DefineTexts() -> Void {
        super.DefineTexts();
        
        // base vocabulary
        this.Text("Mod-Addicted-Thresholds",                            "Umbrales");
        this.Text("Mod-Addicted-Threshold-Barely-Desc",                 "V empieza a volverse apenas adicto después de este umbral.");
        this.Text("Mod-Addicted-Threshold-Mildly-Desc",                 "V comienza a volverse levemente adicto más allá de este umbral.");
        // addiction vocabulary
        this.Text("Mod-Addicted-Substance",                             "sustancia");
        this.Text("Mod-Addicted-Threshold",                             "umbral");
        // each threshold of addiction
        this.Text("Mod-Addicted-Threshold-Clean",                       "limpio");
        this.Text("Mod-Addicted-Threshold-Barely",                      "apenas");
        this.Text("Mod-Addicted-Threshold-Mildly",                      "moderadamente");
        this.Text("Mod-Addicted-Threshold-Notably",                     "notoriamente");
        this.Text("Mod-Addicted-Threshold-Severely",                    "severamente");
        // addiction progress warnings (biomonitor UI)
        this.Text("Mod-Addicted-Warn-Increased",                        "síntomas de dependencia detectados");
        this.Text("Mod-Addicted-Warn-Decreased",                        "síntomas de dependencia en recesión");
        this.Text("Mod-Addicted-Warn-Gone",                             "síntomas de adicción disipados");
        // booting sequence (biomonitor UI)
        this.Text("Mod-Addicted-Biomonitor-Booting",                    "CARGANDO");
        // different types of consumables
        this.Text("Mod-Addicted-Consumable-Unknown",                    "Consumible desconocido");
        this.Text("Mod-Addicted-Consumable-MaxDOC",                     "MaxDoc");
        this.Text("Mod-Addicted-Consumable-BounceBack",                 "Rebote");
        this.Text("Mod-Addicted-Consumable-BlackLace",                  "BlackLace");
        this.Text("Mod-Addicted-Consumable-MemoryBooster",              "Estímulo de RAM");
        // addictions state warnings (biomonitor UI)
        this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Severely",  "SÍNTOMAS DE ADICCIÓN PREOCUPANTES");
        this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Notably",   "SÍNTOMAS DE ADICCIÓN NOTORIOS");
        // addictions withdrawal symptoms descriptions (radial wheel UI)
        this.Text("Mod-Addicted-Withdrawn-BlackLace-Desc",              "{int_0}% Reflejos");
        this.Text("Mod-Addicted-Withdrawn-StaminaBooster-Desc",         "{int_0}% Resistencia máx.");
        this.Text("Mod-Addicted-Withdrawn-CarryCapacityBooster-Desc",   "{int_0}% Capacidad de Carga");
        this.Text("Mod-Addicted-Withdrawn-MemoryBooster-Desc",          "{int_0}% Máx. de memoria RAM");
        // addictions craving descriptions (radial wheel UI)
        this.Text("Mod-Addicted-Craving-For-StaminaBooster",            "Anhelo por el Potenciador de Resistencia");
        this.Text("Mod-Addicted-Craving-For-CarryCapacityBooster",      "Anhelo por el Potenciador de Capacidad de Carga");
        this.Text("Mod-Addicted-Craving-For-MemoryBooster",             "Anhelo de Estímulo de RAM");
        this.Text("Mod-Addicted-Craving-For-BlackLace",                 "Anhelo de BlackLace");
        // chemical description when biomonitor warns V
        this.Text("Mod-Addicted-Chemical-Benzedrine",                   "Benzedrina");
        this.Text("Mod-Addicted-Chemical-Cortisone",                    "Cortisona");
        this.Text("Mod-Addicted-Chemical-Dynorphin",                    "Dinorfina");
        this.Text("Mod-Addicted-Chemical-Ethanol",                      "Etanol");
        this.Text("Mod-Addicted-Chemical-Hydrocortisone",               "Hidrocortisona");
        this.Text("Mod-Addicted-Chemical-Methadone",                    "Metadona");
        this.Text("Mod-Addicted-Chemical-Modafinil",                    "Modafinilo");
        this.Text("Mod-Addicted-Chemical-Oxandrin",                     "Oxandrolona");
        this.Text("Mod-Addicted-Chemical-Prednisone",                   "Prednisona");
        this.Text("Mod-Addicted-Chemical-Testosterone",                 "Testosterona");
        this.Text("Mod-Addicted-Chemical-Trimix",                       "Trimix");
        this.Text("Mod-Addicted-Chemical-Nicotine",                     "Nicotina");
        this.Text("Mod-Addicted-Chemical-Epinephrine",                  "Epinefrina");
        this.Text("Mod-Addicted-Chemical-Paracetamol",                  "Paracetamol");
        this.Text("Mod-Addicted-Chemical-Nanites",                      "Nanitos");
        this.Text("Mod-Addicted-Chemical-Prazosin",                     "Prazosina");
        this.Text("Mod-Addicted-Chemical-Brevibloc",                    "Brevibloc");
        this.Text("Mod-Addicted-Chemical-Lopressor",                    "Lopressor");
        this.Text("Mod-Addicted-Chemical-Irrelevant",                   "Irrelevante");
        // displayed on screen to dismiss biomonitor
        this.Text("Mod-Addicted-Dismiss-Biomonitor",                    "Salte el biomonitor");
        // WannaBe EdgeRunner
        this.Text("Mod-Addicted-Edgerunning-BlackLace-Penalty",         "Sobredosis de BlackLace");
        this.Text("Mod-Addicted-Unknown",                               "DESCONOCIDA", "DESCONOCIDO");
        // status effects (radial wheel UI)
        this.Text("Mod-Addicted-Totter",                                "Vacila");
        this.Text("Mod-Addicted-Totter-Desc",                           "Vacilante");

        this.Text("Mod-Addicted-Overdose-BlackLace",                    "Bajo el dominio del BlackLace");
        this.Text("Mod-Addicted-Overdose-BlackLace-Desc",               "Se dice que el consumo excesivo de BlackLace puede provocar crisis de Ciberpsicosis");
        
        this.Text("Mod-Addicted-ShortBreath",                           "Respiración corta");
        this.Text("Mod-Addicted-ShortBreath-Desc",                      "Tu resistencia se agota, choom, ¡tómate un tiempo para respirar! {int_0}% Regen. de resistencia, correr consume resistencia.");

        this.Text("Mod-Addicted-BreathLess",                            "Sin aliento");
        this.Text("Mod-Addicted-BreathLess-Desc",                       "Tu resistencia está agotada, apenas puedes respirar: {int_0}% Regen. de resistencia, retraso adicional del {int_1}% por pila, correr y esquivar consumen resistencia.");
        
        this.Text("Mod-Addicted-Jitters",                               "Temblores");
        this.Text("Mod-Addicted-Jitters-Desc",                          "Tus manos están temblando, choom... Apuntar se ve gravemente afectado");
        
        this.Text("Mod-Addicted-PhotoSensitive",                        "Fotosensible");
        this.Text("Mod-Addicted-PhotoSensitive-Desc",                   "Las granadas de destello te afectan durante más tiempo");
        // cautions (inventory tooltip UI)
        this.Text("Mod-Addicted-Consumable-Healers-Caution",            "");
        this.Text("Mod-Addicted-Consumable-Alcohols-Caution",           "");
        this.Text("Mod-Addicted-Consumable-MemoryBooster-Caution",      "");
        this.Text("Mod-Addicted-Consumable-StaminaBooster-Caution",     "");
        this.Text("Mod-Addicted-Consumable-CarryCapacityBooster-Caution","");
        this.Text("Mod-Addicted-Consumable-Tobacco-Caution",            "");
        this.Text("Mod-Addicted-Consumable-BlackLace-Caution",          "");
        this.Text("Mod-Addicted-Consumable-NeuroBlocker-Caution",       "");
        this.Text("Mod-Addicted-Consumable-Addiquit-Caution",            "");
        // Drug Pump
        this.Text("Gameplay-Cyberware-DisplayName-DrugPump",            "");
        this.Text("Gameplay-Cyberware-LocalizedDescription-DrugPump",   "");
        this.Text("Gameplay-Cyberware-Abilities-DrugPump",              "");
        // status effect
        this.Text("Mod-Addicted-Lesions-Desc",                          "");
        this.Text("Mod-Addicted-Lesions",                               "");
    }
}