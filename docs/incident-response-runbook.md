# UFOBeep Incident Response Runbook

## Overview

This runbook provides step-by-step procedures for handling various types of incidents in the UFOBeep platform, from minor service disruptions to major security breaches.

## 🚨 Incident Classification

### Severity Levels

**P0 - Critical** 
- Complete platform outage
- Data breach or security compromise
- Legal/regulatory issues
- Mass user safety concerns

**P1 - High**
- Major feature unavailable
- Performance degradation affecting >50% users
- API downtime
- Database connectivity issues

**P2 - Medium**
- Minor feature issues
- Performance issues affecting <50% users
- Third-party integration failures
- Non-critical service degradation

**P3 - Low**
- Cosmetic issues
- Documentation problems
- Minor bugs with workarounds
- Enhancement requests

## 📞 Emergency Contacts

### On-Call Rotation
```
Primary: +1-XXX-XXX-XXXX (Engineering Lead)
Secondary: +1-XXX-XXX-XXXX (DevOps Lead)
Escalation: +1-XXX-XXX-XXXX (CTO)
```

### External Contacts
```
Hosting Provider (DigitalOcean): support@digitalocean.com
CDN Provider (Cloudflare): support@cloudflare.com
Email Service (SendGrid): support@sendgrid.com
Matrix Homeserver: admin@matrix.org
```

### Communication Channels
```
Slack: #ufobeep-incidents
Discord: UFOBeep Emergency
Email: incidents@ufobeep.com
Status Page: https://status.ufobeep.com
```

## 🔄 Incident Response Process

### 1. Detection & Alert
```
🟥 INCIDENT DETECTED
├── Automated monitoring alert
├── User reports
├── Third-party notifications
└── Manual discovery
```

**Actions:**
1. **Acknowledge** the alert within 5 minutes
2. **Assess** severity level (P0-P3)
3. **Create** incident ticket in tracking system
4. **Notify** appropriate on-call personnel
5. **Update** status page if customer-facing

### 2. Initial Response
```
⏱️ INITIAL RESPONSE (Target: 15 minutes for P0/P1)
├── Assemble incident response team
├── Establish communication channel
├── Begin impact assessment
└── Implement immediate containment
```

**Team Roles:**
- **Incident Commander**: Coordinates response, makes decisions
- **Technical Lead**: Investigates root cause, implements fixes
- **Communications Lead**: Updates stakeholders, manages status page
- **Subject Matter Expert**: Provides domain-specific knowledge

### 3. Investigation & Mitigation
```
🔍 INVESTIGATION PHASE
├── Gather logs and metrics
├── Identify root cause
├── Implement temporary fixes
└── Monitor for improvements
```

**Investigation Checklist:**
- [ ] Check system metrics (CPU, memory, disk, network)
- [ ] Review application logs
- [ ] Verify database connectivity
- [ ] Check third-party service status
- [ ] Review recent deployments
- [ ] Analyze error patterns
- [ ] Test user-facing functionality

### 4. Resolution & Recovery
```
✅ RESOLUTION PHASE
├── Implement permanent fix
├── Verify system stability
├── Update documentation
└── Close incident ticket
```

**Recovery Checklist:**
- [ ] Deploy permanent fix
- [ ] Run automated tests
- [ ] Perform manual verification
- [ ] Monitor key metrics for 2 hours
- [ ] Update status page
- [ ] Notify stakeholders of resolution

### 5. Post-Incident Review
```
📊 POST-INCIDENT REVIEW (Within 48 hours)
├── Timeline reconstruction
├── Root cause analysis
├── Action items identification
└── Process improvements
```

## 🛠️ Common Incident Procedures

### API Service Down

**Symptoms:**
- HTTP 5xx errors
- High response times
- Connection timeouts

**Investigation Steps:**
1. Check API server status:
```bash
curl -I https://api.ufobeep.com/health
systemctl status ufobeep-api
```

2. Review API logs:
```bash
tail -f /var/log/ufobeep/api.log
journalctl -u ufobeep-api --since "10 minutes ago"
```

3. Check database connectivity:
```bash
pg_isready -h db.ufobeep.com -p 5432
redis-cli ping
```

4. Verify load balancer health:
```bash
curl -I https://api.ufobeep.com/health
# Check load balancer logs
```

**Mitigation:**
- Restart API services: `sudo systemctl restart ufobeep-api`
- Scale horizontally if traffic spike
- Enable maintenance mode if needed
- Route traffic to backup region

### Database Issues

**Symptoms:**
- Slow query performance
- Connection pool exhaustion
- Data inconsistencies

**Investigation Steps:**
1. Check database metrics:
```sql
SELECT * FROM pg_stat_activity;
SELECT * FROM pg_stat_database;
```

