# Agency.sh

`agency.sh` is a Bash script designed to monitor the availability of a web server specified by a URL. It continuously pings the server and takes specific actions based on the server's response or lack thereof. This script includes a function `make_curl_request` which sends HTTP requests to the provided URL and checks the response status code to determine if the server is online.

## Prerequisites

- **Bash**: The script is written in Bash and requires a Bash shell environment to run.
- **cURL**: The script uses cURL to send HTTP requests. Ensure cURL is installed on your system.

## Customization on '_agency.sh'
- URL: Modify the URL variable in the script to specify the web server you want to monitor.
- Timeout Threshold: Adjust the TIMEOUT_THRESHOLD variable to set the maximum response time in seconds for the HTTP request.
- Fail Count Threshold: Change the CONST_FAIL_TIME_THRESHOLD variable to set the number of consecutive failed requests before taking action.
- Action Script: Set the ACTION_SCRIPT variable to the path of the script you want to execute when the fail count threshold is reached.

## Usage

### 1. Running `agency.sh`

```bash
./agency.sh
> Usage: [kill|start|status]
```
When executed without any arguments, agency.sh continuously pings the specified URL and logs the results in the agency.log file. The script uses the make_curl_request function to check the server's response.'

### 2. Killing the Monitoring Process

```bash
./agency.sh kill
```
To stop the monitoring process, use the kill command. It reads the PID from the PID.txt file and terminates the script execution.

### 3. Starting the Monitoring Process

```bash
./agency.sh start
```
To start the monitoring process, use the start command. It initiates the monitoring script in the background and logs the process ID in the PID.txt file.

### 4. Checking the Status of the Monitoring Process

```bash
./agency.sh status
```
To check the status of the monitoring process, use the status command. It reads the PID from the PID.txt file and verifies if the process is running. It will report if the process is running or if it has stopped.

### Logging
The script logs its activities in the agency.log file. It records the timestamp, request status, response time, and any errors encountered during execution.

### License
This script is released under the MIT License. Feel free to use, modify, and distribute it according to the terms of this license.
