# Bill Keeper - iOS

Bill Keeper is a medical bill management tool that integrates a web-app 💻 and an iOS app 📱 allowing users to scan, organize, and track medical bills and insurance claims.

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

## The project

The project has been built using:

* [Angular 20](https://angular.dev/) with TypeScript 5.8.3 for the frontend ([Frontend repository](https://github.com/maximehutinet/BillKeeper-Front))
* [Spring Boot 3.5.3](https://spring.io/projects/spring-boot) with Java 21 for the backend ([Backend repository](https://github.com/maximehutinet/BillKeeper-Backend))
* [Swift and SwiftUI](https://developer.apple.com/swiftui/) for the iOS app
* [Keycloak](https://www.keycloak.org/) for the authentication