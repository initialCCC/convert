# Convert

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

## API Documentation

A sample python client is provided for testing

    python3 sample_client.py video_name.webm
   
# To get the status of a video


* **Request:**
 
  `GET  /:job_id`
   
* **URL Params:**

   **Required:**
   
 	`job_id=[alphanumerical]`


# To upload a video

* **Request:**
 
  `POST  /`
   
* **Form data:**
 
   **Required:**
   
 	`video=webm video`



## TODO
Add authentication
