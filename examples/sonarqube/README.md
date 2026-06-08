# Local SonarQube

This example starts a local SonarQube server backed by PostgreSQL for IDE-connected analysis against the EbMS workspace.

## Start

```sh
docker compose up -d
```

Open http://localhost:9000 and sign in with:

- username: `admin`
- password: `admin`

SonarQube will ask you to change the default password on first login.

## Stop

```sh
docker compose down
```

To remove persisted SonarQube and PostgreSQL data as well:

```sh
docker compose down -v
```

## Bind the workspace in SonarQube for IDE

1. Create a local project in SonarQube with the key `nl.clockwork.ebms`.
2. Generate a user token in SonarQube.
3. In VS Code, use SonarQube for IDE connected mode and point it to `http://localhost:9000`.
4. Bind the workspace to the `nl.clockwork.ebms` project.

The repository already contains [sonar-project.properties](/workspaces/ebms/sonar-project.properties), so once the server is running you can also analyze the workspace from the CLI or CI against the same project key.