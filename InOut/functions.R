#Fuction to add details of a meeting
#i.e. the date and who was the chair and minute taker
add_meeting = function(chair, minute_taker, meeting_date) {
  #Read the data from file
  data = read_rds("log.rds") %>%
    mutate(
      #Update the last_chaired variable with the meeting date for the chair
      last_chaired = ifelse(name == chair, meeting_date, last_chaired),
      #Update count
      times_chaired = ifelse(name == chair, times_chaired + 1, times_chaired),
      #Update minute taker variables in the same way
      last_minuted = ifelse(name == minute_taker, meeting_date, last_minuted),
      times_minuted = ifelse(name == minute_taker, times_minuted + 1, times_minuted)
    ) %>%
    #Write the data back to file
    write_rds("log.rds")
  #return the data for immediate use
  return(data)
}

#Function to 'farily' pick a chair and minute taker
pick_team = function() {
  #Read the data from file
  data <- read_rds("log.rds") %>%
    #Exclude the previous meeting's chair and minuter from selection
    filter((last_chaired != max(last_chaired) |
              is.na(last_chaired)) &
             (last_minuted != max(last_minuted) |
                is.na(last_minuted)))
  
  #Pick a new chair
  pick_chair <- data %>%
    #Limit the selection to those who have chaired least
    filter(times_chaired == min(times_chaired)) %>%
    #Limit again to the person(s) who chaired the longest ago
    filter(last_chaired == min(last_chaired) |
             is.na(last_chaired)) %>%
    #If we have more than 1 person left, randomly sample
    sample_n(1)
  
  #Pick a new minute taker
  pick_minuter <- data %>%
    #Logic is the same as for picking a chair
    #We also make sure that we can't pick the same person for both
    filter(name != pick_chair$name) %>%
    filter(times_minuted == min(times_minuted)) %>%
    filter(last_minuted == min(last_minuted) |
             is.na(last_chaired)) %>%
    sample_n(1)
  
  #Return a one row tibble
  return(tibble(chair = pick_chair$name, minute_taker = pick_minuter$name))
}
