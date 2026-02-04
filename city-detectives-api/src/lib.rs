//! City Detectives API – bibliothèque (auth, enquêtes, énigmes).
//! Le binaire `main` utilise cette lib ; les tests d'intégration (tests/api/) en dépendent.

pub mod api;
pub mod db;
pub mod models;
pub mod services;

pub use api::graphql::{create_schema, AppSchema};
pub use services::admin_service::AdminService;
pub use services::analytics_service::AnalyticsService;
pub use services::auth_service::{self, AuthService};
pub use services::enigma_service::EnigmaService;
pub use services::gamification_service::GamificationService;
pub use services::investigation_service::InvestigationService;
pub use services::lore_service::LoreService;
pub use services::payment_service::PaymentService;
pub use services::push_service::PushService;
