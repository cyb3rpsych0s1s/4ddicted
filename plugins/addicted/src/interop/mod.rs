mod consumption;
pub use consumption::*;
mod substance;
pub use substance::*;
mod consumable;
pub use consumable::*;
mod threshold;
pub use threshold::*;

use crate::addiction::Addiction;

impl Addiction for (Consumptions, SubstanceId) {
    fn threshold(&self) -> Threshold {
        self.0
            .consumption(self.1.clone())
            .map(|x| x.current().into())
            .unwrap_or(Threshold::Clean)
    }
}