2. Identify slow queries:
```sql
SELECT query, mean_exec_time, calls 
FROM pg_stat_statements 
ORDER BY mean_exec_time DESC LIMIT 10;
```

3. Check disk space:
```bash
df -h
du -sh /var/lib/postgresql/
```

**Mitigation:**
- Kill long-running queries
- Increase connection pool size
- Add database read replicas
- Optimize problematic queries

### High Memory Usage

**Investigation:**
```bash
# Check overall memory usage
free -h
top -o %MEM

# Check container memory usage  
docker stats

# Identify memory-hungry processes
ps aux --sort=-%mem | head -20

# Check for memory leaks
valgrind --tool=memcheck --leak-check=yes ./app
```

**Mitigation:**
- Restart affected services
- Scale up instance size
- Implement memory limits
- Review code for memory leaks

### SSL Certificate Expiration

**Prevention:**
- Monitor certificate expiration dates
- Set up automated renewal with certbot

**If Certificate Expires:**
```bash
# Check certificate status
openssl x509 -in /etc/ssl/certs/ufobeep.com.crt -text -noout

# Renew Let's Encrypt certificate
sudo certbot renew --dry-run
sudo certbot renew

# Restart web services
sudo systemctl reload nginx
```

### DDoS Attack

**Symptoms:**
- Unusual traffic spikes
- High server load
- Legitimate users unable to access site

**Immediate Response:**
1. Enable DDoS protection on Cloudflare
2. Implement rate limiting:
```nginx
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_req zone=api burst=20 nodelay;
```

3. Block malicious IPs:
```bash
# Temporary block
iptables -A INPUT -s <malicious_ip> -j DROP

# Permanent block in Cloudflare dashboard
```

4. Scale infrastructure if needed

### Data Breach Response

**🚨 CRITICAL - P0 INCIDENT**

**Immediate Actions (0-1 hour):**
1. **STOP THE BREACH**
   - Isolate affected systems
   - Revoke compromised credentials
   - Block malicious IP addresses

2. **ASSESS IMPACT**
   - Identify what data was accessed
   - Determine number of users affected
   - Document timeline of events

3. **LEGAL NOTIFICATION**
   - Contact legal counsel immediately
   - Prepare for regulatory notifications (GDPR, CCPA)
   - Document all actions taken

**Containment Checklist:**
- [ ] Isolate compromised systems
- [ ] Reset all admin passwords
- [ ] Revoke API keys and tokens
- [ ] Enable 2FA on all admin accounts
- [ ] Review access logs
- [ ] Patch security vulnerabilities

**User Communication:**
- Draft communication within 2 hours
- Be transparent about impact
- Provide clear next steps
- Offer credit monitoring if PII compromised

### Third-Party Service Failures

**Matrix Homeserver Down:**
```bash
# Check Matrix server status
curl https://matrix.ufobeep.com/_matrix/client/versions

# Switch to backup homeserver
kubectl set env deployment/matrix-service MATRIX_HOMESERVER_URL=https://backup-matrix.ufobeep.com
```

**OpenSky API Unavailable:**
```bash
# Check OpenSky status
curl https://opensky-network.org/api/states/all

# Enable cached data mode
redis-cli set opensky:cache_only true
```

**SendGrid Email Issues:**
```bash
# Check SendGrid status
curl -H "Authorization: Bearer $SENDGRID_API_KEY" \
  https://api.sendgrid.com/v3/mail/send

# Switch to backup provider
kubectl set env deployment/email-service EMAIL_PROVIDER=backup
```

## 📊 Monitoring & Alerting

### Key Metrics to Monitor

**Application Metrics:**
- Response time (95th percentile < 2s)
- Error rate (< 1%)
- Throughput (requests/second)
- Active users
- Feature usage

**Infrastructure Metrics:**
- CPU usage (< 80%)
- Memory usage (< 85%)
- Disk space (< 90%)
- Network I/O
- Database connections

**Business Metrics:**
- New user registrations
- Sighting submissions
- Community engagement
- Revenue metrics

### Alert Thresholds

```yaml
alerts:
  critical:
    - error_rate > 5% for 2 minutes
    - response_time_p95 > 5s for 5 minutes
    - cpu_usage > 90% for 5 minutes
    - memory_usage > 95% for 2 minutes
    - disk_usage > 95%
  
  warning:
    - error_rate > 2% for 5 minutes
    - response_time_p95 > 3s for 10 minutes
    - cpu_usage > 80% for 10 minutes
    - memory_usage > 85% for 10 minutes
```

### Monitoring Tools

**Infrastructure:**
- Prometheus + Grafana
- New Relic / DataDog
- CloudWatch (AWS)
- DigitalOcean Monitoring

