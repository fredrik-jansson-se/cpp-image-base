#include <iostream>

#include <openssl/opensslv.h>
#include <openssl/crypto.h>
#include <openssl/ssl.h>

#include <nlohmann/json.hpp>

int main() {

  std::cout << "Test started\n";

  std::cout << "OpenSSL version: " << OPENSSL_VERSION_STR << '\n';
  OPENSSL_init_ssl(0, nullptr);
  OPENSSL_init_crypto(0, nullptr);

  std::cout << "JSON: " << nlohmann::json::meta() << '\n';
  return 0;
}
