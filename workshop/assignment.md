# Workshop OOP 2021
# 

demo project: https://github.com/cy4n/broken

---

## dependency-check (scan java dependency)  

1. download a local dependency-check vulnerability database 
   <details><summary>solution</summary>
   <p>
        
   ```bash
   ./mvnw dependency-check:update-only
   ```
   
   By default it is saved in your global maven repository 
   (likely `.m2/repository/org/owasp/dependency-check-data/data`)
   </p>     
   </details>
2. find the vulnerable dependencies in the current project and check the html report
   <details><summary>solution</summary>
   <p>

   ```bash
   ./mvnw dependency-check:check
   ```
   open the html report ( ./target/dependency-check-report.html
   </p>     
   </details>
   
3. get rid of struts, you don't need it anyway, check for vulnerabilities after
   <details><summary>solution</summary>
   <p>
   remove the struts dependency from pom.xml, try another dependency-check, watch the results.
   (careful: the html-report will be overwritten, so copy the first one if you would like to compare (or check the dependency-check readme for alternative report path params) 
   </p>     
   </details>
   
4. find the packages that brings snakeyaml as transitive dependency and update it to the next release
   <details><summary>solution</summary>
   <p>
   
   ```bash
   ./mvnw dependency-tree
   ```

   (or use other tooling, most IDEs have a dependecy graph, too)
   </p>     
   </details>
5. find out what's wrong with log4j-api
      <details><summary>solution</summary>
   <p>
   search the cve database (or google) for the CVE-Number found in the dependency-check output for log4j-api
   </p>     
   </details>
6. Spring Security looks scary, score "High 8.8", what is wrong? also try to ignore the dependency in the check 
   <details><summary>solution</summary>
   <p>
   false positive, which has been fixed in 5.0.6, but CVE not updated(see CVE report, additional info at the maintainer website https://tanzu.vmware.com/security/cve-2018-1258 )

   suppress / ignore the Vulnerability:
   
   find the CVE in the html report, copy the xml snippet (next to the CVE you will find a "suppress" button) into ./cve-suppressions.xml file and run :check again 

   </p>     
   </details>
   
7. what about snakeyaml? 
   <details><summary>solution</summary>
   <p>
   just some more report reading and dependency analysis practice :-) 
   </p>     
   </details>

---

## trivy (container image scanning)

trivy has good usage documentation in the readme: https://github.com/aquasecurity/trivy

1. install trivy https://github.com/aquasecurity/trivy#installation
2. download a vulnerability database

   <details><summary>solution</summary>
   <p>

   ```bash
   trivy --download-db-only
   ```

   database file location will differ from operating system. 
   this snippet shows the location:
   
   ```bash
   trivy -h |grep CACHE_DIR
   ```

   </p>     
   </details>   

3. scan the image cy4n/broken:springboot2.1.8-jre11

   <details><summary>solution</summary>
   <p>

   ```bash
   trivy image cy4n/broken:springboot2.1.8-jre11
   ```

   </p>     
   </details>   

4. whitelist the CVE-2005-2541 in .trivyignore

   <details><summary>solution</summary>
   <p>

   create a local .trivyignore file, add CVE-number line by line
      
   ```bash
   ❯ cat .trivyignore
   #ignore TAR vulnerabilty as it is intended behaviour
   CVE-2005-2541
   ```

   Alternative / added practice:
   try using an Open Policy-Agent policy (see readme)

   </p>     
   </details>   

5. scan the image cy4n/broken:alpine and think about the results

   <details><summary>solution</summary>
   <p>

   ```bash
   trivy image cy4n/broken:alpine
   ```

   </p>     
   </details>   
   
6. scan the image from 3.) but only show vulnerability that are at least of HIGH severity


   <details><summary>solution</summary>
   <p>

   ```bash
   trivy image --severity HIGH,CRITICAL cy4n/broken:springboot2.1.8-jre11
   ```

   </p>     
   </details>   


7. play around with --exit-code on findings, especially in regard to your CI/CD solution

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
(defaults to http://localhost:8080)
```bash
./mvnw spring-boot:run 
```

1. scan the app with zaproxy:

```bash
docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-weekly zap-api-scan.py -a -t http://host.docker.internal:8080/v2/api-docs -f openapi
```

2. generate default configuration
   <details><summary>solution</summary>
   <p>

   ```bash
   docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-weekly zap-api-scan.py -a -t http://host.docker.internal:8080/v2/api-docs -f openapi -g generated_config
   ```

   </p>     
   </details>   

3. ignore finding for "X-Content-Type-Options Header Missing" and scan again
   <details><summary>solution</summary>
   <p>

   find the warning for "X-Content-Type-Options Header Missing" and replace "WARN" with "IGNORE" in your `generated_config` (and maybe rename it to `config` since it's no longer generated)

   </p>     
   </details>

4. run zap again with the newly changed config and compare the report

   <details><summary>solution</summary>
   <p>

   ```bash
   docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-weekly zap-api-scan.py -a -t http://host.docker.internal:8080/v2/api-docs -f openapi -c config
   ```

   </p>     
   </details>

## homework 

- try the tools on your own apps or api (if you dare!?)
