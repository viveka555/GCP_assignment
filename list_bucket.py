from google.cloud import storage

client = storage.Client()

for bucket in client.list_buckets():
    print(f"Bucket Name : {bucket.name}")
    print(f"Location    : {bucket.location}")
    print(f"Storage     : {bucket.storage_class}")
    print("-" * 40)