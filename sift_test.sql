
BEGIN;

SET search_path = 'sift';

SELECT AddTask1Stop(
  'testing1',           -- TaskName
  GetAnyFutureDate(),   -- Deadline
  '4 hour'::INTERVAL,   -- Duration
  'home',               -- Place
  'SMS'                 -- Alert
);

SELECT AddTask1Stop('testing2', GetAnyFutureDate(), GetRandomInterval(), 'office',  NULL);
SELECT AddTask1Stop('testing3', GetAnyFutureDate(), GetRandomInterval(), 'office',  NULL);
SELECT AddTask1Stop('testing4', GetAnyFutureDate(), GetRandomInterval(), 'home',    NULL);

SELECT * FROM GetPrioritizedTaskList(GetPlaceID('home'));
SELECT * FROM GetPrioritizedTaskList(GetPlaceID('office'));

COMMIT;
