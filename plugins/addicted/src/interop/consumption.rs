use red4ext_rs::{
    prelude::{redscript_import, RefRepr, Strong},
    types::{IScriptable, Ref},
};

use crate::intoxication::Intoxication;

use super::{Substance, SubstanceId, Threshold};

/// refactor once [fixed](https://github.com/jac3km4/red4ext-rs/issues/24)
pub trait IntoRefs {
    fn into_refs(self) -> Vec<Ref<IScriptable>>;
}

impl IntoRefs for Vec<Consumption> {
    fn into_refs(self) -> Vec<Ref<IScriptable>> {
        self.into_iter().map(|x| x.0).collect()
    }
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct Consumption(pub Ref<IScriptable>);

unsafe impl RefRepr for Consumption {
    type Type = Strong;

    const CLASS_NAME: &'static str = "Addicted.Consumption";
}

impl Intoxication for Consumption {
    fn threshold(&self) -> Threshold {
        Threshold::from(self.current())
    }
}

/// substances consumption.
///
/// SAFETY: consumptions keys and values must be of same size at all time.
#[derive(Default, Clone)]
#[repr(transparent)]
pub struct Consumptions(Ref<IScriptable>);

#[redscript_import]
impl Consumption {
    pub fn current(&self) -> i32;
    pub fn doses(&self) -> Vec<f32>;
    pub fn set_current(&mut self, value: i32) -> ();
    fn set_doses(&mut self, value: Vec<f32>) -> ();
}

unsafe impl RefRepr for Consumptions {
    type Type = Strong;

    const CLASS_NAME: &'static str = "Addicted.Consumptions";
}

#[redscript_import]
impl Consumptions {
    pub fn keys(&self) -> Vec<SubstanceId>;
    fn values(&self) -> Vec<Consumption>;
    fn set_keys(&mut self, keys: Vec<SubstanceId>) -> ();
    /// refactor once [fixed](https://github.com/jac3km4/red4ext-rs/issues/24)
    fn set_values(&mut self, values: Vec<Ref<IScriptable>>) -> ();
    fn create_consumption(&self, score: i32, when: f32) -> Consumption;
}

impl Consumptions {
    /// get index from substance ID, if any.
    fn position(&self, id: SubstanceId) -> Option<usize> {
        let keys = self.keys();
        let mut iter = keys.as_slice().iter().enumerate();
        loop {
            match (iter.next(), iter.next_back()) {
                (None, None) => break None,
                (_, Some((idx, key))) if *key == id => break Some(idx),
                (Some((idx, key)), _) if *key == id => break Some(idx),
                _ => continue,
            }
        }
    }
    /// get consumption by substance ID, if any.
    pub fn get(&self, id: SubstanceId) -> Option<Consumption> {
        if let Some(idx) = self.position(id) {
            // SAFETY: keys and values are guaranteed to be of same size.
            return Some(unsafe { self.values().get_unchecked(idx) }.clone());
        }
        None
    }
    pub fn by_substance(&self, substance: Substance) -> Vec<Consumption> {
        <&[SubstanceId]>::from(substance)
            .iter()
            .filter_map(|x| self.position(*x))
            .map(|x| self.values()[x].clone())
            .collect()
    }
    /// increase consumption for given substance ID.
    ///
    /// if consumed for the first time, create an entry in keys and values.
    /// otherwise update existing entry in values.
    pub fn increase(&mut self, id: SubstanceId, tms: f32) {
        if let Some(idx) = self.position(id.clone()) {
            let mut existing = self.values().as_slice()[idx as usize].clone();
            let mut doses = existing.doses();
            doses.push(tms);

            existing.set_current(existing.current() + id.kicks_in());
            existing.set_doses(doses);
        } else {
            let len = self.keys().as_slice().len();

            let mut keys = Vec::with_capacity(len + 1);
            keys.extend_from_slice(self.keys().as_slice());
            keys.push(id.clone());

            let value = self.create_consumption(id.kicks_in(), tms);
            let mut values = Vec::with_capacity(len + 1);
            values.extend_from_slice(self.values().as_slice());
            values.push(value);

            self.set_keys(keys);
            self.set_values(values.into_refs());
        }
    }
    /// decrease consumption for all substances.
    ///
    /// if greater than zero, decrease consumption score.
    /// otherwise remove entry from both keys and values.
    pub fn decrease(&mut self) {
        let len = self.keys().as_slice().len();
        if len == 0 {
            return;
        }
        let mut removables = Vec::with_capacity(len);
        for (id, (idx, consumption)) in self
            .keys()
            .as_slice()
            .iter()
            .zip(self.values().as_mut_slice().iter_mut().enumerate())
        {
            if consumption.current() <= 0 {
                removables.push(idx);
            } else {
                consumption.set_current(consumption.current() - id.wean_off());
            }
        }
        if removables.len() > 0 {
            let mut keys = Vec::with_capacity(len - removables.len());
            let mut values = Vec::with_capacity(len - removables.len());
            let mut from = 0;
            for to in removables {
                if to != from {
                    keys.extend_from_slice(&self.keys().as_slice()[from..to]);
                    values.extend_from_slice(&self.values().as_slice()[from..to]);
                }
                from = to + 1;
            }
            if from <= len {
                keys.extend_from_slice(&self.keys().as_slice()[from..]);
                values.extend_from_slice(&self.values().as_slice()[from..]);
            }
            self.set_keys(keys);
            self.set_values(values.into_refs());
        }
    }
}
