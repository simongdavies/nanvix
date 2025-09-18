// Copyright(c) The Maintainers of Nanvix.
// Licensed under the MIT License.

//!
//! # Logging
//!
//! This module provides logging functionalities.
//!

//==================================================================================================
// Imports
//==================================================================================================

use ::flexi_logger::{
    FileSpec,
    Logger,
};
use ::std::sync::Once;

//==================================================================================================
// Public Standalone Functions
//==================================================================================================

///
/// # Description
///
/// Initializes the logger.
///
/// # Parameters
///
/// - `log_to_file`: Log to file?
/// - `log_dir`: Log file directory
///
/// # Note
///
/// If the logger cannot be initialized, the function will panic.
///
pub fn initialize(logfile: bool, log_dir: String) {
    static INIT_LOG: Once = Once::new();
    INIT_LOG.call_once(|| {
        let logger =
            Logger::try_with_env_or_str("error").expect("malformed RUST_LOG environment variable");
        if logfile {
            logger
                .log_to_file(FileSpec::default().directory(log_dir))
                .start()
                .expect("failed to initialize logger");
        } else {
            logger.start().expect("failed to initialize logger");
        }
    });
}
