-- YVS User API: initial schema, revision 001.
-- Select an existing empty application database before importing this file.
-- MyISAM is the conservative target for restricted free shared hosting.
-- No seed credentials, database creation, procedures, triggers or transactions.
-- Deliberately no IF NOT EXISTS: existing tables must not hide schema mismatch.
SET SESSION sql_mode = 'STRICT_ALL_TABLES,NO_ENGINE_SUBSTITUTION';
SET SESSION time_zone = '+00:00';
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE yvs_services (
    service_pk INT UNSIGNED NOT NULL AUTO_INCREMENT
        COMMENT 'Internal row key, allocated when registration is requested',
    service_id CHAR(32) CHARACTER SET ascii COLLATE ascii_bin NULL
        COMMENT 'Public lowercase hex identifier; assigned only on approval',
    name VARCHAR(160) NOT NULL COMMENT 'Human-readable service name; not unique',
    status ENUM('pending', 'approved') NOT NULL DEFAULT 'pending',
    service_token VARBINARY(64) NULL
        COMMENT 'Current 64-character lowercase hex bearer token; recoverable for delivery',
    previous_service_token VARBINARY(64) NULL
        COMMENT 'Previous token awaiting confirmation; NULL otherwise',
    token_issued_at DATETIME NULL COMMENT 'UTC issue time of the current token',
    token_version INT UNSIGNED NOT NULL DEFAULT 0
        COMMENT 'Compare-and-swap counter for approval and token state changes',
    requested_at DATETIME NOT NULL COMMENT 'UTC service request creation time',
    approved_at DATETIME NULL COMMENT 'UTC approval time; NULL while pending',
    PRIMARY KEY (service_pk),
    UNIQUE KEY uq_services_public_id (service_id),
    KEY ix_services_pending (status, requested_at, service_pk)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE yvs_users (
    user_id CHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL
        COMMENT 'Public random lowercase hex identifier, unique across all services',
    service_pk INT UNSIGNED NOT NULL COMMENT 'Logical reference to yvs_services.service_pk',
    password_hash VARBINARY(255) NOT NULL COMMENT 'Complete PHP password_hash output',
    password_set_at DATETIME NOT NULL COMMENT 'UTC time current password was set; reset on replacement',
    registered_at DATETIME NOT NULL COMMENT 'UTC account registration time; never reset on password change',
    last_session_cleanup_at DATETIME NULL COMMENT 'UTC last successful expired-session cleanup',
    PRIMARY KEY (user_id),
    KEY ix_users_service (service_pk)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE yvs_user_sessions (
    session_hash BINARY(32) NOT NULL COMMENT 'Raw SHA-256 digest of the issued session bearer token',
    user_id CHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL
        COMMENT 'Logical reference to yvs_users.user_id; service derived through user',
    last_activity_at DATETIME NOT NULL COMMENT 'UTC latest login or successful session check',
    PRIMARY KEY (session_hash),
    KEY ix_sessions_user_activity (user_id, last_activity_at)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE yvs_administrators (
    administrator_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    username VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL
        COMMENT 'Application-normalized lowercase ASCII administrator login',
    password_hash VARBINARY(255) NOT NULL COMMENT 'Complete PHP password_hash output',
    created_at DATETIME NOT NULL COMMENT 'UTC bootstrap creation time',
    PRIMARY KEY (administrator_id),
    UNIQUE KEY uq_administrators_username (username)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
