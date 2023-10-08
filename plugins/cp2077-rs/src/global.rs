use red4ext_rs::prelude::redscript_global;

use crate::Entity;

/// `public static native func IsEntityInInteriorArea(entity: wref<Entity>) -> Bool;`
#[redscript_global(native)]
pub fn is_entity_in_interior_area(entity: Entity) -> bool;