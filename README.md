# Papa

This is a simple application base built using Phoenix and Elixir to handle the based on the following requirements:

In order to simplify our system and give you an opportunity to show various skills, we're going to change the
rules of our system a bit. Build a "Home Visit Service" application with the following core functionality:

- Users must be able to create an account (but authn/authz are out of scope for this exercise). They can perform either or both of two roles: a member (who requests visits) and a pal (who fulfills visits).
- As a member, a user can request visits.
- When a user fulfills a visit, the minutes of the visit's duration are debited from the visit requester's account and credited to the pal's account, minus a 15% overhead fee.
- If a member's account has a balance of 0 minutes, they cannot request any more visits until they fulfill visits themselves.

This application only needs a programmatic API–ideally.

## Actual Functionality
The above requirements are simple, yet leave multiple aspects open to implementation.  I've listed out decisions made.

    The use of 3 schemas is not needed for such a simple use case.  
    I originally thought of using them with the assumption that we will need to extend the functionality in the future.  
    However, I've decided to keep it simple and use only 2 schemas: `users` and `visits`.

    There is a scenario that isn't fully addressed in the requirements, which allows a member to request many vists before they occur.  
    Allowing a member to have a negative balance of minutes and still receive visits.
    I handled this scenario by making the user define the length of the visit when they request it and decrementing the members minutes at that time.

    I used pheonix to help with building out the application.  There's plenty of crud and glue code that you get for free when using pheonix.

## Running the application

Since we are focused solely on the API, we can run the application using iex and perform various operations.

    clone repo
    mix deps.get
    iex -S mix 

    # Create users
    {:ok, john} = Papa.Accounts.create_user(%{first_name: "John", last_name: "Doe", email: "john.doe@example.com", minutes: 100, is_member: true, is_pal: false})
    {:ok, jane} = Papa.Accounts.create_user(%{first_name: "Jane", last_name: "Doe", email: "jane.doe@example.com", minutes: 0, is_member: false, is_pal: true})
    {:ok, erik} = Papa.Accounts.create_user(%{first_name: "Erik", last_name: "Doe", email: "erik.doe@example.com", minutes: 100, is_member: true, is_pal: true})

    # Create Visits
    {:ok, johns_request} = Papa.Visits.request_visit(john.id, Date.add(Date.utc_today(), 1), 100)
    {:ok, eriks_request} = Papa.Visits.request_visit(erik.id, Date.add(Date.utc_today(), 1), 100)
    {:error, :member_not_enough_minutes} = Papa.Visits.request_visit(erik.id, Date.add(Date.utc_today(), 1), 100)

    # Fulfill Visits
    {:ok, %{status: "completed"} = fullfilled_visit} = Papa.Visits.fulfill_visit(eriks_request.id, jane.id)
    {:error, :visit_not_pending} = Papa.Visits.fulfill_visit(eriks_request.id, jane.id)
    {:ok, %{minutes: 85} = jane} = Papa.Accounts.get_pal(jane.id)

    # Cancel Visits
    {:error, :member_not_enough_minutes} = Papa.Visits.request_visit(john.id, Date.add(Date.utc_today(), 1), 100)
    {:ok, %{status: "cancelled"} = cancelled_visit} = Papa.Visits.cancel_visit(johns_request.id)
    {:ok, johns_request} = Papa.Visits.request_visit(john.id, Date.add(Date.utc_today(), 1), 100)



## Running tests

    mix test

