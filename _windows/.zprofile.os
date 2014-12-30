[[ -e /etc/profile ]] && emulate bash -c "source /etc/profile"

for FILE_PATH in /{c,d}/!; do
  touch "${FILE_PATH}"
  chmod 444 "${FILE_PATH}"
done
