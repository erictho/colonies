# Studio Management

This Rails project aims to help Colonies' clients to manage their studios and stays.

## Table of Contents

- [Installation](#installation)
- [Usage - API Contracts](#usage---api-contracts)
- [Database Modeling](#database-modeling)
- [Testing](#testing)
- [Screenshots](#screenshots)
- [Improvements](#improvements)

## Installation

### Prerequisites

- Ruby (version 3.3.0)
- Rails (version 7.2.1)

1. **Clone the repository:**

```
git clone https://github.com/erictho/colonies
cd colonies
```

2. **Install dependencies:**

```
bundle
```

3. **Setup the database:**
```
rails db:setup
```
or
```
rails db:migrate
rails db:seed
```

4. **Start the Rails server:**
```
bundle exec rails server
```

## Usage - API Contracts 

### Fetch All Absences per Studio

**Endpoint:**
```
GET /api/v1/absences
```

**Description:**

Retrieve a list of absences associated with a specific studio. 
This endpoint allows clients to get details about scheduled absences for better management and planning.


**Response:**

**200 OK**
```
{
    "studio1": [
        {
            "start_date": "2024-01-09",
            "end_date": "2024-01-15"
        },
        {
            "start_date": "2024-01-25",
            "end_date": null
        }
    ],
    "studio2": [
        {
            "start_date": "2024-01-01",
            "end_date": null
        }
    ]
}
```

### Update a Studio's stay with Absences

**Endpoint:**
```
POST /api/v1/studios/:studio_id/stays
```

**Description:**

Update the stays for a specific studio based on the provided absences information.

**Request Body:**
```
{
    "absences": [
        {"start_date": "2024-03-03", "end_date": "2024-03-15"}, 
        {"start_date": "2024-03-25", "end_date": "2024-04-06"}
    ]   
}
```


**Path Parameters:**

`studio_id` (required): The unique identifier for the studio being updated

**Response:**

**200 OK**

```
[
    {
        "id": 140,
        "start_date": "2024-02-02",
        "end_date": "2024-02-13",
        "studio_id": 71,
        "created_at": "2024-10-09T21:46:15.602Z",
        "updated_at": "2024-10-09T21:46:15.602Z"
    },
    {
        "id": 142,
        "start_date": "2024-04-15",
        "end_date": null,
        "studio_id": 71,
        "created_at": "2024-10-09T21:46:15.626Z",
        "updated_at": "2024-10-09T21:46:15.626Z"
    }
]
```

**422 Bad Request**

Invalid Date Format
```
{
    "errors": {
        "absences": {
            "1": {
                "start_date": [
                    "must be a date"
                ]
            }
        }
    }
}
```

Missing Date
```
{
    "errors": {
        "absences": {
            "1": {
                "end_date": [
                    "is missing"
                ]
            }
        }
    }
}
```

Invalid Date Range
```
{
    "errors": {
        "absences": {
            "1": [
                "end_date must be greater than start_date"
            ]
        }
    }
}
```

**422 Not Found** (to change to code 404)

```
{
    "errors": "resource_not_found"
}
```


## Database Modeling

![dbdiagram.png](public%2Fdbdiagram.png)

## Testing

### Running Tests
This project uses Rspec for testing. To run the tests, use the following command:
```
bundle exec rspec
```

### Code Coverage

![coverage.png](public%2Fcoverage.png)

## Screenshots

### Absences
![absences.png](public%2Fabsences.png)

### Update Studio stays with Absences

![error1.png](public%2Ferror1.png)
![error2.png](public%2Ferror2.png)
![error3.png](public%2Ferror3.png)
![update_stays.png](public%2Fupdate_stays.png)

## Edge Cases

### Absences

- studio overlapping the opening date (01/01/2024)
- studio not overlapping the opening date (01/01/2024)
- studio without any stay
- studio with an indefinite stay (no end date)

### Update Studio stays with Absences

Notable Edge Cases are related to overlapping between stays and absences/
- An absence covering totally a stay
- One or several absences covering partially a stay
  * Case 2A: absence covering the stay start date
  * Case 2B: absence covering the stay end date
- One or several absences totally covered by a stay
- An absence covering/crossing several stays

## Validations

There are different levels of validation:
- API endpoint
- Controller with strong parameters
- Extended validation of the JSON payload submitted by the client (with dry-schema)
- Database constraints

Further validations can be extended for the JSON payload such as ensuring there are no duplicate or overlapping absences.

## Improvements

- Implement a unique constraint on studio names
- Performance: As the product grows, adding pagination can be considered to enhance performance and user experience
- Implement comprehensive validation for the JSON payload submitted by the client
- Manage validation errors using I18n locales instead of exposing technical errors
- Improve data serialization in responses to ensure proper REST compliance
- Prevent the exposure of internal IDs to the public

