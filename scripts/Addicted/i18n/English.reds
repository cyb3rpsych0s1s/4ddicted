module Addicted.Localization
import Codeware.Localization.*

public class English extends ModLocalizationPackage {

  protected func DefineTexts() -> Void {
    this.Text("Mod-Addicted-Thresholds", "Thresholds");
    this.Text("Mod-Addicted-Threshold-Barely", "Barely");
    this.Text("Mod-Addicted-Threshold-Barely-Desc", "V start getting barely addicted past this threshold");
    this.Text("Mod-Addicted-Threshold-Mildly", "Mildly");
    this.Text("Mod-Addicted-Threshold-Mildly-Desc", "V start getting mildly addicted past this threshold");
    this.Text("Mod-Addicted-Totter", "Totter");
    this.Text("Mod-Addicted-Totter-Desc", "Tottering");
    this.Text("Mod-Addicted-Mode", "Mode");
    this.Text("Mod-Addicted-Mode-Normal", "easy pizzy");
    this.Text("Mod-Addicted-Mode-Hard", "more... lethal");
    this.Text("Mod-Addicted-Substance", "substance");
    this.Text("Mod-Addicted-Threshold", "threshold");
    this.Text("Mod-Addicted-Threshold-Clean", "clean");
    this.Text("Mod-Addicted-Threshold-Barely", "barely");
    this.Text("Mod-Addicted-Threshold-Mildly", "mildly");
    this.Text("Mod-Addicted-Threshold-Notably", "notably");
    this.Text("Mod-Addicted-Threshold-Severely", "severely");
    this.Text("Mod-Addicted-Warn-Increased", "symptoms of addiction detected");
    this.Text("Mod-Addicted-Warn-Decreased", "symptoms of addiction in recession");
    this.Text("Mod-Addicted-Warn-Gone", "symptoms of addiction gone");
    this.Text("Mod-Addicted-Biomonitor-Booting", "BOOTING");
    this.Text("Mod-Addicted-Consumable-Unknown", "Unknown consumable");
    this.Text("Mod-Addicted-Consumable-MaxDOC", "MaxDOC");
    this.Text("Mod-Addicted-Consumable-BounceBack", "BounceBack");
    this.Text("Mod-Addicted-Consumable-HealthBooster", "Health Booster");
    this.Text("Mod-Addicted-Consumable-BlackLace", "BlackLace");
    this.Text("Mod-Addicted-Consumable-StaminaBooster", "Stamina Booster");
    this.Text("Mod-Addicted-Consumable-CarryCapacityBooster", "Carry Capacity Booster");
    this.Text("Mod-Addicted-Consumable-MemoryBooster", "Memory Booster");
    this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Severely", "SERIOUS ADDICTION SYMPTOMS");
    this.Text("Mod-Addicted-Biomonitor-Status-Threshold-Notably", "NOTABLE ADDICTION SYMPTOMS");
    this.Text("Mod-Addicted-Withdrawn-BlackLace-Desc", "{int_0}% Reflexes");
    this.Text("Mod-Addicted-Withdrawn-Stamina-Booster-Desc", "{int_0}% Stamina");
    this.Text("Mod-Addicted-Withdrawn-Capacity-Booster-Desc", "{int_0}% Carry Capacity");
    this.Text("Mod-Addicted-Withdrawn-Memory-Booster-Desc", "{int_0}% Memory");
    this.Text("Mod-Addicted-Craving-For-Stamina-Booster", "Craving for Stamina Booster");
    this.Text("Mod-Addicted-Craving-For-Capacity-Booster", "Craving for Carry Capacity Booster");
    this.Text("Mod-Addicted-Craving-For-Memory-Booster", "Craving for Memory Booster");
    this.Text("Mod-Addicted-Craving-For-BlackLace", "Craving for Black Lace");
    this.Text("Mod-Addicted-Chemical-Benzedrine", "Benzedrine");
    this.Text("Mod-Addicted-Chemical-Cortisone", "Cortisone");
    this.Text("Mod-Addicted-Chemical-Dynorphin", "Dynorphin");
    this.Text("Mod-Addicted-Chemical-Ethanol", "Ethanol");
    this.Text("Mod-Addicted-Chemical-Hydrocortisone", "Hydrocortisone");
    this.Text("Mod-Addicted-Chemical-Methadone", "Methadone");
    this.Text("Mod-Addicted-Chemical-Modafinil", "Modafinil");
    this.Text("Mod-Addicted-Chemical-Oxandrin", "Oxandrin");
    this.Text("Mod-Addicted-Chemical-Prednisone", "Prednisone");
    this.Text("Mod-Addicted-Chemical-Testosterone", "Testosterone");
    this.Text("Mod-Addicted-Chemical-Trimix", "Trimix");
    this.Text("Mod-Addicted-Chemical-Irrelevant", "Irrelevant");
    this.Text("Mod-Addicted-Dismiss-Biomonitor", "Dismiss biomonitor");
  }

  protected func DefineSubtitles() -> Void {
   // snake case suffixes must match entries in info.json (custom sounds)
   this.Subtitle("Addicted-Voice-Subtitle-biomon", "Biomon...");
   this.Subtitle("Addicted-Voice-Subtitle-as_if_I_didnt_know_already", "As if I didn't know already...");
   this.Subtitle("Addicted-Voice-Subtitle-come_on_again", "Come on... again?!?");
   this.Subtitle("Addicted-Voice-Subtitle-come_on_biomon_cant_you_give_me_a_break", "Come on biomon, can't you just give me a break?");
   this.Subtitle("Addicted-Voice-Subtitle-damn_cant_you_just_leave_me_alone", "Damn.. Can't you just leave me alone?");
   this.Subtitle("Addicted-Voice-Subtitle-damn_thats_fucked_up", "Damn.. That's f*cked up!");
   this.Subtitle("Addicted-Voice-Subtitle-dont_you_see_im_in_trouble", "Don't you see I'm in trouble?!");
   this.Subtitle("Addicted-Voice-Subtitle-fuck", "F*ck..");
   this.Subtitle("Addicted-Voice-Subtitle-fuck_this_biomon_just_not_right_now", "F*ck this biomon! Just not right now!!");
   this.Subtitle("Addicted-Voice-Subtitle-get_this_damn_ui_out_of_my_face", "Get this damn UI outta my face!");
   this.Subtitle("Addicted-Voice-Subtitle-nah_everything_is_all_good", "Nah.. Everything's all good.");
   this.Subtitle("Addicted-Voice-Subtitle-noo", "Noo..!");
   this.Subtitle("Addicted-Voice-Subtitle-oh_shit", "Oh, sh*t...");
   this.Subtitle("Addicted-Voice-Subtitle-shit", "Sh*t!!");
   this.Subtitle("Addicted-Voice-Subtitle-so_frustrating", "SO frustrating!");
   this.Subtitle("Addicted-Voice-Subtitle-what", "What..");
   this.Subtitle("Addicted-Voice-Subtitle-yeah_I_know", "Yeah... I know.");
   this.Subtitle("Addicted-Voice-Subtitle-yeah_yeah_yeah_alright", "Yeah, yeah, yeah... Alright.");
   this.Subtitle("Addicted-Voice-Subtitle-yeah_yeah_yeah_who_cares", "Yeah, yeah, yeah... Who cares?");
   this.Subtitle("Addicted-Voice-Subtitle-you_tell_me_biomon", "You tell me, biomon.");
  }
}