use red4ext_rs::{
    prelude::{redscript_import, RefRepr, Strong},
    types::{IScriptable, Ref},
};

use super::SubstanceId;

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct Consumption(Ref<IScriptable>);

unsafe impl RefRepr for Consumption {
    type Type = Strong;

    const CLASS_NAME: &'static str = "Addicted.Consumption";
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct Consumptions(Ref<IScriptable>);

#[redscript_import]
impl Consumption {
    fn current(&self) -> i32;
    fn set_current(&mut self, value: i32) -> ();
    fn doses(&self) -> Vec<f32>;
    fn set_doses(&mut self, value: Vec<f32>) -> ();
}

unsafe impl RefRepr for Consumptions {
    type Type = Strong;

    const CLASS_NAME: &'static str = "Addicted.Consumptions";
}

#[redscript_import]
impl Consumptions {
    fn keys(&self) -> Vec<SubstanceId>;
    fn values(&self) -> Vec<Consumption>;
    fn set_keys(&self, keys: Vec<SubstanceId>) -> ();
    fn set_values(&self, values: Vec<Consumption>) -> ();
    fn create_consumption(&self, score: i32) -> Consumption;
}

#[allow(dead_code)]
impl Consumptions {
    pub fn increase(&mut self, id: SubstanceId) {
        let idx = self
            .keys()
            .as_slice()
            .iter()
            .enumerate()
            .find_map(|(idx, key)| if *key == id { Some(idx as isize) } else { None })
            .unwrap_or(-1);
        if idx == -1 {
            let len = self.keys().as_slice().len();

            let mut keys = Vec::with_capacity(len + 1);
            keys.extend_from_slice(self.keys().as_slice());
            keys.push(id);

            let value = self.create_consumption(1);
            let mut values = Vec::with_capacity(len + 1);
            values.extend_from_slice(self.values().as_slice());
            values.push(value);

            self.set_keys(keys);
            self.set_values(values);
        } else {
            let mut existing = self.values().as_slice()[idx as usize].clone();
            existing.set_current(existing.current() + 1);
            existing.set_doses(existing.doses());
        }
    }
    pub fn decrease(&mut self) {
        let len = self.keys().as_slice().len();
        if len == 0 {
            return;
        }
        let mut removables = Vec::with_capacity(len);
        for (idx, consumption) in self.values().as_mut_slice().iter_mut().enumerate() {
            if consumption.current() == 0 {
                removables.push(idx);
            } else {
                consumption.set_current(consumption.current() - 1);
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
            self.set_values(values);
        }
    }
    pub fn decrease_one(&mut self, id: SubstanceId) {
        let idx = self
            .keys()
            .as_slice()
            .iter()
            .enumerate()
            .find_map(|(idx, key)| if *key == id { Some(idx as isize) } else { None })
            .unwrap_or(-1);
        if idx != -1 {
            let idx = idx as usize;
            if self.values().as_slice()[idx].current() == 0 {
                let len = self.keys().as_slice().len();
                if len > 0 {
                    let mut keys = Vec::with_capacity(len - 1);
                    let mut values = Vec::with_capacity(len - 1);
                    if idx == 0 {
                        keys.extend_from_slice(&self.keys().as_slice()[1..]);

                        values.extend_from_slice(&self.values().as_slice()[1..]);
                    } else if idx == (len - 1) {
                        keys.extend_from_slice(&self.keys().as_slice()[..len]);

                        values.extend_from_slice(&self.values().as_slice()[..len]);
                    } else {
                        keys.extend_from_slice(&self.keys().as_slice()[0..idx]);
                        keys.extend_from_slice(&self.keys().as_slice()[idx + 1..]);

                        values.extend_from_slice(&self.values().as_slice()[0..idx]);
                        values.extend_from_slice(&self.values().as_slice()[idx + 1..]);
                    }
                    self.set_keys(keys);
                    self.set_values(values);
                }
            } else {
                let mut values = self.values();
                let existing = &mut values.as_mut_slice()[idx];
                existing.set_current(existing.current() - 1);
            }
        }
    }
}
