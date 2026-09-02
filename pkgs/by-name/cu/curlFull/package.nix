{
  curl,
  ...
}@args:

curl.override (
  {
    ldapSupport = true;
    gsaslSupport = true;
    websocketSupport = true;
  }
  // removeAttrs args [ "curl" ]
)
