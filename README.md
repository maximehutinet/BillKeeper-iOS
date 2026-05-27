# Bill Keeper - iOS

Bill Keeper is a medical bill management tool that integrates a [web-app](https://github.com/maximehutinet/BillKeeper) 💻 and an iOS app 📱 allowing users to scan, organize, and track medical bills and insurance claims.

![Sneakpeek](/sneakpeek.gif)

## Main features

* 📷 Scanning bills and sending them automatically to the server (iOS app)
* 📄 Adding documents to bills via the web-app or iOS app
* 📂 Merging documents
* 🔎 Keeping track of bills and their status
* 💬 Collaborating on bills via comments
* 👪 Creating a family and adding members so they can have access to the same bills and submissions
* 🛡️ Creating insurance submission claim and tracking their status
* 📈 Getting stats about the numbers of bills to file, amounts to pay and amounts waiting to be reimbursed

## Getting started

To get a local copy up and running, please follow these simple steps.

### Prerequisites

Make sure you have the following installed before getting started:

- **Java** 21+
- **Docker** & **Docker Compose**
- **XCode**
- **[Cocoapods](https://cocoapods.org/)**

### Setup

#### 1. Clone the Bill Keeper iOS repository

```bash
git clone https://github.com/maximehutinet/BillKeeper-iOS
cd BillKeeper-iOS
```

#### 2. Install the dependencies

```bash
pod install
```

#### 3. Open the project

```bash
open BillKeeper.xcworkspace
```

#### 4. Edit the *Info-Dev.plist* file

| Field    | Value                                      |
|----------|--------------------------------------------|
| ServerUrl | `http://<your_ip>:8080`                    |
| KeycloakIssuerUrl | `http://<your_ip>:10491/realms/billkeeper` |

#### 5. Clone the main Bill Keeper repository

```bash
git clone https://github.com/maximehutinet/BillKeeper.git
```

#### 6. Edit the *backend/src/main/resources/application-dev.properties* file

| Field    | Value                                      |
|----------|--------------------------------------------|
| spring.security.oauth2.resourceserver.jwt.issuer-uri | `http://<your_ip>:10491/realms/billkeeper` |

#### 7. Edit the *frontend/src/assets/configuration.json* file

```json
{
  "serverUrl": "http://localhost:8080",
  "keycloakConfiguration": {
    "url": "http://<your_ip>:10491",
    "realm": "billkeeper",
    "clientId": "billkeeper-frontend"
  }
}
```

#### 8. Install frontend dependencies

```bash
npm --prefix frontend/ install
```

#### 9. Start services with Docker Compose

```bash
docker-compose up -d
```

#### 10. Run the frontend and backend

You'll need two bash sessions to run these services:

**Backend:**
```bash
./backend/mvnw spring-boot:run -f backend/pom.xml -Dspring-boot.run.profiles=dev
```

**Frontend:**
```bash
npm --prefix frontend/ run start
```

#### 11. Run the iOS app

Scan a document and create a bill.

#### 5. Open the Bill Keeper admin

Navigate to http://localhost:4200 and log in with the default test user:

| Field    | Value  |
|----------|--------|
| Username | `test` |
| Password | `test` |

You should be able to see the newly created bill.
