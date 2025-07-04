# Security Policy for GitVision Eurovision Workshop

## Supported Versions

The GitVision Eurovision Workshop is currently in active development. We prioritize security updates for:

| Version | Supported          |
| ------- | ------------------ |
| main    | :white_check_mark: |
| < main  | :x:                |

## Security Considerations

### API Tokens and Credentials
- Never commit API tokens, credentials, or secrets
- Use `lib/config/api_tokens.dart` (git-ignored) for local development
- Follow the provided examples in `api_tokens.example.dart`

### Data Privacy
- Do not store personal GitHub data
- Handle Eurovision song metadata responsibly
- Respect Spotify's terms of service and user privacy

### Rate Limiting
- Implement GitHub API rate limit handling (5000 requests/hour)
- Use exponential backoff for API retries
- Cache responses where appropriate

## Reporting a Vulnerability

We take the security of GitVision Eurovision Workshop seriously. If you believe you have found a security vulnerability:

1. **Do Not** open a public GitHub issue
2. Email the workshop maintainers privately
3. Include as much detail as possible:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect
- Acknowledgment of your report within 48 hours
- Regular updates on our progress
- Credit for responsible disclosure (unless you prefer to remain anonymous)

## Best Practices for Workshop Participants

1. **API Security**
   - Keep API tokens secure and private
   - Rotate tokens regularly
   - Use environment variables for secrets

2. **Code Security**
   - Follow Flutter/Dart security best practices
   - Keep dependencies updated
   - Use strong authentication patterns

3. **Data Handling**
   - Validate all inputs
   - Sanitize data before storage or display
   - Handle errors gracefully

## Development Security Guidelines

- Use HTTPS for all API calls
- Implement proper error handling
- Follow secure coding practices
- Keep all dependencies up to date
- Review code for security implications

## Acknowledgments

We appreciate the security community's efforts in responsibly disclosing vulnerabilities and helping make GitVision Eurovision Workshop safer for everyone.

---

For questions about this security policy, please contact the workshop organizers.
