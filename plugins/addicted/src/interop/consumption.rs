use cp2077_rs::GameTime;
use red4ext_rs::{
    call, info,
    prelude::{redscript_import, ClassType},
    types::{IScriptable, MaybeUninitRef, RedArray, Ref, Variant, VariantExt},
};

use crate::{
    intoxication::{Intoxication, Intoxications, VariousIntoxication},
    Field,
};

use super::{Category, Substance, SubstanceId, Threshold};

impl VariousIntoxication for Vec<Ref<Consumption>> {
    fn average_threshold(self) -> Threshold {
        let len = self.len() as i32;
        if len == 0 {
            return Threshold::Clean;
        }
        let sum: i32 = self.iter().map(|x| x.threshold() as i32).sum();
        Threshold::from(sum / len)
    }

    fn highest_threshold(self) -> Threshold {
        self.iter()
            .map(|x| x.threshold())
            .max()
            .unwrap_or(Threshold::Clean)
    }
}

#[derive(Default)]
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
    pub(crate) fn current(self: &Ref<Self>) -> i32;
    pub(crate) fn doses(self: &Ref<Self>) -> Vec<f32>;
}

impl Consumption {
    const MAX_DOSES_LENGTH: usize = 100;
    #[inline]
    pub(crate) fn set_current(self: &mut Ref<Self>, score: i32) {
        Self::field("current").set_value(
            Variant::new(self.clone()),
            Variant::new((self.current() + score).min(Threshold::MAX)),
        );
    }
    #[inline]
    pub(crate) fn push_dose(self: &mut Ref<Self>, dose: f32) {
        call!("ArrayPush;array:FloatFloat" (self.doses(), dose) -> ());
    }
    #[inline]
    pub(crate) fn shrink_doses(self: &mut Ref<Self>) {
        let doses = self.doses();
        let size = doses.len();
        if size > Self::MAX_DOSES_LENGTH {
            let starts = size - Self::MAX_DOSES_LENGTH;
            Self::field("doses").set_value(
                Variant::new(self.clone()),
                Variant::new(doses[starts..].to_vec()),
            );
        }
    }
}

impl Consumption {
    pub fn create(score: i32, tms: f32) -> Ref<Self> {
        call!("Addicted.Consumption::Create;Int32Float" (score, tms) -> Ref<Self>)
    }
    pub fn increase(self: &mut Ref<Self>, score: i32, dose: f32) {
        self.set_current((self.current() + score).min(Threshold::MAX));
        self.push_dose(dose);
    }
    pub fn decrease(self: &mut Ref<Self>, score: i32) {
        self.set_current((self.current() - score).max(Threshold::MIN));
        self.shrink_doses();
    }
}

impl ClassType for Consumptions {
    type BaseClass = IScriptable;
    const NAME: &'static str = "Addicted.Consumptions";
}

#[redscript_import]
impl Consumptions {
    pub(crate) fn keys(self: &Ref<Self>) -> Vec<SubstanceId>;
    pub(crate) fn values(self: &Ref<Self>) -> Vec<Ref<Consumption>>;
}

impl Consumptions {
    pub fn push_key(self: &mut Ref<Self>, value: SubstanceId) {
        let keys = self.keys();
        call!("ArrayPush;array:TweakDBIDTweakDBID" (keys, value) -> ());
    }
    pub fn push_value(self: &mut Ref<Self>, value: Ref<Consumption>) {
        let values = self.values();
        let values = RedArray::<MaybeUninitRef<Consumption>>::from_sized_iter(
            values.into_iter().map(Ref::into_maybe_uninit),
        );
        call!("ArrayPush;array:handle:Addicted.Consumptionhandle:Addicted.Consumption" (values, value) -> ());
    }
}

impl Consumptions {
    /// workaround for unsupported namespace with native struct
    pub fn notify(self: &Ref<Self>, former: Threshold, latter: Threshold) {
        call!(self, "Notify;ThresholdThreshold" (former, latter) -> ());
    }
    pub fn add(self: &Ref<Self>, id: SubstanceId, score: i32, tms: f32) {
        let value = Consumption::create(score, tms);
        let key = id.0;
        let keys = self.keys();
        let values = self.values();
        call!("ArrayPush;array:TweakDBIDTweakDBID" (keys, key) -> ());
        call!("ArrayPush;array:Addicted.ConsumptionAddicted.Consumption" (values, value) -> ());
    }
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
        if let Some(idx) = self.position(id) {
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
        self.by_ids(<Vec<SubstanceId>>::from(substance).as_slice())
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
        if let Some(which) = self.position(id) {
            info!("increase existing consumption");
            let existing = &mut self.values()[which];
            let former = existing.threshold();
            existing.increase(id.kicks_in(), tms);
            let latter = existing.threshold();
            // if former != Threshold::Clean && former != latter {
            // self.fire_callbacks(self.create_cross_threshold_event(former, latter));
            self.notify(former, latter);
            // }
        } else {
            info!("create new consumption");
            self.add(id, id.kicks_in(), tms);
        }
    }
    /// decrease consumption for all substances.
    ///
    /// if greater than zero, decrease consumption score.
    /// otherwise remove entry from both keys and values.
    pub fn decrease(self: &Ref<Self>) {
        let keys = self.keys();
        let mut values = self.values();
        for (key, value) in keys.iter().zip(values.iter_mut()) {
            if value.current() > 0 {
                value.decrease(key.wean_off());
            }
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
    pub fn is_addicted(self: &Ref<Self>, category: Category) -> bool {
        self.highest_threshold(category).is_serious()
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
