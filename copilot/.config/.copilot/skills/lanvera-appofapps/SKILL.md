---
name: lanvera-appofapps
description: Update lv3 and lv3-infra app-of-apps settings in YAML values files and generated templates via tpl sources and Makefile targets. Use when editing lv3/lv3-infra ArgoCD app settings, toggling apps, adding dependencies, or changing environment-specific configuration in this repository.
---

# Update app-of-apps YAML settings (lv3 / lv3-infra)

This skill guides the agent when updating app-of-apps configuration for LV3 in the `lv3/` and `lv3-infra/` folders.

## When to use this skill

Use this skill when you are requested to work inside an ArgoCD app-of-apps repository and the change involves:

- Updating **environment-specific settings** in:
  - `lv3/values-*.yaml`
  - `lv3-infra/values-*.yaml`
- Toggling apps on/off, adjusting replicas/HPA, image tags, or adding new parameters to the values files settings for LV3.

## Repository layout (assumptions)

- **Application values per environment**:
  - `lv3/values-dev-*.yaml`, `lv3/values-qa-*.yaml`, `lv3/values-prd-*.yaml`, `lv3/values-prod-*.yaml`
- **Infrastructure values per environment**:
  - `lv3-infra/values-dev-*.yaml`, `lv3-infra/values-qa-*.yaml`, `lv3-infra/values-prd-*.yaml`, `lv3-infra/values-prod-*.yaml`
- **Generated ArgoCD app-of-apps templates**:
  - `lv3/templates/*.yaml` – LV3 app definitions (e.g. `lvc-api`, web apps, services) **GENERATED, DO NOT EDIT DIRECTLY**
  - `lv3-infra/templates/*.yaml` – infra apps (e.g. namespaces, datadog, rabbitmq, redis, etc.) **GENERATED, DO NOT EDIT DIRECTLY**
- **Template sources**:
  - `scripts/tpl-files/*.tpl` – source templates used to generate the files under `lv3/templates/*.yaml` and related app-of-apps content.

If any of these assumptions do not hold for a specific task, inspect the `lv3/` and `lv3-infra/` directories with `Read` and adjust accordingly.

## General workflow for updates

Follow this workflow whenever modifying LV3 app-of-apps YAML:

1. **Clarify the target**
   - Identify:
     - **Environment**: `dev`, `qa`, `prd` / `prod`, etc.
     - **Tier**: application (`lv3`) vs infrastructure (`lv3-infra`).
     - **App or component** affected (e.g. `lvc.api`, `lv3-cp-web-client-portal`, `redis`).

2. **Locate the relevant files**
   - For **values-only changes** (connection strings, flags, environment-specific settings, key vault configuration, enabling/disabling app, add a new setting etc.):
     - Use `Grep` in:
       - `lv3/values-<env>-*.yaml`
       - `lv3-infra/values-<env>-*.yaml`
   - For **ArgoCD Application structure** (e.g. adding a parameter, wiring a new value):
       - `scripts/tpl-files/*.tpl` for app-of-apps template sources.

3. **Understand current behavior**
   - Use `Read` to pull a **small portion** around the match (with `offset` and `limit`) instead of loading entire large files.
   - Identify:
     - Which `.Values.*` keys are used (e.g. `.Values.lvc.api.*`, `.Values.global.*`, `.Values.lvc.api.keyvault.*`).
     - Whether the setting is controlled by:
       - A **values** entry only (simple config change), or
       - A combination of **values + template wiring** (requires changes in both).

4. **Plan the change (medium safety)**
   - Before editing, write down a short plan in the conversation, including:
     - Files to be changed
     - Keys/sections to add or modify
     - Expected impact (e.g. “change `lvc.api.tag` for dev to X”, “enable kyverno network policy for Y”).
   - Keep changes **scoped and minimal**:
     - Prefer changing a **single environment** at a time unless user requests otherwise.
     - Avoid bulk environment changes unless explicitly requested.

5. **Apply changes**
   - Use `ApplyPatch` with **narrow hunks**:
     - Include only the minimal context needed to uniquely identify the section.
     - Never rewrite or reformat entire large YAML files.
   - Preserve:
     - Indentation and nesting.
     - Comments that document important behavior.
   - For **values files**:
     - Update or add only the required keys under the correct hierarchy, e.g.:
       - `global.*` (shared settings)
       - `lvc.<service>.*`
       - `keyvault.*` and related sections.
   - For **template source files** in `scripts/tpl-files/*.tpl`:
     - Ensure any new `.Values.*` keys are already present (or will be added) in the corresponding `values-*.yaml`.
     - Follow existing patterns for Helm `parameters:` blocks, and conditional sections.
     - **Never edit `lv3/templates/*.yaml` files; they are generated from the `scripts/tpl-files/*.tpl` sources.**

6. **Sanity check YAML and wiring**
   - Confirm:
     - YAML structure is valid (consistent indentation, lists vs maps).
     - Any new `.Values.*` references in templates have matching entries in the relevant `values-*.yaml`.
     - Environment naming is correct (e.g. `dev`, `qa`, `prd` vs `prod`) and consistent with existing files.
   - If the task involves secrets or Key Vault:
     - Do **not** hard-code sensitive values.
     - Prefer adjusting **Key Vault names/URLs/secret names** and related wiring rather than embedding secrets.

