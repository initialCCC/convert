import requests, json, random, string, sys, time

SCRIPT_NAME, VIDEO_PATH = sys.argv

URL="http://localhost:4000/"

POLL_DELAY = 5

def handle_upload_status(status):
    if isinstance(status['status'], dict):
        print("job id:", status['status']['job_id'])
        return status['status']['job_id']
    else:
        print(status)
        sys.exit(1)

def rand_filename():
  return ''.join(i for i in random.choices(string.ascii_letters, k = 8)) + '.mp4'

def get_random_file():
  filename = rand_filename()
  while True:
    try:
      opened = open(filename, 'x')
      opened.close()
      return open(filename, 'wb')
    except:
      continue

def check_status(job_id):
    result = requests.get(URL + job_id)
    if result.headers["content-type"] == "video/mp4":
        return result.content
    if json.loads(result.text)['status'] == "file still converting":
        return 0
    return 1

def upload_vid():
    upload_response = requests.post(URL, files = {"video": ("video.webm", open(VIDEO_PATH, "rb"), "video/webm")})
    status = json.loads(upload_response.text)
    job_id = handle_upload_status(status)

    result = check_status(job_id)
    while True:
        if result == 1:
            print("File not found on the system")
            break
        elif result == 0:
            print("File still converting")
            time.sleep(POLL_DELAY)
            result = check_status(job_id)
        else:
            video_file = get_random_file()
            print("Video was converted successfully:", video_file.name)
            video_file.write(result)
            video_file.close()
            break

if __name__ == '__main__':
    upload_vid()
