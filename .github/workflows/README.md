# GitHub Actions Workflow - Flutter Tests

## Overview
This workflow automatically runs Flutter tests on each pull request and commit to the main and develop branches.

## Workflow Configuration

### File Location
`.github/workflows/flutter_test.yml`

### Triggers
The workflow is triggered on:
- **Push events** to `main` and `develop` branches
- **Pull request events** targeting `main` and `develop` branches

## Jobs

### 1. Test on Web Platform (`test-web`)
This job tests the Flutter application for web platform compatibility.

**Steps:**
1. **Checkout code** - Retrieves the repository code
2. **Setup Flutter** - Installs Flutter SDK (v3.16.0, stable channel)
3. **Get dependencies** - Runs `flutter pub get` to install dependencies
4. **Analyze code** - Runs `flutter analyze` for static code analysis
5. **Run tests (web)** - Executes tests using Chrome platform: `flutter test --platform chrome`

### 2. Test on Mobile Platform (`test-mobile`)
This job tests the Flutter application for mobile platform compatibility.

**Steps:**
1. **Checkout code** - Retrieves the repository code
2. **Setup Flutter** - Installs Flutter SDK (v3.16.0, stable channel)
3. **Get dependencies** - Runs `flutter pub get` to install dependencies
4. **Analyze code** - Runs `flutter analyze` for static code analysis
5. **Run tests (mobile - VM)** - Executes tests using Flutter VM: `flutter test`

## Testing Capabilities

### Web Platform Testing
- Uses Chrome browser for web-based testing
- Validates Flutter web application functionality
- Tests responsive design and web-specific features

### Mobile Platform Testing
- Uses Flutter VM for mobile simulation
- Tests mobile-specific widgets and interactions
- Validates cross-platform mobile compatibility

## Viewing Test Results

After a pull request or commit:
1. Navigate to the **Actions** tab in the GitHub repository
2. Click on the workflow run for your commit/PR
3. View the results for both `test-web` and `test-mobile` jobs
4. Check logs for any failures or warnings

## Local Testing

To run tests locally before pushing:

```bash
# Install dependencies
flutter pub get

# Run code analysis
flutter analyze

# Run all tests
flutter test

# Run tests for web platform
flutter test --platform chrome

# Run specific test file
flutter test test/widget_test.dart
```

## Maintenance

### Updating Flutter Version
To update the Flutter version used in CI:
1. Edit `.github/workflows/flutter_test.yml`
2. Update the `flutter-version` parameter in both jobs
3. Commit and push the changes

### Adding Additional Platforms
To test on additional platforms (iOS, Android), add new jobs following the existing pattern and use appropriate platform-specific commands.

## Troubleshooting

### Common Issues

**Tests failing in CI but passing locally:**
- Ensure you're using the same Flutter version
- Check for environment-specific dependencies
- Review GitHub Actions logs for detailed error messages

**Web tests failing:**
- Verify Chrome driver compatibility
- Check for web-specific configuration in `pubspec.yaml`
- Ensure web platform is enabled in the project

**Mobile tests failing:**
- Check for platform-specific code that might not work in CI
- Verify all dependencies are compatible with the Flutter VM
- Review test isolation and mock implementations

## Best Practices

1. **Keep tests fast** - Long-running tests delay feedback
2. **Write isolated tests** - Tests should not depend on each other
3. **Mock external dependencies** - Don't rely on external services in CI
4. **Test coverage** - Aim for good test coverage of critical functionality
5. **Regular updates** - Keep Flutter SDK and dependencies up to date
