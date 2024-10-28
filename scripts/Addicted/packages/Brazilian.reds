module Addicted

import Codeware.Localization.*

public class Brazilian extends ModLocalizationPackage {
    protected func DefineTexts() -> Void {
        super.DefineTexts();

        // base vocabulary
        this.Text("Mod-Addicted-Thresholds",                            "Nível");
        this.Text("Mod-Addicted-Threshold-Barely-Desc",                 "V está começando a ficar um pouco viciada depois deste nível", "V está começando a ficar um pouco viciado depois deste nível");
        this.Text("Mod-Addicted-Threshold-Mildly-Desc",                 "V está ficando um pouco viciada depois deste nível", "V está ficando um pouco viciado depois deste nível");
        // addiction vocabulary
        this.Text("Mod-Addicted-Substance",                             "substância");
        this.Text("Mod-Addicted-Threshold",                             "nível");
        // each threshold of addiction
        this.Text("Mod-Addicted-Threshold-Clean",                       "limpo");
        this.Text("Mod-Addicted-Threshold-Barely",                      "um pouco");
        this.Text("Mod-Addicted-Threshold-Mildly",                      "suavemente");
        this.Text("Mod-Addicted-Threshold-Notably",                     "notavelmente");
        this.Text("Mod-Addicted-Threshold-Severely",                    "severamente");
        // addiction progress warnings (biomonitor UI)
        this.Text("Mod-Addicted-Warn-Increased",                        "sintomas de vício detectados");
        this.Text("Mod-Addicted-Warn-Decreased",                        "sintomas de vício diminuindo");
        this.Text("Mod-Addicted-Warn-Gone",                             "sintomas de vício acabaram");
        // booting sequence (biomonitor UI)
        this.Text("Mod-Addicted-Biomonitor-Booting",                    "INICIALIZANDO");
        // different types of consumables
        this.Text("Mod-Addicted-Consumable-Unknown",                    "Consumível desconhecido");
        this.Text("Mod-Addicted-Consumable-MaxDOC",                     "MaxDoc");
        this.Text("Mod-Addicted-Consumable-BounceBack",                 "Revitalizante");
        this.Text("Mod-Addicted-Consumable-BlackLace",                  "Calcinha preta");
        this.Text("Mod-Addicted-Consumable-MemoryBooster",              "Estimulante de memória");
        // addictions state warnings (biomonitor UI)
        this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Severely",  "SINTOMAS SÉRIOS DE VÍCIO DETECTADOS");
        this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Notably",   "SINTOMAS NOTÁVEIS DE VÍCIO DETECTADOS");
        // addictions withdrawal symptoms descriptions (radial wheel UI)
        this.Text("Mod-Addicted-Withdrawn-BlackLace-Desc",              "{int_0}% Reflexo máximo");
        this.Text("Mod-Addicted-Withdrawn-StaminaBooster-Desc",         "{int_0}% Vigor máximo");
        this.Text("Mod-Addicted-Withdrawn-CarryCapacityBooster-Desc",   "{int_0}% Carga máxima");
        this.Text("Mod-Addicted-Withdrawn-MemoryBooster-Desc",          "{int_0}% Unidade de memória máxima");
        // addictions craving descriptions (radial wheel UI)
        this.Text("Mod-Addicted-Craving-For-StaminaBooster",            "Precisando de Estimulante de vigor");
        this.Text("Mod-Addicted-Craving-For-CarryCapacityBooster",      "Precisando de Estimulante de capacidade");
        this.Text("Mod-Addicted-Craving-For-MemoryBooster",             "Precisando de Estimulante de memória");
        this.Text("Mod-Addicted-Craving-For-BlackLace",                 "Precisando de Calcinha preta");
        // chemical description when biomonitor warns V
        this.Text("Mod-Addicted-Chemical-Benzedrine",                   "Benzedrina");
        this.Text("Mod-Addicted-Chemical-Cortisone",                    "Cortisona");
        this.Text("Mod-Addicted-Chemical-Dynorphin",                    "Dinorfina");
        this.Text("Mod-Addicted-Chemical-Ethanol",                      "Álcool");
        this.Text("Mod-Addicted-Chemical-Hydrocortisone",               "Hidrocortisona");
        this.Text("Mod-Addicted-Chemical-Methadone",                    "Metadona");
        this.Text("Mod-Addicted-Chemical-Modafinil",                    "Modafinil");
        this.Text("Mod-Addicted-Chemical-Oxandrin",                     "Oxadrina");
        this.Text("Mod-Addicted-Chemical-Prednisone",                   "Predinisona");
        this.Text("Mod-Addicted-Chemical-Testosterone",                 "Testosterona");
        this.Text("Mod-Addicted-Chemical-Trimix",                       "Trimix");
        this.Text("Mod-Addicted-Chemical-Nicotine",                     "Nicotina");
        this.Text("Mod-Addicted-Chemical-Epinephrine",                  "Epinefrina");
        this.Text("Mod-Addicted-Chemical-Paracetamol",                  "Paracetamol");
        this.Text("Mod-Addicted-Chemical-Nanites",                      "Nanorrobôs");
        this.Text("Mod-Addicted-Chemical-Prazosin",                     "Prazosina");
        this.Text("Mod-Addicted-Chemical-Brevibloc",                    "Brevibloco");
        this.Text("Mod-Addicted-Chemical-Lopressor",                    "Lopressor");
        this.Text("Mod-Addicted-Chemical-Irrelevant",                   "Irrelevante");
        // displayed on screen to dismiss biomonitor
        this.Text("Mod-Addicted-Dismiss-Biomonitor",                    "Remover biomonitor");
        // WannaBe EdgeRunner
        this.Text("Mod-Addicted-Edgerunning-BlackLace-Penalty",         "Overdose de Calcinha preta");
        this.Text("Mod-Addicted-Unknown",                               "DESCONHECIDA", "DESCONHECIDO");
        // status effects (radial wheel UI)
        this.Text("Mod-Addicted-Totter",                                "Cambalear");
        this.Text("Mod-Addicted-Totter-Desc",                           "Cambaleando");

        this.Text("Mod-Addicted-Overdose-BlackLace",                    "Insanidade por uso de Calcinha preta");
        this.Text("Mod-Addicted-Overdose-BlackLace-Desc",               "Uso excessivo de Calcinha preta pode causar Ciberpsicose");
        
        this.Text("Mod-Addicted-ShortBreath",                           "Ofegante");
        this.Text("Mod-Addicted-ShortBreath-Desc",                      "Seu vigor esta caindo muito mano, pare um pouco para respirar! {int_0}% Vigor Recuperado. Correr consome vigor.");

        this.Text("Mod-Addicted-BreathLess",                            "Sem ar");
        this.Text("Mod-Addicted-BreathLess-Desc",                       "Seu vigor acabou, você mal pode respirar: {int_0}% Vigor Recuperado., {int_1}% atraso adicional por uso excessivo, correr e esquivar consomem vigor.");
        
        this.Text("Mod-Addicted-Jitters",                               "Tremores");
        this.Text("Mod-Addicted-Jitters-Desc",                          "Suas maos estao tremendo mano... Sua mira esta muito comprometida.");
        
        this.Text("Mod-Addicted-PhotoSensitive",                        "Fotosensitividade");
        this.Text("Mod-Addicted-PhotoSensitive-Desc",                   "Os efeitos de granadas de luz duram mais tempo para você.");
        // cautions (inventory tooltip UI)
        this.Text("Mod-Addicted-Consumable-Healers-Caution",             "");
        this.Text("Mod-Addicted-Consumable-Alcohols-Caution",            "");
        this.Text("Mod-Addicted-Consumable-MemoryBooster-Caution",       "");
        this.Text("Mod-Addicted-Consumable-StaminaBooster-Caution",      "");
        this.Text("Mod-Addicted-Consumable-CarryCapacityBooster-Caution","");
        this.Text("Mod-Addicted-Consumable-Tobacco-Caution",             "");
        this.Text("Mod-Addicted-Consumable-BlackLace-Caution",           "");
        this.Text("Mod-Addicted-Consumable-NeuroBlocker-Caution",        "");
        // Drug Pump
        this.Text("Gameplay-Cyberware-DisplayName-DrugPump",            "");
        this.Text("Gameplay-Cyberware-LocalizedDescription-DrugPump",   "");
        this.Text("Gameplay-Cyberware-Abilities-DrugPump",              "");
    }
}