BEGIN;

SET search_path = 'sift';

DROP FUNCTION IF EXISTS AddTask(TEXT);

DROP FUNCTION IF EXISTS AddDependency (BIGINT);

DROP FUNCTION IF EXISTS AddTaskDuration(BIGINT, INTERVAL);
DROP FUNCTION IF EXISTS GetTaskDuration(BIGINT);

DROP FUNCTION IF EXISTS AddTaskDeadline (BIGINT, INTERVAL, BIGINT);

DROP FUNCTION IF EXISTS AddPlace(TEXT);

DROP FUNCTION IF EXISTS AddTaskActionablePlace(BIGINT, BIGINT);
COMMIT;
