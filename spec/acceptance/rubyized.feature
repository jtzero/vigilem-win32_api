Feature: Provide a simple win 32 api for the dev
  
  Scenario: get events from api
    # this is badly formed @see the step for the reason why
    Given read_console_input called before user presses a key
     Then a PINPUT_RECORD is returned