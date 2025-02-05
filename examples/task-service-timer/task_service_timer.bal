import ballerina/log;
import ballerina/task;

// The Task Timer configuration record to configure the Task Listener.
task:TimerConfiguration timerConfiguration = {
    intervalInMillis: 1000,
    initialDelay: 3000,
    // Number of recurrences will limit the number of times the timer runs.
    noOfRecurrences: 10
};

// Initialize the listener using pre defined configurations.
listener task:Listener timer = new(timerConfiguration);

int count = 0;

// Creating a service on the task Listener.
service timerService on timer {
    // This resource triggers when the timer goes off.
    resource function onTrigger() {
        count = count + 1;
        log:printInfo("Cleaning up...");
        log:printInfo(string.convert(count));
    }
}
