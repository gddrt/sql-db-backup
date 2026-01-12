# Generate a timestamp, in the format YYYYMMDD-HHMM
TIMESTAMP=`date +"%Y%m%d-%H%M"`
# Random filename suffix
RAND=`cat /proc/sys/kernel/random/uuid`
FILENAME=${TIMESTAMP}-${RAND}.sql.gz

# Read env vars
set -a
. ./.env
set +a

# Connect to remote database and get the dump
mysqldump \
	-h ${DATABASE_HOST} \
	-u ${DATABASE_USER} \
	--password="${DATABASE_PASSWORD}" \
	--single-transaction \
	${DATABASE_NAME} | gzip > ${FILENAME}

# Exit if it fails
if [ $? -ne 0 ]; then
	exit 1
fi;

# Save the dump to the bucket. Flags set acl=private and (e)ncrypt
s3cmd put "${FILENAME}" "s3://${BUCKET_NAME}/db/${FILENAME}" --acl-private -e

# Exit if that fails
if [ $? -ne 0 ]; then
	exit 1
fi;

# Delete the local file after it is saved to the bucket
rm ${FILENAME}
