from google.cloud import storage

def delete_blob(bucket_name, blob_name):
    client = storage.Client()

    bucket = client.bucket(bucket_name)

    blob = bucket.blob(blob_name)

    blob.delete()

    print(f"Object '{blob_name}' deleted successfully!")

delete_blob(
    "gcp-aiml-storage-001",
    "documents/sample_content.txt"
)