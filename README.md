# zadanie4-po14-balazia-z4-hrnciar-vidiecan
zadanie4-po14-balazia-z4-hrnciar-vidiecan created by GitHub Classroom

# SQL Model

Chat:

```json
{
	"users": [
		{
			"id": 108383,
			"name": "playerA"
		},
		{
			"id": 145389,
			"name": "playerB"
		},
	],
	"log": [
		{
			"timestamp": "2021-04-07 22:28:11+00:00",
			"from": "playerA",
			"content": "Hey man! How you doing?"
		},
		{
			"timestamp": "2021-04-07 22:28:17+00:00",
			"from": "playerB",
			"content": "I'm good! How about u?"
		},
	]
}
```

```sql
UPDATE chat SET log = jsonb_set(
  log::jsonb,
  array['log'],
  (log->'log')::jsonb || '{"timestamp": "2021-04-07 23:06:21+00.00", 
  "from": "playerA", 
  "content": "New message"}'::jsonb)
WHERE id = 1;
```
