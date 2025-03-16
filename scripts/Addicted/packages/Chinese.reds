module Addicted

import Codeware.Localization.*

public class SimplifiedChinese extends LocalizationPackage {
    protected func DefineTexts() -> Void {
        super.DefineTexts();

        // base vocabulary
        this.Text("Mod-Addicted-Thresholds",                            "临界点");
        this.Text("Mod-Addicted-Threshold-Barely-Desc",                 "V几乎超过成瘾临界点");
        this.Text("Mod-Addicted-Threshold-Mildly-Desc",                 "V轻微超过成瘾临界点");
        // addiction vocabulary
        this.Text("Mod-Addicted-Substance",                             "药物");
        this.Text("Mod-Addicted-Threshold",                             "临界");
        // each threshold of addiction
        this.Text("Mod-Addicted-Threshold-Clean",                       "戒了");
        this.Text("Mod-Addicted-Threshold-Barely",                      "勉强");
        this.Text("Mod-Addicted-Threshold-Mildly",                      "轻微");
        this.Text("Mod-Addicted-Threshold-Notably",                     "明显");
        this.Text("Mod-Addicted-Threshold-Severely",                    "严重");
        // addiction progress warnings (biomonitor UI)
        this.Text("Mod-Addicted-Warn-Increased",                        "监测到成瘾症状");
        this.Text("Mod-Addicted-Warn-Decreased",                        "成瘾症状减退");
        this.Text("Mod-Addicted-Warn-Gone",                             "成瘾症状消退");
        // booting sequence (biomonitor UI)
        this.Text("Mod-Addicted-Biomonitor-Booting",                    "启动");
        // different types of consumables
        this.Text("Mod-Addicted-Consumable-Unknown",                    "位置消耗品");
        this.Text("Mod-Addicted-Consumable-MaxDOC",                     "倾力治");
        this.Text("Mod-Addicted-Consumable-BounceBack",                 "反弹");
        this.Text("Mod-Addicted-Consumable-BlackLace",                  "黑蕾丝");
        this.Text("Mod-Addicted-Consumable-MemoryBooster",              "RAM级联");
        // addictions state warnings (biomonitor UI)
        this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Severely",  "严重成瘾症状");
        this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Notably",   "明显成瘾症状");
        // addictions withdrawal symptoms descriptions (radial wheel UI)
        this.Text("Mod-Addicted-Withdrawn-BlackLace-Desc",              "{int_0}% 最大反应");
        this.Text("Mod-Addicted-Withdrawn-StaminaBooster-Desc",         "{int_0}% 最大耐力");
        this.Text("Mod-Addicted-Withdrawn-CarryCapacityBooster-Desc",   "{int_0}% 最大负重");
        this.Text("Mod-Addicted-Withdrawn-MemoryBooster-Desc",          "{int_0}% 最大RAM装置数");
        // addictions craving descriptions (radial wheel UI)
        this.Text("Mod-Addicted-Craving-For-StaminaBooster",            "耐力增强成瘾");
        this.Text("Mod-Addicted-Craving-For-CarryCapacityBooster",      "负重增强成瘾");
        this.Text("Mod-Addicted-Craving-For-MemoryBooster",             "记忆增强成瘾");
        this.Text("Mod-Addicted-Craving-For-BlackLace",                 "黑蕾丝成瘾");
        // chemical description when biomonitor warns V
        this.Text("Mod-Addicted-Chemical-Benzedrine",                   "苯丙胺");
        this.Text("Mod-Addicted-Chemical-Cortisone",                    "可的松");
        this.Text("Mod-Addicted-Chemical-Dynorphin",                    "强啡肽");
        this.Text("Mod-Addicted-Chemical-Ethanol",                      "乙醇");
        this.Text("Mod-Addicted-Chemical-Hydrocortisone",               "氢化可的松");
        this.Text("Mod-Addicted-Chemical-Methadone",                    "美沙酮");
        this.Text("Mod-Addicted-Chemical-Modafinil",                    "莫达非尼");
        this.Text("Mod-Addicted-Chemical-Oxandrin",                     "氧雄龙");
        this.Text("Mod-Addicted-Chemical-Prednisone",                   "强的松");
        this.Text("Mod-Addicted-Chemical-Testosterone",                 "睾酮");
        this.Text("Mod-Addicted-Chemical-Trimix",                       "三元混合气");
        this.Text("Mod-Addicted-Chemical-Nicotine",                     "尼古丁");
        this.Text("Mod-Addicted-Chemical-Epinephrine",                  "肾上腺素");
        this.Text("Mod-Addicted-Chemical-Paracetamol",                  "对乙酰氨基酚");
        this.Text("Mod-Addicted-Chemical-Nanites",                      "纳米机器");
        this.Text("Mod-Addicted-Chemical-Prazosin",                     "普拉索辛");
        this.Text("Mod-Addicted-Chemical-Brevibloc",                    "布列吡洛克");
        this.Text("Mod-Addicted-Chemical-Lopressor",                    "洛普萨");
        this.Text("Mod-Addicted-Chemical-Irrelevant",                   "无关");
        // displayed on screen to dismiss biomonitor
        this.Text("Mod-Addicted-Dismiss-Biomonitor",                    "关闭生物监测器");
        // WannaBe EdgeRunner
        this.Text("Mod-Addicted-Edgerunning-BlackLace-Penalty",         "黑蕾丝过量");
        this.Text("Mod-Addicted-Unknown",                               "未知");
        // status effects (radial wheel UI)
        this.Text("Mod-Addicted-Totter",                                "踉跄蹒跚");
        this.Text("Mod-Addicted-Totter-Desc",                           "踉跄蹒跚");

        this.Text("Mod-Addicted-Overdose-BlackLace",                    "黑蕾丝错乱");
        this.Text("Mod-Addicted-Overdose-BlackLace-Desc",               "据说食用过多的黑色蕾丝可能会导致网络精神病");
        
        this.Text("Mod-Addicted-ShortBreath",                           "呼吸急促");
        this.Text("Mod-Addicted-ShortBreath-Desc",                      "朋友你的耐力短缺， 别忘了喘口气！{int_0}% 耐力恢复， 快跑消耗耐力");

        this.Text("Mod-Addicted-BreathLess",                            "呼吸困难");
        this.Text("Mod-Addicted-BreathLess-Desc",                       "你的耐力耗尽，几乎无法呼吸：{int_0}% 耐力恢复，每层额外延迟{int_1}％，冲刺和闪避消耗耐力");
        
        this.Text("Mod-Addicted-Jitters",                               "颤抖");
        this.Text("Mod-Addicted-Jitters-Desc",                          "朋友你的手在发抖……瞄准被严重削弱");
        
        this.Text("Mod-Addicted-PhotoSensitive",                        "感光性");
        this.Text("Mod-Addicted-PhotoSensitive-Desc",                   "闪光弹更久地削弱你");
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

public class TraditionalChinese extends ModLocalizationPackage {
    protected func DefineTexts() -> Void {
        super.DefineTexts();

        // base vocabulary
        this.Text("Mod-Addicted-Thresholds",                            "");
        this.Text("Mod-Addicted-Threshold-Barely-Desc",                 "");
        this.Text("Mod-Addicted-Threshold-Mildly-Desc",                 "");
        // addiction vocabulary
        this.Text("Mod-Addicted-Substance",                             "");
        this.Text("Mod-Addicted-Threshold",                             "");
        // each threshold of addiction
        this.Text("Mod-Addicted-Threshold-Clean",                       "");
        this.Text("Mod-Addicted-Threshold-Barely",                      "");
        this.Text("Mod-Addicted-Threshold-Mildly",                      "");
        this.Text("Mod-Addicted-Threshold-Notably",                     "");
        this.Text("Mod-Addicted-Threshold-Severely",                    "");
        // addiction progress warnings (biomonitor UI)
        this.Text("Mod-Addicted-Warn-Increased",                        "");
        this.Text("Mod-Addicted-Warn-Decreased",                        "");
        this.Text("Mod-Addicted-Warn-Gone",                             "");
        // booting sequence (biomonitor UI)
        this.Text("Mod-Addicted-Biomonitor-Booting",                    "");
        // different types of consumables
        this.Text("Mod-Addicted-Consumable-Unknown",                    "");
        this.Text("Mod-Addicted-Consumable-MaxDOC",                     "");
        this.Text("Mod-Addicted-Consumable-BounceBack",                 "");
        this.Text("Mod-Addicted-Consumable-BlackLace",                  "");
        this.Text("Mod-Addicted-Consumable-MemoryBooster",              "");
        // addictions state warnings (biomonitor UI)
        this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Severely",  "");
        this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Notably",   "");
        // addictions withdrawal symptoms descriptions (radial wheel UI)
        this.Text("Mod-Addicted-Withdrawn-BlackLace-Desc",              "");
        this.Text("Mod-Addicted-Withdrawn-StaminaBooster-Desc",         "");
        this.Text("Mod-Addicted-Withdrawn-CarryCapacityBooster-Desc",   "");
        this.Text("Mod-Addicted-Withdrawn-MemoryBooster-Desc",          "");
        // addictions craving descriptions (radial wheel UI)
        this.Text("Mod-Addicted-Craving-For-StaminaBooster",            "");
        this.Text("Mod-Addicted-Craving-For-CarryCapacityBooster",      "");
        this.Text("Mod-Addicted-Craving-For-MemoryBooster",             "");
        this.Text("Mod-Addicted-Craving-For-BlackLace",                 "");
        // chemical description when biomonitor warns V
        this.Text("Mod-Addicted-Chemical-Benzedrine",                   "");
        this.Text("Mod-Addicted-Chemical-Cortisone",                    "");
        this.Text("Mod-Addicted-Chemical-Dynorphin",                    "");
        this.Text("Mod-Addicted-Chemical-Ethanol",                      "");
        this.Text("Mod-Addicted-Chemical-Hydrocortisone",               "");
        this.Text("Mod-Addicted-Chemical-Methadone",                    "");
        this.Text("Mod-Addicted-Chemical-Modafinil",                    "");
        this.Text("Mod-Addicted-Chemical-Oxandrin",                     "");
        this.Text("Mod-Addicted-Chemical-Prednisone",                   "");
        this.Text("Mod-Addicted-Chemical-Testosterone",                 "");
        this.Text("Mod-Addicted-Chemical-Trimix",                       "");
        this.Text("Mod-Addicted-Chemical-Nicotine",                     "");
        this.Text("Mod-Addicted-Chemical-Epinephrine",                  "");
        this.Text("Mod-Addicted-Chemical-Paracetamol",                  "");
        this.Text("Mod-Addicted-Chemical-Nanites",                      "");
        this.Text("Mod-Addicted-Chemical-Prazosin",                     "");
        this.Text("Mod-Addicted-Chemical-Brevibloc",                    "");
        this.Text("Mod-Addicted-Chemical-Lopressor",                    "");
        this.Text("Mod-Addicted-Chemical-Irrelevant",                   "");
        // displayed on screen to dismiss biomonitor
        this.Text("Mod-Addicted-Dismiss-Biomonitor",                    "");
        // WannaBe EdgeRunner
        this.Text("Mod-Addicted-Edgerunning-BlackLace-Penalty",         "");
        this.Text("Mod-Addicted-Unknown",                               "");
        // status effects (radial wheel UI)
        this.Text("Mod-Addicted-Totter",                                "");
        this.Text("Mod-Addicted-Totter-Desc",                           "");

        this.Text("Mod-Addicted-Overdose-BlackLace",                    "");
        this.Text("Mod-Addicted-Overdose-BlackLace-Desc",               "");
        
        this.Text("Mod-Addicted-ShortBreath",                           "");
        this.Text("Mod-Addicted-ShortBreath-Desc",                      "");

        this.Text("Mod-Addicted-BreathLess",                            "");
        this.Text("Mod-Addicted-BreathLess-Desc",                       "");
        
        this.Text("Mod-Addicted-Jitters",                               "");
        this.Text("Mod-Addicted-Jitters-Desc",                          "");
        
        this.Text("Mod-Addicted-PhotoSensitive",                        "");
        this.Text("Mod-Addicted-PhotoSensitive-Desc",                   "");
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
        // status effect
        this.Text("Mod-Addicted-Lesions-Desc",                          "");
        this.Text("Mod-Addicted-Lesions",                               "");
    }
}