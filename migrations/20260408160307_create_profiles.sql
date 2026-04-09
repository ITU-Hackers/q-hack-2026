CREATE TABLE IF NOT EXISTS profiles (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email         TEXT             NOT NULL UNIQUE,
    password      TEXT             NOT NULL,
    adults        INT              NOT NULL DEFAULT 0,
    kids          INT              NOT NULL DEFAULT 0,
    dogs          INT              NOT NULL DEFAULT 0,
    cats          INT              NOT NULL DEFAULT 0,
    cuisines      TEXT[]           NOT NULL DEFAULT '{}',
    pref_fish     INT              NOT NULL DEFAULT 0,
    pref_pork     INT              NOT NULL DEFAULT 0,
    pref_beef     INT              NOT NULL DEFAULT 0,
    pref_dairy    INT              NOT NULL DEFAULT 0,
    pref_spicy    INT              NOT NULL DEFAULT 0,
    restrictions  TEXT[]           NOT NULL DEFAULT '{}',
    health_goal   TEXT             NOT NULL DEFAULT 'balanced',
    cooking_time  TEXT             NOT NULL DEFAULT 'quick',
    budget        TEXT             NOT NULL DEFAULT 'moderate'
);