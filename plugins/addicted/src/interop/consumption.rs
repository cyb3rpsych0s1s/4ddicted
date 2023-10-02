use cp2077_rs::GameTime;
use red4ext_rs::{
    info,
    prelude::{redscript_import, RefRepr, Strong},
    types::{IScriptable, Ref},
};

use crate::intoxication::{Intoxication, Intoxications, VariousIntoxication};

use super::{Category, Substance, SubstanceId, Threshold};

/// refactor once [fixed](https://github.com/jac3km4/red4ext-rs/issues/24)
pub trait IntoRefs {
    fn into_refs(self) -> Vec<Ref<IScriptable>>;
}

impl IntoRefs for Vec<Consumption> {
    fn into_refs(self) -> Vec<Ref<IScriptable>> {
        self.into_iter().map(|x| x.0).collect()
    }
}

impl VariousIntoxication for Vec<Consumption> {
    fn average_threshold(&self) -> Threshold {
        let len = self.len() as i32;
        if len == 0 {
            return Threshold::Clean;
        }
        let sum: i32 = self.iter().map(|x| x.threshold() as i32).sum();
        Threshold::from(sum / len)
    }

    fn highest_threshold(&self) -> Threshold {
        self.iter()
            .map(|x| x.threshold())
            .max()
            .unwrap_or(Threshold::Clean)
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
    pub fn get_owned(&self, id: SubstanceId) -> Option<Consumption> {
        if let Some(idx) = self.position(id) {
            // SAFETY: keys and values are guaranteed to be of same size.
            return Some(unsafe { self.values().get_unchecked(idx) }.clone());
        }
        None
    }
    /// get consumptions by substance ids, if any.
    fn by_ids(&self, ids: &[SubstanceId]) -> Vec<Consumption> {
        ids.iter().filter_map(|x| self.get_owned(*x)).collect()
    }
    /// get consumptions by substance, if any.
    pub fn by_substance(&self, substance: Substance) -> Vec<Consumption> {
        self.by_ids(<&[SubstanceId]>::from(substance))
    }
    /// get consumptions by category, if any.
    pub fn by_category(&self, category: Category) -> Vec<Consumption> {
        self.by_ids(<Vec<SubstanceId>>::from(category).as_slice())
    }
    /// increase consumption for given substance ID.
    ///
    /// if consumed for the first time, create an entry in keys and values.
    /// otherwise update existing entry in values.
    pub fn increase(&mut self, id: SubstanceId, tms: f32) {
        if let Some(mut existing) = self.get_owned(id) {
            let current = existing.doses();
            let len = current.len();
            let mut doses;
            doses = vec![f32::default(); len + 1];
            if len > 0 {
                doses[..len].clone_from_slice(current.as_slice());
            }
            doses[len] = tms;

            existing.set_current(existing.current() + id.kicks_in());
            existing.set_doses(doses);
        } else {
            let len = self.keys().as_slice().len();

            let value = self.create_consumption(id.kicks_in(), tms);
            let mut keys;
            let mut values;

            keys = vec![SubstanceId::default(); len + 1];
            keys[len] = id;
            if len > 0 {
                keys[..len].clone_from_slice(&self.keys().as_slice());
            }

            values = vec![Consumption::default(); len + 1];
            if len > 0 {
                values[..len].clone_from_slice(self.values().as_slice());
            }
            values[len] = value;

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
    pub fn is_withdrawing_from_substance(&self, substance: Substance, at: GameTime) -> bool {
        for ref consumption in self.by_substance(substance) {
            if let Some(last) = consumption.doses().last() {
                let last = GameTime::from(*last);
                info!("last: [{last}] vs now: [{at}]");
                return at >= last.add_hours(24);
            }
        }
        false
    }
}

impl Intoxications<Substance> for Consumptions {
    /// get average threshold by substance, across all its related consumptions, if any.
    fn average_threshold(&self, by: Substance) -> Threshold {
        <dyn VariousIntoxication>::average_threshold(&self.by_substance(by))
    }
    /// get highest threshold by substance, across all its related consumptions, if any.
    fn highest_threshold(&self, by: Substance) -> Threshold {
        <dyn VariousIntoxication>::highest_threshold(&self.by_substance(by))
    }
}

impl Intoxications<Category> for Consumptions {
    /// get average threshold by category, across all its related consumptions, if any.
    fn average_threshold(&self, by: Category) -> Threshold {
        <dyn VariousIntoxication>::average_threshold(&self.by_category(by))
    }
    /// get highest threshold by category, across all its related consumptions, if any.
    fn highest_threshold(&self, by: Category) -> Threshold {
        <dyn VariousIntoxication>::highest_threshold(&self.by_category(by))
    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn concatenate() {
        let slice = [1, 2, 3, 4, 5];
        let additional = 6;
        let len = slice.len();
        let mut copy = vec![i32::default(); len + 1];
        copy[..len].clone_from_slice(&slice);
        copy[len] = additional;
        assert_eq!(copy.as_slice(), &[1, 2, 3, 4, 5, 6]);
    }
    #[test]
    fn removal() {
        let logic = |slice: &[i32]| {
            let len = slice.len();
            let removables: Vec<usize> = slice
                .iter()
                .enumerate()
                .filter_map(|(idx, x)| if *x <= 0 { Some(idx) } else { None })
                .collect();
            let mut copy;
            if removables.len() != len {
                copy = Vec::with_capacity(len - removables.len());
                let mut from = 0 as usize;
                for to in removables {
                    if to != from {
                        copy.extend_from_slice(&slice[from..to]);
                    }
                    from = to + 1;
                }
                if from <= len {
                    copy.extend_from_slice(&slice[from..]);
                }
            } else {
                copy = vec![];
            }
            copy
        };

        let slice = [0i32, -1, 2, 4, 0, 1, 0];
        let copy = logic(&slice);
        assert_eq!(copy.as_slice(), &[2, 4, 1]);

        let slice = [0i32, 0, 0];
        let copy = logic(&slice);
        assert_eq!(copy.as_slice(), &[]);

        let slice = [0i32, 1, 1];
        let copy = logic(&slice);
        assert_eq!(copy.as_slice(), &[1, 1]);

        let slice = [1i32, 1, 0];
        let copy = logic(&slice);
        assert_eq!(copy.as_slice(), &[1, 1]);

        let slice = [];
        let copy = logic(&slice);
        assert_eq!(copy.as_slice(), &[]);

        let slice = [1, 1, 1];
        let copy = logic(&slice);
        assert_eq!(copy.as_slice(), &[1i32, 1, 1]);
    }
}
