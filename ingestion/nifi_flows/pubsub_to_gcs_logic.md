PROCESSOR: ConsumeGCPubSub
  - Subscription: projects/{{project_id}}/subscriptions/intel-ingestion-sub
  - Batch Size: 1000
  
PROCESSOR: PutGCSObject
  - Bucket: {{raw_data_bucket}}
  - Content Type: application/octet-stream
  - Encryption: CMEK (Customer-Managed Encryption Key)
