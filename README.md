# nextjs-aca

An `azd` ([Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/overview)) template for getting a [Next.js](https://nextjs.org/) 13 app running on Azure Container Apps with CDN and Application Insights.

The Next.js 13 app included with the template has been generated with [`create-next-app`](https://nextjs.org/docs/getting-started/installation#automatic-installation) and has some additional code and components specific to this template that provide:

* Server-side and client-side instrumentation and logging via App Insights
* Serving of Next.js static assets through an Azure CDN (with cache busting)
* Support for custom domain names and automatic canonical host name redirect
* Support for checking the current environment at runtime

Of course with this being an `azd` template you are free to build on top of the sample app, replace the sample app with your own, or cherry-pick what you want to keep or remove.

## Quickstart

The quickest way to try this `azd` template out is using [GitHub Codespaces](https://docs.github.com/en/codespaces) or in a [VS Code Dev Container](https://code.visualstudio.com/docs/devcontainers/containers):

* Create a new Codespace from the `main` branch or clone this repo and start the included Dev Container in VS Code
* Open a Terminal
* `npm i` to install dependencies
* `npm run env:init` to create a `.env.local` file from the provided template
* `azd auth login` and follow the prompts to sign in to your Azure account
* `azd provision` and follow the prompts to provision the infrastructure resources in Azure
* `azd deploy` to deploy the app to the provisioned infrastructure

> The output from the `azd deploy` command includes a link to the Resource Group in your Azure Subscription where you can see the provisioned infrastructure resources. A link to the Next.js app running in Azure is also included so you can quickly navigate to your Next.js app that is now hosted in Azure.

🚀 You now have a Next.js 13 app running in Container Apps in Azure with a CDN for fast delivery of static files and Application Insights attached for monitoring!

💥 When you're done testing you can run `azd down` in the terminal and that will delete the Resource Group and all of the resources in it.

## TODO: Docs

* [x] Running locally
* [x] Dev loop
* [ ] Deploying to Azure with `azd` in a CI/CD pipeline
* [x] App Insights on server and client
* [ ] CDN support
* [ ] Environment conditions
* [x] Environment variables
* [x] Pipelines
* [x] Custom domain name
* [ ] Create architecture diagram
* [ ] Check other azd templates to see what they have included in docs

## Setting up locally

If you do not have access to or do not want to work in Codespaces or a Dev Container you can of course work locally, but you will need to ensure you have the following pre-requisites installed:

* [Node.js](https://nodejs.org/) v18.x
  * Later versions should be fine also, but v18.x is the target version set in the template
  * Use of [`nvm`](https://github.com/nvm-sh/nvm) or [`fnm`](https://github.com/Schniz/fnm) is recommended
* [PowerShell](https://github.com/PowerShell/PowerShell)
* [Azure Developer CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd)
* [Docker Desktop](https://www.docker.com/products/docker-desktop/)

> The template was developed on a Windows machine, and has been tested in a Linux environment (in the Dev Container). macOS is supported, but has not been tested.
>
> `azd` supports several [development environments](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/supported-languages-environments#supported-development-environments). This template was developed in VS Code, and has been tested in GitHub Codespaces and Dev Containers (via VS Code). Visual Studio has not been tested.
>
> `npm` is used as it is the "safest" default. You should be able to switch out for the package manager of your choice, but only `npm` has been tested.

✔️ Once you have everything installed you can clone this repo and [start developing](#developing-your-app-with-this-template) or [deploy to Azure with the `azd` CLI](#deploying-to-azure-with-the-azd-cli).

## Developing your app with this template

You should develop your Next.js app as [you normally would](https://nextjs.org/docs/app/building-your-application) with a couple of (hopefully minor) concessions:

* As and when environment variables need to be added to a `.env.local` file that the the `.env.local.template` file is updated to include a matching empty or example entry
  * This is so that the `azd provision` and `azd deploy` hooks have context of all of the environment variables required by your app at build and at runtime
  * See the [Environment variables](#environment-variables) section for a fuller description of why this is needed
* To get the most out of the CDN and App Insights resources used by this template you should keep (or copy across) the relevant code and configuration assets related to these resources
  * See the [Azure CDN](#azure-cdn) and [Application Insights](#application-insights) sections for more information

> Some of the file and folder naming conventions used in this template are directly influenced by `azd` so it is a good idea to be familiar with those as renaming or moving things that [`azd` has a convention for](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/make-azd-compatible?pivots=azd-create#azd-conventions) will break the `azd` commands used to provision and deploy your app.

⚡ As with any Next.js app you have the option of running your app in the [Development Server](https://nextjs.org/docs/getting-started/project-structure) or the [Node.js server](https://nextjs.org/docs/app/building-your-application/deploying#nodejs-server) locally, but because this is an `azd` template you also have the option of deploying your app to Azure [via the command line](#deploying-to-azure-with-the-azd-cli) if you want to test in a production-like environment, and then easily pull it all back down again when you are done.

> This template is configured to create [`standalone` output](https://nextjs.org/docs/app/api-reference/next-config-js/output#automatically-copying-traced-files) when you run `next build`. This produces a smaller build output to keep the size of the Docker container deployed to Azure Container Apps as small as possible. However, if you are running `next build` locally this may not be desirable because you will receive a warning when you run `next start` and your app may not work as intended. You can remove `output: 'standalone'` from `next.config.js` in this situation, but it is advised to revert/not commit this change when you are done.

## Deploying to Azure with the `azd` CLI

To deploy your app from your Terminal with `azd` run:

* `npm i` to install dependencies
  * *if you have not already done so*
* `azd auth login` and follow the prompts to sign in to your Azure account
  * *if you are not already signed in*
* `npm run env:init` to create a `.env.local` file from the provided template
  * *if you don't already have a `.env.local` file*
  * *this will be a no-op if you have*
* `azd provision` and follow the prompts to provision the infrastructure resources in Azure
* `azd deploy` to deploy the app to the provisioned infrastructure

Then when you're finished with the deployment run:

* `azd down` to delete the app and its infrastructure from Azure

> `azd` has an `azd up` command, which the [docs describe as](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/make-azd-compatible?pivots=azd-create#update-azureyaml) *"You can run `azd up` to perform both `azd provision` and `azd deploy` in a single step"*. Running `azd up` actually seems to be the equivalent of `azd package` -> `azd provision` -> `azd deploy` though, which does not work for this template because outputs from the `azd provision` step such as the app's URL and the CDN endpoint URL are required by `next build`, which is run inside the `Dockerfile` during `azd package`. So unless the behaviour of `azd up` can be changed in future you will need to continue to run `azd provision` -> `azd deploy`.

## Deploying to Azure with `azd` in a CI/CD pipeline

TODO

## Application Insights

The template includes instrumentation and components to enable server-side and client-side instrumentation and logging via App Insights when deployed to Azure.

### Server-side instrumentation and components

Server-side instrumentation is implemented using the [Application Insights for Node.js (Beta)](https://github.com/microsoft/ApplicationInsights-node.js/tree/beta) package. The package is initialised via Next.js's [Instrumentation](https://nextjs.org/docs/app/building-your-application/optimizing/instrumentation) feature and leverages Next.js's support for [OpenTelemetry](https://nextjs.org/docs/app/building-your-application/optimizing/open-telemetry).

The template also provides a logging implementation to allow for explicit logging of errors, warnings etc in your app's server-side code (including inside server components). The logger is implemented using [`pino`](https://getpino.io/) and sends logs to Application Insights via a `pino` [transport](https://github.com/CMeeg/pino-appinsights-transport). To use the logger in your app you can `import { logger } from '@/lib/instrumentation/logger'`.

> Server-side instrumentation and logging to Application Insights requires a connection string to an Application Insights resource to be provided via an environment variable `APPLICATIONINSIGHTS_CONNECTION_STRING`. Thie environment variable is provided to the app automatically by `azd provision`.
>
> If the connection string is not available, for example when running in your development environment outside of `azd provision`, the instrumentation will not be initialised and the logger will fallback to using the [`pino-pretty`](https://github.com/pinojs/pino-pretty) transport to log to `console`.

### Client-side instrumentation and logging

Client-side instrumentation is implemented using the [Microsoft Application Insights JavaScript SDK - React Plugin](https://github.com/microsoft/applicationinsights-react-js) package. The package is initialised in a `AppInsightsProvider` server component, which is a wrapper around a client component that renders the `AppInsightsContext` component from the React Plugin. You can `import { AppInsightsProvider } from '@/components/instrumentation/AppInsightsProvider'` and place it somewhere fairly high up in the component tree, for example this template renders the component inside its [Root Layout](https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts#root-layout-required).

Client-side logging can be performed by using the `useAppInsightsContext` hook from within client components as described in the [documentation for the React Plugin](https://learn.microsoft.com/en-gb/azure/azure-monitor/app/javascript-framework-extensions?tabs=react#use-application-insights-with-react-context).

> Client-side instrumentation and logging to Application Insights requires a connection string to an Application Insights resource to be provided via an environment variable `APPLICATIONINSIGHTS_CONNECTION_STRING`. . Thie environment variable is provided to the app automatically by `azd provision`.
>
> If the connection string is not available, for example when running in your development environment outside of `azd provision`, the `AppInsightsProvider` will not render and `useAppInsightsContext` will return `undefined`.

🙏 Thank you to [Jonathan Rupp](https://github.com/jorupp) who very kindly shared his implementation for client-side instrumentation in this [GitHub discussion](https://github.com/vercel/next.js/discussions/55405#discussioncomment-7118671), which was mostly reused for the implementation in this template.

## Azure CDN

TODO

## Environment variables

When developing your app you should use environment variables as per the [Next documentation](https://nextjs.org/docs/app/building-your-application/configuring/environment-variables):

* Use `.env` for default vars for all builds and environments
* Use `.env.development` for default development build (i.e. `next dev`) vars
* Use `.env.production` for default production build (i.e. `next build`) vars
* Use `.env.local` for secrets, environment-specific values, or overrides of development or production build defaults set in any of the other files above

> `.env.local` should never be committed to your repo, but this repo includes a `.env.local.template` file that should be maintained as an example of what environment variables your app can support or is expecting in `.env.local`.
>
> The `.env.local.template` file is also [used in CI/CD pipelines](#how-the-envlocal-file-is-generated-when-running-in-a-pipeline) to generate a `env.local` file for the target environment. It is therefore important to keep this file updated as and when you add additional environment variables to your app.

### How `azd` uses environment variables in this template

When running `azd provision`:

1. A `preprovision` hook runs the `.azd/hooks/preprovision.ps1` script
   * The `.azd/scripts/create-infra-env-vars.ps1` script runs
   * The entries from the `.env`, `.env.production` and `.env.local` files (if they exist) are read and merged together (matching entries from the later files override entries from earlier files)
   * The merged entries are written to a `infra/env-vars.json` file as key value pairs (values are always of type `string`)
2. `azd` runs the `main.bicep` file
   * The `infra/env-vars.json` file created by the `preprovision` hook is loaded into a variable named `envVars` to be used during provisioning of the infrastructure
   * The environment variables exposed via `envVars` can be used to set properties of the infratructure resources defined in the `main.bicep` script such as min/max scale replicas, custom domain name, and to pass environment variables through to the Container App that are required at runtime
3. `azd` writes any `output`(s) from the `main.bicep` file to `.azure/{AZURE_ENV_NAME}/.env`
   * This is standard behaviour of `azd provision` and not specific to this template
4. A `postprovision` hooks runs the `.azd/hooks/postprovision.ps1` script
   * The contents of the `.azure/{AZURE_ENV_NAME}/.env` file are merged with the `.env.local` file (if one exists) and the results are written to a `.env.azure` file
   * The `.env.azure` file will be used by `azd deploy`

> The `main.bicep` script will error if it is expecting a key to be present in your `infra/env-vars.json` file, but it is missing. This is why you must keep your [environment variables](#environment-variables) updated.
>
> The `infra/env-vars.json` and `.env.azure` files should not be committed to your repo as they may contain secret or sensitive values from your `.env.local` file.

When running `azd deploy`:

1. The `Dockerfile` copies all `.env*` files from the local disk
2. It then copies `.env.azure` and renames and overwrites the `.env.local` file with it
3. `next build` then runs, which loads in env files as normal including the `.env.local` file

### How the `.env.local` file is generated when running in a pipeline

The `.env.local` file is required to provision, build and deploy the app, but it should never be committed to your repository and so is not available to the CI/CD pipeline when it clones your repo.

To overcome this problem the pipelines provided in this template are capable of generating an `env.local` file by reading environment variables from the pipeline build agent context and merging them with the `.env.local.template` file.

Exactly how the environment variables are surfaced to the build agent is slightly different depending on whether you are using an [Azure DevOps (AZDO)](#azure-devops-pipelines) or [GitHub Actions](#github-actions) pipeline due to the specific capabilities of each, but the approach used to generate the `.env.local` file is broadly the same:

1. The pipeline determines the target environment for the deployment based on the branch ref that triggered the pipeline to run
   * This can be extended to support multiple target environments
2. Environment variables specific to the target environment are loaded into the build agent context
   * These environment variables are named with the same keys used in the `.env.local.template` file
3. The pipeline runs `npm run env:init`, which merges the contents of the `.env.local.template` file with the environment variables in the build agent context and outputs the result to `.env.local`

⚡ `azd provision` and `azd deploy` then run as they would [locally](#how-azd-uses-environment-variables-in-this-template), using the `env.local` file created during the current pipeline run.

## Pipelines

This template includes support for running a CI/CD in GitHub Actions or Azure DevOps Pipelines. The specifics of the pipelines does differ due to the differing capabilities and behaviour of each platform, but an effort has been made to keep the two pipelines broadly in line with each other so that they are comparable.

Below are some instructions for how to setup and configure the pipelines included with this template for:

* [GitHub Actions](#github-actions)
* [Azure DevOps Pipelines](#azure-devops-pipelines)

> `azd` includes an `azd pipeline config` command that can be used to help initialise a pipeline on either platform. This is not recommended by this template because a) it requires creating target (non-development) environments locally, which doesn't feel "right"; and b) it creates "global" environment variables, but we recommend environment variables scoped to specific target environments.

### GitHub Actions

You don't need to do anything specific to add the workflow in GitHub Actions, the presence of the `.github/workflows/azure-dev.yml` file is enough, but you will need to:

1. [Create an Environment](#create-an-environment)
2. [Setup permissions in Azure](#setup-permissions-in-azure) to allow GitHub Actions to create resources in your Azure subscription
3. [Add Environment variables](#add-environment-variables)

#### Create an Environment

1. Sign in to [GitHub](https://github.com/)
2. Find the repo where your code has been pushed
3. Go to `Settings` -> `Environments`
   * Click `New environment`, name it `production`, and click `Configure environment`
   * Add protection rules if you wish, though it's not required

#### Setup permissions in Azure

1. Create a Service principal in Azure
   * Sign into the [Azure Portal](https://portal.azure.com)
   * Make sure you are signed into the tenant you want the pipeline to deploy to
   * Go to `Microsoft Entra ID` -> `App registrations`
   * Click `New registration`
   * Enter a `name` for your Service principal, and click `Register`
   * Copy the newly created Service principal's `Application ID` and `Directory (tenant) ID` - we will need those later
   * Go to `Certificates & secrets`
   * Select `Federated credentials` and click `Add credential`
   * Select the `GitHub Actions deploying Azure resources` scenario, and fill in the required information
     * `Organization` - your GitHub username
     * `Repository` - your GitHub repository name
     * `Entity type` - `Environment`
     * `GitHub environment name` - the environment name (`production`)
     * `Name` - a name for the scenario (suggestion: concatenate `{Organization}-{Repository}-{GitHub environment name}`)
   * Click `Add`
2. Give the Service principal the permissions required to deploy to your Azure Subscription
   * Go to `Subscriptions`
   * Select an existing or create a new Subscription where you will be deploying to
   * Copy the `Subscription ID` - we will need this later
   * Go to `Access control (IAM)` -> `Role assignments`
   * Assign the `Contributor` role
     * Click `Add` -> `Add role assignment`
     * Select `Privileged administrator roles` -> `Contributor`
     * Click `Next`
     * Click `Select members` and select your Service principal
     * Click `Review + assign` and complete the Role assignment
   * Assign the `Role Based Access Control Administrator` role
     * Click `Add` -> `Add role assignment`
     * Select `Privileged administrator roles` -> `Contributor`
     * Click `Next`
     * Click `Select members` and select your Service principal
     * Click `Next`
     * Select `Constrain roles` and only allow assignment of the `AcrPull` role
     * Click `Review + assign` and complete the Role assignment

#### Add Environment variables

1. Find and edit the Environment that you created in GitHub earlier
2. Add Environment variables
   * `AZURE_ENV_NAME=prod`
     * This doesn't need to match the GitHub Environment name and because it is used when generating Azure resource names it's a good idea to keep it short
   * `AZURE_TENANT_ID={tenant_id}`
     * Replace `{tenant_id}` with your Tenant's `Tenant ID`
   * `AZURE_SUBSCRIPTION_ID={subscription_id}`
     * Replace `{subscription_id}` with your Subscription's `Subscription ID`
   * `AZURE_CLIENT_ID={service_principal_id}`
     * Replace `{service_principal_id}` with your Service principal's `Application ID`
   * `AZURE_LOCATION={location_name}`
     * Replace `{location_name}` with your desired region name
     * You can see a list of region names using the Azure CLI: `az account list-locations -o table`
   * `SERVICE_WEB_CONTAINER_MIN_REPLICAS=1`
     * Assuming that you don't want your production app to scale to zero
3. If you want to add additional variables (e.g. those found in the `.env.local.template` file) then you can continue to do so e.g. `SERVICE_WEB_CONTAINER_MAX_REPLICAS=5`
   * If you don't add them then they will fallback to any default value set in the app or in the `main.bicep` file

If you add additional environment variables for use in your app and want to override them in this environment then you can come back here later to add or change anything as needed.

> If you add environment variables to `.env.local.template` you must also make sure you edit the `Create .env.local file` step of the `deploy` job in `.github/workflows/azure-dev.yml` to make them available as environment variabls when `npm run env:init` is executed. GitHub Actions doesn't automatically make environment variables available to scripts so they need to be added explicitly to this step (this is something you don't need to do in the AZDO pipeline, which does expose its environment variables to scripts implicitly).

### Azure DevOps Pipelines

You need to manually create a pipeline in Azure DevOps - the presence of the `.azdo/pipelines/azure-dev.yml` file is not enough - you will need to:

1. [Create the Pipeline](#create-the-pipeline)
2. [Setup permissions](#setup-permissions) to allow the Pipeline to create resources in your Azure subscription
3. [Create an Environment](#create-an-environment-1)
4. [Create a Variable group for your Environment](#create-a-variable-group-for-your-environment)

#### Create the Pipeline

1. Sign into [Azure DevOps](https://dev.azure.com)
2. Select an existing or create a new Project where you will create the pipeline
3. Go to `Pipelines` -> `Pipelines`
4. Click `New pipeline`
   * Connect to your repository
   * When prompted to `Configure your pipeline`, select `Existing Azure Pipelines YAML file` and select the `.azdo/pipelines/azure-dev.yml` file
   * `Save` (don't `Run`) the pipeline

#### Setup permissions

1. Create a Service connection for you Pipeline
   * Go to `Project settings` -> `Service connections`
   * Click `New service connection`
     * Select `Azure Resource Manager`
     * Select `Service pincipal (automatic)`
     * Choose the `Subscription` that you wish to deploy your resources to
     * Don't select a `Resource group`
     * Name the Service connection `azconnection`
       * This is the default name used by `azd` - feel free to change it, but if you do you will need to update your `azure-dev.yml` file also
     * Add a `Description` if you want
     * Check `Grant access permissions to all pipelines`
       * You can setup more fine grained permissions if you don't wish to do this
     * Click `Save`
2. Give the Service connection the permissions required to deploy to your Azure Subscription
   * After your Service connection has been created, click on it to edit it
   * Click on `Manage Service Principal`
   * Copy the `Display name`
     * If you don't like the generated name you can go to `Branding & properties` and change the `Name`
   * Copy the Service principal's `Directory (tenant) ID` - we will need that later
   * Go back to your Service connection in AZDO
   * Click on `Manage service connection roles`
   * Go to `Role assignments`
   * Assign the `Role Based Access Control Administrator` role
     * Click `Add` -> `Add role assignment`
     * Select `Privileged administrator roles` -> `Contributor`
     * Click `Next`
     * Click `Select members` and select your Service principal
     * Click `Next`
     * Select `Constrain roles` and only allow assignment of the `AcrPull` role
     * Click `Review + assign` and complete the Role assignment
   * Go to the `Overview` tab of your Subscription
   * Copy the `Subscription ID` - we will need this later
   * Go back to your Service connection in AZDO

#### Create an Environment

1. Go to `Pipelines` -> `Environments`
2. Create a `production` environment
   * Add a `Description` if you want
   * For `Resource` select `None`
   * You can setup Approvals & checks if you wish

#### Create a Variable group for your Environment

1. Go to `Pipelines` -> `Library`
2. Add a `Variable group` called `production`
3. Add the following variables:
   * `AZURE_ENV_NAME=prod`
     * This doesn't need to match the Environment name and because it is used when generating Azure resource names it's a good idea to keep it short
   * `AZURE_TENANT_ID={tenant_id}`
     * Replace `{tenant_id}` with your Tenant's `Tenant ID`
   * `AZURE_SUBSCRIPTION_ID={subscription_id}`
     * Replace `{subscription_id}` with your Subscription's `Subscription ID`
   * `AZURE_LOCATION={location_name}`
     * Replace `{location_name}` with your desired region name
     * You can see a list of region names using the Azure CLI: `az account list-locations -o table`
   * `SERVICE_WEB_CONTAINER_MIN_REPLICAS=1`
     * Assuming that you don't want your production app to scale to zero
4. If you want to add additional variables (e.g. those found in the `.env.local.template` file) then you can continue to do so e.g. `SERVICE_WEB_CONTAINER_MAX_REPLICAS=5`
   * If you don't add them then they will fallback to any default value set in the app or in the `main.bicep` file

If you add additional environment variables for use in your app and want to override them in this environment then you can come back here later to add or change anything as needed.

> The first time you run the pipeline it may ask you to permit access to the `production` Environment and Variable group, which you should allow.

## Adding a custom domain name

To add a custom domain name to your container app you will need to add an environment variable named `SERVICE_WEB_CUSTOM_DOMAIN_NAME`.

For example, to set the domain name for the container app to `www.example.com` you would add an environment variable `SERVICE_WEB_CUSTOM_DOMAIN_NAME=www.example.com`:

* In your local dev environment - to your `.env.local` file
* In GitHub Actions - as an [Environment variable](#add-environment-variables) in the target environment (e.g. `production`)
* In Azure DevOps - as a [Variable in the Variable group](#create-a-variable-group-for-your-environment) for the target environment (e.g. `production`)

When you add a custom domain name a redirect rule is automatically added so that if you attempt to navigate to the default domain of the Container App there will be a permanent redirect to the custom domain name - this redirect is configured in `next.config.js`.

### Add a free managed certificate for your custom domain

When you add a custom domain name to your container app (as described above) there is no SSL certificate provided, but Azure provides a facility to add a free managed SSL certificate.

To add the managed certificate to your container app:

1. Sign in to the [Azure Portal](https://portal.azure.com)
2. Go to the Container Apps Environment resource that the Container App you added the custom domain name to is located under
3. Go to `Certificates` -> `Managed certificate`
4. Click `Add certificate`
   * Select your `Custom domain` name
   * Choose the appropriate `Hostname record type`
   * Follow the instructions under `Domain name validation`
     * If you need further instruction there is [official documentation](https://learn.microsoft.com/en-us/azure/container-apps/custom-domains-managed-certificates?pivots=azure-portal#add-a-custom-domain-and-managed-certificate)
   * `Validate` the custom domain name
   * `Add` the certificate

Azure will now provision the certificate. When the `Certificate Status` is `Suceeded` you will need its ID:

1. Copy the `Certificate Name`
2. Go to `Overview` -> `JSON View`
3. Copy the `Resource ID`
4. Create the `Certificate ID` using the pattern:
   * `{Resource ID}/managedCertificates/{Certificate Name}`

Next you will need to add an environment variable named `SERVICE_WEB_CUSTOM_DOMAIN_CERT_ID` set to the value of your `Certificate ID`. Follow the same process you followed when adding your custom domain name to add this environment variable so that it sits alongside the custom domain name.

Finally you will need to trigger `azd provision` again - either by running locally or through your pipeline - and verify that the certificate binding has been added to your Container App.

To verify you can see what Container Apps are using your managed certificates from the Container Apps Environment resource in Azure Portal or you locate the Container App resource in the Azure Portal and check under `Custom domains`.

> It is possible to automate the creation of managed certificates through Bicep, which would be preferable to the above manual process, but there are a few ["chicken and egg" issues](https://johnnyreilly.com/azure-container-apps-bicep-managed-certificates-custom-domains) that make automation difficult at the moment. In the context of this template it was decided that a manual solution, though not preferable, is the most pragmatic solution.
>
> The situation with managed certificates is discussed on this [GitHub issue](https://github.com/microsoft/azure-container-apps/issues/607) so hopefully there will be better support for automation in the future - one to keep an eye on! If a manual approach is not scaleable for your needs have a read through the links provided for some ideas of how others have approached an automated solution.
