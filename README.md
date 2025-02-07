# Print Label Request Handler

WIP (Might be changed)
- Handle incoming requests
- Validate data from incoming requests
- Dispatch signal messages to RabbitMQ to trigger Address Validator Process and Cost + Surcharge Collector Process
- Handle Create Parcel and Print Label processes
- Response data back to frontend

## Source setup
- Copy ***.env-example*** to .env
- Update ***.env*** values based on your own settings
- Might need to run `npm install` to ensure source work correctly
```
