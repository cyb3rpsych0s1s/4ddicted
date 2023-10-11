use cp2077_rs::GameTime;
use red4ext_rs::{
    info,
    prelude::{redscript_import, ClassType},
    types::{IScriptable, Ref, WRef},
};

use crate::intoxication::{Intoxication, Intoxications, VariousIntoxication};

use super::{Category, Substance, SubstanceId, Threshold};

impl VariousIntoxication for Vec<Ref<Consumption>> {
    fn average_threshold(self: Self) -> Threshold {
        let len = self.len() as i32;
        if len == 0 {
            return Threshold::Clean;
        }
        let sum: i32 = self.iter().map(|x| x.threshold() as i32).sum();
        Threshold::from(sum / len)
    }

    fn highest_threshold(self: Self) -> Threshold {
        self.iter()
            .map(|x| x.threshold())
            .max()
            .unwrap_or(Threshold::Clean)
    }
}

#[derive(Default, Clone)]
#[repr(transparent)]
pub struct Consumption;

impl ClassType for Consumption {
    type BaseClass = IScriptable;
    const NAME: &'static str = "Addicted.Consumption";
}

impl Intoxication for Consumption {
    fn threshold(self: &Ref<Consumption>) -> Threshold {
        Threshold::from(self.current())
    }
}

/// substances consumption.
///
/// SAFETY: consumptions keys and values must be of same size at all time.
#[derive(Debug)]
pub struct Consumptions;

#[redscript_import]
impl Consumption {
    pub fn current(self: &Ref<Self>) -> i32;
    pub fn doses(self: &Ref<Self>) -> Vec<f32>;
    pub fn set_current(self: &Ref<Self>, value: i32) -> ();
    fn set_doses(self: &Ref<Self>, value: Vec<f32>) -> ();
}

impl ClassType for Consumptions {
    type BaseClass = IScriptable;
    const NAME: &'static str = "Addicted.Consumptions";
}

#[redscript_import]
impl Consumptions {
    pub fn keys(self: &Ref<Self>) -> Vec<SubstanceId>;
    fn values(self: &Ref<Self>) -> Vec<Ref<Consumption>>;
    fn set_keys(self: &Ref<Self>, keys: Vec<SubstanceId>) -> ();
    fn set_values(self: &Ref<Self>, values: Vec<Ref<IScriptable>>) -> ();
    fn create_consumption(self: &Ref<Self>, score: i32, when: f32) -> Ref<Consumption>;
}

impl Consumptions {
    /// get index from substance ID, if any.
    fn position(self: &Ref<Self>, id: SubstanceId) -> Option<usize> {
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
    pub fn get_owned(self: &Ref<Self>, id: SubstanceId) -> Option<Ref<Consumption>> {
        info!("get owned consumption");
        if let Some(idx) = self.position(id) {
            info!(
                "found owned consumption position {idx} out of {} value(s)",
                self.values().len()
            );
            // SAFETY: keys and values are guaranteed to be of same size.
            return Some(
                self.values()
                    .get(idx)
                    .expect("keys and values should be of the same size, hence consumption should exists")
                    .clone(),
            );
        }
        None
    }
    /// get consumptions by substance ids, if any.
    fn by_ids(self: &Ref<Self>, ids: &[SubstanceId]) -> Vec<Ref<Consumption>> {
        ids.iter().filter_map(|x| self.get_owned(*x)).collect()
    }
    /// get consumptions by substance, if any.
    pub fn by_substance(self: &Ref<Self>, substance: Substance) -> Vec<Ref<Consumption>> {
        self.by_ids(<&[SubstanceId]>::from(substance))
    }
    /// get consumptions by category, if any.
    pub fn by_category(self: &Ref<Self>, category: Category) -> Vec<Ref<Consumption>> {
        self.by_ids(<Vec<SubstanceId>>::from(category).as_slice())
    }
    /// increase consumption for given substance ID.
    ///
    /// if consumed for the first time, create an entry in keys and values.
    /// otherwise update existing entry in values.
    pub fn increase(self: &Ref<Self>, id: SubstanceId, tms: f32) {
        if let Some(existing) = self.get_owned(id) {
            info!("increase existing consumption");
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
            info!("create new consumption");
            let len = self.keys().as_slice().len();

            let value = self.create_consumption(id.kicks_in(), tms);
            let mut keys;
            let mut values;

            keys = vec![SubstanceId::default(); len + 1];
            keys[len] = id;
            if len > 0 {
                keys[..len].clone_from_slice(self.keys().as_slice());
            }

            values = vec![WRef::<Consumption>::default(); len + 1];
            if len > 0 {
                values[..len].clone_from_slice(
                    self.values()
                        .as_slice()
                        .iter()
                        .map(|x| red4ext_rs::prelude::Ref::<Consumption>::downgrade(&x))
                        .collect::<Vec<_>>()
                        .as_slice(),
                );
            }
            values[len] = red4ext_rs::prelude::Ref::<Consumption>::downgrade(&value);

            self.set_keys(keys);
            self.set_values(
                values
                    .into_iter()
                    .map(|x| {
                        red4ext_rs::prelude::Ref::<Consumption>::upcast(x.upgrade().expect(
                            "Consumption can be upgraded since they were created from valid slice",
                        ))
                    })
                    .collect(),
            );
        }
    }
    /// decrease consumption for all substances.
    ///
    /// if greater than zero, decrease consumption score.
    /// otherwise remove entry from both keys and values.
    pub fn decrease(self: &Ref<Self>) {
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
        if !removables.is_empty() {
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
            self.set_values(
                values
                    .into_iter()
                    .map(|x| red4ext_rs::prelude::Ref::<Consumption>::upcast(x))
                    .collect(),
            );
        }
    }
    pub fn is_withdrawing_from_substance(
        self: &Ref<Self>,
        substance: Substance,
        at: GameTime,
    ) -> bool {
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
    fn average_threshold(self: &Ref<Self>, by: Substance) -> Threshold
    where
        Self: Sized,
    {
        VariousIntoxication::average_threshold(self.by_substance(by))
    }
    /// get highest threshold by substance, across all its related consumptions, if any.
    fn highest_threshold(self: &Ref<Self>, by: Substance) -> Threshold
    where
        Self: Sized,
    {
        VariousIntoxication::highest_threshold(self.by_substance(by))
    }
}

impl Intoxications<Category> for Consumptions {
    /// get average threshold by category, across all its related consumptions, if any.
    fn average_threshold(self: &Ref<Self>, by: Category) -> Threshold
    where
        Self: Sized,
    {
        VariousIntoxication::average_threshold(self.by_category(by))
    }
    /// get highest threshold by category, across all its related consumptions, if any.
    fn highest_threshold(self: &Ref<Self>, by: Category) -> Threshold
    where
        Self: Sized,
    {
        VariousIntoxication::highest_threshold(self.by_category(by))
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
                let mut from = 0_usize;
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
