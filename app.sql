--USERS --
CREATE TABLE users (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email        CITEXT UNIQUE NOT NULL,
  name         TEXT NOT NULL,
  tz           TEXT NOT NULL DEFAULT 'Europe/Dublin',
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

--FITBIT INPUT --
CREATE TABLE fitbit_samples (
  id           BIGSERIAL PRIMARY KEY,
  user_id      UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  ts           TIMESTAMPTZ NOT NULL,          -- sample timestamp
  hr_bpm       INTEGER,                        -- heart rate
  steps        INTEGER,                        -- step count for the interval
  calories     NUMERIC(10,2),                  -- optional
  hrv_ms       NUMERIC(10,2),                  -- optional
  sleep_stage  TEXT,                           -- 'AWAKE','LIGHT','REM','DEEP' if applicable
  raw          JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE INDEX fitbit_samples_user_ts_idx ON fitbit_samples (user_id, ts DESC);

-- TASKS (--
CREATE TABLE tasks (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title          TEXT NOT NULL,
  notes          TEXT,
  duration_min   INTEGER CHECK (duration_min > 0),  -- estimate
  due_at         TIMESTAMPTZ,                        -- optional deadline
  -- If scheduled it, fill these --
  start_ts       TIMESTAMPTZ,
  end_ts         TIMESTAMPTZ,
  status         TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','scheduled','done','cancelled')),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX tasks_user_status_idx ON tasks (user_id, status);
CREATE INDEX tasks_user_due_idx    ON tasks (user_id, due_at);
CREATE INDEX tasks_user_start_idx  ON tasks (user_id, start_ts);
