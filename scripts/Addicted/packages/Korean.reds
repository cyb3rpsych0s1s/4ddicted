module Addicted

import Codeware.Localization.*

public class Korean extends LocalizationPackage {
    protected func DefineTexts() -> Void {
        super.DefineTexts();

        // base vocabulary
        this.Text("Mod-Addicted-Thresholds",                            "임계치");
        this.Text("Mod-Addicted-Threshold-Barely-Desc",                 "수치를 초과하면 V는 약간 중독되기 시작합니다.");
        this.Text("Mod-Addicted-Threshold-Mildly-Desc",                 "수치를 초과하면 V는 중독되기 시작합니다.");
        // addiction vocabulary
        this.Text("Mod-Addicted-Substance",                             "물질");
        this.Text("Mod-Addicted-Threshold",                             "임계치");
        // each threshold of addiction
        this.Text("Mod-Addicted-Threshold-Clean",                       "깨끗함");
        this.Text("Mod-Addicted-Threshold-Barely",                      "약한");
        this.Text("Mod-Addicted-Threshold-Mildly",                      "중간");
        this.Text("Mod-Addicted-Threshold-Notably",                     "강한");
        this.Text("Mod-Addicted-Threshold-Severely",                    "치명적인");
        // addiction progress warnings (biomonitor UI)
        this.Text("Mod-Addicted-Warn-Increased",                        "중독 증상 감지");
        this.Text("Mod-Addicted-Warn-Decreased",                        "중독 증상 감소");
        this.Text("Mod-Addicted-Warn-Gone",                             "중독 증상 회복");
        // booting sequence (biomonitor UI)
        this.Text("Mod-Addicted-Biomonitor-Booting",                    "부팅중");
        // different types of consumables
        this.Text("Mod-Addicted-Consumable-Unknown",                    "알 수 없는 소모품");
        this.Text("Mod-Addicted-Consumable-MaxDOC",                     "맥스닥");
        this.Text("Mod-Addicted-Consumable-BounceBack",                 "바운스백");
        this.Text("Mod-Addicted-Consumable-BlackLace",                  "블랙레이스");
        this.Text("Mod-Addicted-Consumable-MemoryBooster",              "램 졸트");
        // addictions state warnings (biomonitor UI)
        this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Severely",  "심각한 중독 증상");
        this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Notably",   "강한 중독 증상");
        // addictions withdrawal symptoms descriptions (radial wheel UI)
        this.Text("Mod-Addicted-Withdrawn-BlackLace-Desc",              "{int_0}% 최대 반사 신경");
        this.Text("Mod-Addicted-Withdrawn-StaminaBooster-Desc",         "{int_0}% 최대 스태미나");
        this.Text("Mod-Addicted-Withdrawn-CarryCapacityBooster-Desc",   "{int_0}% 운반 용량");
        this.Text("Mod-Addicted-Withdrawn-MemoryBooster-Desc",          "{int_0}% 최대 램 유닛");
        // addictions craving descriptions (radial wheel UI)
        this.Text("Mod-Addicted-Craving-For-StaminaBooster",            "갈망: 스태미나 부스터");
        this.Text("Mod-Addicted-Craving-For-CarryCapacityBooster",      "갈망: 용량 부스터");
        this.Text("Mod-Addicted-Craving-For-MemoryBooster",             "갈망: 램 졸트");
        this.Text("Mod-Addicted-Craving-For-BlackLace",                 "갈망: 블랙레이스");
        // chemical description when biomonitor warns V
        this.Text("Mod-Addicted-Chemical-Benzedrine",                   "벤제드린");
        this.Text("Mod-Addicted-Chemical-Cortisone",                    "코르티손");
        this.Text("Mod-Addicted-Chemical-Dynorphin",                    "디노르핀");
        this.Text("Mod-Addicted-Chemical-Ethanol",                      "에탄올");
        this.Text("Mod-Addicted-Chemical-Hydrocortisone",               "하이드로코르티손");
        this.Text("Mod-Addicted-Chemical-Methadone",                    "메타돈");
        this.Text("Mod-Addicted-Chemical-Modafinil",                    "모다피닐");
        this.Text("Mod-Addicted-Chemical-Oxandrin",                     "옥산드린");
        this.Text("Mod-Addicted-Chemical-Prednisone",                   "프레드니손");
        this.Text("Mod-Addicted-Chemical-Testosterone",                 "테스토스테론");
        this.Text("Mod-Addicted-Chemical-Trimix",                       "트라이믹스");
        this.Text("Mod-Addicted-Chemical-Nicotine",                     "니코틴");
        this.Text("Mod-Addicted-Chemical-Epinephrine",                  "에피네프린");
        this.Text("Mod-Addicted-Chemical-Paracetamol",                  "파라세타몰");
        this.Text("Mod-Addicted-Chemical-Nanites",                      "나나이트");
        this.Text("Mod-Addicted-Chemical-Prazosin",                     "프라조신");
        this.Text("Mod-Addicted-Chemical-Brevibloc",                    "브레비블록");
        this.Text("Mod-Addicted-Chemical-Lopressor",                    "로프레서");
        this.Text("Mod-Addicted-Chemical-Irrelevant",                   "관련 없음");
        // displayed on screen to dismiss biomonitor
        this.Text("Mod-Addicted-Dismiss-Biomonitor",                    "바이오 모니터 해제");
        // WannaBe EdgeRunner
        this.Text("Mod-Addicted-Edgerunning-BlackLace-Penalty",         "블랙레이스 과용");
        this.Text("Mod-Addicted-Unknown",                               "알 수 없음");
        // status effects (radial wheel UI)
        this.Text("Mod-Addicted-Totter",                                "비틀거림");
        this.Text("Mod-Addicted-Totter-Desc",                           "몸을 가누기 힙듭니다");

        this.Text("Mod-Addicted-Overdose-BlackLace",                    "블랙레이스 사이코시스");
        this.Text("Mod-Addicted-Overdose-BlackLace-Desc",               "블랙레이스의 과용은 사이버 사이코시스를 유발합니다.");
        
        this.Text("Mod-Addicted-ShortBreath",                           "숨가쁨");
        this.Text("Mod-Addicted-ShortBreath-Desc",                      "스태미나 저하, 잠시 멈춰서 심호흡하세요! {int_0}% 스태미나 재생., 달리기는 스태미나를 소모합니다");

        this.Text("Mod-Addicted-BreathLess",                            "심한 숨가쁨");
        this.Text("Mod-Addicted-BreathLess-Desc",                       "스태미나 고갈, 숨을 거의 쉴 수 없습니다., {int_0}% 스태미나 재생, {int_1}% 스택당 추가 지연, 달리기와 회피는 스태미나를 소모합니다");
        
        this.Text("Mod-Addicted-Jitters",                               "신경 과민");
        this.Text("Mod-Addicted-Jitters-Desc",                          "손이 떨립니다...조준능력 저하");
        
        this.Text("Mod-Addicted-PhotoSensitive",                        "감광성");
        this.Text("Mod-Addicted-PhotoSensitive-Desc",                   "섬광탄은 당신의 시각을 더 오래 손상시킵니다");
        // cautions (inventory tooltip UI)
        this.Text("Mod-Addicted-Consumable-Healers-Caution",             "");
        this.Text("Mod-Addicted-Consumable-Alcohols-Caution",            "");
        this.Text("Mod-Addicted-Consumable-MemoryBooster-Caution",       "");
        this.Text("Mod-Addicted-Consumable-StaminaBooster-Caution",      "");
        this.Text("Mod-Addicted-Consumable-CarryCapacityBooster-Caution","");
        this.Text("Mod-Addicted-Consumable-Tobacco-Caution",             "");
        this.Text("Mod-Addicted-Consumable-BlackLace-Caution",           "");
        this.Text("Mod-Addicted-Consumable-NeuroBlocker-Caution",        "");
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