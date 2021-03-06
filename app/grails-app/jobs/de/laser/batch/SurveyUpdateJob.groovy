package de.laser.batch

import de.laser.SystemEvent
import de.laser.quartz.AbstractJob


class SurveyUpdateJob extends AbstractJob {

    def surveyUpdateService

    static triggers = {
        cron name:'SurveyUpdateJobTrigger', cronExpression: "0 0 23 * * ?" //Fire at 23:00 every day
    }

    static configFlags = []

    boolean isAvailable() {
        !jobIsRunning && !surveyUpdateService.running
    }
    boolean isRunning() {
        jobIsRunning
    }

    def execute() {
        if (! isAvailable()) {
            return false
        }
        jobIsRunning = true

        try {
            log.info("Execute::SurveyUpdateJob - Start")
            SystemEvent.createEvent('SURVEY_UPDATE_JOB_START')

            if (! surveyUpdateService.surveyCheck()) {
                log.warn('Failed. Maybe ignored due blocked surveyUpdateService')
            }

            log.info("Execute::SurveyUpdateJob - Finished")
            SystemEvent.createEvent('SURVEY_UPDATE_JOB_COMPLETE')
        }
        catch (Exception e) {
            log.error(e)
        }

        jobIsRunning = false
    }
}
