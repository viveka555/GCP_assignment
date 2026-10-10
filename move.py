from google.cloud import storage

def move_blob(bucket_name, source_blob_name, destination_blob_name):
    client = storage.Client()

    bucket = client.bucket(bucket_name)

    source_blob = bucket.blob(source_blob_name)

    # Copy object
    bucket.copy_blob(
        source_blob,
        bucket,
        destination_blob_name
    )

    # Delete original
    source_blob.delete()

    print("Object moved successfully!")

move_blob(
    "your-bucket-name",
    "sample_content.txt",
    "archive/sample_content.txt"
)