use red4ext_rs::types::{Ref, WRef};

pub trait IsDefined {
    fn is_defined(&self) -> bool;
}

impl<A> IsDefined for Ref<A> {
    fn is_defined(&self) -> bool {
        !self.clone().into_shared().as_ptr().is_null()
    }
}

impl<A> IsDefined for WRef<A> {
    fn is_defined(&self) -> bool {
        !self.clone().into_shared().as_ptr().is_null()
    }
}
