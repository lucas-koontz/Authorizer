# Authorizer

Authorizer is an application that authorizes a transaction for a specific account following a set of predefined rules.


## Table of Contents
- [Authorizer](#authorizer)
  - [Table of Contents](#table-of-contents)
  - [Scenario](#scenario)
    - [Operations](#operations)
    - [Violations](#violations)
  - [Operations](#operations-1)
    - [Account creation](#account-creation)
      - [Transaction authorization](#transaction-authorization)
  - [Requirements](#requirements)
  - [Usage](#usage)
    - [Running without docker](#running-without-docker)
      - [Running with docker](#running-with-docker)
  - [Contributing](#contributing)
  - [License](#license)
  - [Code of Conduct](#code-of-conduct)
## Scenario

The authorizer is going to be provided JSON lines as input in the stdin and should provide a JSON line output for each one — imagine this as a stream of events arriving at the authorizer.


All operations in the stream are transformed into account statements and saved in a history for later usage.

The authorizer utilizes design patterns to provide a maintainable code.

### Operations

The adapter pattern creates a builder to handle each type of operation.

### Violations

Strategy pattern offers a structure to handle multiple violations that can occur in an operation.

## Operations
The program handles two kinds of operations, deciding on which one according to the line that is being processed:
1. Account creation
2. Transaction authorization

For the sake of simplicity, you can assume:
- All monetary values are positive integers using a currency without cents
- Transactions will arrive in chronological order

### Account creation

**Input**

Creates the account with `available-limit` and `active-card` set. For simplicity's sake, we will assume the application will deal with just one account.

**Output**

The created account's current state + all business logic violations.

**Business rules** 
- Once created, the account should not be updated or recreated: `account-already-initialized`.

**Examples**

```bash
input
    {"account": {"active-card": true, "available-limit": 100}}
    ...
    {"account": {"active-card": true, "available-limit": 350}}


output
    {"account": {"active-card": true, "available-limit": 100}, "violations": []}
    ...
    {"account": {"active-card": true, "available-limit": 100}, "violations": ["account-already-initialized" ]}
```


#### Transaction authorization


**Input**

Tries to authorize a transaction for a particular `merchant`, `amount`, and `time` given the account's state and last authorized transactions.

**Output**

The created account's current state + all business logic violations.

**Business rules** 
- No transaction should be accepted without a properly initialized account: `account-not-initialized`
- No transaction should be accepted when the card is not active: `card-not-active`
- The transaction amount should not exceed the available limit: `insufficient-limit`
- There should not be more than 3 transactions on a 2-minute interval: `high-frequency-small-interval`
- There should not be more than 1 similar transaction (same amount and merchant) in a 2 minutes interval: `doubled-transaction`

**Examples**

Given there is an account with `active-card`: true and `available-limit`: 100
```bash
input
    {"transaction": {"merchant": "Burger King", "amount": 20, "time": "2019-02-13T10:00:00.000Z"}}

output
    {"account": {"active-card": true, "available-limit": 80}, "violations": []}
```



## Requirements

- Ruby v2.7.2 

## Usage

To run Authorizer you just need to run:
```bash
$ bin/authorize
```

It will open a prompt and you can provide `JSON` lines. Alternatively, you can input a stream of events from a file.

```bash
$ cat operations
{"account": {"active-card": true, "available-limit": 100}}
{"transaction": {"merchant": "Burger King", "amount": 20, "time": "2019-02-13T10:00:00.000Z"}}
{"transaction": {"merchant": "Habbib's", "amount": 90, "time": "2019-02-13T11:00:00.000Z"}}
```

```bash
$ bin/authorize < operations
```

### Running without docker

Make sure to have installed Ruby v2.7.2 in your console, then run:
```bash
$ bundle install
$ bin/authorize
```


#### Running with docker

```bash
$ docker-compose run authorizer bin/authorize
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/authorizer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/authorizer/blob/master/CODE_OF_CONDUCT.md).

## License

The api is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Authorizer project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/authorizer/blob/master/CODE_OF_CONDUCT.md).
