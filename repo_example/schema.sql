BEGIN;

CREATE TABLE messages (
       verification_code_id BIGINT UNSIGNED,
       twilio_sid           CHAR(34) UNIQUE,
       phone                VARCHAR(32) NOT NULL,
       body                 TEXT NOT NULL,
       sender_type          VARCHAR(16) NOT NULL,
       status               VARCHAR(16) NOT NULL
                            DEFAULT 'unsent',
       created_at           TIMESTAMP NOT NULL
                            DEFAULT CURRENT_TIMESTAMP

);

CREATE TABLE verification_codes (
       code                CHAR(6) NOT NULL,
       attempts            TINYINT NOT NULL
                           DEFAULT 0,
       used_at             TIMESTAMP NULL,
       expires_at          TIMESTAMP NOT NULL,
       created_at          TIMESTAMP NOT NULL
                           DEFAULT CURRENT_TIMESTAMP
);

COMMIT;
