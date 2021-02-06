# Workshop OOP 2021
# 

demo project: https://github.com/cy4n/broken

---

## dependency-check (scan java dependency)  

1. download a local dependency-check vulnerability database 
2. find the vulnerable dependencies in the current project and check the html report
3. get rid of struts, you don't need it anyway, check for vulnerabilities after
4. find the packages that brings snakeyaml as transitive dependency and update it to the next release
5. find out what's wrong with log4j-api
6. Spring Security looks scary, score "High 8.8", what is wrong? 
7. what about snakeyaml? 


---

## trivy (container image scanning)

1. install trivy https://github.com/aquasecurity/trivy#installation
2. download a vulnerability database
3. scan the image cy4n/broken:springboot2.1.8-jre11
4. whitelist the CVE-2005-2541 in .trivyignore
5. scan the image cy4n/broken:alpine
6. scan the image from 3.) but only for HIGH severity
7. play around with --exit-code on findings

<details><summary>Alternative: Quay Clair (formerly CoreOS)</summary>
<p>

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

</p>
</details>

---
## OWASP ZAP (API scanning) 

run the zap demo app from https://github.com/cy4n/owaspzapdemo and run it:
```bash
./mvnw spring-boot:run
```

1. scan the app with zaproxy:

```bash
docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-weekly zap-api-scan.py -a -t http://host.docker.internal:8080/v2/api-docs -f openapi
```

2. generate default configuration
3. ignore finding for "X-Content-Type-Options Header Missing" and scan again

## homework 

- try the tools on your own apps or api (if you dare!?)
