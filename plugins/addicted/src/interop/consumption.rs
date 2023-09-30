use red4ext_rs::{
    prelude::{redscript_import, NativeRepr, RefRepr, Strong},
    types::{IScriptable, RedArray, Ref},
};

use super::SubstanceId;

#[derive(Default, Clone)]
#[repr(C)]
pub struct Consumption {
    pub current: i32,
    pub doses: Vec<f32>,
}

unsafe impl NativeRepr for Consumption {
    const NAME: &'static str = "Addicted.Consumption";
}

impl Consumption {
    pub fn new(amount: i32) -> Self {
        Self {
            current: amount,
            doses: Default::default(),
        }
    }
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct Consumptions(Ref<IScriptable>);

unsafe impl RefRepr for Consumptions {
    type Type = Strong;

    const CLASS_NAME: &'static str = "Addicted.Consumptions";
}

#[redscript_import]
impl Consumptions {
    fn persist(keys: RedArray<i32>, values: RedArray<Consumption>) -> ();
    fn keys(&self) -> Vec<SubstanceId>;
    fn values(&self) -> Vec<Consumption>;
}

#[allow(dead_code)]
impl Consumptions {
    pub fn index(&self, id: SubstanceId) -> Option<usize> {
        let keys = self.keys();
        let mut iter = keys.iter().enumerate();
        let idx: Option<usize> = loop {
            match (iter.next(), iter.next_back()) {
                (None, None) => break None,
                (_, Some((idx, key))) | (Some((idx, key)), _) if *key == id => return Some(idx),
                _ => continue,
            }
        };
        idx
    }
    pub fn contains(&self, id: SubstanceId) -> bool {
        self.index(id).is_some()
    }
    pub fn get(&self, id: SubstanceId) -> Option<Consumption> {
        if let Some(idx) = self.index(id) {
            return Some(unsafe { self.values().get_unchecked(idx) }.clone());
        }
        None
    }
    pub fn set(&mut self, id: SubstanceId, value: Consumption) {
        if let Some(idx) = self.index(id.clone()) {
            unsafe { *self.values().get_unchecked_mut(idx) = value };
        } else {
            self.keys().push(id);
            self.values().push(value);
        }
    }
    pub fn unset(&mut self, id: SubstanceId) -> bool {
        if let Some(idx) = self.index(id) {
            self.keys().remove(idx);
            self.values().remove(idx);
        }
        false
    }
}
