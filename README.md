# DB Backup
For dumping MySQL/MariaDB databases to a DigitalOcean Spaces bucket.

## Compatibility
The dump script uses the `--single-transaction` flag to create a consistent backup without locking the DB. This only works on InnoDB.

## Warning!
We're using an S3 bucket for storage. If you are not careful, it is possible to expose data in buckets. You **must** ensure **all** of these precautions are taken.
1. Disable publicly listing file contents on the bucket. This should be the default setting. This does not make files private, it only prevents listing them.
2. Save files with a random, unguessable name component. (eg. "20240101-e2cb9d0f252ec0adf2ca4f829b418ab7", not "20240101"). This alone is not secure, just adds another safety layer.
3. Set permission to "Private" on all uploaded files. This ensures only authenticated users can access the file. This is quite secure.
4. Enable encryption and encrypt stored files with a secure encryption key. This ensures that, even in the event a file is compromised, it cannot be read.

## Bucket Setup
1. Make a bucket. Save the name.
2. Ensure "File Listing" is set to Restricted (This should be the default.)
3. Go to API > Spaces Keys and generate an API key. Save the access and secret keys.

## Configuration Setup
1. Create a `.env` file with all the fields shown in the `.env.sample` file.

## Server Setup
1. `apt install s3cmd` to install s3cmd, the command-line tool to interact with s3 buckets
2. `s3cmd --configure` to save the configuration.
    1. Enter the Access key and Secret key
    2. Select region (Maybe default)
    3. Enter the spaces endpoint for the region (eg. nyc3.digitaloceanspaces.com) This is not the name of the bucket.
    4. Enter `%(bucket)s.nyc3.digitaloceanspaces.com` as the template.
3. Set a secure encryption password.
4. Path to GPG program will be the default on linux.
5. HTTPS is required.
6. Can probably leave proxy server blank.
7. Installer will test settings. Test should be successful.
8. Set lifecycle rule on the bucket. `s3cmd setlifecycle lifecycle.xml s3://bucket-name`. The provided lifecycle.xml will delete files starting with "db/" after 90 days.
9. Ensure mysqldump is available (`which mysqldump`). If it is not you will need to install mysql-server.
10. Now that configuration is done, set up a cron job for `backup.sh` to run.

## Performance
It takes about 1 minute per 150MB of database to run. YMMV.