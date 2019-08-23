# Workshop CCCamp19
# Security Testing

demo project: https://github.com/cy4n/broken with fun dependencies

---

## dependency-check

* find the vulnerable dependencies

```bash
./mvnw dependency-check:check
```

* upgrade the dependency if possible
* whitelist / suppress the vulnerability

(hint: check the maven goal for dependency-check)

---

## clair container scanning
### get the clair-scanner binary:

download clair-scanner for your OS: https://github.com/arminc/clair-scanner/releases and make it executable

### setup clair and its database:
```bash
docker run -p 5432:5432 -d --name db arminc/clair-db
docker run -p 6060:6060 --link db:postgres -d --name clair arminc/clair-local-scan
```

run the actual scan
```bash
./clair-scanner_darwin_amd64 -c http://$(ipconfig getifaddr en0):6060 --ip $(ipconfig getifaddr en0) -r clair-report.json -l clair.log -w clair-whitelist.yml cy4n/broken:latest
```

* find out about vulnerable packages
* try to set the criticality threshold ( ./clair-scanner --help )
* try to approve a CVE via whitelist

* try to scan the image "cy4n/broken:alpine", what happens, what are the implications?

---
## WEB API scanning with ZAProxy

run the vulnerable app via docker run or maven/java

* scan the app with zaproxy:

```bash
docker run -t owasp/zap2docker-weekly zap-baseline.py -t http://$(ipconfig getifaddr en0):8080
```

* scan your own (company) website :-)
