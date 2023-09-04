# Scope: Searches for global entry appointment dates that are sooner than existing appointment and sends email if so
# note: I recommend using cron_rstudioaddin() to schedule this every minute
#
# packages ----------------------------------------------------------------

suppressPackageStartupMessages(library(httr))
suppressPackageStartupMessages(library(rvest))
suppressPackageStartupMessages(library(jsonlite))
suppressPackageStartupMessages(library(purrr))
suppressPackageStartupMessages(library(gmailr))

# to run automatically
suppressPackageStartupMessages(library(cronR))

# function ----------------------------------------------------------------

get_appointments <- function(location_id) {

  ge_api_url <- as.character(
    glue::glue("https://ttp.cbp.dhs.gov/schedulerapi/slots?orderBy=soonest&limit=3&locationId={location_id}&minimum=1")
  )

  response <- GET(ge_api_url)

  contents <- content(response)

  appointments <- contents |>
    map_chr("startTimestamp") |>
    lubridate::ymd_hm()

  appointments

}

send_email <- function(appointments,
                       current_appointment_date_time,
                       email) {

  desired_appointments <- appointments[appointments < current_appointment_date_time]
  ind_send <- any(appointments < current_appointment_date_time)

  if(ind_send) {

    msg_text <- glue::glue(
      "
      Good news! New Global Entry appointment(s) available on the following date(s):

      {desired_appointments}

      If you want to claim one, please sign in to https://ttp.cbp.dhs.gov/ ASAP to reschedule.
      "
    )

    msg <- gm_mime() |>
      gm_to(email) |>
      gm_from(email) |>
      gm_subject("Global Entry appointment available!") |>
      gm_text_body(as.character(msg_text))

    mail_status <- gm_send_message(msg)

  } else {

    mail_status <- "unsent"

  }

  glue::glue("
             Mail: {mail_status}.
             Appointment(s): {ifelse(ind_send, desired_appointments, 'none.')}
             ")

}

# To run this script automatically:
# 1. Run cronR::cron_rstudioaddin() and select this script from the menu + the frequency with which you want the script to run (I recommend every minute - the appointments go quickly!)
# 2. If you want this to run while your computer (Mac) is asleep, open Terminal and run the command "caffeinate" - this will keep your computer awake to run the cron job
# 3. Wait for a Gmail message notifying you of new appointments, and log in ASAP when you get one!

location_id <- 6480  # Bowling Green NYC - replace this with your own
current_appointment_date_time <- lubridate::ymd_hm("2023-01-01 12:00")  # replace this datetime with the latest appointment you want or the current appointment you have and are trying to replace
email <- "_____@gmail.com"  # gmail account from AND to which you want the notification sent

# this will run as part of a cron job (can also run this ad hoc)
get_appointments(location_id = location_id) |>
  send_email(
    current_appointment_date_time = current_appointment_date_time,
    email = email
  )
