
BEGIN;

SET search_path = 'sift';

SELECT AddTask('testing1');

SELECT AddTaskDeadline(
  GetRandomTaskID(),
  GetRandomInterval(),
  GetRandomAlertID()
);

COMMIT;
