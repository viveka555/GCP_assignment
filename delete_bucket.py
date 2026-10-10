from google.cloud import storage

def delete_bucket(bucket_name):
    client = storage.Client()

    bucket = client.bucket(bucket_name)

    bucket.delete()

    print(f"Bucket '{bucket_name}' deleted successfully!")


if __name__ == "__main__":
    delete_bucket("gcp-aiml-dummydata")