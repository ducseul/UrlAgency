#!/bin/bash
# Start by command "nohup ./agency.sh >> agency.log 2>&1 & echo $! > PID.txt"
URL="http://localhost:8088/sleepy/time?time=10000"
ACTION_SCRIPT="/home/app/8088_tomcat/bin/restart.sh"
LOG_FILE_DIR="agency.log"

TIMEOUT_THRESHOLD=15
CONST_INTERVAL_SLEEP=60
INTERVAL_SLEEP=60 # Mỗi lần check thì nghỉ 60s
CONST_FAIL_TIME_THRESHOLD=3 # Nếu ping lỗi FAIL_TIME_THRESHOLD lần thì mới can thiệp restart

function get_timestamp {
    echo "$(date +'%d/%m/%Y %H:%M:%S')"
}

function make_curl_request {
    local http_status=$(curl -o /dev/null -s -w '%{http_code}\n' -m "$TIMEOUT_THRESHOLD" "$URL")
    if [[ "$http_status" =~ ^2[0-9][0-9]$ ]]; then
        return 0  # Successful response
    else
        echo "HTTP Status Code: $http_status"
        return 1  # Error response
    fi
}

FAIL_COUNT=0


echo -e "\n-------------------------------------------"
echo "Start script on $(get_timestamp)"

#Check ACTION_SCRIPT exist and executable
# Check ACTION_SCRIPT exist and executable
if [ ! -x "$ACTION_SCRIPT" ]; then
    echo "Action script is NOT exist or executable. Script exiting!" >> "$LOG_FILE_DIR"
    exit 1
fi
	
#Start script
while true; do
    echo "$(get_timestamp) : Start to ping" >> "$LOG_FILE_DIR"
	

    if make_curl_request; then
        RESPONSE_TIME=$(curl -o /dev/null -s -w '%{time_total}\n' "$URL")
        echo "$(get_timestamp) : Request successful. Response time: $RESPONSE_TIME seconds" >> "$LOG_FILE_DIR"
        FAIL_COUNT=0
        INTERVAL_SLEEP=60
    else #Gặp lỗi
        ((FAIL_COUNT++)) #Tăng FAIL_COUNT lên 1 đơn vị
		INTERVAL_SLEEP=30
        echo "$(get_timestamp) : Error: Request failed or timed out. Timeout threshold $TIMEOUT_THRESHOLD seconds exceeded." >> "$LOG_FILE_DIR"
        echo "Fail $FAIL_COUNT times, action intervention after $CONST_FAIL_TIME_THRESHOLD time." >> "$LOG_FILE_DIR"
        if [ "$FAIL_COUNT" -ge "$CONST_FAIL_TIME_THRESHOLD" ]; then
            # Chạy action script khi lỗi đủ số lần đã cấu hình
            echo "$(get_timestamp) : Executing action script: $ACTION_SCRIPT" >> "$LOG_FILE_DIR"
            "$ACTION_SCRIPT" # Start ACTION_SCRIPT

            INTERVAL_SLEEP=10 # Wait until the script is done, trying to ping it for each 10s
            while true; do
                if make_curl_request; then
                    RESPONSE_TIME=$(curl -o /dev/null -s -w '%{time_total}\n' "$URL")
                    echo "$(get_timestamp) : Server is online. Response time: $RESPONSE_TIME seconds" >> "$LOG_FILE_DIR"
                    INTERVAL_SLEEP=$CONST_INTERVAL_SLEEP
                    FAIL_COUNT=0
                    break
                else
                    echo "$(get_timestamp) : >> Waiting for server to respond!" >> "$LOG_FILE_DIR"
                fi
                sleep $INTERVAL_SLEEP
            done
        fi
    fi
    
    echo "$(get_timestamp): Sleep for $INTERVAL_SLEEP seconds." >> "$LOG_FILE_DIR"
    # Wait for INTERVAL_SLEEP seconds before making the next request
    sleep $INTERVAL_SLEEP
done