const appConfig = (
  server: (
    host: "rzssh1.informatik.uni-hamburg.de",
    port: 22,
  ),
  about: (
    name: "printikum",
    version: "0.2.4",
    buildNumber: 4,
    author: "Robin Naumann",
    homepage: "https://apps.robbb.in/printikum",
    source: "https://github.com/RobinNaumann/printikum",
  ),
  dataSources: (
    printers: 'https://linuxprint.informatik.uni-hamburg.de/allQueues.shtml',
    userInfo:
        "https://linuxprint.informatik.uni-hamburg.de/jobsPerPrinter.shtml",
  )
);
