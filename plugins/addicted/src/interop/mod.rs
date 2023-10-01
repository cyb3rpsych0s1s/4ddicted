mod consumption;
pub use consumption::*;
mod substance;
pub use substance::*;
mod threshold;
pub use threshold::*;

use crate::intoxication::Intoxication;

impl Intoxication for (Consumptions, SubstanceId) {
    fn threshold(&self) -> Threshold {
        self.0
            .get(self.1.clone())
            .map(|x| x.current().into())
            .unwrap_or(Threshold::Clean)
    }
}
