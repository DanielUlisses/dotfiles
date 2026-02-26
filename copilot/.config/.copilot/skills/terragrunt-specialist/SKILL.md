---
name: terragrunt-specialist
description: Update terragrunt files and input.yaml files in the repository, based on user requests.
---

# Update terragrunt files and input.yaml files on different environments

This skill guides de agent when updating terragrunt files and input.yaml files in the repository, based on user requests. The agent will be able to understand the structure of the terragrunt files and input.yaml files, and make the necessary changes as per the user's instructions.

# When to use this skill

Use this skill when you need to update terragrunt files and input.yaml files in the repository. This could include adding new variables, updating existing variables, changing configurations, or any other modifications that are required based on user requests.

# Repository layout (assumptions)
- **Environments folders**: The repository is organized into different environment folders (e.g., `dev`, `qa`, `prd`).
- **Compositions per environment**: Each environment folder contains multiple compositions (e.g., `region/instance`, `centralus/blue`, `centralus/function-apps`).
- **Terragrunt files**: Each composition contains a `terragrunt.hcl` file that defines the infrastructure configuration for that composition.
- **Input.yaml files**: Each composition also contains an `input.yaml` file that defines the input variables for that composition.
- **Regional settings**: There may be regional settings defined in the `region.yaml` file that can be referenced in the `terragrunt.hcl` files.
- **Environment settings**: There may be environment-specific settings defined in the `env.yaml` file that can be referenced in the `terragrunt.hcl` files.
- **Root settings**: There may be root-level settings defined in the `root.yaml` file that can be referenced in the `terragrunt.hcl` files.
- **Strings interpolation**: The `strings.hcl` file may contain string interpolation functions that can be used in the `terragrunt.hcl` files to dynamically generate values based on the input variables and settings.

## General workflow for updating terragrunt files and input.yaml files
1. **Identify the target environment and composition**: Determine which environment and composition the user wants to update based on their request.
2. **Locate the relevant files**: Navigate to the appropriate environment folder and composition folder to find the `terragrunt.hcl` and `input.yaml` files that need to be updated.
3. **Understand the requested changes**: Analyze the user's request to understand what specific changes need to be made to the `terragrunt.hcl` and `input.yaml` files. This could involve adding new variables, updating existing variables, changing configurations, or any other modifications.
4. **Make the necessary updates**: Edit the `terragrunt.hcl` and `input.yaml` files to reflect the requested changes. Ensure that the changes are consistent with the existing structure and conventions used in the files.
5. **Validate the changes**: After making the updates, validate the changes to ensure that they are correct and do not introduce any errors.
6. **Summarize the diff**: Provide a summary of the changes made to the `terragrunt.hcl` and `input.yaml` files, highlighting the key modifications that were made based on the user's request.

## Example user request
### Example 1: Adding a new namespace to a Kubernetes deployment
- "Please update the `dev/centralus/blue` composition to add a new namespace on Kubernetes. The namespace should be called `arch-file-vault-archive-service`.

In the composition `dev/centralus/blue`, the agent would:
- lookup for the kubernetes deployment folder and relevant `input.yaml` file and `terragrunt.hcl` file.
- Add the new namespace variable to the `input.yaml` file.
- make sure yaml syntax is correct and consistent with the existing structure.

### Example 2: Adding a new parameter to a terragrunt configuration
- "Please update the `prd/centralus/function-apps` composition to add a new parameter called `app_insights_enabled` to the `terragrunt.hcl` file, and set its value to `true`."
- In the composition `prd/centralus/function-apps`, the agent would:
- Locate the `terragrunt.hcl` file for the `prd/centralus/function-apps` composition.
- Add the new parameter `app_insights_enabled` to the `terragrunt.hcl` file and set its value to `local.inputs.app_insights_enabled`.
- Update the `input.yaml` file for the `prd/centralus/function-apps` composition to include the new variable `app_insights_enabled` and set its value to `true`.

### Example 3: Adding a new parameter at environment level
- "Please update the `qa` environment to add a new parameter called `enable_monitoring` to the `env.yaml` file, and set its value to `false`, add this parameter to kubernetes deployment."
- In the `qa` environment, the agent would:
- Locate the `env.yaml` file for the `qa` environment.
- Add the new parameter `enable_monitoring` to the `env.yaml` file and set
  its value to `false`.
- Update the relevant `terragrunt.hcl` files the compositions in the `qa` environment to include the new parameter `enable_monitoring` and set its value to `local.env.enable_monitoring`.

### Aditional guidelines
- When making updates to the `terragrunt.hcl` files, ensure that the changes are consistent with the existing structure and conventions used in the files. This includes maintaining proper indentation, using the correct syntax for defining variables and configurations, and ensuring that any references to other files (e.g., `region.yaml`, `env.yaml`, `root.yaml`, `strings.hcl`) are correctly formatted.
- Reuse key names and patterns instead of inventing new ones.
- Avoid:
- Large-scale search-and-replace across all environments without an explicit request.
- Reformatting YAML (changing quoting style, reordering keys) unless strictly necessary for the change.
- Explain that choice briefly in the conversation.