7. **Summarize the diff**
   - After edits, summarize for the user:
     - Which files were modified.
     - Which keys/sections changed.
     - Any behavioral impact (e.g. “dev `lvc-api` image tag updated to X; no other environments changed”).

## Structural vs value changes

- **Value-only changes (common)**:
  - Example: changing image tags, URLs, ports, toggling features, tweaking HPA thresholds.
  - Act primarily in `values-*.yaml`; leave generated templates unchanged.

- **Structural changes (less common, more risky)**:
  - Example: adding a new app, adding/removing Helm parameters, changing sync options, or altering ArgoCD `spec`.
  - Steps:
    1. Identify the **application type**:
       - `arch` – default LV3 app type (most `arch:` Makefile target apps).
       - `api` – LV3 Client Portal APIs (`lv3.cp.api` apps).
       - `web` – LV3 Client Portal web apps (`lv3.cp.web` apps).
       - `lvc` – Lanvera Connect apps.
       - `lvp` – Lanvera Print apps.
       - If the application type cannot be clearly determined from context, **ask the user for clarification** before proceeding.
    2. Work in the **makefile targets** under `Makefile`, not in `lv3/templates/*.yaml` neither in `scripts/tpl-files/*.tpl`.
       - Copy patterns from a similar existing app of the same type for a new Makefile target.
       - Add only the new fields required, reusing existing global patterns where possible.
    3. Update or add corresponding values in the appropriate `values-*.yaml` for each environment that should use the new behavior.
    4. After template source changes, **run the `make all` command twice** to regenerate the app-of-apps output and ensure consistency.

## Examples

### Example 1: Change image tag for a single app in dev

Goal: Update the `lvc-api` image tag for `dev` only.

1. Identify:
   - Environment: `dev`
   - App: `lvc.api`
2. Use `Grep`:
   - Search for `lvc.api.tag` in `lv3/values-dev-*.yaml`.
3. Use `Read` to inspect the surrounding section.
4. Use `ApplyPatch` to update only the `tag` value for `dev`, keeping indentation and comments intact.
5. Summarize: “Updated `lvc.api.tag` in `lv3/values-dev-*.yaml` for dev; other environments unchanged.”

### Example 2: Wire a new value from values into a template

Goal: Expose a new config option for `lvc-api` via Helm values.

1. In the appropriate `values-<env>-*.yaml`, add a new key under `lvc.api` (following existing patterns).
2. In the matching `.tpl` file under `scripts/tpl-files/` for `lvc-api`:
   - Find the `helm.parameters` section.
   - Add a new parameter or value line referencing `.Values.lvc.APP_SHORT_NAME.<newKey>`, copying style from similar existing entries.
3. Run `make all` **twice** to regenerate the `lv3/templates/*.yaml` output.
4. Check:
   - Key name matches exactly between values and template.
   - Any conditionals (`{{- if ... }}`) align with how other optional settings are handled.

### Example 3: Toggle an infrastructure component

Goal: Enable or disable an infra component (e.g. a monitoring tool) for `qa`.

1. Locate:
   - `lv3-infra/values-qa-*.yaml`
2. Use `Grep` for the component name or `enabled:` flag.
3. Adjust the `enabled` value in the relevant section only.
4. Confirm no unrelated infra settings were touched.

### Example 4: Add a dependency between applications

Goal: Add a new dependency between applications so one app depends on another.

1. Identify the application type of the dependent app (`arch`, `lvc`, or `lvp`).
2. Update the appropriate Makefile target for that application, adding the dependency with the correct parameter:
   - `-a` or `--app-lv3-apps`: For LV3/arch application dependencies (most applications in the `arch:` target).
   - `-l` or `--app-lvc-apps`: For LVC (Lanvera Connect) application dependencies.
   - `-p` or `--app-lvp-apps`: For LVP (Lanvera Print) application dependencies.
3. If it’s unclear which application type applies, **ask the user** before changing the Makefile.
4. Run `make all` **twice** to ensure generated outputs are updated with the new dependency.

### Example 5: Add a new application

Goal: Add a brand-new app to the app-of-apps setup.

1. Determine the **application type** (`arch`, `api`, `web`, `lvc`, or `lvp`). If unclear, ask the user.
2. Add the app values to the appropriate `values-*.yaml` files for the environments where it should be enabled.
3. Create or update the relevant Makefile targets for that application and:
   - Add the new target to the main target for its application type (e.g. arch/api/web/lvc/lvp group).
4. Run `make all` **twice** so that `lv3/templates/*.yaml` (and related outputs) are regenerated and include the new app.

## Additional guidelines

- Prefer **consistency** with existing structure and naming:
  - Reuse key names and patterns instead of inventing new ones.
- Avoid:
  - Large-scale search-and-replace across all environments without an explicit request.
  - Reformatting YAML (changing quoting style, reordering keys) unless strictly necessary for the change.
- If unsure between multiple similar patterns:
  - Choose the one most frequently used in `lv3/templates/` or `lv3-infra/templates/`.
  - Explain that choice briefly in the conversation.
  - When asked to sync changes between files, sync only changes related to the same session and avoid bulk copying unrelated sections.