**Application:**
- Sentry (Error tracking)
- LogRocket (User sessions)
- Mixpanel (Analytics)
- Custom health checks

**Uptime:**
- Pingdom
- UptimeRobot
- StatusCake
- Internal health checks

## 🔄 Recovery Procedures

### Database Recovery

**Point-in-Time Recovery:**
```bash
# Stop the database
sudo systemctl stop postgresql

# Restore from backup
pg_restore -d ufobeep_prod /backups/ufobeep_backup_2024_01_15.sql

# Start database
sudo systemctl start postgresql

# Verify data integrity
psql -d ufobeep_prod -c "SELECT COUNT(*) FROM sightings;"
```

**Replica Failover:**
```bash
# Promote read replica to master
pg_ctl promote -D /var/lib/postgresql/data

# Update application config
kubectl set env deployment/api DATABASE_URL=postgresql://new-master:5432/ufobeep

# Update DNS records
# Point db.ufobeep.com to new master IP
```

### Application Recovery

**Blue-Green Deployment Rollback:**
```bash
# Switch traffic to previous version
kubectl patch service api-service -p '{"spec":{"selector":{"version":"v1.2.3"}}}'

# Verify rollback
kubectl get pods -l version=v1.2.3
curl -I https://api.ufobeep.com/health
```

**Container Recovery:**
```bash
# Restart failed pods
kubectl delete pods -l app=ufobeep-api

# Scale deployment
kubectl scale deployment api --replicas=5

# Check pod status
kubectl get pods -w
```

## 📋 Runbook Checklists

### P0 Incident Checklist

**Immediate (0-15 minutes):**
- [ ] Acknowledge alert
- [ ] Assess impact and severity
- [ ] Create incident ticket
- [ ] Notify incident commander
- [ ] Establish incident channel
- [ ] Update status page

**Short-term (15-60 minutes):**
- [ ] Assemble response team
- [ ] Begin investigation
- [ ] Implement containment
- [ ] Communicate to stakeholders
- [ ] Document actions taken

**Resolution (1-4 hours):**
- [ ] Implement permanent fix
- [ ] Verify system stability
- [ ] Update status page
- [ ] Notify resolution
- [ ] Begin post-mortem

**Post-Incident (24-48 hours):**
- [ ] Complete post-mortem
- [ ] Identify action items
- [ ] Update documentation
- [ ] Implement improvements

### Security Incident Checklist

**Detection:**
- [ ] Identify compromise indicators
- [ ] Assess scope of breach
- [ ] Preserve evidence
- [ ] Contact legal counsel

**Containment:**
- [ ] Isolate affected systems
- [ ] Reset compromised credentials  
- [ ] Block malicious activity
- [ ] Patch vulnerabilities

**Eradication:**
- [ ] Remove malware/backdoors
- [ ] Close attack vectors
- [ ] Update security controls
- [ ] Validate system integrity

**Recovery:**
- [ ] Restore from clean backups
- [ ] Monitor for reinfection
- [ ] Gradually restore services
- [ ] Validate operations

**Lessons Learned:**
- [ ] Document incident timeline
- [ ] Analyze response effectiveness
- [ ] Update security controls
- [ ] Train staff on improvements

## 📞 Escalation Procedures

### When to Escalate

**P0 Incidents:**
- Immediately to incident commander
- After 1 hour if no resolution
- If legal/regulatory implications

**P1 Incidents:**
- After 2 hours if no resolution
- If scope increases significantly
- If customer escalation occurs

**Security Incidents:**
- Immediately if data breach suspected
- If external parties involved
- If media attention likely

### Escalation Path

```
Level 1: On-call Engineer
    ↓ (30 minutes)
Level 2: Team Lead
    ↓ (1 hour)  
Level 3: Engineering Manager
    ↓ (2 hours)
Level 4: CTO
    ↓ (4 hours)
Level 5: CEO
```

## 📚 Additional Resources

### Documentation
- [Architecture Overview](./architecture.md)
- [API Documentation](./API_CONTRACTS.md)
- [Deployment Guide](../scripts/setup-deployment.sh)
- [Security Policy](./security-policy.md)

### Tools & Access
- [Grafana Dashboard](https://grafana.ufobeep.com)
- [Sentry Error Tracking](https://sentry.io/ufobeep)
- [Status Page Admin](https://admin.status.ufobeep.com)
- [Server Access Guide](./server-access.md)

### Training Materials
- Incident Response Training
- Security Awareness Training
- Tool-specific Documentation
- Vendor Support Contacts

---

**Document Version:** 1.0  
**Last Updated:** 2024-01-15  
**Next Review:** 2024-04-15  
**Owner:** Engineering Team  

**Emergency Contact:** incidents@ufobeep.com | +1-XXX-XXX-XXXX