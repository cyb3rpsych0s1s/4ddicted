use red4ext_rs::{
    prelude::{redscript_import, ClassType},
    types::{IScriptable, Ref, TweakDbId, WRef},
};

use crate::GameDataEquipmentArea;

#[derive(Debug)]
pub struct TweakDBInterface;

impl ClassType for TweakDBInterface {
    type BaseClass = IScriptable;
    const NAME: &'static str = "gamedataTweakDBInterface";
}

// #[cfg(feature = "codeware")]
// impl TweakDBInterface {
//     pub fn get_item_record(&self, path: TweakDbId) -> Option<ItemRecord> {
//         let reflection = crate::codeware::Reflection::default();
//         let ty = reflection.get_type_of(red4ext_rs::types::VariantExt::new(self.0.clone()));
//         info!("got ty");
//         // let cls = ty.get_inner_type().as_class();
//         let cls = reflection.get_class(red4ext_rs::types::CName::new(Self::CLASS_NAME));
//         info!("got cls");
//         // for fun in cls.get_functions().as_slice() {
//         //     info!(
//         //         "member function: {} ({})",
//         //         red4ext_rs::ffi::resolve_cname(&fun.get_name()),
//         //         red4ext_rs::ffi::resolve_cname(&fun.get_full_name())
//         //     );
//         // }
//         // for fun in cls.get_static_functions().as_slice() {
//         //     info!(
//         //         "static function: {} ({})",
//         //         red4ext_rs::ffi::resolve_cname(&fun.get_name()),
//         //         red4ext_rs::ffi::resolve_cname(&fun.get_full_name())
//         //     );
//         // }
//         let fun = cls.get_function(red4ext_rs::types::CName::new("GetItemRecord"));
//         if fun.is_defined() {
//             info!("func is defined");
//             let output = fun.call(
//                 self.0.clone(),
//                 RedArray::from_sized_iter(
//                     vec![red4ext_rs::types::VariantExt::new(path)].into_iter(),
//                 ),
//                 ScriptRef::new(&false),
//             );
//             info!("called fun");
//             info!("status success!");
//             return Some(
//                 red4ext_rs::types::VariantExt::try_get(&output)
//                     .expect("GetItemRecord() should return an Item_Record"),
//             );
//         }
//         None
//     }
// }

#[derive(Debug)]
pub struct ItemRecord;

impl ClassType for ItemRecord {
    type BaseClass = IScriptable;
    const NAME: &'static str = "gamedataItem_Record";
}

#[redscript_import]
impl ItemRecord {
    // `public final native func EquipArea() -> wref<EquipmentArea_Record>`
    #[redscript(native)]
    pub fn equip_area(self: &Ref<Self>) -> WRef<EquipmentAreaRecord>;
}

#[derive(Debug)]
pub struct EquipmentAreaRecord;

impl ClassType for EquipmentAreaRecord {
    type BaseClass = IScriptable;
    const NAME: &'static str = "gamedataEquipmentArea_Record";
}

#[redscript_import]
impl EquipmentAreaRecord {
    /// `public final native func GetID() -> TweakDBID`
    #[redscript(native)]
    pub fn get_id(self: &Ref<Self>) -> TweakDbId;
    /// `public final native func Type() -> gamedataEquipmentArea`
    #[redscript(native)]
    pub fn r#type(self: &Ref<Self>) -> GameDataEquipmentArea;
}
