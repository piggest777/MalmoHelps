//
//  Constants.swift
//  MalmoHelps
//
//  Created by Denis Rakitin on 2022-08-26.
//

import Foundation
import Firebase


let REF_FAMILIES = "families"
let CATEGORIES = "categories"
let REF_DISTRIBUTED = "distributed_categories"

let PLACE = "place"
let ROOM = "room"
let FIRST_NAME = "first_name"
let LAST_NAME = "second_name"
let FAMILY_SIZE = "family_size"
let NOTES = "notes"
let KEYWORDS = "keywords"
let ADDING_DATE = "adding_date"

let CATEGORY = "category"
let DISTRIBUTION_DATE = "distribution_date"
let DURATION = "duration"
let EXPIRED_DATE = "expired_date"

let CATEGORY_NAME = "name"

//Person constants
let PERSON_COLLECTION = "persons"
let PERSONAL_NUMBER = "personal_number"
let PHONE_NUMBER = "phone"
let START_DATE = "start_date"
let FINISH_DATE = "finish_date"
let CUSTOM_QR_CODE = "custom_qr_code"

//ActivityEntries
let ACTIVITY_NAME = "activity_name"
let VENUE = "venue"
let PERSON_IN_CHARGE = "person_in_charge"
let ACTIVITY_COLLECTION = "activities"
let DEFAULT_DURATION = "default_duration"

//ParticipantRegistration
let REGISTRATION_COLLECTION = "participant_registration"
let YEAR = "year"
let MONTH = "month"
let DAY = "day"
let TIMESTAMP = "timestamp"
let PARTICIPANT_ID = "participant_id"
let PARTICIPANT_NAME = "participant_name"

//User Management
let USERS_COLLECTION = "users"
let USER_NAME = "name"
let USER_UID = "user_uid"
let AUTH_STATUS = "auth_status"
let ROLE = "role"
let USER_EMAIL = "email"

//UserStatus
let LOADING = "loading"
let UNDEFINED = "undefined"
let VOLUNTEER = "volunteer"
let TEACHER = "teacher"
let ADMIN = "admin"

let DIST_POINTS = [
    ActivityVenue(venue: "Jägersro"),
    ActivityVenue(venue: "ABF"),
    ActivityVenue(venue: "Bilda"),
    ActivityVenue(venue: "Wesley"),
    ActivityVenue(venue: "St Petri"),
    ActivityVenue(venue: "Out of list")
]

 let ACTIVITIES = [
    ActivityVenue(venue: "Singing"),
    ActivityVenue(venue: "Painting"),
    ActivityVenue(venue: "Dancing")
]

let CURR_POINT = "distribution_point"

let dummyPerson = Person(firstName: "John", lastName: "Doe", startDate: Timestamp(), finishDate: nil, personalNumber: "_", phoneNumber: "_", customQrCode: nil, keywords: [])

let dummyActivity = ActivityEntry(id: "", activityName: "Dancing", venue: "Malmö", personInCharge: "Victoria")





