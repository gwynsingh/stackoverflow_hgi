# Stackoverflow

This is a single page stackoverflow clone . Head to /questions to search questions from stackoverflow . 
There is also an option to sort using OpenAI LLM. Use will need a working `OPENAI_API_KEY` for the same. 

To start your Phoenix server:

- Run `./setup.sh` to start Postgres (containerized) and set up the project
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
- Head over to `http://localhost:4000/questions` 
- You can either SignUp and create a new user account . Or you can use the Pre-Seeded account 
- Account Details: 
    - Email: `johndoe@example.com`
    - Passowrd: `password`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Environment Variables

- Refer `.env.sample` for the required environment variables.
- A working `OPENAI_API_KEY` is needed for accessing the AI sort functionality. 
- If you want to use Postgres as a containerized service, use port 5433. Otherwise, use port 5432.


### TODO
- Add Logout . 
- Display 'Hi , ${user_name}' at top right. 
- Add pagination
- Test Cases
- Update Login/Signup page
    - Add stackoverflow UI
    - SSO Signin Options via Google/Github