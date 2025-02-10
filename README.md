# Breezyship Boilerplate

## About

- A docker compose boilerplate to setup infrastructure for Breezyship System.

## Setup

1. In project root, copy **.env-example** to **.env** and **docker-compose-example.yml** to **docker-compose.yml**.
2. In **./source** folder, clone all services needed to develop along with **bsCommonLibrary**.
3. In each cloned service, copy and paste **.env-example** to **.env** to ensure all services work without any issue.
4. In project root run **`./breezyship help`** or **`bash breezyship help`** command to check all available commands.
5. If this is your first time setting up the project, running **`./breezyship up --fresh`** is recommended.

![Commands example.](/images/commands.png "This is a sample command.")
