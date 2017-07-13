
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


WITH haves AS (
  SELECT phraseto_tsquery('english', 'postgres split_words_into_rows') AS cond
), havenots AS (
  SELECT phraseto_tsquery('english', 'aws') AS cond
), x AS (
  SELECT unnest(string_to_array(b, ' ')) token 
  FROM a, haves h, havenots hn
  WHERE phraseto_tsquery('english', b) @> h.cond
    AND NOT phraseto_tsquery('english', b) @> hn.cond
)
SELECT token, COUNT(*) c 
FROM x, haves h
WHERE NOT cond @> phraseto_tsquery('english', token)
GROUP BY token 
ORDER BY c DESC, token ASC ;
