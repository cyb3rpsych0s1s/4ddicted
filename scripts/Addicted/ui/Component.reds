public class BiomonitorComponent extends inkComponent {

  private let booting: ref<inkText>;
  private let firstname: ref<inkText>;
  private let lastname: ref<inkText>;
  private let age: ref<inkText>;
  private let blood: ref<inkText>;
  private let insurance: ref<inkText>;
  private let chemicals: array<ref<inkText>>;
  private let vitals: array<array<ref<inkWidget>>>;

  private let hydroxyzine: ref<inkText>;
  private let hydroxyzineValue: ref<inkText>;
  private let tramadol: ref<inkText>;
  private let tramadolValue: ref<inkText>;
  private let desvenlafaxine: ref<inkText>;
  private let desvenlafaxineValue: ref<inkText>;
  private let amoxapine: ref<inkText>;
  private let amoxapineValue: ref<inkText>;
  private let lactobacillius: ref<inkText>;
  private let lactobacilliusValue: ref<inkText>;
  private let acetaminofen: ref<inkText>;
  private let acetaminofenValue: ref<inkText>;
  private let bupropion: ref<inkText>;
  private let bupropionValue: ref<inkText>;
  
  protected cb func OnCreate() -> ref<inkWidget> {
    let container = new inkCanvas();
    container.SetName(n"Addicted_Biomon_Canvas");
    container.SetAnchor(inkEAnchor.Fill);
    container.SetVisible(false);

    return container;
  }

  // Called when component is attached to the widget tree
  protected cb func OnInitialize() {this.booting = this.root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Booting_Screen/BOOTING_Text") as inkText;
    let infos       = this.root.GetWidget(n"main_canvas/Booting_Info_Critica_Mask_Canvas/Booting_Info_Critical_Canvas/Info_Screen/Info_MainScreen_Mask_Canvas/Info_MainScreen_Canvas") as inkCompoundWidget;
    // E(s"\(ToString(infos))");
    this.firstname  = infos.GetWidget(n"SANDRA_HPanel/Info_SANDRA_Text") as inkText;
    this.lastname   = infos.GetWidget(n"DORSET_HPanel/Info_DORSETT_Text") as inkText;
    this.age        = infos.GetWidget(n"AGE_HPanel/Info_29_Text") as inkText;
    this.blood      = infos.GetWidget(n"BLOOD_HPanel/Info_ABRHD_Text") as inkText;
    this.insurance  = (infos.GetWidgetByIndex(5) as inkHorizontalPanel).GetWidget(n"Info_NC570442_Text") as inkText;

    let chemicals   = infos.GetWidget(n"Info_Chemical_Information_Canvas") as inkCanvas;
    let topLine     = chemicals.GetWidget(n"Info_Chemical_Info_Vertical/Info_Chemical_Info_H_Line1") as inkHorizontalPanel;
    let middleLine  = chemicals.GetWidget(n"Info_Chemical_Info_Vertical/Info_Chemical_Info_H_Line2") as inkHorizontalPanel;
    let bottomLine  = chemicals.GetWidget(n"Info_Chemical_Info_Vertical/Info_Chemical_Info_H_Line3") as inkHorizontalPanel;

    // defined individually because widgets path are kind of a mess
    this.hydroxyzine = topLine.GetWidget(n"Info_N_HYDROXYZINE_text") as inkText;
    this.hydroxyzineValue = topLine.GetWidget(n"inkHorizontalPanelWidget2/170/Info_170_text") as inkText;
    this.tramadol = topLine.GetWidget(n"Info_TR2_TRAMADOL_Text") as inkText;
    this.tramadolValue = topLine.GetWidget(n"inkHorizontalPanelWidget3/720/Info_TR2_TRAMADOL_Text") as inkText;
    this.desvenlafaxine = topLine.GetWidget(n"Info_DESVENLAFAXINE_Text") as inkText;
    this.desvenlafaxineValue = topLine.GetWidget(n"inkHorizontalPanelWidget4/300/Info_DESVENLAFAXINE_Text") as inkText;
    this.amoxapine = middleLine.GetWidget(n"Info_AMOXAPINE_Text") as inkText;
    this.amoxapineValue = middleLine.GetWidget(n"inkHorizontalPanelWidget5/220/Info_AMOXAPINE_Text") as inkText;
    this.lactobacillius = middleLine.GetWidget(n"Info_R7_LACTOBACILLIUS_Text") as inkText;
    this.lactobacilliusValue = middleLine.GetWidget(n"inkHorizontalPanelWidget6/400/Info_R7_LACTOBACILLIUS_Text") as inkText;
    this.acetaminofen = middleLine.GetWidget(n"Info_ACETAMINOFEN_Text") as inkText;
    this.acetaminofenValue = middleLine.GetWidget(n"inkHorizontalPanelWidget7/250/Info_ACETAMINOFEN_Text") as inkText;
    this.bupropion = bottomLine.GetWidget(n"Info_BUPROPION_Text") as inkText;
    this.bupropionValue = bottomLine.GetWidget(n"inkHorizontalPanelWidget5/Info_BUPROPION_Text") as inkText;

    this.chemicals = [];
    ArrayPush(this.chemicals, this.hydroxyzine);
    ArrayPush(this.chemicals, this.hydroxyzineValue);
    ArrayPush(this.chemicals, this.tramadol);
    ArrayPush(this.chemicals, this.tramadolValue);
    ArrayPush(this.chemicals, this.desvenlafaxine);
    ArrayPush(this.chemicals, this.desvenlafaxineValue);
    ArrayPush(this.chemicals, this.amoxapine);
    ArrayPush(this.chemicals, this.amoxapineValue);
    ArrayPush(this.chemicals, this.lactobacillius);
    ArrayPush(this.chemicals, this.lactobacilliusValue);
    ArrayPush(this.chemicals, this.acetaminofen);
    ArrayPush(this.chemicals, this.acetaminofenValue);
    ArrayPush(this.chemicals, this.bupropion);
    ArrayPush(this.chemicals, this.bupropionValue);

    let row: array<ref<inkWidget>>;
    
    let summary     = infos.GetWidget(n"Critical_Screen_Text_Canvas/inkVerticalPanelWidget7/inkHorizontalPanelWidget2") as inkHorizontalPanel;
    let leftmost    = summary.GetWidget(n"Critical_Vertical") as inkVerticalPanel;
    let center      = summary.GetWidget(n"Critical_Vertical2") as inkVerticalPanel;
    let rightmost   = summary.GetWidget(n"Critical_Vertical_Warning") as inkVerticalPanel;


    // E(s"summary: \(ToString(summary))");
    // E(s"leftmost: \(ToString(leftmost))");
    // E(s"center: \(ToString(center))");
    // E(s"rightmost: \(ToString(rightmost))");

    // let size = center.GetNumChildren();
    // let j = 0;
    // let child: ref<inkWidget>;
    // while j < size {
    //     child = center.GetWidgetByIndex(j);
    //     E(s"name: \(child.GetName()), type: \(ToString(child))");
    //     j += 1;
    // }

    ArrayResize(row, 3);
    ArrayInsert(row, 0, leftmost.GetWidget(n"Critical_BLOOD_PRESSURE_text"));
    ArrayInsert(row, 1, center.GetWidgetByIndex(0));
    ArrayInsert(row, 2, rightmost.GetWidgetByIndex(0));
    ArrayPush(this.vitals, row);

    ArrayClear(row);
    ArrayInsert(row, 0, leftmost.GetWidget(n"Critical_LEVEL_AO_text"));
    ArrayInsert(row, 1, center.GetWidgetByIndex(1));
    ArrayInsert(row, 2, rightmost.GetWidgetByIndex(1));
    ArrayPush(this.vitals, row);
    
    ArrayClear(row);
    ArrayInsert(row, 0, leftmost.GetWidget(n"Critical_ALBU_GLOBU_text"));
    ArrayInsert(row, 1, center.GetWidgetByIndex(2));
    ArrayInsert(row, 2, rightmost.GetWidgetByIndex(2));
    ArrayPush(this.vitals, row);

    ArrayClear(row);
    ArrayInsert(row, 0, leftmost.GetWidget(n"Critical_ESR_text"));
    ArrayInsert(row, 1, center.GetWidget(n"Critical_CRITICAL_text"));
    ArrayInsert(row, 2, rightmost.GetWidgetByIndex(3));
    ArrayPush(this.vitals, row);

    ArrayClear(row);
    ArrayInsert(row, 0, leftmost.GetWidget(n"Critical_RESPIRATORY_text"));
    ArrayInsert(row, 1, center.GetWidget(n"Critical_AT_RISK_text"));
    ArrayInsert(row, 2, rightmost.GetWidgetByIndex(4));
    ArrayPush(this.vitals, row);
    
    ArrayClear(row);
    ArrayInsert(row, 0, leftmost.GetWidget(n"Critical_IMMUNE_text"));
    ArrayInsert(row, 1, center.GetWidget(n"Critical_AT_RISK2_text"));
    ArrayInsert(row, 2, rightmost.GetWidgetByIndex(5));
    ArrayPush(this.vitals, row);

    ArrayClear(row);
    ArrayInsert(row, 0, leftmost.GetWidget(n"Critical_CNS_text"));
    ArrayInsert(row, 1, center.GetWidget(n"Critical_AT_RISK3_text"));
    ArrayInsert(row, 2, rightmost.GetWidgetByIndex(6));
    ArrayPush(this.vitals, row);
    
    ArrayClear(row);
    ArrayInsert(row, 0, leftmost.GetWidget(n"Critical_PNS_text"));
    ArrayInsert(row, 1, center.GetWidget(n"Critical_CRITICAL2_text"));
    ArrayInsert(row, 2, rightmost.GetWidgetByIndex(7));
    ArrayPush(this.vitals, row);
    
    this.booting.SetLocalizedText(n"Mod-Addicted-Biomonitor-Booting");
  }

  // Called when component is no longer used anywhere
  protected cb func OnUninitialize() {}

  public func SetCustomer(evt: ref<CrossThresholdEvent>) -> Void {
    this.firstname.SetText(evt.Customer.FirstName);
    this.lastname.SetText(evt.Customer.LastName);
    this.age.SetText(evt.Customer.Age);
    this.blood.SetText(evt.Customer.BloodGroup);
    this.insurance.SetText(evt.Customer.Insurance);

    let chemicals = evt.Chemicals;
    let chemical: ref<Chemical>;

    let found: Int32 = ArraySize(chemicals);
    let current: Int32 = 0;

    let substance: ref<inkText>;
    let value: ref<inkText>;
    let controller: ref<inkTextValueProgressController>;

    while current < 7 {
        substance = this.chemicals[current*2];
        value = this.chemicals[current*2+1];
        controller = value.GetController() as inkTextValueProgressController;

        if current < found {
            chemical = chemicals[current];
            substance.SetLocalizationKey(chemical.Key);
            controller.SetBaseValue(chemical.From);
            controller.SetTargetValue(chemical.To);
        } else {
            substance.SetLocalizationKey(n"Mod-Addicted-Chemical-Irrelevant");
            controller.SetBaseValue(0.0);
            controller.SetTargetValue(0.0);
        }

        current += 1;
    }

    let i = 0;
    let total = ArraySize(this.vitals);
    let symptom: ref<Symptom>;
    let symptoms: array<ref<Symptom>> = evt.Symptoms;
    let size = ArraySize(symptoms);
    while i < total {
        if i < size {
            symptom = symptoms[i];
            E(s"\(ToString(this.vitals[i][0])): \(symptom.Title)");
            E(s"\(ToString(this.vitals[i][1])): \(symptom.Status)");
            E(s"\(ToString(this.vitals[i][2])): show");
            (this.vitals[i][0] as inkText).SetText(symptom.Title);
            (this.vitals[i][1] as inkText).SetText(symptom.Status);
            this.vitals[i][0].SetVisible(true);
            this.vitals[i][1].SetVisible(true);
            this.vitals[i][2].SetVisible(true);
        } else {
            E(s"\(ToString(this.vitals[i][0])): empty");
            E(s"\(ToString(this.vitals[i][1])): empty");
            E(s"\(ToString(this.vitals[i][2])): hide");
            this.vitals[i][0].SetVisible(false);
            this.vitals[i][1].SetVisible(false);
            this.vitals[i][2].SetVisible(false);
        }
        i += 1;
    }
    E(s"");
  }
}