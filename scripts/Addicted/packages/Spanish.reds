module Addicted

import Codeware.Localization.*

public class Spanish extends ModLocalizationPackage {
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
        this.Text("Mod-Addicted-Consumable-Healers-Caution",            "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Cuidado</>\nAunque nuestros productos de sanación en <Rich color=\"MainColors.ActiveBlue\">TraumaTeam</> ofrecen un alivio potente y casi instantáneo, no son un sustituto del descanso adecuado y la curación natural. El uso excesivo puede disminuir su eficacia y retrasar la recuperación.");
        this.Text("Mod-Addicted-Consumable-Alcohols-Caution",           "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Cuidado</>\nSi bien todos apreciamos las cualidades de lubricación social del alcohol, se les advierte que el consumo excesivo puede resultar en la aparición de temblores \"espirituosos\". Recuerden, la moderación es la receta para una experiencia más fluida, tanto social como fisiológicamente.");
        this.Text("Mod-Addicted-Consumable-MemoryBooster-Caution",      "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Cuidado</>\nEl consumo excesivo de Estímulo de RAM puede provocar efectos adversos, incluidos síntomas de abstinencia, disminución de la capacidad de memoria, migrañas y aumento de la fotosensibilidad. Por favor, úselo de manera responsable y consulte a un profesional médico calificado si experimenta alguna reacción negativa.\n<Rich color=\"MainColors.ActiveBlue\">Arasaka</> no puede ser responsabilizada en ninguna circunstancia por un uso indebido.");
        this.Text("Mod-Addicted-Consumable-StaminaBooster-Caution",     "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Cuidado</>\nEl consumo excesivo de Potenciador de Resistencia puede resultar en efectos adversos, incluyendo disminución de la resistencia, fatiga y posible deterioro del rendimiento. Por favor, úselo de manera responsable y consulte a un profesional médico calificado si experimenta alguna reacción negativa.\n<Rich color=\"MainColors.ActiveBlue\">Militech Corporation</> no puede ser responsabilizada en ninguna circunstancia por un uso indebido.");
        this.Text("Mod-Addicted-Consumable-CarryCapacityBooster-Caution","\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Cuidado</>\nEl consumo excesivo de Potenciador de Capacidad de Carga puede provocar efectos adversos, incluyendo disminución de la movilidad, fatiga muscular y posible tensión en el cuerpo. Por favor, úselo de manera responsable y consulte a un profesional médico calificado si experimenta alguna reacción negativa.\n<Rich color=\"MainColors.ActiveBlue\">Kang Tao Corporation</> no puede ser responsabilizada en ninguna circunstancia por un uso indebido.");
        this.Text("Mod-Addicted-Consumable-Tobacco-Caution",            "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Cuidado</>\nEl consumo de tabaco, incluyendo cigarrillos y puros, puede provocar falta de aliento o dificultad para respirar. Por favor, úselo con precaución y considere los riesgos potenciales para la salud asociados con fumar.");
        this.Text("Mod-Addicted-Consumable-BlackLace-Caution",          "\n<Rich color=\"MainColors.ActiveRed\" style=\"Semi-Bold\">Advertencia</>\nBlackLace es una sustancia ilegal potente y altamente adictiva. El consumo regular puede provocar síntomas de abstinencia severos y efectos adversos, incluyendo fibromialgia y una mayor susceptibilidad a la ciberpsicosis. Se desaconseja fuertemente el uso de esta sustancia, ya que puede tener serias consecuencias para su salud y bienestar.");
        this.Text("Mod-Addicted-Consumable-NeuroBlocker-Caution",       "\n<Rich color=\"MainColors.ActiveYellow\" style=\"Semi-Bold\">Cuidado</>\nNeuroBlocker, aunque inicialmente es útil para manejar la sobrecarga cognitiva y los síntomas de ciberpsicosis, puede llevar a una rápida adicción cuando se usa junto con ciberware basado en neuroestímulos, como Sandevistan y Ex-Disk, entre otros. Por favor, úselo con moderación y busque consejo médico si se desarrolla dependencia.");
        // Drug Pump
        this.Text("Gameplay-Cyberware-DisplayName-DrugPump",            "Bomba Negra");
        this.Text("Gameplay-Cyberware-LocalizedDescription-DrugPump",   "Esta bomba de sangre modificada en la calle acelera la curación de su poseedor mientras inyecta BlackLace en su torrente sanguíneo.");
        this.Text("Gameplay-Cyberware-Abilities-DrugPump",              "\nUtiliza BlackLace, si se posee, pero con solo un <Rich color=\"TooltipText.cyberwareDescriptionHighlightColor\" style=\"Semi-Bold\">{int_0}%</> de probabilidad de consumir el objeto.");
    }
}