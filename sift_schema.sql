--Tool to gradually increase priority of tasks based on multiple of factors

ROLLBACK;
BEGIN;

DROP SCHEMA IF EXISTS sift CASCADE;
CREATE SCHEMA sift;
SET search_path = 'sift';

CREATE TABLE Task(
  TaskID      BIGSERIAL     PRIMARY KEY,
  Description TEXT,
  CreatedTS   TIMESTAMPTZ   DEFAULT NOW(),
  UpdatedTS   TIMESTAMPTZ
);

CREATE TABLE Dependency(
  DependentTaskID   BIGINT  REFERENCES Task(TaskID),
  DependencyTaskID  BIGINT  REFERENCES Task(TaskID),
  CreatedTS   TIMESTAMPTZ   DEFAULT NOW(),
  UpdatedTS   TIMESTAMPTZ,
  PRIMARY KEY (DependencyTaskID, DependentTaskID),
  CHECK (DependencyTaskID IS DISTINCT FROM DependentTaskID)
);

CREATE TABLE Duration(
  TaskID      BIGINT        PRIMARY KEY REFERENCES Task(TaskID),
  Duration    INTERVAL,
  CreatedTS   TIMESTAMPTZ   DEFAULT NOW(),
  UpdatedTS   TIMESTAMPTZ
);


CREATE TABLE Deadline (
  TaskID      BIGINT        REFERENCES Task(TaskID),
  Deadline    INTERVAL,
  AlertID     BIGINT        REFERENCES Alert(AlertID),
  CreatedTS   TIMESTAMPTZ   DEFAULT NOW(),
  UpdatedTS   TIMESTAMPTZ,
  PRIMARY KEY (TaskID, Deadline)
);

/*
CREATE TABLE ActionableTimeInDay(
  TaskID      BIGINT        REFERENCES Task(TaskID),
  BeginTime   TIMESTAMPTZ,
  EndTime     TIMESTAMPTZ,
  CreatedTS   TIMESTAMPTZ   DEFAULT NOW(),
  UpdatedTS   TIMESTAMPTZ,
  PRIMARY KEY (TaskID, BeginTime)
); 

CREATE TABLE ActinableTimeInWeek(
  TaskID      BIGINT        REFERENCES Task(TaskID),
  DayOfWeek   SMALLINT,
  CreatedTS   TIMESTAMPTZ   DEFAULT NOW(),
  UpdatedTS   TIMESTAMPTZ,
  PRIMARY KEY (TaskID, DayOfWeek)
);

CREATE TABLE Place(
  PlaceID     BIGSERIAL     PRIMARY KEY,
  Name        TEXT,
  CreatedTS   TIMESTAMPTZ   DEFAULT NOW(),
  UpdatedTS   TIMESTAMPTZ
);

CREATE TABLE ActionablePlace(
  TaskID      BIGINT        REFERENCES Task(TaskID),
  PlaceID     BIGSERIAL,
  CreatedTS   TIMESTAMPTZ   DEFAULT NOW(),
  UpdatedTS   TIMESTAMPTZ,
  PRIMARY KEY (TaskID, PlaceID)
);

CREATE TABLE Alert (
  AlertID     BIGSERIAL     PRIMARY KEY,
  Name        TEXT,
  CreatedTS   TIMESTAMPTZ   DEFAULT NOW(),
  UpdatedTS   TIMESTAMPTZ
);
*/
COMMIT;
