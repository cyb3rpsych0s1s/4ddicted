use red4ext_rs::prelude::redscript_global;

#[allow(non_snake_case)]
#[redscript_global(name = "DEBUG")]
pub(crate) fn REDS_DEBUG(message: String) -> ();

#[allow(non_snake_case)]
#[redscript_global(name = "ASSERT")]
pub(crate) fn REDS_ASSERT(message: String) -> ();

#[macro_export]
macro_rules! reds_debug {
    ($($args:expr),*) => {
        let args = format!("{}", format_args!($($args),*));
        $crate::utils::REDS_DEBUG(args);
    }
}
