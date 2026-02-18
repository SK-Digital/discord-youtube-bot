# Contributing to Discord YouTube Bot

Thank you for your interest in contributing to the Discord YouTube to WAV Converter Bot! This document provides guidelines for contributors.

## 🚀 Getting Started

### Prerequisites

- Python 3.11+
- Docker (optional, for containerized development)
- FFmpeg (included in Docker image)
- Discord Bot Token for testing

### Setup

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/discord-youtube-bot.git
   cd discord-youtube-bot
   ```

2. **Set up development environment**
   ```bash
   # Run the setup script
   ./scripts/setup.sh
   
   # Or manually:
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   cp .env.example .env
   # Edit .env with your Discord bot token
   ```

3. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 🛠️ Development Guidelines

### Code Style

- Use **Black** for code formatting
- Use **flake8** for linting
- Follow PEP 8 style guidelines
- Use meaningful variable and function names
- Add docstrings to functions and classes

### Testing

```bash
# Run linting
flake8 .
black --check .

# Run tests (when available)
pytest tests/ -v

# Test imports
python -c "import slash_bot; import filebin_hosting"
```

### Commit Messages

Use clear, descriptive commit messages:

```
feat: Add playlist support
fix: Handle SSL certificate issues on macOS
docs: Update README with Docker instructions
refactor: Simplify YouTubeConverter class
```

## 📁 Project Structure

```
discord-youtube-bot/
├── slash_bot.py              # Main bot application
├── run_slash_bot.py          # SSL handling wrapper
├── filebin_hosting.py        # Filebin.net integration
├── requirements.txt           # Python dependencies
├── Dockerfile                # Docker configuration
├── docker-compose.yml        # Docker Compose configuration
├── .env.example              # Environment variables template
├── .github/workflows/        # CI/CD workflows
├── scripts/                  # Utility scripts
└── tests/                    # Test files
```

## 🐛 Bug Reports

When reporting bugs, please include:

1. **Environment**: OS, Python version, Docker version (if applicable)
2. **Error messages**: Full error traceback
3. **Steps to reproduce**: Detailed steps to reproduce the issue
4. **Expected behavior**: What you expected to happen
5. **Actual behavior**: What actually happened

### Bug Report Template

```markdown
## Bug Description
Brief description of the bug

## Environment
- OS: 
- Python version:
- Docker version (if applicable):
- Discord.py version:

## Steps to Reproduce
1. 
2. 
3. 

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Error Messages
```
Paste error messages here
```

## Additional Context
Any additional information
```

## ✨ Feature Requests

When requesting features, please include:

1. **Use case**: Why this feature would be useful
2. **Proposed implementation**: How you envision it working
3. **Alternatives considered**: Other approaches you've thought of

### Feature Request Template

```markdown
## Feature Description
Brief description of the feature

## Use Case
Why this feature would be useful

## Proposed Implementation
How you envision it working

## Alternatives Considered
Other approaches you've thought of

## Additional Context
Any additional information
```

## 🔧 Pull Requests

### Before Submitting

1. **Test your changes**
   ```bash
   # Run linting
   flake8 .
   black .
   
   # Test imports
   python -c "import slash_bot; import filebin_hosting"
   ```

2. **Update documentation**
   - Update README.md if needed
   - Add docstrings to new functions
   - Update .env.example if new environment variables

3. **Ensure your branch is up to date**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Code passes linting (flake8, black)
- [ ] Code imports successfully
- [ ] Tested manually (if applicable)

## Checklist
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code where necessary
- [ ] I have updated the documentation if necessary
- [ ] My changes generate no new warnings
```

## 🚀 Deployment

### Docker Deployment

```bash
# Build and run locally
docker-compose up -d

# View logs
docker-compose logs -f
```

### Production Considerations

- Use environment variables for configuration
- Don't commit sensitive data (tokens, API keys)
- Use the provided Docker image for consistency
- Monitor logs for errors

## 🤝 Code of Conduct

Please be respectful and professional in all interactions:

- **Be inclusive**: Welcome contributors of all backgrounds
- **Be constructive**: Provide helpful, specific feedback
- **Be patient**: Remember that everyone is learning
- **Be professional**: Keep discussions focused and productive

## 📞 Getting Help

If you need help:

1. **Check existing issues**: Look for similar problems or requests
2. **Ask questions**: Create an issue with the "question" label
3. **Join discussions**: Comment on existing issues or pull requests
4. **Contact maintainers**: Reach out to the project maintainers

## 🏆 Recognition

Contributors will be recognized in:

- README.md contributors section
- Release notes
- Commit history (with proper attribution)

Thank you for contributing to the Discord YouTube Bot! 🎵
