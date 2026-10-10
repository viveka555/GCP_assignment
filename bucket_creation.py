from google.cloud import storage

def create_bucket(bucket_name, location="asia-south1"):
    """
    Creates a Google Cloud Storage bucket.
    """

    client = storage.Client()

    bucket = client.bucket(bucket_name)

    bucket.storage_class = "STANDARD"

    bucket = client.create_bucket(
        bucket,
        location=location
    )

    print(f"Bucket '{bucket.name}' created in '{bucket.location}' with storage class'{bucket.storage_class}'")


if __name__ == "__main__":
    create_bucket("vicky-ml-demo-bucket-12345")