DO
$$
BEGIN
    IF
NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'domain_code_enum') THEN
CREATE TYPE domain_code_enum AS ENUM ('CLOUD', 'SEC', 'TECH', 'BILL');
END IF;

    IF
NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'question_type_enum') THEN
CREATE TYPE question_type_enum AS ENUM ('SINGLE_CHOICE', 'MULTIPLE_CHOICE');
END IF;

    IF
NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'simulation_status_enum') THEN
CREATE TYPE simulation_status_enum AS ENUM ('EM_ANDAMENTO', 'COMPLETO', 'ABANDONADO');
END IF;

    IF
NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'simulation_type_enum') THEN
CREATE TYPE simulation_type_enum AS ENUM ('PADRAO', 'PERSONALIZADO', 'QUESTOES_ERRADAS');
END IF;
END$$;

DO
$$
BEGIN
    IF
NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'domains') THEN
CREATE TABLE domains
(
    domain_id         serial PRIMARY KEY,
    names             jsonb            NOT NULL,
    code              domain_code_enum NOT NULL,
    weight_percentage integer,
    description       jsonb
);

CREATE INDEX idx_domain_names ON domains USING gin (names);
END IF;

    IF
NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'questions') THEN
CREATE TABLE questions
(
    question_id     serial PRIMARY KEY,
    domain_id       integer REFERENCES domains,
    question_text   jsonb              NOT NULL,
    options         jsonb              NOT NULL,
    correct_answers jsonb              NOT NULL,
    question_type   question_type_enum NOT NULL,
    explanation     jsonb,
    metadata        jsonb,
    created_at      timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at      timestamp DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_question_text ON questions USING gin (question_text);
CREATE INDEX idx_options ON questions USING gin (options);
END IF;
END$$;

CREATE TABLE IF NOT EXISTS users
(
    user_id
    serial
    PRIMARY
    KEY,
    keycloak_id
    varchar
(
    255
) UNIQUE NOT NULL,
    username varchar
(
    100
) NOT NULL,
    email varchar
(
    255
) NOT NULL,
    weight_profiles jsonb DEFAULT '[]'::jsonb,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
    );

CREATE INDEX IF NOT EXISTS idx_users_keycloak_id ON users(keycloak_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

CREATE TABLE IF NOT EXISTS simulation_runs
(
    run_id
    serial
    PRIMARY
    KEY,
    user_id
    integer
    REFERENCES
    users
(
    user_id
),
    run_type simulation_type_enum NOT NULL,
    total_questions integer NOT NULL,
    correct_answers integer NOT NULL DEFAULT 0,
    score decimal
(
    5,
    2
) NOT NULL DEFAULT 0.0,
    custom_weights jsonb DEFAULT NULL,
    settings jsonb DEFAULT '{}'::jsonb,
    started_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at timestamp DEFAULT NULL,
    status simulation_status_enum NOT NULL DEFAULT 'EM_ANDAMENTO',
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
    );

CREATE INDEX IF NOT EXISTS idx_simulation_runs_user_id ON simulation_runs(user_id);
CREATE INDEX IF NOT EXISTS idx_simulation_runs_status ON simulation_runs(status);

CREATE TABLE IF NOT EXISTS run_questions
(
    run_question_id
    serial
    PRIMARY
    KEY,
    run_id
    integer
    REFERENCES
    simulation_runs
(
    run_id
),
    question_id integer REFERENCES questions
(
    question_id
),
    user_answers jsonb DEFAULT NULL,
    is_correct boolean DEFAULT NULL,
    time_spent_seconds integer DEFAULT NULL,
    question_order integer NOT NULL,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    UNIQUE
(
    run_id,
    question_id
)
    );

CREATE INDEX IF NOT EXISTS idx_run_questions_run_id ON run_questions(run_id);
CREATE INDEX IF NOT EXISTS idx_run_questions_question_id ON run_questions(question_id);

CREATE TABLE IF NOT EXISTS user_domain_performance
(
    performance_id
    serial
    PRIMARY
    KEY,
    user_id
    integer
    REFERENCES
    users
(
    user_id
),
    domain_id integer REFERENCES domains
(
    domain_id
),
    total_questions integer NOT NULL DEFAULT 0,
    correct_answers integer NOT NULL DEFAULT 0,
    accuracy_rate decimal
(
    5,
    2
) NOT NULL DEFAULT 0.0,
    last_updated timestamp DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT user_domain_unique UNIQUE
(
    user_id,
    domain_id
)
    );

CREATE INDEX IF NOT EXISTS idx_user_domain_performance_user_id ON user_domain_performance(user_id);
CREATE INDEX IF NOT EXISTS idx_user_domain_performance_domain_id ON user_domain_performance(domain_id);

CREATE
OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at
= CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$
LANGUAGE plpgsql;

DO
$$
BEGIN
    IF
NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_users_timestamp') THEN
CREATE TRIGGER update_users_timestamp
    BEFORE UPDATE
    ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();
END IF;

    IF
NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_simulation_runs_timestamp') THEN
CREATE TRIGGER update_simulation_runs_timestamp
    BEFORE UPDATE
    ON simulation_runs
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();
END IF;

    IF
EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'questions') AND
       NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_questions_timestamp') THEN
CREATE TRIGGER update_questions_timestamp
    BEFORE UPDATE
    ON questions
    FOR EACH ROW
    EXECUTE FUNCTION update_timestamp();
END IF;
END$$;

COMMENT
ON TABLE users IS 'Tabela de usuários que utilizam o sistema de simulados';
COMMENT
ON TABLE simulation_runs IS 'Registro de execuções de simulados por usuários';
COMMENT
ON TABLE run_questions IS 'Detalhes de questões incluídas em cada simulado realizado';
COMMENT
ON TABLE user_domain_performance IS 'Estatísticas de desempenho de usuários por domínio';