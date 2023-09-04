# 1. FIRST - follow instructions here:
# https://gmailr.r-lib.org/dev/articles/oauth-client.html

# 2. run once, after which RStudio should automatically authenticate
library(gmailr)
gm_auth_configure()
gm_oauth_client()
gm_auth()

# your email
email <- "_____@gmail.com"

# test
msg_text <- "test"
msg <- gm_mime() |>
  gm_to(email) |>  # this email will be sent both to and from your email, but able to customize
  gm_from(email) |>
  gm_subject("Global Entry appointment available!") |>
  gm_text_body(as.character(msg_text))
gm_send_message(msg)

