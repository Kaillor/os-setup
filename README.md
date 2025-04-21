# OS Setup

[![CI](https://github.com/Kaillor/os-setup/actions/workflows/ci.yml/badge.svg)](https://github.com/Kaillor/os-setup/actions/workflows/ci.yml)

This project is designed to automate the configuration of freshly installed operating systems. It simplifies this process by providing a structured and extensible framework. The project contains automation scripts that fit my personal needs. Still, it is highly customizable, allowing anyone to adapt it to their needs by modifying or adding scripts for different operating systems.

## Features

- **Automated OS Setup**: Fully autonomous configuration and installation after selecting a profile and operating system.
- **Customizable Configuration**: Easily adaptable and extendable to support additional operating systems, distributions, and profiles.
- **Utility Scripts & Commands**: Utilities usable for automation or as standalone scripts.
- **Comprehensive Logging**: Logs all actions to the terminal and a file, with clear messages about warnings or errors.
- **Robust Testing**: Extensive test coverage using [BATS](https://bats-core.readthedocs.io/), ensuring reliability and correctness.

## Usage

1. Obtain the repository:

   You can acquire the repository using various methods. Choose the one that suits you best. For example:

   - **Clone with Git**:

     - HTTPS

       ```bash
       git clone https://github.com/Kaillor/os-setup.git
       ```

     - SSH

       ```bash
       git clone git@github.com:Kaillor/os-setup.git
       ```

     - GitHub CLI

       ```bash
       gh repo clone Kaillor/os-setup
       ```

   - **Download**:

     - curl

       ```bash
       curl -L -o os-setup.zip https://github.com/Kaillor/os-setup/archive/refs/heads/main.zip
       unzip os-setup.zip
       ```

     - wget

       ```bash
       wget https://github.com/Kaillor/os-setup/archive/refs/heads/main.zip -O os-setup.zip
       unzip os-setup.zip
       ```

     - Manually
       - Click the "Code" button on the repository page and select "Download ZIP" ([Direct Link](https://github.com/Kaillor/os-setup/archive)).
       - Extract the ZIP file.

2. Run the setup script `setup.sh` in the root directory:

   ```bash
   ./setup.sh
   ```

3. Follow the prompts:
   - Select a profile (e.g., `personal`).
   - Select an operating system and its details (e.g., `debian` > `mint` > `cinnamon`).
   - Confirm your choices to start the installation process.

### Utility Scripts

- **Apply Patches**: Apply patches to a bulk of files.

  ```bash
  ./script/patch/apply-patches.sh
  ```

- **Revert Patches**: Revert patches applied by `apply-patches.sh`.

  ```bash
  ./script/patch/revert-patches.sh
  ```

## Development

The project includes a VSCode workspace (`os-setup.code-workspace`). Use this workspace and the recommended extensions for a streamlined development experience.

### Project Structure

- **`setup/`**: Contains a hierarchical operating system structure for user selection and the respective automation scripts. For example:

  ```
  setup/
  ├─ arch/
  │  └─ endeavouros/
  └─ debian/
     ├─ kali/
     └─ mint/
        ├─ cinnamon/
        └─ mate/
  ```

  Each directory includes a directory `install/` containing common and profile-specific installation scripts that will be executed if they match the selected operating system and profile. For example:

  ```
  cinnamon/
  └─ install/
     ├─ common/
     │  └─ install.sh
     ├─ personal/
     │  └─ install.sh
     └─ work/
        └─ install.sh
  ```

  Each directory that requires an additional selection to be made includes a script `setup.sh` that handles the user selection.

- **`script/`**: Contains utility scripts and commands.
- **`test/`**: Contains testing libraries, utilities, and resources.

### Testing

The project uses [BATS](https://bats-core.readthedocs.io/) for testing.

- Test files are located next to the scripts under test (e.g., `setup-test.bats` for `setup.sh`).
- A convenient `just` recipe is available to execute all or specific test files. See the [Recipes](#recipes) section for details.

### Recipes

The project uses a [JustFile](https://github.com/casey/just) for task automation. The available recipes are:

- **`ci`**: Runs recipes `test`, `shellcheck`, `shellharden-check`, and `format-check`.
- **`format-apply`**: Applies the desired formatting to all scripts.
- **`format-check`**: Checks whether all scripts adhere to the desired formatting.
- **`shellcheck`**: Checks all scripts for potential issues.
- **`shellharden-apply`**: Applies a strict syntax and best practices to all scripts.
- **`shellharden-check`**: Checks whether all scripts adhere to a strict syntax and best practices.
- **`test`**: Runs all tests or a specific test file if one is provided as an argument.

### GitHub Workflow

A CI workflow ensures code quality:

- Runs nightly and on pull requests.
- Executes tests.
- Analyzes scripts for potential issues.
- Enforces strict syntax and best practices.
- Checks formatting.
